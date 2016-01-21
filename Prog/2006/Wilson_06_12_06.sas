/**************************************************************************
 Program:  Wilson_06_12_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/12/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Geocode DC HA properties to identify tracts, clusters.
 Request from Julian Wilson, DC Housing Authority, 6/12/06.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )
%DCData_lib( General )

filename infcsv "D:\DCData\Requests\2006\DCHA Housing Units Count and Managers Assignments.csv" lrecl=256;

data Wilson_06_12_06;

  infile infcsv dsd stopover;
  
  length development $ 80 dc_num $ 8 addr_stno $ 8 addr_st_zip $ 80
    addr_st $ 80 addr_zip $ 5;
  
  input 
    development dc_num addr_stno addr_st_zip;
    
  if development = "SCATTERED SITES" then delete;

  addr_st_zip = left( trim( addr_st_zip ) );

  addr_zip = reverse( substr( reverse( trim( addr_st_zip ) ) , 1, 5 ) );
  
  if addr_zip =: "20" then do;
    addr_st = compbl( addr_stno || substr( addr_st_zip, 1, length( addr_st_zip ) - 5 ) );
  end;
  else do;
    addr_zip = "";
    addr_st = compbl( addr_stno || addr_st_zip );
  end;
  
  keep development dc_num addr_st addr_zip;

run;

proc print;

rsubmit;

proc upload status=no
  data=Wilson_06_12_06 
  out=Wilson_06_12_06;
run;

%DC_geocode(
  data=Wilson_06_12_06,
  out=Wilson_06_12_06_geo,
  staddr=addr_st,
  zip=addr_zip,
  id=dc_num development,
  ds_label=,
  listunmatched=Y
)

proc download status=no
  data=Wilson_06_12_06_geo 
  out=Wilson_06_12_06_geo;
run;

endrsubmit;

filename fexport "D:\DCData\Requests\2006\Wilson_06_12_06.csv" lrecl=256;

data Wilson_06_12_06_geo;

  set Wilson_06_12_06_geo;
  
  format geo2000 $geo00a.;
  
  drop addr_st_std geoblk2000 zip_match cluster2000 dcg_num_parcels 
       x_coord y_coord ssl addr_st_match dcg_match_score;

run;

proc export data=Wilson_06_12_06_geo
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

signoff;
