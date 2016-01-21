**************************************************************************
Program: births_by_zip.sas
Library: requests
Project: NighborhoodInfo DC Technical Assistance: Prepared for Alejandro Yepes 
Author: Lesley Freiman
Created: 6/26/08
Version: SAS 9.1
Environment: Windows with SAS/Connect
Description: Number of Births by Zip Code 2005
Modifications:

**************************************************************************/;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;



*/ Defines libraries /*;
%DCData_lib( Vital );
%DCData_lib( Requests );
libname requests 'K:\Metro\PTatian\DCData\Libraries\Requests\Raw';

rsubmit;

/* creates a file on the alpha - temp
including kept variables */

data births_sum_zip_lf;
set vital.Births_sum_zip (keep= zip births_total_2005 births_total_2004 births_total_2003 births_total_2002 births_total_2001 births_total_2000 births_total_1999 births_total_1998);
run;
*/downloads dataset from temporary alpha folder to specified 
"requests" libname location/*;

proc download inlib=work outlib=requests; 
select births_sum_zip_lf; 

run;

endrsubmit; 
signoff;

*/ creates output: .sas7bdat => .cvs /*;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\births_by_zip_lf.csv" lrecl=2000;

proc export data=Requests.births_sum_zip_lf
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
