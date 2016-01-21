/**************************************************************************
 Program:  Schwartzman_02_14_08.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/25/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Get summary data on Trinidad for request from
 Paul Schwartzman, Washington Post. 
 Trinidad is defined as tracts 88.2 + 88.4.
 
 ADD CRIME DATA.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Realprop )
%DCData_lib( Tanf )
%DCData_lib( HMDA )
%DCData_lib( ROD )

** List of warehouse variables to use in creating report **;

%let keep_vars = 
  fs_client_: tanf_client_: units_condo_: units_owner_: units_coop_: units_sf_:
  r_mprice_tot_: sales_tot_: 
  nummrtgorigwhite_: nummrtgorigblack_: nummrtgorighisp_: nummrtgorigwithrace_: 
  nummrtgorig_vli_: nummrtgorig_li_: nummrtgorig_mi_: nummrtgorig_hinc_: 
  nummrtgorig_inc_: numsubprimeconvorighomepur_: numconvmrtgorighomepurch_:
  fcl_num_: fcl_den_:
;

%syslput keep_vars=&keep_vars;

** Start submitting commands to remote server **;

rsubmit;

/** Macro Foreclosures - Start Definition **/

%macro Foreclosures();

  %let end_yr = 2007;

  array fcl_num_sf{*} forecl_sf_condo_1997-forecl_sf_condo_&end_yr;
  array fcl_num_condo{*} forecl_ntc_sale_condo_ssl_1997-forecl_ntc_sale_condo_ssl_&end_yr;
  array fcl_den_sf{*} parcel_sf_condo_1997-parcel_sf_condo_&end_yr;
  array fcl_den_condo{*} parcel_condo_1997-parcel_condo_&end_yr;
  array fcl_num{*} fcl_num_1997-fcl_num_&end_yr;
  array fcl_den{*} fcl_den_1997-fcl_den_&end_yr;
  
  do i = 1 to dim( fcl_num_sf );
  
    fcl_num{i} = 10 * ( fcl_num_sf{i} );
    fcl_den{i} = fcl_den_sf{i};
    
  end; 
  
  label
    fcl_num_1997 = "Foreclosure rate, 1997"
    fcl_num_1998 = "Foreclosure rate, 1998"
    fcl_num_1999 = "Foreclosure rate, 1999"
    fcl_num_2000 = "Foreclosure rate, 2000"
    fcl_num_2001 = "Foreclosure rate, 2001"
    fcl_num_2002 = "Foreclosure rate, 2002"
    fcl_num_2003 = "Foreclosure rate, 2003"
    fcl_num_2004 = "Foreclosure rate, 2004"
    fcl_num_2005 = "Foreclosure rate, 2005"
    fcl_num_2006 = "Foreclosure rate, 2006"
    fcl_num_2007 = "Foreclosure rate, 2007";
    
%mend Foreclosures;

/** End Macro Definition **/


** Summarize data for neighborhood **;

data Tract;

  merge 
    Hmda.Hmda_sum_tr00
    Realprop.Num_units_tr00
    Realprop.Sales_sum_tr00
    Tanf.Fs_sum_tr00
    Tanf.Tanf_sum_tr00
    Rod.Foreclosures_sum_tr00
  ;
  by geo2000;
    
  where geo2000 in ( '11001008802', '11001008804' );
  
  %Foreclosures()
  
  keep geo2000 &keep_vars;

run;

proc summary data=Tract;
  var &keep_vars;
  output out=Neighborhood sum=;
run;


data City;

  merge 
    Hmda.Hmda_sum_city
    Realprop.Num_units_city
    Realprop.Sales_sum_city
    Tanf.Fs_sum_city
    Tanf.Tanf_sum_city
    Rod.Foreclosures_sum_city
  ;
  by city;
  
  %Foreclosures()

  keep city &keep_vars;
    
run;

data Cluster_city;

  set
    City (in=inA)
    Neighborhood;
    
    if inA then geo = '1';
    else geo = '2';
    
run;

proc download status=no
  inlib=work 
  outlib=work memtype=(data);
  select Cluster_city;

run;

endrsubmit;

** End submitting commands to remote server **;

proc format;
  value $geo 
    '1' = 'D.C.'
    '2' = 'Trinidad';

ods rtf file="&_dcdata_path\requests\prog\2008\Schwartzman_06_25_08.rtf" style=Styles.Rtf_arial_9pt;

options nodate nonumber;

%fdate()

