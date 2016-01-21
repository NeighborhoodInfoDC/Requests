/**************************************************************************
 Program:  Kershbaum_11_26_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/27/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Four-quarter moving average of median sales price,
single family homes (like HM fig. 2), for CITY.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HsngMon )
%DCData_lib( RealProp )

%let end_dt = '01oct2006'd;
%let sales_data = HsngMon.Sales_clean_2007_2;

%put _user_;

*options obs=0;

data Sales_adj (compress=no);

  set &sales_data;
  
  where 
    ( cluster_tr2000 ~= '' and Ward2002 ~= '' ) and
    ( '01jan1995'd <= saledate < &end_dt ) and
    ui_proptype = '10';
  
  ** Synchronize start at first quarter 1996 **;
  
  if year( saledate ) = 1995 and qtr( saledate ) = 1 then delete;
  
  %dollar_convert( saleprice, saleprice_adj, saledate_yr, 2006 )
  
  city = '1';
  
run;

proc summary data=Sales_adj nway;
  class city saledate;
  var saleprice_adj;
  output out=Qtrly_sales_price (drop=_type_ _freq_ compress=no) median=;
  format saledate yyq.;

data Qtrly_sales_city (compress=no);

  set Qtrly_sales_price;
  by city;
  
  retain price1 price2 price3;
  
  if first.city then do;
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
  
proc print data=Qtrly_sales_city;
  by city;
  
run;

proc sort data=Qtrly_sales_city;
  by saledate;

proc transpose data=Qtrly_sales_city 
    out=Qtrly_sales_city_tr (drop=_name_ compress=no) 
    prefix=price_wd_;
  var mov_avg_price;
  id city;
  by saledate;
  format city $1.;

proc print;
  
data Csv_out (compress=no);

  length year_fmt $ 4;

  set Qtrly_sales_city_tr;
  
  if qtr( saledate ) = 1 then year_fmt = put( year( saledate ), 4. );
  else year_fmt = "";
  
  drop saledate;
  
run;

filename fexport "&_dcdata_path\Requests\Prog\2007\Qtrly_sales_city.csv" lrecl=256;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;




run;
