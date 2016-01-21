/**************************************************************************
 Program:  DCData\Requests\Prog\2006\Births_race.sas
 Library:  DCData\Libraries\Vital
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  12/05/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate  number of births and number of births less than 37 weeks 
 for clusters, 21, 22, 23 and 25,
 for 2000-2004

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
libname requests 'D:\DCData\Libraries\Requests'; 
rsubmit;

data births_preterm /* creates a file on the alpha - temp */;
set vital.births_sum_cltr00   ;



proc download inlib=work outlib=requests; /* download to PC */
select births_preterm ; 

run;

endrsubmit; 

proc contents data=requests.births_preterm;
run;


**********Pull out preterm and number of births for four clusters;

data preterm (keep=cluster_tr2000  Births_w_gest_age_2000 Births_w_gest_age_2001 Births_w_gest_age_2002 Births_w_gest_age_2003
Births_w_gest_age_2004 Births_preterm_2000 Births_preterm_2001 Births_preterm_2002 Births_preterm_2003 Births_preterm_2004) ;
set requests.births_preterm;

run;

data preterm_4cluster; 
set preterm;

keep cluster_tr2000="21" and cluster_tr2000="22" and cluster_tr2000="23" and cluster_tr2000="25";

run;

proc contents data=preterm_4cluster;
run;

**********Create table of total number of births and preterm births from 2001-2004*******************;


**********Export table of total number of births from 1998-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\Gogue_preterm.csv" lrecl=2000;

proc export data=preterm
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;