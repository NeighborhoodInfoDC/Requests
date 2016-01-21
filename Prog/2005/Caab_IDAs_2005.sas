/**************************************************************************
 Program:  Caab_IDAs_2005.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/02/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Geocode CAAB IDA addresses in wards 7 & 8 for 2005 to
 determine which are in Casey neighborhoods.
 
 Request from Colleen Dailey, 6/1/05 (email).  Source data in file

 Source data in "D:\DCData\Requests\CAAB\Wards 7-8 IDAs_2005.xls"

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Realprop )
%DCData_lib( General )

filename source dde "excel|D:\DCData\Requests\CAAB\[Wards 7-8 IDAs_2005.xls]sheet1!r2c2:r33c3" lrecl=256 notab;

data Caab_IDAs_2005;

  infile source missover dsd dlm='09'x;

  length ward $ 1 address st_address $ 80;
  
  input ward address;
  
  i = index( address, "Washington" );
  
  if i > 0 then
    st_address = substr( address, 1, i - 1 );
  else do;
    %err_put( msg="Address problem: " address= );
  end;
  
  drop i;
    
run;  

*proc print;

run;

rsubmit;

proc upload status=no
  data=Caab_IDAs_2005 
  out=Caab_IDAs_2005;

run;

%DC_geocode(
  data=Caab_IDAs_2005,
  out=Caab_IDAs_2005_geo,
  staddr=st_address,
  id=ward,
  ds_label=,
  listunmatched=Y
)

run;

proc download status=no
  data=Caab_IDAs_2005_geo 
  out=Caab_IDAs_2005_geo;

run;

endrsubmit;

data Requests.Caab_IDAs_2005_geo (label="Geocoded IDA addresses for CAAB, 2005");

  set Caab_IDAs_2005_geo;
  
  length isn2004 $ 1;
  
  if geo2000 ~= "" then   
    isn2004 = put( geo2000, $Tr0is4f. );
    
  label
    isn2004 = "Issue Scan neighborhoods (2004)";
    
run;

proc print data=Requests.Caab_IDAs_2005_geo;
  var ward address isn2004 geo2000;
  
run;

signoff;
