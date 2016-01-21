/**************************************************************************
 Program:  DCData\Requests\Prog\2007\silverman2_03_29_07.sas
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

data Hmda_sum_psa04 ;/* creates a file on the alpha - temp */
set Hmda.Hmda_sum_psa04  (keep= PSA2004 mrtgorigmedamthomepur1_4m_1997 mrtgorigmedamthomepur1_4m_1998 mrtgorigmedamthomepur1_4m_1999 mrtgorigmedamthomepur1_4m_2000
mrtgorigmedamthomepur1_4m_2001 mrtgorigmedamthomepur1_4m_2002 mrtgorigmedamthomepur1_4m_2003 mrtgorigmedamthomepur1_4m_2004 mrtgorigmedamthomepur1_4m_2005);



proc download inlib=work outlib=requests; /* download to PC */
select Hmda_sum_psa04; ; 

run;

endrsubmit; 

proc contents data=requests.Hmda_sum_psa04 ;
run;


**********Create table of housing market in 1997 and 2005 for psa 103*******************;


**********Export table of housing market in 1997 and 2005 for psa 103*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\silverman_HMDA.csv" lrecl=2000;

proc export data=requests.Hmda_sum_psa04
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;