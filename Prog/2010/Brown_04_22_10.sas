/**************************************************************************
 Program:  Brown_04_22_10.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/05/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Request from Jay-Me Brown, CBS News, 4/22/10.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ipums )

data Acs;

  merge
    Ipums.Acs_2008_dc (in=in1)
    Ipums.Acs_2008_fam_pmsa99;
  by serial;

  if in1;
  
  if is_sfemwkids then hh_type = 1;
  else if is_smalwkids then hh_type = 2;
  else if is_mrdwkids then hh_type = 3;
  else hh_type = 4;

run;

proc format;
  value agef
    0-17 = '< 18'
    18-high = '18+';
  value povf
    1 - 100 = 'At or below FPL'
    101 - 200 = '101-200% FPL'
    201 - high = '201% or more FPL';
run;

proc freq data=Acs;
  where pernum=1 and gq in (1,2);
  tables age hh_type;
  weight hhwt;
  format age agef.;
run;

proc means data=ACS;
  class upuma;
  where poverty > 0;
  var poverty;
  weight perwt;
run;

proc freq data=ACS;
  where poverty > 0 and upuma = '1100104';
  table poverty;
  weight perwt;
  format poverty povf.;
run;

