/**************************************************************************
 Program:  Watson_08_16_05.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/19/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Create ward-level summary file with 1990 & 2000 NCDB,
 persons under supervision.
 
 Request from Keith Watson, Kairos Management, for the DC State
 Education Agency.  (Email 8/16/05)

 Modifications:
  10/05/05  Added disability, TANF, Food Stamps, income, earnings, 
            poverty status.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Reentry )
%DCData_lib( NCDB )
%DCData_lib( General )
%DCData_lib( Fairhsng )
%DCData_lib( Tanf )

** Variable lists **;

%let ncdb_2000 = 

  /* Population by age */
  trctpop0 
  FEM40 FEM90 FEM140 FEM190 FEM240 FEM290 FEM340 FEM440 FEM540
  FEM640 FEM740 FEM750
  MEN40 MEN90 MEN140 MEN190 MEN240 MEN290 MEN340 MEN440 MEN540
  MEN640 MEN740 MEN750

  /* Education */
  EDUC80 EDUC110 EDUC120 EDUC150 EDUCA0 EDUC160 EDUCPP0 hsdrop0n hsdrop0d

  /* Race */
  SHRWHT0N SHRBLK0N SHRAMI0N SHRAPI0N SHROTH0N

  /* Speak English not well/at all */
  SPNENY0N ASNENY0N OTNENY0N SPNENO0N ASNENO0N OTNENO0N
  SPNENE0N ASNENE0N OTNENE0N

  /* Lived abroad & foreign born */
  NOCITY0 NATBORN0 OUTBORN0 FORBORN0 

  /* Weeks worked */
  MNOPRT0N MNOPRT0D MNPRTB0D FNOPRT0N FNOPRT0D FNPRTB0D
  MNOWORK0 FNOWORK0 MNOPRT0A MNPRTC0D MNOFLT0D MNTWRK0D
  FNOPRT0A FNPRTC0D FNOFLT0D FNTWRK0D

  /* Occupations */
  OCC10 OCC20 OCC30 OCC40 OCC50 OCC60 OCC70 OCC80 OCC90

  /* Labor force */
  UNEMPT0N UNEMPT0D
  
  /* Family types */
  MCWKID0 MCNKID0 MHWKID0 MHNKID0 FHWKID0 FHNKID0 NONFAM0
  
  /* Income */
  AVHHIN0N NUMHHS0 
  AVEMER0N AVEMER0D AVSEME0N AVSEME0D
  AVGERN0N AVGERN0D
  POVRAT0N POVRAT0D
  ;

%let ncdb_1990 = 

  /* Population by age */
  trctpop9 
  FEM49 FEM99 FEM149 FEM199 FEM249 FEM299 FEM349 FEM449 FEM549
  FEM649 FEM749 FEM759
  MEN49 MEN99 MEN149 MEN199 MEN249 MEN299 MEN349 MEN449 MEN549
  MEN649 MEN749 MEN759
  
  /* Education */
  EDUC89 EDUC119 EDUC129 EDUC159 EDUCA9 EDUC169 EDUCPP9 hsdrop9n hsdrop9d

  /* Race */
  SHRWHT9N SHRBLK9N SHRAMI9N SHRAPI9N SHROTH9N

  /* Speak English not well/at all */
  SPNENY9N ASNENY9N OTNENY9N SPNENO9N ASNENO9N OTNENO9N
  SPNENE9N ASNENE9N OTNENE9N

  /* Lived abroad & foreign born */
  NOCITY9 NATBORN9 OUTBORN9 FORBORN9 

  /* Weeks worked */
  MNOPRT9N MNOPRT9D MNPRTB9D FNOPRT9N FNOPRT9D FNPRTB9D
  MNOWORK9 FNOWORK9 MNOPRT9A MNPRTC9D MNOFLT9D MNTWRK9D
  FNOPRT9A FNPRTC9D FNOFLT9D FNTWRK9D

  /* Occupations */
  OCC19 OCC29 OCC39 OCC49 OCC59 OCC69 OCC79 OCC89 OCC99

  /* Labor force */
  UNEMPT9N UNEMPT9D

  /* Family types */
  MCWKID9 MCNKID9 MHWKID9 MHNKID9 FHWKID9 FHNKID9 NONFAM9

  /* Income */
  AVHHIN9N NUMHHS9 
  AVEMER9N AVEMER9D AVSEME9N AVSEME9D
  AVGERN9N AVGERN9D
  POVRAT9N POVRAT9D
;

%syslput ncdb_2000=&ncdb_2000;
%syslput ncdb_1990=&ncdb_1990;

** Download NCDB data **;

*OPTIONS OBS=0;

rsubmit;

*OPTIONS OBS=0;

