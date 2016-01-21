/**************************************************************************
 Program:  FMF_mapping.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/27/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create mapping file for FMF data request.

 Modifications:
  05/01/06 PT  Added extra NCDB variables.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Casey )
%DCData_lib( NCDB )

** Get extra NCDB data **;

rsubmit;

data Ncdb;

  set Ncdb.Ncdb_lf_2000_dc
    (keep=geo2000 vacrt0 vacfs0 rntocc0
          shrnhr0 shrnhh0 shrnhb0 shrnhi0 shrnho0 shrnhw0 shrhsp0 );
          
run;

proc download status=no
  data=Ncdb 
  out=Ncdb;

run;

endrsubmit;

** Merge tract data from Casey closing the gap analysis, NCDB **;

data Fmf_mapping (compress=no);

  merge 
    Casey.gap_analysis
    Casey.Sales_sum_geo2000
    Ncdb;
  by geo2000;
  
  where geo2000 ~= "11001999999";
  
  array num{*} _numeric_;
  
  do i = 1 to dim( num );
    if num{i} = . then num{i} = 0;
    else if num{i} = .i then num{i} = -999;
  end;
  
  drop i;
  
  format _all_ ;
  informat _all_ ;

run;

proc contents data=Fmf_mapping;

run;

filename fexport "D:\DCData\Libraries\Requests\Raw\FMF_mapping.csv" lrecl=5000;

proc export data=Fmf_mapping
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

/*

libname dbmsdbf dbdbf "D:\DCData\Libraries\Requests\Raw" ver=4 width=12 dec=2
  map=FMF_mapping;

data dbmsdbf.map;

  set Fmf_mapping;
  
run;


