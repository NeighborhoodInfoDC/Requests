/**************************************************************************
 Program:  Ray_1_12_08.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  01/12/08
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Gabrielle Ray: Houses built by ward.  

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( NCDB )

libname requests  "D:\DCData\Libraries\Requests" ; 

rsubmit;

** Get total number of homes built by different year spans by ward**;

data house_ncdb;

  set ncdb.ncdb_lf_2000_dc 
    (keep= geo2000 bltyr390 bltyr490 bltyr590 bltyr690 bltyr790 bltyr890 bltyr940 bltyr980 bltyr000 );

proc download inlib=work outlib=requests; /* download to PC */
select house_ncdb; 

run;

endrsubmit; 



/* transforms tracts to wards */
run;

%Transform_geo_data(
    dat_ds_name = requests.house_ncdb,
    dat_org_geo = geo2000, 


/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ bltyr390 bltyr490 bltyr590 bltyr690 bltyr790 bltyr890 bltyr940 bltyr980 bltyr000  
    ,

/* add in vars here proportion*/
/*,*/
	
	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var =popwt ,
	
    out_ds_name = Requests.ray_1_12_08_housblt,
    out_ds_label = Number of total homes built by ward 
  );

run;

proc sort data=Requests.ray_1_12_08_housblt;
by ward2002;
run;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\ray_housebuilt.csv" lrecl=2000;

proc export data=Requests.ray_1_12_08_housblt
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;