proc tabulate data=Cluster_city format=comma8.0 noseps missing;
  var &keep_vars;
  class geo;

  table 
    /** Rows **/
    fs_client_2000 fs_client_2001 fs_client_2002 fs_client_2003 fs_client_2004 fs_client_2005 fs_client_2006 fs_client_2007
    ,
    /** Columns **/
    ( sum='Clients' pctsum<fs_client_2000>='Pct. of 2000' ) * geo=' '
    /rts=70 box='Numbers of food stamp clients'
  ;

  table 
    /** Rows **/
    tanf_client_2000 tanf_client_2001 tanf_client_2002 tanf_client_2003 tanf_client_2004 tanf_client_2005 tanf_client_2006 tanf_client_2007
    ,
    /** Columns **/
    ( sum='Clients' pctsum<tanf_client_2000>='Pct. of 2000' ) * geo=' '
    /rts=70 box='Numbers of TANF clients'
  ;

  table 
    /** Rows **/
    ( r_mprice_tot_2000 r_mprice_tot_2001 r_mprice_tot_2002 r_mprice_tot_2003 r_mprice_tot_2004 r_mprice_tot_2005 r_mprice_tot_2006 r_mprice_tot_2007 ) * sum=' '
    ( sales_tot_2000 sales_tot_2001 sales_tot_2002 sales_tot_2003 sales_tot_2004 sales_tot_2005 sales_tot_2006 ) * sum=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Sales of S.F. homes and condos'
  ;

  table 
    /** Rows **/
    ( r_mprice_tot_2000 r_mprice_tot_2001 r_mprice_tot_2002 r_mprice_tot_2003 r_mprice_tot_2004 r_mprice_tot_2005 r_mprice_tot_2006 ) * pctsum<r_mprice_tot_2000>=' '
    ( sales_tot_2000 sales_tot_2001 sales_tot_2002 sales_tot_2003 sales_tot_2004 sales_tot_2005 sales_tot_2006 ) * pctsum<sales_tot_2000>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Sales of S.F. homes and condos (pct. of 2000 value)'
  ;

  table 
    /** Rows **/
    ( units_owner_2000 units_owner_2001 units_owner_2002 units_owner_2003 units_owner_2004 units_owner_2005 units_owner_2006 units_owner_2007 ) * sum=' '
    ( units_condo_2000 units_condo_2001 units_condo_2002 units_condo_2003 units_condo_2004 units_condo_2005 units_condo_2006 units_condo_2007 ) * sum=' '
    ( units_sf_2000 units_sf_2001 units_sf_2002 units_sf_2003 units_sf_2004 units_sf_2005 units_sf_2006 units_sf_2007 ) * sum=' '
    ( units_coop_2000 units_coop_2001 units_coop_2002 units_coop_2003 units_coop_2004 units_coop_2005 units_coop_2006 units_coop_2007 ) * sum=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Number of housing units'
  ;

  table 
    /** Rows **/
    nummrtgorigwhite_2000 * pctsum<nummrtgorigwithrace_2000>=' '
    nummrtgorigwhite_2001 * pctsum<nummrtgorigwithrace_2001>=' '
    nummrtgorigwhite_2002 * pctsum<nummrtgorigwithrace_2002>=' '
    nummrtgorigwhite_2003 * pctsum<nummrtgorigwithrace_2003>=' '
    nummrtgorigwhite_2004 * pctsum<nummrtgorigwithrace_2004>=' '
    nummrtgorigwhite_2005 * pctsum<nummrtgorigwithrace_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. white home buyers (HMDA)'
  ;

  table 
    /** Rows **/
    nummrtgorigblack_2000 * pctsum<nummrtgorigwithrace_2000>=' '
    nummrtgorigblack_2001 * pctsum<nummrtgorigwithrace_2001>=' '
    nummrtgorigblack_2002 * pctsum<nummrtgorigwithrace_2002>=' '
    nummrtgorigblack_2003 * pctsum<nummrtgorigwithrace_2003>=' '
    nummrtgorigblack_2004 * pctsum<nummrtgorigwithrace_2004>=' '
    nummrtgorigblack_2005 * pctsum<nummrtgorigwithrace_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. black home buyers (HMDA)'
  ;

  table 
    /** Rows **/
    nummrtgorighisp_2000 * pctsum<nummrtgorigwithrace_2000>=' '

    nummrtgorighisp_2001 * pctsum<nummrtgorigwithrace_2001>=' '
    nummrtgorighisp_2002 * pctsum<nummrtgorigwithrace_2002>=' '
    nummrtgorighisp_2003 * pctsum<nummrtgorigwithrace_2003>=' '
    nummrtgorighisp_2004 * pctsum<nummrtgorigwithrace_2004>=' '
    nummrtgorighisp_2005 * pctsum<nummrtgorigwithrace_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. Hispanic home buyers (HMDA)'
  ;

  table 
    /** Rows **/
    nummrtgorig_vli_2000 * pctsum<nummrtgorig_inc_2000>=' '
    nummrtgorig_vli_2001 * pctsum<nummrtgorig_inc_2001>=' '
    nummrtgorig_vli_2002 * pctsum<nummrtgorig_inc_2002>=' '
    nummrtgorig_vli_2003 * pctsum<nummrtgorig_inc_2003>=' '
    nummrtgorig_vli_2004 * pctsum<nummrtgorig_inc_2004>=' '
    nummrtgorig_vli_2005 * pctsum<nummrtgorig_inc_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. very low income home buyers (HMDA)'
  ;

  table 
    /** Rows **/
    nummrtgorig_li_2000 * pctsum<nummrtgorig_inc_2000>=' '
    nummrtgorig_li_2001 * pctsum<nummrtgorig_inc_2001>=' '
    nummrtgorig_li_2002 * pctsum<nummrtgorig_inc_2002>=' '
    nummrtgorig_li_2003 * pctsum<nummrtgorig_inc_2003>=' '
    nummrtgorig_li_2004 * pctsum<nummrtgorig_inc_2004>=' '
    nummrtgorig_li_2005 * pctsum<nummrtgorig_inc_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. low income home buyers (HMDA)'
  ;

  table 
    /** Rows **/
    nummrtgorig_mi_2000 * pctsum<nummrtgorig_inc_2000>=' '
    nummrtgorig_mi_2001 * pctsum<nummrtgorig_inc_2001>=' '
    nummrtgorig_mi_2002 * pctsum<nummrtgorig_inc_2002>=' '
    nummrtgorig_mi_2003 * pctsum<nummrtgorig_inc_2003>=' '
    nummrtgorig_mi_2004 * pctsum<nummrtgorig_inc_2004>=' '
    nummrtgorig_mi_2005 * pctsum<nummrtgorig_inc_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. middle income home buyers (HMDA)'
  ;

  table 
    /** Rows **/
    nummrtgorig_hinc_2000 * pctsum<nummrtgorig_inc_2000>=' '
    nummrtgorig_hinc_2001 * pctsum<nummrtgorig_inc_2001>=' '
    nummrtgorig_hinc_2002 * pctsum<nummrtgorig_inc_2002>=' '
    nummrtgorig_hinc_2003 * pctsum<nummrtgorig_inc_2003>=' '
    nummrtgorig_hinc_2004 * pctsum<nummrtgorig_inc_2004>=' '
    nummrtgorig_hinc_2005 * pctsum<nummrtgorig_inc_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. high income home buyers (HMDA)'
  ;

  table 
    /** Rows **/
    numsubprimeconvorighomepur_2000 * pctsum<numconvmrtgorighomepurch_2000>=' '
    numsubprimeconvorighomepur_2001 * pctsum<numconvmrtgorighomepurch_2001>=' '
    numsubprimeconvorighomepur_2002 * pctsum<numconvmrtgorighomepurch_2002>=' '
    numsubprimeconvorighomepur_2003 * pctsum<numconvmrtgorighomepurch_2003>=' '
    numsubprimeconvorighomepur_2004 * pctsum<numconvmrtgorighomepurch_2004>=' '
    numsubprimeconvorighomepur_2005 * pctsum<numconvmrtgorighomepurch_2005>=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Pct. home purchase loans from subprime lenders (HMDA)'
  ;

  table 
    /** Rows **/
    (
      fcl_num_1997 * pctsum<fcl_den_1997>=' '
      fcl_num_1998 * pctsum<fcl_den_1998>=' '
      fcl_num_1999 * pctsum<fcl_den_1999>=' '
      fcl_num_2000 * pctsum<fcl_den_2000>=' '
      fcl_num_2001 * pctsum<fcl_den_2001>=' '
      fcl_num_2002 * pctsum<fcl_den_2002>=' '
      fcl_num_2003 * pctsum<fcl_den_2003>=' '
      fcl_num_2004 * pctsum<fcl_den_2004>=' '
      fcl_num_2005 * pctsum<fcl_den_2005>=' '
      fcl_num_2006 * pctsum<fcl_den_2006>=' '
      fcl_num_2007 * pctsum<fcl_den_2007>=' '
    ) * f=comma10.1
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Foreclosure rate (per 1,000 SF homes + condos)'
  ;

  %macro skip;
  table 
    /** Rows **/
    ( foreclosures_2001 foreclosures_2002 foreclosures_2003 foreclosures_2004 foreclosures_2005 foreclosures_2006 ) * sum=' '
    ,
    /** Columns **/
    geo=' '
    /rts=70 box='Notices of foreclosure'
  ;
  %mend skip;
  
  format geo $geo.;

  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;

signoff;
