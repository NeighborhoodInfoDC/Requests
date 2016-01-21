/**************************************************************************
 Program:  stebbins_1_16_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  01/11/07
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Helene Stebbins 1/16/07. Wants to know the proportion of children under age 5
 living in poverty by ward.  

 Modifications:
**************************************************************************/
/**************************************************************************
 Program:  stebbins_1_16_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  01/11/07
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Helene Stebbins 1/16/07. Wants to know the proportion of children under age 5
 living in poverty by ward.  

 Modifications:
**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
libname drequests 'D:\DCData\Libraries\Requests'; 
** Get Census 2000 tract data proportion of children under age 18
 living in poverty  **;

data under5pov;

  set drequests.stebbins_under5pov (rename=(AreaKey=geo2000));

  Num_under5=P087003+P087011;
  Label Num_under5=	"Total number of children under age 5";
   
  run;

proc contents data=under5pov;
proc print data=under5pov (obs=20);
run;
/* transforms tracts to wards */


%Transform_geo_data(
    dat_ds_name = under5pov,
    dat_org_geo = geo2000, 


/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ P087003 P087011 num_under5
    ,

/* add in vars here proportion*/
/*,*/
	
	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = stebbins_ward,
    out_ds_label = Percent of children under age 5 living in poverty by ward ) ;

run;

proc sort data=stebbins_ward;
by ward2002;
run;

data drequest.stebbins_1_16_07_under5;
	set stebbins_ward;
       
    Propov_under5=100*(P087003/Num_under5);
  Label Propov_under5="Proportion of children under age 5 living in poverty";
   Label P087003="Number of under 5 years olds below poverty level";
 Label P087011="Number of under 5 year olds at or above poverty level";
run;

proc contents data=dRequest.stebbins_1_16_07_under5;
run;
filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\stebbins_1_16_07_under5.csv" lrecl=2000;

proc export data=dRequest.stebbins_1_16_07_under5
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
