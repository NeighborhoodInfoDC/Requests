/**************************************************************************
 Program:  Anacostia_wd_city_chars.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   S. Zhang
 Created:  4/28/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Compile ward + city characteristics for Anacostia Park analysis.

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital, local=n )

%macro create_vars(level, lvl);
data Anacostia_&level._chars;

set
    Vital.deaths_sum_&lvl.
	  (keep=&level.  deaths_total_2007 deaths_w_cause_2007 deaths_cancer_2007 deaths_cereb_2007 deaths_diabetes_2007 deaths_heart_2007 
			deaths_hiv_2007 deaths_liver_2007 deaths_respitry_2007 deaths_suicide_2007) 
  ;
  by &level.;
  
  %if &level.=ward2012 %then %do;
  where ward2012="7" or ward2012="8";
  %end;

	/*deaths with cause reports*/
	p_deaths_cancer_2007 = deaths_cancer_2007 / deaths_w_cause_2007;
	p_deaths_cereb_2007 = deaths_cereb_2007/ deaths_w_cause_2007;
	p_deaths_diabetes_2007 = deaths_diabetes_2007/ deaths_w_cause_2007;
	p_deaths_heart_2007 = deaths_heart_2007/ deaths_w_cause_2007;
	p_deaths_hiv_2007 = deaths_hiv_2007/deaths_w_cause_2007; 
	p_deaths_liver_2007 = deaths_liver_2007/deaths_w_cause_2007; 
	p_deaths_respitry_2007 = deaths_respitry_2007/deaths_w_cause_2007;
	p_deaths_suicide_2007= deaths_suicide_2007/deaths_w_cause_2007; 

run;

%File_info( data=Anacostia_&level._chars, printobs=0 )

%mend create_vars;

%create_vars(city, city);
%create_vars(ward2012, wd12);

** Summary tables **;
%macro run_table(level, lvl);
ods listing close;

ods tagsets.excelxp file="L:\Libraries\Requests\Data\Anacostia_&level._chars.xls" style=Printer options(sheet_interval='Proc' );

proc tabulate data=Anacostia_&level._chars;
  class &level.;
  var 
   deaths_total_2007 deaths_w_cause_2007 p_deaths_cancer_2007 p_deaths_cereb_2007 p_deaths_diabetes_2007 p_deaths_heart_2007 p_deaths_hiv_2007 
	p_deaths_liver_2007 p_deaths_respitry_2007 p_deaths_suicide_2007 ;

table 
   deaths_total_2007 deaths_w_cause_2007 p_deaths_cancer_2007 p_deaths_cereb_2007 p_deaths_diabetes_2007 p_deaths_heart_2007 p_deaths_hiv_2007 
	p_deaths_liver_2007 p_deaths_respitry_2007 p_deaths_suicide_2007, &level.;
  format &level. $clus00f. _numeric_ comma10.5;
run;

ods tagsets.excelxp close;

ods listing;

filename fexport "L:\Libraries\Requests\Data\Anacostia_&level._chars.csv" lrecl=2000;

proc export data=Summit_&level._chars
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

%mend;

%run_table(city, city)
%run_table(ward2012, wd12)

