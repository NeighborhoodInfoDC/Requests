/**************************************************************************
 Program:  DCData\Requests\Prog\2010\0-5yearolds.sas
 Library:  DCData\Libraries\Requests
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  08/31/10
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate  number of 0-5 year olds by census tracks
 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( census )
rsubmit;

data age0_5 ;/* creates a file on the alpha - temp */
set census.Cen2000_sf1_dc_ph   (keep= geo2000 sumlev block p14i24 p14i25 p14i26 p14i27 p14i28 p14i29
p14i3 p14i4 p14i5 p14i6 p14i7 p14i8 pop100);
where sumlev="080"; /*census track only, not block*/

proc download inlib=work outlib=census; /* download to PC */
select age0_5 ; 

run;

endrsubmit; 

proc contents data=census.age0_5;
run;



**********Export table of total number of 0-5 year olds by census tract*******************;

filename fexport "K:\Metro\SPopkin\Promise & Choice Neighborhoods\DCPN\Evaluation\RDWG\age0_5.csv" lrecl=2000;

proc export data=census.age0_5
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;
