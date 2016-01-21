/**************************************************************************
 Program:  Schwartzman_11_03_09.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/03/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Request from Paul Schwartzman, Washington Post.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

%let where = ( ui_proptype in ( '10', '11' ) and '01jan2000'd <= saledate < '01jul2009'd );

proc sql noprint;
  create table Sales_units_cltr00 as
  select * from 
    Realprop.Sales_res_clean 
      (keep=cluster_tr2000 saledate ui_proptype owner_occ_sale where=(&where and not(missing(cluster_tr2000)))) as Sales 
    left join 
    Realprop.Num_units_cltr00 (keep=cluster_tr2000 units_sf_condo_2000-units_sf_condo_2009 ) as Units
  on Sales.cluster_tr2000 = Units.cluster_tr2000;

data Sales_units_cltr00;

  set Sales_units_cltr00;

  array a{2000:2009} units_sf_condo_2000-units_sf_condo_2009;
  
  Units = a{ year( saledate ) };
  
  Sale = 1;
  Sale_per_unit = 1000 * ( 1 / Units );
  owner_occ_sale_per_unit = 1000 * ( owner_occ_sale / Units );

run;

proc print data=Sales_units_cltr00 (obs=50);
proc means data=Sales_units_cltr00;
run;

%fdate() 

options nodate nonumber;

ods rtf file="D:\DCData\Libraries\Requests\Prog\2009\Schwartzman_11_03_09.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Sales_units_cltr00 format=comma8.0 noseps missing;
  where ui_proptype in ( '10', '11' ) and '01jan2000'd <= saledate < '01jul2009'd and
        cluster_tr2000 in ( '02', '07', '18', '22', '23', '25' );
  class cluster_tr2000 saledate;
  var Sale Sale_per_unit owner_occ_sale owner_occ_sale_per_unit;
  table 
    /** Pages **/
    cluster_tr2000=' '
    ,
    /** Rows **/
    Sale='Total sales' * sum=' '
    mean='% Sales to homeowners' * owner_occ_sale=' ' * f=percent8.
    Sale_per_unit='Sales per 1,000 units' * sum=' '
    owner_occ_sale_per_unit='Sales to homeowners per 1,000 units' * sum=' '
    ,
    /** Columns **/
    saledate='Year'
  ;
  format saledate year4. cluster_tr2000 $clus00b.;
  title1 'Property Sales, Single-Family Homes and Condominiums, Washington, DC';
  footnote1 height=9pt "Note: 2009 data for Jan-Jun only.";
  footnote2 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
  
run;

ods rtf close;

