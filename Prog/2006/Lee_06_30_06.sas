/**************************************************************************
 Program:  Lee_06_30_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/30/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Tabulate TANF data for Irene Lee, AECF.  Two
 indicators:
 
 # TANF HHs w/three children
 # TANF recipients east of the river

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( TANF )
%DCData_lib( Ncdb )
%DCData_lib( General )

rsubmit;

proc summary data=Tanf.Tanf_2006_01 nway;
  class uicaseid;
  id geo1980;
  var child;
  output out=Tanf_hhs (rename=(_freq_=persons)) sum=;

run;

proc freq data=Tanf_hhs;
  tables child;

run;

data Tanf_hhs_2;

  set Tanf_hhs;
  
  if child >= 3 then child3 = 1;
  else child3 = 0;
  
  cases = 1;
  
run;

proc summary data=Tanf_hhs_2 nway;
  class geo1980;
  var child3 cases;
  output out=Tanf_tr80 sum=;
run;

%Transform_geo_data(
    dat_ds_name=Tanf_tr80,
    dat_org_geo=geo1980,
    dat_count_vars=child3 cases,
    dat_prop_vars=,
    wgt_ds_name=Ncdb.TWT80_00_DC,
    wgt_org_geo=geo1980,
    wgt_new_geo=geo2000,
    wgt_id_vars=,
    wgt_wgt_var=weight,
    out_ds_name=Tanf_tr00,
    out_ds_label=,
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=Y,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

run;

proc download status=no
  data=Tanf_tr00 
  out=Tanf_tr00;

run;

endrsubmit;

data Tanf_tr00_2;

  set Tanf_tr00;
  
  eor = put( geo2000, $TR0EOR. );
  
run;

proc tabulate data=Tanf_tr00_2 format=comma12.0 noseps missing ;
  var child3 cases;
  class eor;
  tables all='Washington, D.C.' eor=' ',
    sum='TANF Cases' * ( cases='Total' child3='W/3+ children' );
  format eor $eor.;
  title4 'TANF Cases by Presence of Children, January 2006';
  footnote1 'Source:  DC Income Maintenance Administration TANF Case Records';
  footnote2 '         tabulated by Urban Institute/NeighborhoodInfo DC (6/30/06)';
    
run;  

signoff;

