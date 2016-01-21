/**************************************************************************
 Program:  stebbins_1_11_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  01/25/07
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Cassandra Toone. Wants to know the number of African Americans 
 age 62 and older in Ward 7. 

 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
libname drequest 'D:\DCData\Libraries\Requests'; 
** Pulled Census 2000 tract data from Geolytics CC**;

data blackseniors;

  set drequest.aaage (rename=(AreaKey=geo2000));

  Male_62plus=P012B019+P012B020+P012B021+P012B022+P012B023+P012B024+P012B025;
  Label Male_62plus=	"Number of black males 62 plus";
  
  Fem_62plus=P012B043+P012B044+P012B045+P012B046+P012B047+P012B048+P012B049;
  Label Fem_62plus=	"Number of black females 62 plus";
  
  Seniors=Male_62plus+Fem_62plus;
  Label Seniors=	"Number of African Americans 62 plus";
  
  run;

proc contents data=blackseniors;
proc print data=blackseniors (obs=20);
run;

/* transforms tracts to wards */


%Transform_geo_data(
    dat_ds_name = blackseniors,
    dat_org_geo = geo2000, 


/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ Male_62plus Fem_62plus Seniors
    ,

/* add in vars here proportion*/
/*,*/
	
	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = dRequest.toone_012507,
    out_ds_label = Number of African Americans seniors by ward ) ;

run;

proc sort data=dRequest.toone_012507;
by ward2002;
run;

proc contents data=dRequest.toone_012507;
run;
filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\toone_012507.csv" lrecl=2000;

proc export data=dRequest.toone_012507
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
                              