/**************************************************************************
 Program:  Watson_10_14_05.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/14/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Export ward to tract weighting file for Keith Watson
 (request 10/14/05).

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( General )

filename fexport "D:\DCData\Libraries\Requests\Raw\wt_tr00_ward02.csv" lrecl=256;

proc export data=General.wt_tr00_ward02
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

%File_info(
  data=General.wt_tr00_ward02,
  contents=Y,
  printobs=0,
  printchar=N,
  printvars=,
  freqvars=,
  stats=
)


run;

