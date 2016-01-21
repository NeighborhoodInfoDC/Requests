    /**************************************************************************
 Program:  DCData\Requests\Prog\2008\youthsuicideshomicides_05byward.sas
 Library:  DCData\Libraries\Requests
 Project:  NeighborhoodInfo DC
 Author:   Shelby Kain
 Created:  November 18, 2008
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect

 Description: Number of suicides and homicides for youth ages 12-17 and 18-24 for 2005 by ward

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
%DCData_lib( requests );

/*suicides and homicides 12-17*/

rsubmit;
data youth12to17deaths05;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep=year deaths_suicide deaths_homicide age_calc ward);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17deaths05;

run;
endrsubmit;

/*suicides and homicides 18-24*/

rsubmit;

data youth18to24deaths05;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep=year deaths_suicide deaths_homicide age_calc ward);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24deaths05;

run;

endrsubmit;




proc sort data=requests.youth12to17deaths05;
by year age_calc deaths_homicide deaths_suicide ward;
run;


proc sort data=requests.youth18to24deaths05;
by year age_calc deaths_homicide deaths_suicide ward;
run;


**********Export table youth suicides and homicides 2005 by ward*******************;

filename fexport "D:\DCData\Libraries\Requests\Doc\youth12to17suicidehomicidebyward.csv" lrecl=2000;

proc export data=requests.youth18to24deaths05
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Requests\Doc\youth18to24suicidehomicidebyward.csv" lrecl=2000;

proc export data=requests.youth12to17deaths05
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;

