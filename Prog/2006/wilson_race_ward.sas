/**************************************************************************
 Program:  Wilson_race_ward.sas
 Library:  requests
 Project:  NeighborhoodInfo DC
 Author:   Jenn Comey
 Created:  8/23/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Number of each race and ethnicity and total population by ward for 1980,
1990, and 2000  
 Modifications:
**************************************************************************/

libname requests 'd:\DCData\Libraries\Requests ';

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ncdb )
%DCData_lib( requests ) 

/*2000 data*/
rsubmit;
data ncdb00_race;/* creates a file on the alpha - temp */
set ncdb.ncdb_lf_2000_dc (keep= geo2000 
 /* totalpop */ trctpop0
 /* race ethnicity */ shrnhw0n shrnhb0n shrhsp0n shrnho0n shrnhi0n shrnha0n shr0d);
 

proc download inlib=work outlib=requests; /* download to PC */
select ncdb00_race; 

run;

endrsubmit; 

signoff;


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ncdb )
%DCData_lib( requests ) 

/*1990 data*/
rsubmit;
data ncdb90_race;/* creates a file on the alpha - temp */
set ncdb.ncdb_1990_2000_dc (keep= geo2000 
 /* totalpop */ trctpop9
 /* race ethnicity */ shrnhw9n shrnhb9n shrhsp9n shrnho9n shrnhi9n shrnha9n shr9d);

proc download inlib=work outlib=requests; /* download to PC */
select ncdb90_race; 

run;

endrsubmit; 

signoff;


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ncdb )
%DCData_lib( requests ) 



/*1980 data*/
rsubmit;
data ncdb80_race;/* creates a file on the alpha - temp */
set ncdb.ncdb_1980_2000_dc (keep= geo2000 
 /* totalpop */ trctpop8
 /* race ethnicity */ shrnhw8n shrnhb8n shrhsp8n shrnhj8n shr8d);


proc download inlib=work outlib=requests; /* download to PC */
select ncdb80_race; 

run;

endrsubmit; 

signoff;


*******************************************************************
MERGE 3 DECADE FILES TOGETHER
******************************************************************;

proc sort data=requests.ncdb00_race;
	by geo2000;

proc sort data=requests.ncdb90_race;
	by geo2000;

proc sort data=requests.ncdb80_race;
	by geo2000;

run;

data requests.race_allyears;
	merge requests.ncdb00_race requests.ncdb90_race requests.ncdb80_race;
	by geo2000;
run;

*******************************************************************
WARD-LEVEL ANALYSES
******************************************************************;

/* transforms tracts to wards */
%Transform_geo_data(
    dat_ds_name = requests.race_allyears,
    dat_org_geo = geo2000, 

/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ trctpop0 shrnhw0n shrnhb0n shrhsp0n shrnho0n shrnhi0n shrnha0n shr0d
    /*1990 variables*/ trctpop9 shrnhw9n shrnhb9n shrhsp9n shrnho9n shrnhi9n shrnha9n shr9d
    /*1980 variables*/ shrnhw8n shrnhb8n shrhsp8n shrnhj8n shr8d
    ,

/* add in vars here proportion*/
	/*dat_prop_vars = old0 ,*/ 

 	
	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = Requests.race_allyrs_ward,
    out_ds_label = Race and Ethnicities for _80_90_00 by ward);

run;

proc sort data=Requests.race_allyrs_ward;
by ward2002;
run;

*filename outexc dde "Excel|K:\Metro\PTatian\DCData\Libraries\Requests\Raw [Race/ethn by ward.xls]"; 

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\race_ward.csv" lrecl=2000;

proc export data=Requests.race_allyrs_ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;