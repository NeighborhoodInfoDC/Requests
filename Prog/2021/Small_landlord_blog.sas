/**************************************************************************
 Program:  Small_landlord_blog.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  04/26/21
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  65
 
 Description:  Analysis of owners of smaller portfolios of
 residential units in DC. 

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( DHCD )
%DCData_lib( RealProp )


** Multifamily properties owned by owners of 2 - 19 units 
** Exclude properties owned by quasi-public entities, CDCs, schools, religious institutions, GSEs, and banks
** Exclude government-owned and assisted properties;

data Small_landlord;

  set DHCD.parcels_rent_control;
  
  where in_last_ownerpt and 
    ui_proptype not in ( '10', '11' ) and 
    ( 2 <= max( adj_unit_count_ownername_sum, adj_unit_count_owner_add_sum ) <= 19 ) and
    ownercat not in ( '070', '080', '090', '100', '120', '130' ) and 
    not( Exempt_govowned or Excluded_Foreign or Exempt_assisted );
    
  retain total 1;
  
  adj_unit_count_owner_max = max( adj_unit_count_ownername_sum, adj_unit_count_owner_add_sum );
  adj_prop_count_owner_max = max( ownername_count, owner_add_count );
  
  label 
    adj_unit_count_owner_max = "Total units belonging to owner"
    adj_prop_count_owner_max = "Total properties belonging to owner";
  
  ** Owner state var **;
  
  length owner_state $ 20;
  
  do i = 1 to 10 by 1 until( missing( scan( address3, i ) ) );
  
    if length( scan( address3, i ) ) = 2 then do;
      if not missing( stfips( left( upcase( scan( address3, i ) ) ) ) ) then do;
        owner_state = stnamel( left( upcase( scan( address3, i ) ) ) );
        leave;
      end;
    end;

  end;
  
  label owner_state = "Owner's state from property tax billing address";
  
  label
    ward2012 = "Property ward (2012)"
    Zip = "Property ZIP code"
    cluster2017 = "Property neighborhood cluster (2017)";
  
  drop i;
    
run;


** Summary tables **;

/** Macro table_stmt - Start Definition **/

%macro table_stmt( row= );

  table 
    /** Rows **/
    all='Total'
    &row=' ',
    /** Columns **/
    total='Parcels' * ( sum='Number' colpctsum='Percent' * f=comma12.1 )
    adj_unit_count='Housing units' * ( sum='Number' colpctsum='Percent' * f=comma12.1 ) 
  /rts=60 box=&row
  ;

%mend table_stmt;

/** End Macro Definition **/

proc format;
  value year_built (notsorted)
    low -< 1900 = 'Pre-1900'
    1900 - 1919 = '1900 - 1919'
    1920 - 1939 = '1920 - 1939'
    1940 - 1959 = '1940 - 1959'
    1960 - 1979 = '1960 - 1979'
    1980 - 1999 = '1980 - 1999'
    2000 - high = '2000 or later'
    . = 'Unknown';
  value num_properties
    5-high = '5 or more';
run;

%fdate()

ods rtf file="&_dcdata_default_path\Requests\Prog\2021\Small_landlord_blog.rtf" style=Styles.Rtf_arial_9pt;
options nodate nonumber;

footnote1 height=9pt "Prepared by Urban-Greater DC (greaterdc.urban.org), &fdate..";
footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

title2 "INCLUDING taxable/nontaxable corporations, partnerships, associations";

proc tabulate data=Small_landlord format=comma12.0 noseps missing;
  class ui_proptype usecode ownercat rent_controlled Owner_state owner_occ_sale Zip ward2012 cluster2017 Trust_flag /order=freq;
  class year_built_min /order=data preloadfmt;
  class adj_unit_count_owner_max adj_prop_count_owner_max;
  var total adj_unit_count;
  %table_stmt( row=ownercat )
  %table_stmt( row=ui_proptype )
  %table_stmt( row=usecode )
  %table_stmt( row=ward2012 )
  %table_stmt( row=Zip )
  %table_stmt( row=cluster2017 )
  %table_stmt( row=rent_controlled )
  %table_stmt( row=year_built_min )
  %table_stmt( row=adj_prop_count_owner_max )
  %table_stmt( row=adj_unit_count_owner_max )
  %table_stmt( row=Trust_flag )
  %table_stmt( row=Owner_state )
  %table_stmt( row=owner_occ_sale )
  format year_built_min year_built. adj_prop_count_owner_max num_properties. cluster2017 $clus17f.;
run;


title2 "EXCLUDING taxable/nontaxable corporations, partnerships, associations";

proc tabulate data=Small_landlord format=comma12.0 noseps missing;
  where ownercat not in ( '111', '115' );
  class ui_proptype usecode ownercat rent_controlled Owner_state owner_occ_sale Zip ward2012 cluster2017 Trust_flag /order=freq;
  class year_built_min /order=data preloadfmt;
  class adj_unit_count_owner_max adj_prop_count_owner_max;
  var total adj_unit_count;
  %table_stmt( row=ownercat )
  %table_stmt( row=ui_proptype )
  %table_stmt( row=usecode )
  %table_stmt( row=ward2012 )
  %table_stmt( row=cluster2017 )
  %table_stmt( row=Zip )
  %table_stmt( row=rent_controlled )
  %table_stmt( row=year_built_min )
  %table_stmt( row=adj_prop_count_owner_max )
  %table_stmt( row=adj_unit_count_owner_max )
  %table_stmt( row=Trust_flag )
  %table_stmt( row=Owner_state )
  %table_stmt( row=owner_occ_sale )
  format year_built_min year_built. adj_prop_count_owner_max num_properties. cluster2017 $clus17f.;
run;

title3 "Owners living in DC only";

proc tabulate data=Small_landlord format=comma12.0 noseps missing;
  where ownercat not in ( '111', '115' ) and ownerdc;
  class ui_proptype usecode ownercat rent_controlled Owner_state owner_occ_sale Zip ward2012 cluster2017 Trust_flag /order=freq;
  class year_built_min /order=data preloadfmt;
  class adj_unit_count_owner_max adj_prop_count_owner_max;
  var total adj_unit_count;
  %table_stmt( row=ownercat )
  %table_stmt( row=ui_proptype )
  %table_stmt( row=usecode )
  %table_stmt( row=ward2012 )
  %table_stmt( row=Zip )
  %table_stmt( row=cluster2017 )
  %table_stmt( row=rent_controlled )
  %table_stmt( row=year_built_min )
  %table_stmt( row=adj_prop_count_owner_max )
  %table_stmt( row=adj_unit_count_owner_max )
  %table_stmt( row=Trust_flag )
  %table_stmt( row=Owner_state )
  %table_stmt( row=owner_occ_sale )
  format year_built_min year_built. adj_prop_count_owner_max num_properties. cluster2017 $clus17f.;
run;

title2;
footnote1;

ods rtf close;


** Export data for review **;

ods listing close;
ods tagsets.excelxp file="&_dcdata_default_path\Requests\Prog\2021\Small_landlord.xls" style=Normal options(sheet_interval='None' );

proc print data=Small_landlord;
  id ssl;
run;

ods tagsets.excelxp close;
ods listing;


