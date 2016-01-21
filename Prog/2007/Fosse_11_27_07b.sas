/**************************************************************************
 Program:  Fosse_11_27_07b.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/27/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

rsubmit;

/*
data A;

  address = "1425 T St NW";
  
run;

%DC_geocode(
  geo_match=Y,
  data=A,
  out=A_geo,
  staddr=address,
  zip=,
  id=,
  ds_label=,
  listunmatched=N
)

proc print data=A_geo;

run;
*/

data _null_;
  set RealProp.Parcel_base;
  where ssl = "0205    0052";
  *where ssl =: "0205";
  *where premiseadd =: "1425 T ST";
  file print;
  put / '--------------------';
  put (_all_) (= /);
run;

data _null_;
  set RealProp.Sales_master;
  where ssl = "0205    0052";
  file print;
  put / '---------------------';
  put 'RealProp.Sales_master';
  put '---------------------';
  put (_all_) (= /);
run;

endrsubmit;

run;

signoff;
