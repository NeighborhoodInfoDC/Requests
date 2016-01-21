/**************************************************************************
 Program:  DCData\Requests\Prog\2007\schwartzmanHMDA_03_13_07.sas
 Library:  DCData\Libraries\Vital
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  12/05/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate change in housing market for 2 census tracts, 68.01 and 68.02,
 for 1997-2005

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( HMDA )
libname requests 'D:\DCData\Libraries\Requests'; 
rsubmit;

data Hmda_sum_tr00 ;/* creates a file on the alpha - temp */
set Hmda.Hmda_sum_tr00  (keep= geo2000 NumMrtgOrig_hinc_1997 NumMrtgOrig_mi_1997 NumMrtgOrig_li_1997 NumMrtgOrig_vli_1997 NumMrtgOrig_Inc_1997
NumMrtgOrig_hinc_2005 NumMrtgOrig_mi_2005 NumMrtgOrig_li_2005 NumMrtgOrig_vli_2005 NumMrtgOrig_Inc_2005
NumMrtgOrigBlack_1997 NumMrtgOrigWhite_1997 NumMrtgOrigHisp_1997 NumMrtgOrigasianpi_1997 nummrtgorigotherx_1997 NumMrtgOrigWithRace_1997
NumMrtgOrigBlack_2005 NumMrtgOrigWhite_2005 NumMrtgOrigHisp_2005 NumMrtgOrigasianpi_2005 nummrtgorigotherx_2005 NumMrtgOrigWithRace_2005);



proc download inlib=work outlib=requests; /* download to PC */
select Hmda_sum_tr00 ; ; 

run;

endrsubmit; 

proc contents data=requests.Hmda_sum_tr00 ;
run;

data hmda_hilleast;
set requests.Hmda_sum_tr00 ;
keep geo2000="11001006801" and geo2000="11001006802";
run;

**********Create table of housing market in 1997 and 2005 for 11001006801 11001006802*******************;


**********Export table of total number of births from 1998-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\schwartzman_hilleast.csv" lrecl=2000;

proc export data=requests.Hmda_sum_tr00
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;