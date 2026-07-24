/**************************************************************************
 Program:  Annual_sales_ward.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  7/24/2026
 Version:  SAS 9.4
 Environment:  Remote session (SAS1)
 GitHub issue:  117
 
 Description:  Download data for annual sales by ward chart.

 Modifications:
**************************************************************************/

%include "F:\DCDATA\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( RealProp )

/** Macro Annual_sales - Start Definition **/

%macro Annual_sales( start_yr=, end_yr=, geo=, geosuffix= );

  data Annual_sales_&geosuffix;
  
    set Realprop.Sales_sum_&geosuffix 
         (keep=&geo mprice_sf_&start_yr-mprice_sf_&end_yr mprice_condo_&start_yr-mprice_condo_&end_yr);
    
    length type $ 8;
    
    ** Single family sales **;
    
    %do i = &start_yr %to &end_yr;
    
      %dollar_convert( mprice_sf_&i, r_mprice_&i, &i, &end_yr, series=CUUR0000SA0L2 );
      
      label r_mprice_&i = "&i";
      
    %end;
    
    type = "SF";
    
    output;
    
    ** Condominium sales **;
      
    %do i = &start_yr %to &end_yr;
    
      %dollar_convert( mprice_condo_&i, r_mprice_&i, &i, &end_yr, series=CUUR0000SA0L2 );
      
      label r_mprice_&i = "&i";
      
    %end;
    
    type = "CONDO";
    
    output;
      
    format r_mprice_&start_yr-r_mprice_&end_yr 12.0;
    
    keep &geo type r_mprice_&start_yr-r_mprice_&end_yr;
    
    ***drop mprice_&type._&start_yr-mprice_&type._&end_yr;
    
  run;

  ** Output data to CSV **;
  
  proc format;
    value $type
      "SF" = "Single Family"
      "CONDO" = "Condominium";
  run;

  ods listing close;

  ods csvall body="&_dcdata_default_path\Requests\Prog\2026\Annual_sales_&geosuffix..csv";

  proc print data=Annual_sales_&geosuffix label;
    by ward2022;
    id type;
    var r_mprice_&start_yr-r_mprice_&end_yr;
    format type $type.;
  run;
  
  ods csvall close;

  ods listing;

%mend Annual_sales;

/** End Macro Definition **/


%Annual_sales( start_yr=1995, end_yr=2025, geo=ward2022, geosuffix=wd22 )


