/**************************************************************************
 Program:  Simmons_07_06_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/06/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Export tract-ward weighting file to Excel.  Requested
 by Pat Simmons, Fannie Mae, 07/06/07.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

filename fexport "&_dcdata_path\requests\prog\2007\Wt_tr00_ward02.csv" lrecl=256;

proc export data=General.Wt_tr00_ward02
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

run;
