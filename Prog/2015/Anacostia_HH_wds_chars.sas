/**************************************************************************
 Program:  Anacostia_HHwrds_chars.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Simington
 Created:  7/14/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Compile Ward household characteristics for Anacostia Park analysis.

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS, local=n )

data Anacostia_HHwrds_chars;

set
    ACS.Acs_2008_12_sum_tr_wd12_2
	  (keep=ward2012  B11001e1: B11005e6: B11005e15: B11005e7: B11005e16: B11001e8) 
  ;
  by ward2012;
  
 if ward2012 ~= '99';
  if ward2012 not in ('8','7') then delete; 

	/*Household Breakdown */
	NumHouseholds = B11001e1;
		Perc_MaleHouseholds = (B11005e6 + B11005e15) / NumHouseholds;
		Perc_FemHouseholds = (B11005e7 + B11005e16) / NumHouseholds;
		Perc_LivAlone = B11001e8 / NumHouseholds;


run;

%File_info( data=Anacostia_HHwrds_chars, printobs=0 )

** Summary tables **;
ods listing close;

ods tagsets.excelxp file="L:\Libraries\Requests\Data\Anacostia_HHwrds_chars.xls" style=Printer options(sheet_interval='Proc' );

proc tabulate data=Anacostia_HHwrds_chars;
  class ward2012;
  var 
   NumHouseholds Perc_MaleHouseholds Perc_FemHouseholds Perc_LivAlone;

table 
   NumHouseholds Perc_MaleHouseholds Perc_FemHouseholds Perc_LivAlone, ward2012;
  format ward2012 $clus00f. _numeric_ comma10.5;
run;

ods tagsets.excelxp close;

ods listing;

filename fexport "L:\Libraries\Requests\Data\Anacostia_HHwrds_chars.csv" lrecl=2000;

proc export data=Anacostia_HHwrds_chars
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;






