/**************************************************************************
 Program:  DCData\Requests\Prog\2006\silverman_03_29_07.sas
 Library:  DCData\Libraries\Police
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  12/05/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate number of part 1 crimes in PSA 103
 for 2000-2004

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( police )
libname requests 'D:\DCData\Libraries\Requests'; 
rsubmit;

data police ;/* creates a file on the alpha - temp */
set police.crimes_sum_psa04 (keep= psa2004 crimes_pt1_violent_2000 crimes_pt1_violent_2001 crimes_pt1_violent_2002 crimes_pt1_violent_2003 crimes_pt1_violent_2004
crimes_pt1_property_2000 crimes_pt1_property_2001 crimes_pt1_property_2002 crimes_pt1_property_2003 crimes_pt1_property_2004
crime_rate_pop_2000 crime_rate_pop_2001 crime_rate_pop_2002 crime_rate_pop_2003 crime_rate_pop_2004);



proc download inlib=work outlib=requests; /* download to PC */
select police ; 

run;

endrsubmit; 

proc contents data=requests.police;
run;

**********Create table of total number of part 1 crimes from 2001-2004*******************;


**********Create table of total number of part 1 crimes from 2001-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\silverman_psa103.csv" lrecl=2000;

proc export data=requests.police
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;