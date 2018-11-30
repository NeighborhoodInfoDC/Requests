/**************************************************************************
 Program:  DCPN_MF_Sales.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  11/29/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Data on multifamily housing sales for DC Preservation
Network 2018 strategy report. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )
%DCData_lib( MAR )

** MAR unit counts by parcel **;

proc sql noprint;
  create table Mar_units as
  select ssl, sum( units.active_res_occupancy_count ) as Units_mar, count( address_id ) as Recs_mar, min( address_id ) as First_address_id from
  ( select xwalk.ssl, xwalk.address_id, units.address_id, units.active_res_occupancy_count
    from Mar.Address_ssl_xref as xwalk left join Mar.Address_points_view as units
    on xwalk.address_id = units.address_id )
  group by ssl;
quit;

** Combine property data **;

data DCPN_MF_sales;

  merge 
    Realprop.Sales_master 
      (keep=ssl sale: ui_proptype ward2012 cluster2017 address: premiseadd usecode ownername_full:
       where=(ui_proptype in ( '12', '13' ) and ( '01jan2018'd > saledate >= '01jan2002'd ) )
       in=in1)
    RealProp.Cama_parcel
      (keep=ssl num_bldg num_units stories usecode yr_rmdl ayb eyb
       rename=(usecode=usecode_cama))
    Mar_units
    ;
    by ssl;
         
  if in1;
  
  ** Filter for multifamily properties, exclude duplexes **;
  
  if 
    Units_mar > 2 or 
    Num_units > 2 or
    usecode in ( '021', '022', '023', '025', '026', '027', '028', '029' );

  Units_combined = max( units_mar, num_units );

  retain total 1;

run;

proc tabulate data=DCPN_MF_sales format=comma8. noseps missing;
  class saledate saletype ui_proptype usecode usecode_cama ward2012 cluster2017;
  var total;
  table 
    /** Rows **/
    all='Total' usecode=' ',
    /** Columns **/
    total='Number of sales by use code' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' usecode_cama=' ',
    /** Columns **/
    total='Number of sales by use code (CAMA)' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' saletype=' ',
    /** Columns **/
    total='Number of sales' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' ward2012=' ',
    /** Columns **/
    total='Number of sales' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' cluster2017=' ',
    /** Columns **/
    total='Number of sales' * sum=' ' * saledate=' '
  ;
  format saledate year4.;
run;

** Sharable tables **;

proc format;
  value units
    0, . = 'Unknown'
    1-4 = 'Fewer than 5 units'
    5-10 = '5 to 10'
    11-25 = '11 to 25'
    26 - 50 = '26 to 50'
    51 - 100 = '51 to 100'
    101 - high = '101 or more';
run;

%fdate()

options nodate nonumber;

options orientation=landscape missing='-';

ods rtf file="D:\DCData\Libraries\Requests\Prog\2018\DCPN_MF_Sales.rtf" style=Styles.Rtf_arial_9pt;
ods listing close;

footnote1 height=9pt "DC real property, computer-aided mass appraisal, and master address respository data tabulated by Urban-Greater DC (greaterdc.urban.org), &fdate..";
footnote2 " ";
footnote3 "\b\i DRAFT - NOT FOR CIRCULATION OR CITATION";
footnote4 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

title1 'Sales of Multifamily Residential Properties (3 or More Housing Units), District of Columbia, 2002 - 2017';

proc tabulate data=DCPN_MF_sales format=comma8. noseps missing;
  where not( missing( ward2012 ) );
  class saledate ui_proptype ward2012 cluster2017 units_combined;
  var total;
  table 
    /** Rows **/
    all='Total' ui_proptype=' ',
    /** Columns **/
    total='Number of sales by property type' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' units_combined=' ',
    /** Columns **/
    total='Number of sales by number of units in property' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' ward2012=' ',
    /** Columns **/
    total='Number of sales by ward' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' cluster2017=' ',
    /** Columns **/
    total='Number of sales by neighborhood cluster' * sum=' ' * saledate=' '
  ;
  format saledate year4. units_combined units.;
run;

ods rtf close;
ods listing;


** Export data **;

filename fexport "&_dcdata_default_path\Requests\Prog\2018\DCPN_MF_Sales.csv" lrecl=2000;

proc export data=DCPN_MF_sales
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

