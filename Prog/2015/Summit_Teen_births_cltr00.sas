/**************************************************************************
 Program:  Summit_teen_births_cltr00.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/14/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create data set for mapping teen births by cluster for
 Summit Fund presentation, 3/15.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Census, local=n )
%DCData_lib( Vital, local=n )

** Get female population 15-19 from 2000 and 2010 census data **;

** 2000 **;

proc summary data=Census.Cen2000_sf1_dc_ph (where=(sumlev='140'));
  by geo2000;
  var p12i30 p12i31;
  output out=Cen_2000_tr00 sum=;
run;

%Transform_geo_data(
    dat_ds_name=Cen_2000_tr00,
    dat_org_geo=geo2000,
    dat_count_vars=p12i30 p12i31,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_tr00_cltr00,
    wgt_org_geo=geo2000,
    wgt_new_geo=cluster_tr2000,
    wgt_id_vars=,
    wgt_wgt_var=popwt,
    out_ds_name=Cen_2000_cltr00,
    out_ds_label=,
    calc_vars=
      Pop_15to19_f_2000 = p12i30 + p12i31;
      ,
    calc_vars_labels=
      Pop_15to19_f_2000 = "Females 15 to 19 years old, 2000"
      ,
    keep_nonmatch=Y,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

/**%File_info( data=Cen_2000_cltr00, printobs=40 )**/

** 2010 **;

proc summary data=Census.Census_sf1_2010_dc_ph (where=(sumlev='140'));
  by geo2010;
  var p12i30 p12i31;
  output out=Cen_2010_tr10 sum=;
run;

%Transform_geo_data(
    dat_ds_name=Cen_2010_tr10,
    dat_org_geo=geo2010,
    dat_count_vars=p12i30 p12i31,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_tr10_cltr00,
    wgt_org_geo=geo2010,
    wgt_new_geo=cluster_tr2000,
    wgt_id_vars=,
    wgt_wgt_var=popwt,
    out_ds_name=Cen_2010_cltr00,
    out_ds_label=,
    calc_vars=
      Pop_15to19_f_2010 = p12i30 + p12i31;
      ,
    calc_vars_labels=
      Pop_15to19_f_2010 = "Females 15 to 19 years old, 2010"
      ,
    keep_nonmatch=Y,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

/***%File_info( data=Cen_2010_cltr00, printobs=40 )***/


** Combine birth and census data **;

data A;

  merge
    Vital.Births_sum_cltr00 
        (keep=cluster_tr2000 births_15to19_1998-births_15to19_2011 births_w_age_1998-births_w_age_2011
              births_total_1998-births_total_2011)
    Cen_2000_cltr00 (keep=cluster_tr2000 Pop_: )
    Cen_2010_cltr00 (keep=cluster_tr2000 Pop_: )
    ;
  by cluster_tr2000;

  ** Interpolate populations **;
  
  array Pop{1998:2011} Pop_15to19_f_1998-Pop_15to19_f_2011;
  
  do i = 1998 to 2011;
  
    if i <= 2000 then 
      Pop{i} = Pop{2000};
    else if 2000 < i < 2010 then 
      Pop{i} = Pop{2000} + ( ( Pop{2010} - Pop{2000} ) * ( ( i - 2000 ) / ( 2010 - 2000 ) ) );
    else if i >= 2010 then 
      Pop{i} = Pop{2010};
  
  end;

  array birth_rate{1998:2011} birth_rate_15to19_1998-birth_rate_15to19_2011;
  array births{1998:2011} births_15to19_1998-births_15to19_2011;
  
  do i = 1998 to 2011;
  
    if Pop{i} > 0 then birth_rate{i} = 1000 * births{i} / Pop{i};
    
  end;
  
  Chg_births_15to19_1998_2011 = Births_15to19_2011 - Births_15to19_1998;
  Chg_birth_rate_15to19_1998_2011 = Birth_rate_15to19_2011 - Birth_rate_15to19_1998;
  Chg_births_total_1998_2011 = Births_total_2011 - Births_total_1998;
  Chg_pop_15to19_f_1998_2011 = Pop_15to19_f_2011 - Pop_15to19_f_1998;
    
  drop i;
  
run;

proc rank data=A out=B descending ties=low;
  where cluster_tr2000 ~= '99';
  var Birth_rate_15to19_1998 Birth_rate_15to19_2011 
      Chg_births_15to19_1998_2011 Chg_birth_rate_15to19_1998_2011;
  ranks Birth_rate_15to19_1998_rank Birth_rate_15to19_2011_rank
        Chg_births_15to19_1998_2011_rank Chg_b_rt_15to19_1998_2011_rank;
run;

data Requests.Summit_teen_births_cltr00;

  set B;
  
  Chg_rank_birth_rt_15to19_98_11 = Birth_rate_15to19_2011_rank - Birth_rate_15to19_1998_rank;
  
  format 
    births_15to19_1998-births_15to19_2011 births_w_age_1998-births_w_age_2011 
    Pop_15to19_f_1998-Pop_15to19_f_2011 
    Chg_births_15to19_1998_2011 Chg_births_total_1998_2011 Chg_pop_15to19_f_1998_2011 8.0
    birth_rate_15to19_1998-birth_rate_15to19_2011
    Chg_birth_rate_15to19_1998_2011 8.1;
      
run;

%File_info( data=Requests.Summit_teen_births_cltr00 )

proc univariate data=Requests.Summit_teen_births_cltr00 plot;
  where cluster_tr2000 ~= '99';
  id cluster_tr2000;
  var Chg_: births_15to19_1998 births_15to19_2011 birth_rate_15to19_1998 birth_rate_15to19_2011; 
run;

proc corr data=Requests.Summit_teen_births_cltr00;
  where cluster_tr2000 ~= '99';
  var Chg_: Birth_rate_15to19_1998;
run;

proc plot data=Requests.Summit_teen_births_cltr00;
  where cluster_tr2000 ~= '99';
  plot Chg_birth_rate_15to19_1998_2011 * Birth_rate_15to19_1998;
  plot Chg_births_total_1998_2011 * Birth_rate_15to19_1998;
run;

/*
proc univariate data=Requests.Summit_teen_births_rank_cltr00 plot;
  id cluster_tr2000;
  var Chg_birth_rt_15to19_98_11_rank;
run;

proc plot data=Requests.Summit_teen_births_rank_cltr00;
  plot Birth_rate_15to19_1998_rank * Birth_rate_15to19_2011_rank;
run;
*/

filename fexport "&_dcdata_r_path\Requests\Raw\2015\Summit_teen_births_cltr00.csv" lrecl=2000;

proc export data=Requests.Summit_teen_births_cltr00
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

