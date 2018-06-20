/**************************************************************************
 Program:  Qtrly_sales_ward.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  9/19/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Single-family home price trends by ward. (Old HsngMon Figure 2)

 Modifications:
 07/09/13 LH Moved from HsngMon library to Realprop.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( OCC )

%Init_macro_vars( rpt_yr=2015, rpt_qtr=4, sales_qtr_offset=0, sales_start_dt='01jan1996'd, sales_end_dt='31dec2015'd )

data Sales_adj (compress=no);

  set realprop.Sales_clean_&g_rpt_yr._&g_rpt_qtr;
  
  where 
    ( cluster_tr2000 ~= '' and Ward2012 ~= '' ) and
    ( intnx( 'qtr', intnx( 'year', &g_sales_start_dt, 0, 'beginning' ), -3, 'beginning' ) <= saledate <= &g_sales_end_dt ) and
    ui_proptype = '10';
  
run;

proc summary data=Sales_adj nway;
  class ward2012 saledate;
  var saleprice_adj;
  output out=Qtrly_sales_price (drop=_type_ _freq_ compress=no) median=;
  format saledate yyq.;
  
proc print data=Qtrly_sales_price;
  where ward2012 = '1';
run;

data Qtrly_sales_ward (compress=no);

  set Qtrly_sales_price;
  by ward2012;
  
  retain price1 price2 price3;
  
  if first.ward2012 then do;
    price1 = .;
    price2 = .;
    price3 = .;
  end;

  ** 4 quarter moving average **;
  
  mov_avg_price = ( saleprice_adj + price1 + price2 + price3 ) / 4;
  
  put (_all_) (=);
  
  if mov_avg_price ~= . then output;
  
  price3 = price2;
  price2 = price1;
  price1 = saleprice_adj;
  
  drop price1 price2 price3 saleprice_adj;
  
run;  
  
/*
proc print data=Qtrly_sales_ward;
  by Ward2012;
  
run;
*/

proc sort data=Qtrly_sales_ward;
  by saledate;

proc transpose data=Qtrly_sales_ward 
    out=Qtrly_sales_ward_tr (drop=_name_ compress=no) 
    prefix=price_wd_;
  var mov_avg_price;
  id ward2012;
  by saledate;
  format ward2012 $1.;

proc print;
  
data Csv_out (compress=no);

  length year_fmt $ 4;

  set Qtrly_sales_ward_tr;
  
  if qtr( saledate ) = 1 then year_fmt = put( year( saledate ), 4. );
  else year_fmt = "";
  
  drop saledate;
  
run;

filename fexport "L:\Libraries\Requests\Prog\2016\Qtrly_sales_ward.csv" lrecl=256;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

