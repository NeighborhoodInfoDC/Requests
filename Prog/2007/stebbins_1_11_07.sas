/**************************************************************************
 Program:  stebbins_1_11_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  01/11/07
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Helene Stebbins 1/11/07. Wants to know the proportion of children under age 18
 living in poverty by ward.  

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( NCDB )
%DCData_lib( Requests )

rsubmit;

** Get Census 2000 tract data proportion of children under age 18
 living in poverty  **;

data stebbins_07_ncdb;

  set ncdb.ncdb_lf_2000_dc 
    (keep= geo2000 chdpoo0n chdpoo0d);

proc download inlib=work outlib=requests; /* download to PC */
select stebbins_07_ncdb; 

run;

endrsubmit; 



/* transforms tracts to wards */
run;

%Transform_geo_data(
    dat_ds_name = requests.stebbins_07_ncdb,
    dat_org_geo = geo2000, 


/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ chdpoo0n chdpoo0d 
    ,

/* add in vars here proportion*/
/*,*/
	
	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = Requests.stebbins_1_11_07_chilpov_ward,
    out_ds_label = Percent of children living in poverty by ward 
  );

run;

proc sort data=Requests.stebbins_1_11_07_chilpov_ward;
by ward2002;
run;

data Requests.stebbins__1_11_07_chilpov_ward;
	set Requests.stebbins_1_11_07_chilpov_ward;
    chdpoo02 = 100* (chdpoo0n / chdpoo0d);

proc contents data=Requests.stebbins__1_11_07_chilpov_ward;
run;
filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\child_pov_ward.csv" lrecl=2000;

proc export data=Requests.stebbins__1_11_07_chilpov_ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
