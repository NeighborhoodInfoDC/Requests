/**************************************************************************
 Program:  Median_sf_sales_price_1995_2016.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/15/17
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Get real property SF home price series for 1995 -
2016.
ULI Leadership Institute Presentation.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

data Median_sf;

  set Realprop.Sales_sum_city;
  
  keep r_mprice_sf_: ;

run;

ods csvall body="&_dcdata_default_path\Requests\Prog\2017\Median_sf_sales_price_1995_2016.csv";

proc print data=Median_sf noobs;
run;

ods csvall close;

