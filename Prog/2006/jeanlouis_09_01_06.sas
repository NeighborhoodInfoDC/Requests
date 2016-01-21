/**************************************************************************
 Program:  jeanlouis_09_01_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/01/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Magda Jeanlouis of the Washington
 Post, 9/1/06.  Total population 0-16 and 17+ years old by Police
 District for article on youth curfew.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Census )

rsubmit;

** Get Census 2000 tract data on population by age **;

data Census_2000;

  set Census.Cen2000_sf1_dc_ph 
    (keep=sumlev geo2000 p12i1 p14i:
     where=(sumlev="140"));

  pop_0_16 = sum( of p14i3-p14i19, of p14i24-p14i40 );
  pop_17_plus = p12i1 - pop_0_16;
  
  drop p14i: ;
  
  rename p12i1=pop_total;

run;

** Create data for PSAs **;

%Transform_geo_data(
    dat_ds_name=Census_2000,
    dat_org_geo=geo2000,
    dat_count_vars=pop_:,
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

ods rtf file="D:\DCData\Libraries\Requests\Prog\Jeanlouis_09_01_06.rtf" style=Rtf_arial_9pt;

proc tabulate data=Census_2000_psa04 format=comma16.0 noseps missing;
  class poldist2004;
  var pop_total pop_0_16 pop_17_plus;
  table
    all='Washington, DC' poldist2004='Police Districts',
    sum='Number of persons, 2000' * 
      ( pop_total='Total' pop_0_16='0-16 years old' pop_17_plus='17+ years old' );
  footnote "Source:  Census 2000 data (SF1) tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate";

run;

ods rtf close;
  
signoff;

