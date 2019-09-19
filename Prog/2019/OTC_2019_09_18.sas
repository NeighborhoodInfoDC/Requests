/**************************************************************************
 Program:  OTC_2019_09_18.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  09/18/19
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  44
 
 Description:  DC rental housing fact sheet for OTA Tenant Summit.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( DHCD )
%DCData_lib( RealProp )
%DCData_lib( PresCat )

** Compile catalog project subsidy info **;

%let PUBHSNG  = 1;
%let S8PROG   = 2;
%let LIHTC    = 3;
%let HOME     = 4;
%let CDBG     = 5;
%let HPTF     = 6;
%let TEBOND   = 7;
%let HUDMORT  = 8;
%let S202811  = 9;
%let OTHER    = 10;
%let MAXPROGS = 10;

proc format;
  value ProgCat (notsorted)
    1 = 'Public housing'
    2,4,5,6,9 = 'Section 8 and other project-based subsidies'
    3,8 = 'Low income housing tax credits'
    7,10,20,30 = 'Other subsidized housing'
    40 = 'Rent controlled housing'
    50 = 'Other multifamily rental housing'
    60 = 'Renter-occupied single-family dwellings/condos'
    ;
run;

%Data_to_format(
  FmtLib=work,
  FmtName=$nlihcid2cat,
  Desc=,
  Data=PresCat.Project_category,
  Value=nlihc_id,
  Label=category_code,
  OtherLabel='',
  DefaultLen=1,
  Print=N,
  Contents=N
  )

** Aggregate subsidies so one record per portfolio **;

proc summary data=PresCat.Subsidy (where=(Subsidy_Active and Portfolio~='PRAC')) nway;
  class nlihc_id portfolio;
  var Units_assist Poa_end Compl_end;
  output out=Subsidy_unique 
    sum(Units_assist)= min(Poa_end Compl_end)=;
run;

** Combine project and subsidy data **;

data Project_subsidy;

  merge
    PresCat.Project
      (drop=Cat_: Hud_Mgr_: Hud_Own_:
       where=(put( nlihc_id, $nlihcid2cat. ) in ( '1', '2', '3', '4', '5' ))
       in=inProject)
    Subsidy_unique
      (in=inSubsidy);
  by NLIHC_ID;
  
  if inProject and inSubsidy;
  
run;

data Assisted_units;

  set Project_subsidy;
  by NLIHC_ID;
  
  retain num_progs total_units min_asst_units max_asst_units asst_units1-asst_units&MAXPROGS
         poa_end_min poa_end_max compl_end_min compl_end_max;

  array a_aunits{&MAXPROGS} asst_units1-asst_units&MAXPROGS;
  
  if first.NLIHC_ID then do;
  
    total_units = .;
    num_progs = 0;
    
    min_asst_units = .;
    mid_asst_units = .;
    max_asst_units = .;
    
    poa_end_min = .;
    poa_end_max = .;

    compl_end_min = .;
    compl_end_max = .;

    do i = 1 to &MAXPROGS;
      a_aunits{i} = 0;
    end;
      
  end;
  
  num_progs + 1;
  
  total_units = max( total_units, Proj_Units_Tot, Units_Assist );

  select ( portfolio );
    when ( 'PUBHSNG' ) a_aunits{&PUBHSNG} = sum( Units_Assist, a_aunits{&PUBHSNG} );
    when ( 'PB8' ) a_aunits{&S8PROG} = sum( Units_Assist, a_aunits{&S8PROG} );
    when ( 'LIHTC' ) a_aunits{&LIHTC} = sum( Units_Assist, a_aunits{&LIHTC} );
    when ( 'HOME' ) a_aunits{&HOME} = sum( Units_Assist, a_aunits{&HOME} );
    when ( 'CDBG' ) a_aunits{&CDBG} = sum( Units_Assist, a_aunits{&CDBG} );
    when ( 'DC HPTF' ) a_aunits{&HPTF} = sum( Units_Assist, a_aunits{&HPTF} );
    when ( 'TEBOND' ) a_aunits{&TEBOND} = sum( Units_Assist, a_aunits{&TEBOND} );
    when ( 'HUDMORT' ) a_aunits{&HUDMORT} = sum( Units_Assist, a_aunits{&HUDMORT} );
    when ( '202/811' ) a_aunits{&S202811} = sum( Units_Assist, a_aunits{&S202811} );
    otherwise a_aunits{&OTHER} = sum( Units_Assist, a_aunits{&OTHER} );
  end;
  
  min_asst_units = max( Units_Assist, min_asst_units );
  
  poa_end_min = min( poa_end, poa_end_min );
  poa_end_max = max( poa_end, poa_end_max );
  
  compl_end_min = min( compl_end, compl_end_min );
  compl_end_max = max( compl_end, compl_end_max );
  
  if last.NLIHC_ID then do;
  
    do i = 1 to &MAXPROGS;
      a_aunits{i} = min( a_aunits{i}, total_units );
    end;

    max_asst_units = min( sum( of asst_units1-asst_units&MAXPROGS ), total_units );
    
    mid_asst_units = min( round( mean( min_asst_units, max_asst_units ), 1 ), max_asst_units );
    
    if mid_asst_units ~= max_asst_units then err_asst_units = max_asst_units - mid_asst_units;
    
    ** Reporting categories **;
    
    if num_progs = 1 then do;
    
      if a_aunits{&PUBHSNG} > 0 then ProgCat = 1;
      else if a_aunits{&S8PROG} > 0 then ProgCat = 2;
      else if a_aunits{&LIHTC} > 0 then ProgCat = 3;
      else if a_aunits{&HOME} > 0 then ProgCat = 4;
      else if a_aunits{&CDBG} > 0 then ProgCat = 5;
      else if a_aunits{&HPTF} > 0 then ProgCat = 6;
      else if a_aunits{&HUDMORT} > 0 then ProgCat = 7;
      else if a_aunits{&S202811} > 0 then ProgCat = 10;
      else if a_aunits{&TEBOND} > 0 or a_aunits{&OTHER} > 0 then ProgCat = 20;
    
    end;
    else do;
    
      if a_aunits{&S8PROG} > 0 then ProgCat = 9;
      else if a_aunits{&LIHTC} > 0 and a_aunits{&TEBOND} > 0 then ProgCat = 8;
      else if a_aunits{&LIHTC} > 0 then ProgCat = 3;
      else ProgCat = 30;
      
    end;
    
    if min_asst_units > 0 then output;
  
  end;
  
  format ProgCat ProgCat.;
  format poa_end_min poa_end_max compl_end_min compl_end_max mmddyy10.;
  
  drop i portfolio Units_Assist poa_end compl_end _freq_ _type_;

run;

%File_info( data=Assisted_units, printobs=0, freqvars=ProgCat )

run;

** Combine with rent control database **;

proc summary data=Dhcd.Parcels_rent_control (where=(/*ui_proptype not in ( '10', '11' ) and*/ not(missing(nlihc_id)))) nway;
  class nlihc_id ui_proptype ward2012;
  var adj_unit_count;
  output out=Catalog_parcel_sum sum=;
