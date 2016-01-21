/**************************************************************************
 Program:  Sommer_07_13_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/13/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Pull selected vars from Real Property data for Ethan
 Sommer (reporter).

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

rsubmit;

data Sommer_07_13_06 (compress=no);

  set RealProp.Ownerpt_2006_03 
    (keep=ssl nbhdname ui_proptype proptype usecode tax_: );

run;

proc download status=no
  data=Sommer_07_13_06 
  out=Sommer_07_13_06 (compress=no);

run;

endrsubmit;

filename fexport "D:\DCData\Requests\2006\Sommer_07_13_06.csv" lrecl=2000;

proc export data=Sommer_07_13_06
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

signoff;
