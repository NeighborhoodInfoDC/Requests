/**************************************************************************
 Program:  Summit_teen_births_3yr_cltr00.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/14/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create data set for mapping teen births by cluster for
 Summit Fund presentation, 3/15.
 
 USE 3 YEAR AVERAGE DATA FOR BIRTHS.

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

/** Macro Mean3y - Start Definition **/

%macro Mean3y( var=, new=, year= );

  %local y1 y2 y3;

  %if &new = %then %let new = &var;
  
  %let y1 = %eval( &year - 1 );
  %let y2 = &year;
  %let y3 = %eval( &year + 1 );
  
  &new._&y2._3y = mean( &var._&y1, &var._&y2, &var._&y3 );

%mend Mean3y;

/** End Macro Definition **/



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

  array birth_rate{1998:2011} brate_15to19_1998-brate_15to19_2011;
  array births{1998:2011} births_15to19_1998-births_15to19_2011;
  
  do i = 1998 to 2011;
  
    if Pop{i} > 0 then birth_rate{i} = 1000 * births{i} / Pop{i};
    
  end;
  
  ** 3 Year averages **;
  
  %Mean3y( var=births_15to19, year=1999 )
  %Mean3y( var=births_15to19, year=2010 )

  %Mean3y( var=brate_15to19, year=1999 )
  %Mean3y( var=brate_15to19, year=2010 )

  %Mean3y( var=births_total, year=1999 )
  %Mean3y( var=births_total, year=2010 )

  %Mean3y( var=pop_15to19_f, year=1999 )
  %Mean3y( var=pop_15to19_f, year=2010 )

  /*
  births_15to19_1999_3y = mean( births_15to19_1998, births_15to19_1999, births_15to19_2000 );
  births_total_1999_3y = mean( births_total_1998, births_total_1999, births_total_2000 );
  */
  
  Chg_births_15to19_99_10_3y = Births_15to19_2010_3y - Births_15to19_1999_3y;
  Chg_brate_15to19_99_10_3y = brate_15to19_2010_3y - brate_15to19_1999_3y;
  Chg_births_total_99_10_3y = Births_total_2010_3y - Births_total_1999_3y;
  Chg_pop_15to19_f_99_10_3y = Pop_15to19_f_2010_3y - Pop_15to19_f_1999_3y;
    
  drop i;
  
run;

proc rank data=A out=B descending ties=low;
  where cluster_tr2000 ~= '99';
  var brate_15to19_1999_3y brate_15to19_2010_3y 
      Chg_births_15to19_99_10_3y Chg_brate_15to19_99_10_3y;
  ranks brate_15to19_1999_3y_rank brate_15to19_2010_3y_rank
        Chg_births_15to19_99_10_3y_rank Chg_brate_15to19_99_10_3y_rank;
run;

data Requests.Summit_teen_births_3yr_cltr00;

  set B;
  
  Chg_rank_brate_15to19_99_10_3y = brate_15to19_2010_3y_rank - brate_15to19_1999_3y_rank;
  
  keep Cluster_tr2000 
    Chg_brate_15to19_99_10_3y_rank Chg_births_15to19_99_10_3y
    Chg_births_15to19_99_10_3y_rank Chg_births_total_99_10_3y
    Chg_brate_15to19_99_10_3y Chg_pop_15to19_f_99_10_3y
    Chg_rank_brate_15to19_99_10_3y births_15to19_1999_3y
    births_15to19_2010_3y births_total_1999_3y
    births_total_2010_3y brate_15to19_1999_3y
    brate_15to19_1999_3y_rank brate_15to19_2010_3y
    brate_15to19_2010_3y_rank pop_15to19_f_1999_3y
    pop_15to19_f_2010_3y;

run;

%File_info( data=Requests.Summit_teen_births_3yr_cltr00 )

proc univariate data=Requests.Summit_teen_births_3yr_cltr00 plot;
  where cluster_tr2000 ~= '99';
  id cluster_tr2000;
  var Chg_: births_15to19_1999_3y births_15to19_2010_3y brate_15to19_1999_3y brate_15to19_2010_3y; 
run;

proc corr data=Requests.Summit_teen_births_3yr_cltr00;
  where cluster_tr2000 ~= '99';
  var Chg_: brate_15to19_1999_3y;
run;

proc plot data=Requests.Summit_teen_births_3yr_cltr00;
  where cluster_tr2000 ~= '99';
  plot Chg_brate_15to19_99_10_3y * brate_15to19_1999_3y;
  plot Chg_births_total_99_10_3y * brate_15to19_1999_3y;
run;

/*
proc univariate data=Requests.Summit_teen_births_rank_cltr00 plot;
  id cluster_tr2000;
  var Chg_birth_rt_15to19_98_11_rank;
run;

proc plot data=Requests.Summit_teen_births_rank_cltr00;
  plot brate_15to19_1998_rank * brate_15to19_2011_rank;
run;
*/


** Summary tables **;

ods listing close;

ods tagsets.excelxp file="L:\Libraries\Requests\Prog\2015\Summit_Teen_births_3yr_cltr00.xls" style=Printer options(sheet_interval='Proc' );

proc print data=Requests.Summit_teen_births_3yr_cltr00 label;
  id cluster_tr2000;
  var
    pop_15to19_f_1999_3y
    pop_15to19_f_2010_3y
    Chg_pop_15to19_f_99_10_3y
    births_15to19_1999_3y
    births_15to19_2010_3y
    Chg_births_15to19_99_10_3y
    brate_15to19_1999_3y
    brate_15to19_2010_3y
    Chg_brate_15to19_99_10_3y
    births_total_1999_3y
    births_total_2010_3y
    Chg_births_total_99_10_3y
    brate_15to19_1999_3y_rank
    brate_15to19_2010_3y_rank
    Chg_brate_15to19_99_10_3y_rank
    Chg_rank_brate_15to19_99_10_3y
    Chg_births_15to19_99_10_3y_rank;
  label
    pop_15to19_f_1999_3y = "Females 15-19, 1999"
    pop_15to19_f_2010_3y = "Females 15-19, 2010"
    Chg_pop_15to19_f_99_10_3y = "Change females 15-19"
    births_15to19_1999_3y = "Births 15-19, 1999"
    births_15to19_2010_3y = "Births 15-19, 2010"
    Chg_births_15to19_99_10_3y = "Change births 15-19"
    births_total_1999_3y = "Births, 1999"
    births_total_2010_3y = "Births, 2010"
    Chg_births_total_99_10_3y = "Change births"
    brate_15to19_1999_3y = "Birth rate 15-19, 1999"
    brate_15to19_2010_3y = "Birth rate 15-19, 2010"
    Chg_brate_15to19_99_10_3y "Change birth rate 15-19"
    brate_15to19_1999_3y_rank = "Birth rate 15-19 rank, 1999"
    brate_15to19_2010_3y_rank = "Birth rate 15-19 rank, 2010"
    Chg_brate_15to19_99_10_3y_rank = "Change birth rate 15-19 rank"
    Chg_rank_brate_15to19_99_10_3y = "Change in rank of birth rate 15-19"
    Chg_births_15to19_99_10_3y_rank = "Change births 15-19 rank";
  format cluster_tr2000 $clus00f. _numeric_ comma10.0;
run;

ods tagsets.excelxp close;

ods listing;


filename fexport "&_dcdata_r_path\Requests\Raw\2015\Summit_teen_births_3yr_cltr00.csv" lrecl=2000;

proc export data=Requests.Summit_teen_births_3yr_cltr00
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

