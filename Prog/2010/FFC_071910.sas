/**************************************************************************
 Program:  fightforchildren071910.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  07/19/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Pull births by cluster for them to figure out where high quality schools should be located.

 Modifications:
**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( VITAL )
%DCData_lib( Requests )
rsubmit;

data births_sum_cluster;/* creates a file on the alpha - temp */
set vital.Births_sum_cltr00 (keep=cluster_tr2000  births_total_1998  births_total_1999 births_total_2000 births_total_2001
births_total_2002 births_total_2003 births_total_2004 births_total_2005 births_total_2006 births_total_2007);


proc download inlib=work outlib=requests; /* download to PC */
select births_sum_cluster; 

run;

endrsubmit; 

**********Export table of total number of births from 1998-2004*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\births_cluster_9807.csv" lrecl=2000;

proc export data=Requests.births_sum_cluster
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;
