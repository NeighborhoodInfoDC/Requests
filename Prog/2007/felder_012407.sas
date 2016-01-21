/**************************************************************************
 Program:  felder_1_24_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  01/25/07
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Shalome Kim Felder. Wants to BA and higher by neighborhood clusters. 

 Modifications:
**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
libname drequest 'D:\DCData\Libraries\Requests'; 
** Pulled Census 2000 tract data from Geolytics CC**;

data BAeduc;

  set drequest.educsex (rename=(AreaKey=geo2000));

  BAplus_male=P037015+P037016+P037017+P037018+P037019;
  Label BAplus_male=	"Number of BA and higher for males";
  
  BAplus_fem=P037032+P037033+P037034+P037035;
  Label BAplus_fem=	"Number of BA and higher for females";
  
  BAplus_total=P037015+P037016+P037017+P037018+P037019+P037032+P037033+P037034+P037035;
  Label BAplus_total=	"Number of BA and higher for all persons";
  
  run;

proc contents data=BAeduc;
proc print data=BAeduc(obs=20);
run;


%Transform_geo_data(
    dat_ds_name = BAeduc,
    dat_org_geo = geo2000, 


/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ BAplus_male BAplus_fem BAplus_total
    ,

/* add in vars here proportion*/
/*,*/
	
	wgt_ds_name = general.wt_tr00_cl00,
	wgt_org_geo=geo2000,
	wgt_new_geo=cluster2000,
    wgt_wgt_var = popwt,
	
    out_ds_name = dRequest.felder_012507,
    out_ds_label = Number of Percent of children under age 5 living in poverty by ward ) ;

run;

proc sort data=dRequest.felder_012507;
by ward2002;
run;

proc contents data=dRequest.felder_012507;
run;
filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\felder_012507.csv" lrecl=2000;

proc export data=dRequest.felder_012507
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
                                       