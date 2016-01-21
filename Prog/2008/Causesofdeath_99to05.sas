


     /**************************************************************************
 Program:  DCData\Requests\Prog\2008\causeofdeath98_05.sas
 Library:  DCData\Libraries\Requests
 Project:  NeighborhoodInfo DC
 Author:   Shelby Kain
 Created:  November 10, 2008
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect

 Description: Causes of death from 1999-2005, looking for frequency of deaths
                due to heat or heatstroke

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
%DCData_lib( requests );

rsubmit;

data causesofdeath99;/* creates a file on the alpha - temp */
set vital.deaths_1999 (keep=year icd10_4d);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath99;

run;

rsubmit;

data causesofdeath00;/* creates a file on the alpha - temp */
set vital.deaths_2000 (keep=year icd10_4d);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath00;

run;

rsubmit;
data causesofdeath01;/* creates a file on the alpha - temp */
set vital.Deaths_2001 (keep=year icd10_4d);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath01;

run;

rsubmit;
data causesofdeath02;/* creates a file on the alpha - temp */
set vital.deaths_2002 (keep=year icd10_4d);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath02;

run;

rsubmit;
data causesofdeath03;/* creates a file on the alpha - temp */
set vital.deaths_2003 (keep=year icd10_4d);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath03;

run;

rsubmit;
data causesofdeath04;/* creates a file on the alpha - temp */
set vital.deaths_2004 (keep=year icd10_4d);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath04;

run;

rsubmit;
data causesofdeath05;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep=year icd10_4d);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath05;

run;
endrsubmit;

*want to see frequency of causes of death;
proc freq data=requests.causesofdeath99;
 table Icd10_4d;
run;
proc sort data=requests.causesofdeath99;
by year Icd10_4d;
run;

proc summary data=requests.causesofdeath99;
by year Icd10_4d;
output out=heatcauses99;
run;

proc sort data=requests.causesofdeath00;
by year Icd10_4d;
run;
proc summary data=requests.causesofdeath00;
by year Icd10_4d;
output out=heatcauses00;
run;

proc sort data=requests.causesofdeath01;
by year Icd10_4d;
run;
proc summary data=requests.causesofdeath01;
by year Icd10_4d;
output out=heatcauses01;
run;

proc sort data=requests.causesofdeath02;
by year Icd10_4d;
run;
proc summary data=requests.causesofdeath02;
by year Icd10_4d;
output out=heatcauses02;
run;

proc sort data=requests.causesofdeath03;
by year Icd10_4d;
run;
proc summary data=requests.causesofdeath03;
by year Icd10_4d;
output out=heatcauses03;
run;

proc sort data=requests.causesofdeath04;
by year Icd10_4d;
run;
proc summary data=requests.causesofdeath04;
by year Icd10_4d;
output out=heatcauses04;
run;

proc sort data=requests.causesofdeath05;
by year Icd10_4d;
run;
proc summary data=requests.causesofdeath05;
by year Icd10_4d;
output out=heatcauses05;
run;

*merge heat-related causes of death for 1999 to 2005;
data heatcausesall; 
merge heatcauses99 heatcauses00 heatcauses01 heatcauses02 heatcauses03 heatcauses04 heatcauses05;
by year Icd10_4d;
run;

**********Export table of causes of death 1999-2005*******************;

filename fexport "D:\DCData\Libraries\Requests\Raw\heatcausesalll.csv" lrecl=2000;

proc export data=heatcausesall
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;

