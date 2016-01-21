/**************************************************************************
 Program:  Rothman_06_24_09.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/24/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  List of foreclosed multifamily properties, 2006-2009.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( HsngMon )
%DCData_lib( RealProp )

proc format;
    value $newptyp
      10 = 'Single-family homes'
      11 = 'Condominium'
      12 = 'Cooperative building'
      14 = 'Rental building (< 5 apts.)'
      15 = 'Rental building (5+ apts.)';

data NSP_forecl_address;

  set HsngMon.Foreclosures_qtr_2009_2;

  where report_dt = '01jan2009'd and in_foreclosure_end and
        put( geo2000, $nbrhd. ) ~= '' and
        ui_proptype in ( '12', '13', '14', '15' );

  length new_proptype $ 2;
  
  if ui_proptype = '13' then do;
    if usecode in ( '023', '024' ) then new_proptype = '14';
    else new_proptype = '15';
  end;
  else new_proptype = ui_proptype;
  
run;

** Create address list **;

proc sql noprint;
  create table Foreclosure_list as
  select * from 
    NSP_forecl_address as f
    left join (
      select * from 
        RealProp.Parcel_base (keep=ssl premiseadd ownername ownname2 hstd_code address: assess_val) as p1
        left join
        RealProp.Parcel_geo as p2
      on p1.ssl = p2.ssl
    ) as p
    on f.ssl = p.ssl
  order by geo2000
;

run;

** Reformat owner address into single field **;

data Foreclosure_list;

  set Foreclosure_list;
  
  length owner_addr $ 500;
  
  if address2 = '' then 
    owner_addr = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );

run;

/*
** Add owner_occ_sale flag **;

%create_own_occ( inds=Foreclosure_list, outds=Foreclosure_list )
*/

ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2009\Rothman_06_24_09.xls" style=minimal
      options( sheet_interval='page' );

ods listing close;

ods tagsets.excelxp options( sheet_name="Multifamily");

proc print data=Foreclosure_list label noobs;
  var SSL PREMISEADD new_proptype 
      Zip Ward2002 Anc2002 Cluster_tr2000 Geo2000 
      OWNERNAME OWNNAME2 owner_addr hstd_code assess_val;
  format Cluster_tr2000 $clus00f. new_proptype $newptyp.;
  label 
    assess_val = 'Current assessed value ($)'
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    new_proptype = 'Property type' 
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp close;

ods listing;

run;