run;

data Assisted_units_b;

  merge Catalog_parcel_sum Assisted_units;
  by nlihc_id;
  
run;

** Compile MF rental, rented SFD and condo units **;

data SFD_condo;

  merge
    RealProp.Parcel_base_who_owns 
      (where=(in_last_ownerpt and ui_proptype in ( '10', '11' ) and owner_occ_sale=0)
       in=in1)
    RealProp.Parcel_geo 
      (keep=ssl ward2012 cluster2017);
  by ssl;
  
  if in1;
  
  retain adj_unit_count 1;
  
run;

** Merge **;

data A;

  set 
    SFD_condo
    Assisted_units_b
    Dhcd.Parcels_rent_control (where=(ui_proptype not in ( '10', '11', '19' ) and missing(nlihc_id)))
    ;

run;

data Rental_parcels;

  set A;

  if ui_proptype not in ( '10', '11' ) and ownercat = '045' then ProgCat = 1;

  if missing( ProgCat ) then do;
    select;
    when ( ui_proptype in ( '10', '11' ) ) ProgCat = 60;
    when ( rent_controlled ) ProgCat = 40;
    otherwise ProgCat = 50;
    end;
  end;

  units = max( adj_unit_count, max_asst_units );

run;

proc freq data=Rental_parcels;
  weight units;
  tables progcat / missing;
  format progcat progcat. ;
run;

ods csvall body="&_dcdata_default_path\Requests\Prog\2019\OTC_2019_09_18.csv";

proc tabulate data=Rental_parcels format=comma10.0 noseps missing;
  where not(missing(ward2012)) and ProgCat < 60;
  class ward2012;
  class ProgCat / preloadfmt order=data;
  var units;
  table 
    /** Rows **/
    all='All multifamily rental housing' ProgCat=' '
    ,
    /** Columns **/
    sum=' ' * units='Housing Units' * ( all='DC' ward2012=' ' )
    / condense;
  format progcat progcat. ;
run;

proc tabulate data=Rental_parcels format=comma10.0 noseps missing;
  where not(missing(ward2012)) and ProgCat = 60;
  class ward2012 ui_proptype;
  var units;
  table 
    /** Rows **/
    all='Renter-occ. SFD and condos' ui_proptype=' '
    ,
    /** Columns **/
    sum=' ' * units='Housing Units' * ( all='DC' ward2012=' ' )
    / condense;
  format progcat progcat. ;
run;

ods csvall close;
