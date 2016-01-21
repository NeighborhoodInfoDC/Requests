
**************************************************************************
Program: Females_35to64_byWard.sas
Library: requests
Project: NighborhoodInfo DC Technical Assistance: Prepared for Justice Armattoe
Author: Lesley Freiman
Created: 7/14/08
Version: SAS 9.1
Environment: Windows with SAS/Connect
Description: Number of females age 35-64 by ward
Modifications:

**************************************************************************/;


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
run;


*/ Defines libraries /*;
%DCData_lib( Ncdb );
%DCData_lib( Requests );
%DCData_lib( General );

rsubmit;

*/creates a file with females by age group on alpha - temp */;
data female_35to64; 
set ncdb.ncdb_lf_2000_dc (keep= geo2000 fem440 fem540 fem640);
run;

proc download inlib=work outlib=requests; 
select female_35to64; 
run;

endrsubmit;

/* transforms tracts to wards */;

%Transform_geo_data(
    dat_ds_name = requests.female_35to64,
    dat_org_geo = geo2000, 

	dat_count_vars = /*yr 2000 vars*/ fem440 fem540 fem640,

	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = Requests.female_35to64_ward,
    out_ds_label = Number of females in agegroup by ward 
  );
run;



filename fexport "D:\DCDATA\Libraries\Requests\Raw\female_35to64_ward.csv" lrecl=2000;
proc export data=requests.female_35to64_ward
	outfile=fexport 
	dbms=csv replace;
	run;

	filename fexport clear;
	run;
