/**************************************************************************
 Program:  DC_courts_05_02_13.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/11/13
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Compile data for DC Courts presentation, 5/2/13.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ACS )
%DCData_lib( NCDB )
%DCData_lib( Police )
%DCData_lib( Tanf )
%DCData_lib( Vital )

*options obs=0;

/** Macro Compile_data - Start Definition **/

%macro Compile_data( Geo );

%local Geo_suffix Geo_wtfile;

%if %upcase( &Geo ) = CITY %then %let Geo_suffix = _city;
%else %if %upcase( &Geo ) = WARD2012 %then %let Geo_suffix = _wd12;

%if %upcase( &Geo ) = CITY %then %let Geo_wtfile = Wt_tr00_city;
%else %if %upcase( &Geo ) = WARD2012 %then %let Geo_wtfile = Wt_tr00_ward12;

** Compile data **;

%Transform_geo_data(
    dat_ds_name=Ncdb.Ncdb_lf_2000_dc ,
    dat_org_geo=Geo2000,
    dat_count_vars=Occ10 Occ20 Occ30 Occ40 Occ50 Occ60 Occ70 Occ80 Occ90,
    dat_prop_vars=,
    wgt_ds_name=General.&Geo_wtfile,
    wgt_org_geo=Geo2000,
    wgt_new_geo=&Geo.,
    wgt_id_vars=,
    wgt_wgt_var=popwt,
    out_ds_name=Ncdb_occ_sum&Geo_suffix.,
    out_ds_label=,
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=Y,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

data Requests.Dc_courts_05_02_13&Geo_suffix.;

  merge
    Ncdb.Ncdb_sum&Geo_suffix.
      (keep=&Geo. 
aggfamilyincome_2000
childrenpovertydefined_2000
elderlypovertydefined_2000
numfamilies_2000
numhshldfemalesinparwkids_2000
numhshldmalesinparwkids_2000
numhshldmarriedcouplewkids_2000
numhshldnonfamily_2000
numhshldotherfamily_2000
numhighschooldropout_2000
numhshlds_2000
personspovertydefined_2000
pop16andoveremployed_2000
pop16to19unemploutofschool_2000
pop16to19years_2000
pop18to64poorenglishlang_2000
pop18to64years_2000
pop25andoverwcollege_2000
pop25andoverwhs_2000
pop25andoverwouths_2000
pop25andoveryears_2000
pop5to17years_2000
pop5to17poorenglishlang_2000
pop65andoverpoorenglishlang_2000
pop65andoveryears_2000
poppoorchildren_2000
poppoorelderly_2000
poppoorpersons_2000
popunemployed_2000
popincivlaborforce_2000
totpop_2000 
rename=(
numhshldfemalesinparwkids_2000=numhhfemalesinparwkids_2000
numhshldmalesinparwkids_2000=numhhmalesinparwkids_2000
numhshldmarriedcouplewkids_2000=numhhmarriedcouplewkids_2000
numhshldnonfamily_2000=numhhnonfamily_2000
numhshldotherfamily_2000=numhhotherfamily_2000
pop16to19unemploutofschool_2000=pop16to19unemploutofsch_2000
pop5to17poorenglishlang_2000=pop5to17poorenglish_2000
pop18to64poorenglishlang_2000=pop18to64poorenglish_2000
pop65andoverpoorenglishlang_2000=pop65andoverpoorenglish_2000
)
)
    Ncdb_occ_sum&Geo_suffix.
      (keep=&Geo. occ:
       rename=(
         Occ10=Occ1_2000
         Occ20=Occ2_2000
         Occ30=Occ3_2000
         Occ40=Occ4_2000
         Occ50=Occ5_2000
         Occ60=Occ6_2000
         Occ70=Occ7_2000
         Occ80=Occ8_2000
         Occ90=Occ9_2000
         )
       )
    Acs.Acs_2007_11_sum_tr&Geo_suffix. 
      (keep=&Geo. 
aggfamilyincome_2007_11
childrenpovertydefined_2007_11
elderlypovertydefined_2007_11
numfamilies_2007_11
numhhfemalesinparwkids_2007_11
numhhmalesinparwkids_2007_11
numhhmarriedcouplewkids_2007_11
numhhnonfamily_2007_11
numhhotherfamily_2007_11
numhighschooldropout_2007_11
numhshlds_2007_11
occ1_2007_11
occ2_2007_11
occ3_2007_11
occ4_2007_11
occ5_2007_11
occ6_2007_11
occ7_2007_11
occ8_2007_11
occ9_2007_11
personspovertydefined_2007_11
pop16andoveremployed_2007_11
pop16to19unemploutofsch_2007_11
pop16to19years_2007_11
pop18to64poorenglish_2007_11
pop18to64years_2007_11
pop25andoverwcollege_2007_11
pop25andoverwhs_2007_11
pop25andoverwouths_2007_11
pop25andoveryears_2007_11
pop5to17poorenglish_2007_11
pop5to17years_2007_11
pop65andoverpoorenglish_2007_11
pop65andoveryears_2007_11
poppoorchildren_2007_11
poppoorelderly_2007_11
poppoorpersons_2007_11
popunemployed_2007_11
popincivlaborforce_2007_11
totpop_2007_11
)
Police.Crimes_sum&Geo_suffix.
  (keep=&Geo. crimes_pt1_property_: crimes_pt1_violent_: crime_rate_pop_:)
Tanf.Fs_sum&Geo_suffix.
  (keep=&Geo. fs_client_2000-fs_client_2013)
Tanf.Tanf_sum&Geo_suffix.
  (keep=&Geo. tanf_client_2000-tanf_client_2013)
Vital.Births_sum&Geo_suffix.
  (keep=&Geo. 
        births_total_2002-births_total_2010 
        births_teen_2002-births_teen_2010 
        births_single_2002-births_single_2010
        births_w_mstat_2002-births_w_mstat_2010
        births_w_age_2002-births_w_age_2010
   )
;
by &Geo.;

** Calculated indicators **;

    %Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=2000 2007_11 )
    
    %dollar_convert( AvgFamilyIncome_2000, AvgFamilyIncAdj_2000, 1999, 2011 )
    
    AvgFamilyIncAdj_2007_11 = AvgFamilyIncome_2007_11;

run;

%File_info( data=Requests.Dc_courts_05_02_13&Geo_suffix., printobs=0 )

%mend Compile_data;

/** End Macro Definition **/

%Compile_data( City )

%Compile_data( Ward2012 )


