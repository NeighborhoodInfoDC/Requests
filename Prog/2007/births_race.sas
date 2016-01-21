/**************************************************************************
 Program:  DCData\Requests\Prog\2006\Births_race.sas
 Library:  DCData\Libraries\Vital
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  12/05/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate  number of births for 2 census tracts, 68.01 and 68.02,
 for 2000-2004

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
libname requests 'D:\DCData\Libraries\Requests'; 
rsubmit;

data births_race ;/* creates a file on the alpha - temp */
set vital.births_sum_tr00  (keep= geo2000 births_asian_2001 births_asian_2002 births_asian_2003 births_asian_2004 
births_black_2001 births_black_2002 births_black_2003 births_black_2004
births_hisp_2001 births_hisp_2002 births_hisp_2003 births_hisp_2004
births_white_2001 births_white_2002 births_white_2003 births_white_2004 births_w_race_2001 births_w_race_2002
births_w_race_2003 births_w_race_2004);



proc download inlib=work outlib=requests; /* download to PC */
select births_race ; 

run;

endrsubmit; 

proc contents data=requests.births_race;
run;

**********Create table of total number of births by race from 2001-2004*******************;


**********Export table of total number of births from 1998-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\births_race.csv" lrecl=2000;

proc export data=requests.births_race
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;