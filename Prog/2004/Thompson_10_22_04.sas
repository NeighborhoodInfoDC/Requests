************************************************************************
* Program:  Thompson_10_22_04.sas
* Library:  Requests
* Project:  DC Data Warehouse
* Author:   P. Tatian
* Created:  10/22/04
* Version:  SAS 8.2
* Environment:  Windows
* 
* Description:  Tract correspondence file for 1980 - 2000 for
* Terri Thompson.
*
* Modifications:
************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

%Concat_lib( Ncdb2000, D:\Data\NCDB2000\Data )

data corresp;

  set Ncdb2000.twt80_00 (keep=geo80 geo00);
  
  where geo80 =: "11";
  
run;

proc sort data=corresp;
  by geo80 geo00;

filename fexport "D:\DCData\Libraries\Requests\Prog\DC_tracts_1980_2000.csv" lrecl=256;

proc export data=corresp
    outfile=fexport
    dbms=csv replace;

run;

