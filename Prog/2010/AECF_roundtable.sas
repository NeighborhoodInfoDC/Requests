/**************************************************************************
 Program:  AECF_roundtable.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/16/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summaries on families with children for AECF poverty
roundtable.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ipums )

data AECF_roundtable;

  merge
    Ipums.Acs_2008_dc (in=in1)
    Ipums.Acs_2008_fam_pmsa99;
  by serial;

  if in1;
  
  if age < 18;
  
  if is_mrdnokid or is_mrdwkids then hh_type = 1;
  else if is_sfemwkids or is_sngfem then hh_type = 2;
  else if is_smalwkids or is_sngmal then hh_type = 3;
  else hh_type = 4;

run;

proc freq data=AECF_roundtable;
  tables hh_type upuma;
  weight perwt;
  title2 'All children < 18';
run;

proc freq data=AECF_roundtable;
  where age < 5;
  tables hh_type upuma;
  weight perwt;
  title2 'All children < 5';
run;

