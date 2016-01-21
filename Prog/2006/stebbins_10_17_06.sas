/**************************************************************************
 Program:  stebbins_10_17_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/01/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request from Helene Stebbins 10/17/06.  DC population under 3, 3-17, 
  and under 18 by zipcode.
 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Census )

rsubmit;

** Get Census 2000 tract data on population by age **;

data stebbins_10_17_06_tr00;

  set Census.Cen2000_sf1_dc_ph 
    (keep=sumlev geo2000 p12i1 p14i:
     where=(sumlev="140"));

  pop_0_2 = sum( of p14i3-p14i5, of p14i24-p14i26 );
  pop_3_17 = sum ( of p14i6-p14i20, of p14i27-p14i41 );
  pop_0_17 = sum( of p14i3-p14i20, of p14i24-p14i41);

  drop p14i: ;
  
  rename p12i1=pop_total;

run;
endrsubmit;

rsubmit;
** Create data for Zip Code**;

%Transform_geo_data(
    dat_ds_name=stebbins_10_17_06_tr00,
    dat_org_geo=geo2000,
    dat_count_vars=pop_:,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_tr00_zip,
    wgt_org_geo=geo2000,
    wgt_new_geo=zip,
    wgt_wgt_var=popwt,
    out_ds_name=stebbins_10_17_06_zip,
    out_ds_label=,
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=N,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

proc download status=no
  data=stebbins_10_17_06_zip 
  out=requests.stebbins_10_17_06_zip;
proc download status=no
  data=stebbins_10_17_06_tr00 
  out=requests.stebbins_10_17_06_tr00;

run;

endrsubmit;

** Summarize for Zip Codes **;

%fdate()

options nodate nonumber;

ods rtf file="D:\DCData\Libraries\Requests\Prog\stebbins_10_17_06.rtf" style=Rtf_arial_9pt;

proc tabulate data=requests.stebbins_10_17_06_zip format=comma16.0 noseps missing;
  class zip;
  var pop_total pop_0_2 pop_3_17 pop_0_17;
  table
    all='Washington, DC' zip=' ',
    sum='Number of persons, 2000' * 
      ( pop_total='Total' pop_0_17='Under 18' pop_0_2='Under 3' pop_3_17='3 to 17' );
   title2 " ";
   title3 "Population by Age and by Zip Code, Washington, DC, 2000";
   footnote height=9pt "Source:  Census 2000 data (SF1) tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate";

run;

ods rtf close;
  
signoff;

