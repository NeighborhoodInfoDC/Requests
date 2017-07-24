/**************************************************************************
 Program:  13_Median_sf_sales_price_1995_2016.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/15/17
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Get real property SF home price series for 1995 - 2016,
 city, tracts, ANCs, wards, and neighborhood clusters.

 Request for Housing Insights V2
 GitHub issue #13

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

/** Macro Export_prices - Start Definition **/

%macro Export_prices( geo );

  %local geosuf;
  
  %let geosuf = %sysfunc( putc( %upcase(&geo), $geosuf. ) );

  data Median_sf;

    set Realprop.Sales_sum&geosuf;
    
    keep &geo r_mprice_sf_: ;

  run;

  ods csvall body="&_dcdata_default_path\Requests\Raw\2017\13_Median_sf_sales_price_1995_2016&geosuf..csv";

  proc print data=Median_sf noobs;
   id &geo;
   format r_mprice_sf_: comma20.0;
   title;
  run;

  ods csvall close;

%mend Export_prices;

/** End Macro Definition **/

options missing=' ';

%Export_prices( city )
%Export_prices( ward2012 )
%Export_prices( anc2012 )
%Export_prices( cluster_tr2000 )
%Export_prices( geo2010 )
