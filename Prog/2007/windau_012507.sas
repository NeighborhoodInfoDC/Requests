/**************************************************************************
 Program:  windau_1_25_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  01/25/07
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Tamara Windau. Wants to know the number of female 15-19 year olds
 and the number of female 15-44 year olds by ward
 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

libname drequest 'D:\DCData\Libraries\Requests'; 
** Pulled Census 2000 tract data from Geolytics CC**;

data femage;

  set drequest.agesex (rename=(AreaKey=geo2000));

  Fem_15to19=P012030+P012031;
  Label Fem_15to19=	"Number of females aged 15 to 19";
  
  Fem_15to44=P012030+P012031+P012032+P012033+P012034 +P012035+P012036+P012037+P012038;
  Label Fem_15to44=	"Number of females aged 15 to 44";
  
  run;

proc contents data=femage;
proc print data=femage (obs=5);
run;

/* transforms tracts to wards */


%Transform_geo_data(
    dat_ds_name = femage,
    dat_org_geo = geo2000, 


/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ Fem_15to19 Fem_15to44
    ,

/* add in vars here proportion*/
/*,*/
	
	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = dRequest.windau_012507,
    out_ds_label = Number of African Americans seniors by ward ) ;

run;

proc sort data=dRequest.windau_012507;
by ward2002;
run;

proc contents data=dRequest.windau_012507;
run;
filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\windau_012507.csv" lrecl=2000;

proc export data=dRequest.windau_012507
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
                              