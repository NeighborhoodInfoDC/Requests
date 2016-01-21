/**************************************************************************
 Program:  Rodgers_02_27_09.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/27/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Download and export 2008 foreclosure and trustee deed
 sale records for Art Rodgers, OP.
 
 Output:  Foreclosures_2008_ar_02_27_09.csv

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Rod )

** Start submitting commands to remote server **;

rsubmit;

data Foreclosures_2008;

  set Rod.Foreclosures_2008;
  
  where ui_instrument in ( 'F1', 'F4', 'F5' );
  
  drop casey_: ;

run;

proc download status=no
  data=Foreclosures_2008 
  out=Requests.Foreclosures_2008_ar_02_27_09 (compress=no);
 
run;

endrsubmit;

/*
** End submitting commands to remote server **;

filename fexport "&_dcdata_path\requests\prog\2009\Foreclosures_2008_ar_02_27_09.csv" lrecl=3000;

proc export data=Foreclosures_2008
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

*/

signoff;
