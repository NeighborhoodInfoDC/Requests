/**************************************************************************
 Program:  Appel.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/09/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  % population 14-21 years old at or below 200% federal
poverty level.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ipums )

** Start submitting commands to remote server **;

rsubmit;

data TableDat (compress=no);

  set Ipums.Acs_2006_dc (keep=age poverty upuma perwt);
  
  where 14 <= age <= 21 and poverty > 0;
  
run;

proc download status=no
  data=TableDat 
  out=TableDat (compress=no);

run;

endrsubmit;

** End submitting commands to remote server **;

%fdate()

proc format;
  value pov
    0 <-< 200 = 'Below 200% FPL'
    200 - high = 'At or above 200% FPL';
  value $upuma (notsorted)
    '1100104' = 'East of the River'
    '1100103' = 'East of N. Capitol St. (not EOR)'
    other = 'Rest of city';


options nodate nonumber;

ods rtf file="&_dcdata_path\requests\prog\2008\Appel_05_01_08.rtf" style=Styles.Rtf_arial_9pt bodytitle;

proc tabulate data=TableDat format=comma12.0 noseps missing;
  class poverty;
  class upuma / preloadfmt order=data;
  var perwt;
    table 
    /** Rows **/
    all='Total' poverty=' ',
    /** Columns **/
    ( all='District of Columbia' upuma=' ' ) * perwt=' ' * ( sum='Persons' colpctsum='Percent'*f=comma12.1 )
  ;
  format poverty pov. upuma $upuma.;
  title2 ' ';
  title3 'Persons 14-21 years old by ratio of income to federal poverty level (FPL)';
  title4 'Washington, D.C., 2006';
  footnote1 height=9pt "Source: American Community Survey data (2006) tabulated by NeighborhoodInfo DC (&fdate).";

run;

ods rtf close;

run;

signoff;
