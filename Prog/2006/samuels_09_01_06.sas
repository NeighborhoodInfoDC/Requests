/**************************************************************************
 Program:  samuels_09_01_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/01/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from R. Samuels of the Washington
 Post, 9/1/06.  Total population by race by Police
 District for article on youth curfew.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )

rsubmit;

data Census_2000;

  set Ncdb.Ncdb_lf_2000_dc 
    (keep=geo2000 shr0d shrnhb0n shrnhw0n shrhsp0n shrnha0n shrnhi0n shrnho0n);

run;

** Create data for PSAs **;

%Transform_geo_data(
    dat_ds_name=Census_2000,
    dat_org_geo=geo2000,
    dat_count_vars=shr:,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_tr00_psa04,
    wgt_org_geo=geo2000,
    wgt_new_geo=psa2004,
    wgt_id_vars=poldist2004,
    wgt_wgt_var=popwt,
    out_ds_name=Census_2000_psa04,
    out_ds_label=,
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=N,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

proc download status=no
  data=Census_2000_psa04 
  out=Census_2000_psa04;

run;

endrsubmit;

** Summarize for Police districts **;

%fdate()

options nodate nonumber;

ods rtf file="D:\DCData\Libraries\Requests\Prog\Samuels_09_01_06.rtf" style=Rtf_arial_9pt;

proc tabulate data=Census_2000_psa04 format=comma9.0 noseps missing;
  class poldist2004;
  var shr0d shrnhb0n shrnhw0n shrhsp0n shrnha0n shrnhi0n shrnho0n;
  table
    all='Washington, DC' poldist2004='Police Districts',
    sum='Number of persons by race/ethnicity, 2000' * 
      ( shr0d='Total' shrnhb0n='Non-Hisp. Black' shrnhw0n='N.H. White' 
        shrhsp0n='Hispanic' shrnha0n='N.H. Asian/Pacific Islander' 
        shrnhi0n='N.H. Am. Indian' shrnho0n='N.H. Other' );
  footnote1 "Source:  Census 2000 data (SF1) tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org)";
  footnote2 "Created &fdate.";

run;

ods rtf close;
  
signoff;

