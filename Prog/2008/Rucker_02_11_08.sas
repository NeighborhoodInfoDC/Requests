
/**************************************************************************
 Program:  Rucker_02_11_08.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Getsinger
 Created:  2/11/08
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description: List of rental apartment buildings in police district 4, pulled for Alicia Rucker. 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

rsubmit;
data tempdat;
merge RealProp.Parcel_base RealProp.Parcel_geo;
by ssl;
if psa2004=:'4' and ui_proptype='13' and in_last_ownerpt=1;
keep premiseadd zip;
format zip;
run;
proc download data=tempdat out=tempdat;
run; 
endrsubmit;
filename fexport "D:\DCData\Libraries\Requests\Raw\Rucker_02_11_08.csv" Lrecl=256;
proc export data=tempdat
outfile=fexport
dbms=csv replace;
run;


run;

signoff;
