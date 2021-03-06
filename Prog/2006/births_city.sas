/**************************************************************************
 Program:  DCData\Requests\Prog\2006\Births_city.sas
 Library:  DCData\Libraries\Vital
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  12/05/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate total number of births for the city from 1998-2004

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
libname requests 'D:\DCData\Libraries\Requests'; 
rsubmit;

data births_sum_city;/* creates a file on the alpha - temp */
set vital.births_sum_city (keep= births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004);


proc download inlib=work outlib=requests; /* download to PC */
select births_sum_city; 

run;

endrsubmit; 



**********Create table of total number of births from 1998-2004*******************;

proc print data=requests.births_sum_city;
var births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004;

run;

**********Export table of total number of births from 1998-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\births_city.csv" lrecl=2000;

proc export data=Requests.births_sum_city
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;