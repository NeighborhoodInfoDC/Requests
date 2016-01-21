/**************************************************************************
 Program:  DCData\Requests\Prog\2006\preschoolage_census.appletree.sas
 Library:  DCData\Libraries\Vital
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  12/05/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate  number of 3 and 4 year olds in 2000 for three census tracts, 
 37.00, 36.00, 28.02, 30.00,
 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( census )
libname requests 'D:\DCData\Libraries\Requests'; 
rsubmit;

data age3and4_sf1 ;/* creates a file on the alpha - temp */
set census.Cen2000_sf1_dc_ph   (keep= geo2000 sumlev block p14i27 p14i28 p14i6 p14i7);
where sumlev="140";

proc download inlib=work outlib=requests; /* download to PC */
select age3and4_sf1 ; 

run;

endrsubmit; 

proc contents data=requests.age3and4_sf1;
run;



**********Export table of total number of births from 1998-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\age3and4_sf1.csv" lrecl=2000;

proc export data=Requests.age3and4_sf1
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;