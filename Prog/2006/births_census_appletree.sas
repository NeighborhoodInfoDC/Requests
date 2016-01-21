/**************************************************************************
 Program:  DCData\Requests\Prog\2006\Births_census.appletree.sas
 Library:  DCData\Libraries\Vital
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  12/05/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate  number of births for three census tracts, 37.00, 36.00, 28.02, 30.00,
 for 2000-2004

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
libname requests 'D:\DCData\Libraries\Requests'; 
rsubmit;

data births_sum_tr00 ;/* creates a file on the alpha - temp */
set vital.births_sum_tr00  (keep= geo2000 births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004);



proc download inlib=work outlib=requests; /* download to PC */
select births_sum_tr00 ; 

run;

endrsubmit; 

proc contents data=requests.births_sum_tr00;
run;

**********Create table of total number of births from 1998-2004*******************;


proc print data=requests.births_sum_tr00;
where geo2000="11001003700";
var births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004;
title "Number of births for census tract 37.00";

proc print data=requests.births_sum_tr00;
where geo2000="11001003600" ;
var births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004;
title "Number of births for census tract 36.00";

proc print data=requests.births_sum_tr00;
where geo2000="11001002802" ;
var births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004;
title "Number of births for census tract 28.02";

proc print data=requests.births_sum_tr00;
where geo2000="11001003000" ;
var births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004;
title "Number of births for census tract 30.00";
run;



**********Export table of total number of births from 1998-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\births_census.csv" lrecl=2000;

proc export data=Requests.births_sum_tr00
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;