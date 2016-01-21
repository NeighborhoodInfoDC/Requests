
**************************************************************************
Program: Ward8_Female_by_Agegroup.sas
Library: requests
Project: NighborhoodInfo DC Technical Assistance: Prepared for Mary Dooley
Author: Lesley Freiman
Created: 6/26/08
Version: SAS 9.1
Environment: Windows with SAS/Connect
Description: Number of Females in Ward 8, by agegroup
Modifications:

**************************************************************************/;


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;


*/ Defines libraries /*;
%DCData_lib( Ncdb );
%DCData_lib( Requests );
%DCData_lib( General );


rsubmit;

*/creates a file with females by age group on alpha - temp */;
data ncdb00_female_age; 
set ncdb.ncdb_lf_2000_dc (keep= geo2000 fem40 fem90 fem140 fem190 fem240 fem290
	fem340 fem440 fem540 fem640 fem740 fem750);
	run;

proc download inlib=work outlib=requests; 
select ncdb00_female_age; 
run;

endrsubmit;

/* transforms tracts to wards */;

%Transform_geo_data(
    dat_ds_name = requests.ncdb00_female_age,
    dat_org_geo = geo2000, 

	dat_count_vars = /*yr 2000 vars*/ fem40 fem90 fem140 fem190 fem240 fem290
	fem340 fem440 fem540 fem640 fem740 fem750,

	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = Requests.female_age_ward,
    out_ds_label = Number of females in agegroup by ward 
  );
run;



filename fexport "D:\DCDATA\Libraries\Requests\Raw\female_age.csv" lrecl=2000;
proc export data=requests.female_age_ward
	outfile=fexport 
	dbms=csv replace;
	run;

	filename fexport clear;
	run;