** TANF & Food Stamps **;

/** Macro Annualize_tanf_fs - Start Definition **/

%macro Annualize_tanf_fs( start_yr, end_yr );

  data Tanf_fs_clients;
  
    set
      %do y = &start_yr %to &end_yr;
        Tanf.Tanf_&y._07 (in=in_tanf_pers_&y)
        Tanf.Fs_&y._07   (in=in_fs_pers_&y)
      %end;
      ;

    %do y = &start_yr %to &end_yr;
      tanf_pers_&y = in_tanf_pers_&y;
      fs_pers_&y = in_fs_pers_&y;
      label
        tanf_pers_&y = "Persons receiving TANF, &y"
        fs_pers_&y = "Persons receiving Food Stamps, &y";
    %end;

  run;
  
%mend Annualize_tanf_fs;

/** End Macro Definition **/

%Annualize_tanf_fs( 2000, 2005 )

proc summary data=Tanf_fs_clients nway;
  var tanf_pers_: fs_pers_: ;
  class geo1980;
  output out=Tanf_fs_tr80 sum= ;

%Transform_geo_data(
    dat_ds_name=Tanf_fs_tr80,
    dat_org_geo=geo1980,
    dat_count_vars=tanf_pers_: fs_pers_:,
    dat_prop_vars=,
    wgt_ds_name=Ncdb.twt80_00_dc,
    wgt_org_geo=geo1980,
    wgt_new_geo=geo2000,
    wgt_id_vars=,
    wgt_wgt_var=weight,
    out_ds_name=Tanf_fs_tr00,
    out_ds_label=,
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=Y,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

proc download status=no
  data=Tanf_fs_tr00 
  out=Tanf_fs_tr00;

run;

data Ncdb_req;

  merge
    Ncdb.Ncdb_lf_2000_dc
      (keep=geo2000 &ncdb_2000)
    Ncdb.Ncdb_1990_2000_dc
      (keep=geo2000 &ncdb_1990
       rename=(OTNENO9N=OTNENO9N_c));
  by geo2000;
  
  OTNENO9N = 1 * OTNENO9N_c;
  
  label OTNENO9N = "Persons 18-64 years old who speak other language and speak English not well or not at all, 1990";
  
  drop OTNENO9N_c;
      
run;

proc download status=no
  data=Ncdb_req 
  out=Ncdb_req;

run;

endrsubmit;

** Get persons under supervision data **;
/*** REMOVED DBMS/ENGINES CODE ****
libname dbmsdbf dbdbf "D:\DCData\Libraries\Reentry\Raw" ver=4 width=12 dec=2;

proc sort data=dbmsdbf.numprsa (keep=geo2000 persup) out=numprsa;
  by geo2000;
  
run;
*********************************/

proc sort data=Reentry.numprsa (keep=geo2000 persup) out=numprsa;
  by geo2000;
  
run;

** Merge together tract data **;

data watson_tr;

  merge 
    Ncdb_req 
    Tanf_fs_tr00
    Fairhsng.Census_disb (keep=geo2000 disb_work pct026001)
    numprsa;
  by geo2000;
  
  nodisb_work = pct026001 - disb_work;
  
  label 
    persup = 'Persons on parole supervision or other supervised release (excluding probation), 2004'
    nodisb_work = 'Civilian noninstitutionalized persons 16+ years without go-outside-home or employment disability';
  
  format _all_;
  informat _all_;
  
  drop pct026001;

run;

** Convert to ward totals **;

%Transform_geo_data(
    dat_ds_name=watson_tr,
    dat_org_geo=geo2000,
    dat_count_vars=&ncdb_1990 &ncdb_2000 persup disb_work nodisb_work tanf_pers_: fs_pers_:,
    dat_prop_vars=,
    wgt_ds_name=General.wt_tr00_ward02,
    wgt_org_geo=geo2000,
    wgt_new_geo=ward2002,
    wgt_id_vars=,
    wgt_wgt_var=popwt,
    out_ds_name=Requests.Watson_08_16_05,
    out_ds_label=Ward level data for Keith Watson request 8/16/05,
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=N,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )


%File_info( data=Requests.Watson_08_16_05 )

run;

** Create dbf file **;

/*** REMOVED DBMS/ENGINES CODE ****
libname dbmsdbf2 dbdbf "D:\DCData\Libraries\Requests\Data" ver=4 width=12 dec=2
  watson=Watson_08_16_05;

data dbmsdbf2.Watson;

  set Requests.Watson_08_16_05;

run;
**********************************/

filename fexport "D:\DCData\Libraries\Requests\Raw\Watson_08_16_05.csv" lrecl=5000;

proc export data=Requests.Watson_08_16_05
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

signoff;
