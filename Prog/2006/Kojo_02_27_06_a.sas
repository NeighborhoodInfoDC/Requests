/**************************************************************************
 Program:  Kojo_02_27_06_a.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/27/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Prepare data for use on Kojo Namdi show.
 Neighborhood near All Souls Church (tracts 37 & 28.02).
 
 Part A - Compile and download data.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )
%DCData_lib( Hmda )
%DCData_lib( TANF )
%DCData_lib( NCDB )

rsubmit;

*options obs=0;
options compress=no;

** Format for aggregating tracts for neighborhood **;

proc format;
  value $nbrhd
   '11001003700' = '1'
   '11001002802' = '1'
    other = '9';

run; 

endrsubmit;

rsubmit;

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

run;

** Home mortgage data **;

/** Macro Annualize_hmda - Start Definition **/

%macro Annualize_hmda;

  %let vars = medianmrtginc nummrtgorigtotal nummrtgorigwithrace nummrtgorigblack
              NumSubprimeMrtgOrigHomePurch NumConvMrtgOrigHomePurch
              NumMrtgOrigHomePurch;

  %let start_yr = 1995;
  %let end_yr = 2003;

  %** Count variables in list **;
  
  %let num_vars = 0;
  %let i = 1;
  %let onev = %scan( &vars, &i );
  
  %do %while( &onev ~= );
  
    %let num_vars = %eval( &num_vars + 1 );
    
    %let i = %eval( &i + 1 );
    %let onev = %scan( &vars, &i );
  
  %end;
  
  data Hmda_tr00 (compress=no);
  
    merge
      %do y = &start_yr %to &end_yr;
        Hmda.Hmda_sum_&y._was (
          where=(geo2000=:'11')
          keep=geo2000 &vars
          rename=(
            %do i = 1 %to &num_vars;
              %let onev = %scan( &vars, &i );
              %if %length( &onev ) > 27 %then %do;
                &onev=%substr( &onev, 1, 27 )_&y
              %end;
              %else %do;
                &onev=&onev._&y
              %end;
            %end;
            )
          )
      %end;
      ;
    by geo2000;
      
  run;

%mend Annualize_hmda;

/** End Macro Definition **/

%Annualize_hmda

** Merge data files **;

data Tract_data (compress=no);

  merge
    Ncdb.Ncdb_lf_2000_dc
      (keep=geo2000 

            /* Family and Household Composition */
            trctpop0 child0n kids0n
            nkidmcf0 nkidmhh0 nkidfhh0
            mcwkid0 mcnkid0 mhwkid0 mhnkid0 fhwkid0 fhnkid0 nonfam0

            /* Employment and Educational Attainment */
            unempt0n unempt0d lfrat0d
            educ80 educ110 educ120 educ150 educa0 educ160 educpp0

            /* Housing, Home Ownership & Mortgages */
            occhu0 ownocc0

            /* Financial Assets and Services */
            avfiny0d welfar0d
       )

    Ncdb.Ncdb_1990_2000_dc
      (keep=geo2000 

            /* Family and Household Composition */
            trctpop9 child9n kids9n
            nkidmcf9 nkidmhh9 
            fhhlt39 fhh349 fhh59 fhh6119 fhh12139 fhh149 fhh15179
            mcwkid9 mcnkid9 mhwkid9 mhnkid9 fhwkid9 fhnkid9 nonfam9

            /* Employment and Educational Attainment */
            unempt9n unempt9d lfrat9d
            educ89 educ119 educ129 educ159 educa9 educ169 educpp9

            /* Housing, Home Ownership & Mortgages */
            occhu9 ownocc9

            /* Financial Assets and Services */
            avfiny9d welfar9d
       )
     
     Realprop.Num_units_tr00 
     Hmda_tr00
     Tanf_fs_tr00
     ;
     
     by geo2000;
     
     city = '1';
     
     shaw = put( geo2000, $nbrhd. );
     
run;

proc freq data=Tract_data;
  where shaw = '1';
  tables shaw * geo2000 / list;

run;

** Create summary files **;

%let tract_var_list = 

        /*** NCDB 2000 ***/
        /* Family and Household Composition */
        trctpop0 child0n kids0n
        nkidmcf0 nkidmhh0 nkidfhh0
        mcwkid0 mcnkid0 mhwkid0 mhnkid0 fhwkid0 fhnkid0 nonfam0

        /* Employment and Educational Attainment */
        unempt0n unempt0d lfrat0d
        educ80 educ110 educ120 educ150 educa0 educ160 educpp0

        /* Housing, Home Ownership & Mortgages */
        occhu0 ownocc0

        /* Financial Assets and Services */
        avfiny0d welfar0d
        
        /*** NCDB 1990 ***/
        /* Family and Household Composition */
        trctpop9 child9n kids9n
        nkidmcf9 nkidmhh9 
        mcwkid9 mcnkid9 mhwkid9 mhnkid9 fhwkid9 fhnkid9 nonfam9

        /* Employment and Educational Attainment */
        unempt9n unempt9d lfrat9d
        educ89 educ119 educ129 educ159 educa9 educ169 educpp9

        /* Housing, Home Ownership & Mortgages */
        occhu9 ownocc9

        /* Financial Assets and Services */
        avfiny9d welfar9d
        
        /**** TANF & Food Stamps ****/
        
        tanf_pers_: fs_pers_:
        
        /**** Home sales ****/

        units_total_2004
        
        /**** HMDA ****/
        
        nummrtgorigtotal_: nummrtgorigwithrace_: nummrtgorigblack_: NumSubprimeMrtgOrigHomePurc_: 
        NumConvMrtgOrigHomePurch_: NumMrtgOrigHomePurch_:
  ;
  
proc summary data=Tract_data;
  where city = '1';
  by city;
  var &tract_var_list medianmrtginc_: ;
  output out=Tract_data_city (compress=no) sum(&tract_var_list)= mean(medianmrtginc_:)=;
run;

proc summary data=Tract_data;
  where shaw = '1';
  by shaw;
  var &tract_var_list medianmrtginc_: ;
  output out=Tract_data_shaw (compress=no) sum(&tract_var_list)= mean(medianmrtginc_:)=;
run;

%file_info( data=Tract_data_city, printobs=0 )
%file_info( data=Tract_data_shaw, printobs=0 )

run;

endrsubmit;

** HOME SALES DATA **;

rsubmit;

** Add EOR, Casey neighborhood IDs **;

data Sales_obs (compress=no);

  set Realprop.Sales_res_clean_dc (keep=geo2000 ward2002 saledate_yr ui_proptype saleprice);

  where 1995 <= saledate_yr <= 2004 and ui_proptype in ( '1', '2' );
  
  city = '1';
  
  shaw = put( geo2000, $nbrhd. );

run;

** City summary **;
  
/** Macro Create_summary - Start Definition **/

%macro Create_summary( by, where );

proc summary data=Sales_obs nway;
  where &where;
  var saleprice;
  class &by saledate_yr;
  output out=sales_&by (compress=no)
    median(saleprice)=med_saleprice
    n=num_sales;

proc transpose data=Sales_&by out=med_saleprice_&by prefix=med_saleprice_;
  var med_saleprice;
  by &by;
  id saledate_yr;

**proc print data=med_saleprice_&by;

proc transpose data=Sales_&by out=num_sales_&by prefix=num_sales_;
  var num_sales;
  by &by;
  id saledate_yr;

**proc print data=num_sales_&by;

data Sales_sum_&by (label="Summary sales data, &where" compress=no);

  merge med_saleprice_&by (drop=_name_ _label_) num_sales_&by (drop=_name_ _label_);
  by &by;
  
  format med_saleprice_:  num_sales_: ;
    
run;

%File_info( data=Sales_sum_&by, printobs=0, freqvars=&by )

run;

%mend Create_summary;

/** End Macro Definition **/

%Create_summary( city, %str(city = '1') )
%Create_summary( shaw, %str(shaw = '1') )

run;

endrsubmit;

rsubmit;



**** Merge data together and create indicators ****;

data Kojo_city;

  merge
    Tract_data_city
    sales_sum_city;

run;

data Kojo_shaw;

  merge
    Tract_data_shaw
    sales_sum_shaw;

run;


data Kojo_all;

  set
    Kojo_shaw
    Kojo_city;
  
  ** Poverty and Income **;
  
  pct_tanf_pers_2000 = 100 * tanf_pers_2000 / trctpop0;
  pct_tanf_pers_2001 = 100 * tanf_pers_2001 / trctpop0;
  pct_tanf_pers_2002 = 100 * tanf_pers_2002 / trctpop0;
  pct_tanf_pers_2003 = 100 * tanf_pers_2003 / trctpop0;
  pct_tanf_pers_2004 = 100 * tanf_pers_2004 / trctpop0;
  pct_tanf_pers_2005 = 100 * tanf_pers_2005 / trctpop0;

  pct_fs_pers_2000 = 100 * fs_pers_2000 / trctpop0;
  pct_fs_pers_2001 = 100 * fs_pers_2001 / trctpop0;
  pct_fs_pers_2002 = 100 * fs_pers_2002 / trctpop0;
  pct_fs_pers_2003 = 100 * fs_pers_2003 / trctpop0;
  pct_fs_pers_2004 = 100 * fs_pers_2004 / trctpop0;
  pct_fs_pers_2005 = 100 * fs_pers_2005 / trctpop0;

  ** Housing, Home Ownership & Mortgages **;
  
  ownrt0 = 100 * ownocc0 / occhu0;
  ownrt9 = 100 * ownocc9 / occhu9;
  
  num_sales_p100_1995 = 100 * num_sales_1995 / units_total_2004;
  num_sales_p100_1996 = 100 * num_sales_1996 / units_total_2004;
  num_sales_p100_1997 = 100 * num_sales_1997 / units_total_2004;
  num_sales_p100_1998 = 100 * num_sales_1998 / units_total_2004;
  num_sales_p100_1999 = 100 * num_sales_1999 / units_total_2004;
  num_sales_p100_2000 = 100 * num_sales_2000 / units_total_2004;
  num_sales_p100_2001 = 100 * num_sales_2001 / units_total_2004;
  num_sales_p100_2002 = 100 * num_sales_2002 / units_total_2004;
  num_sales_p100_2003 = 100 * num_sales_2003 / units_total_2004;
  num_sales_p100_2004 = 100 * num_sales_2004 / units_total_2004;

  PctBlackLoans_1995 = 100 * NumMrtgOrigBlack_1995 / nummrtgorigwithrace_1995;
  PctBlackLoans_1996 = 100 * NumMrtgOrigBlack_1996 / nummrtgorigwithrace_1996;
  PctBlackLoans_1997 = 100 * NumMrtgOrigBlack_1997 / nummrtgorigwithrace_1997;
  PctBlackLoans_1998 = 100 * NumMrtgOrigBlack_1998 / nummrtgorigwithrace_1998;
  PctBlackLoans_1999 = 100 * NumMrtgOrigBlack_1999 / nummrtgorigwithrace_1999;
  PctBlackLoans_2000 = 100 * NumMrtgOrigBlack_2000 / nummrtgorigwithrace_2000;
  PctBlackLoans_2001 = 100 * NumMrtgOrigBlack_2001 / nummrtgorigwithrace_2001;
  PctBlackLoans_2002 = 100 * NumMrtgOrigBlack_2002 / nummrtgorigwithrace_2002;
  PctBlackLoans_2003 = 100 * NumMrtgOrigBlack_2003 / nummrtgorigwithrace_2003;

  PctInvestLoans_1995 = 100 * ( 1 - ( NumMrtgOrigTotal_1995 / NumMrtgOrigHomePurch_1995 ) );
  PctInvestLoans_1996 = 100 * ( 1 - ( NumMrtgOrigTotal_1996 / NumMrtgOrigHomePurch_1996 ) );
  PctInvestLoans_1997 = 100 * ( 1 - ( NumMrtgOrigTotal_1997 / NumMrtgOrigHomePurch_1997 ) );
  PctInvestLoans_1998 = 100 * ( 1 - ( NumMrtgOrigTotal_1998 / NumMrtgOrigHomePurch_1998 ) );
  PctInvestLoans_1999 = 100 * ( 1 - ( NumMrtgOrigTotal_1999 / NumMrtgOrigHomePurch_1999 ) );
  PctInvestLoans_2000 = 100 * ( 1 - ( NumMrtgOrigTotal_2000 / NumMrtgOrigHomePurch_2000 ) );
  PctInvestLoans_2001 = 100 * ( 1 - ( NumMrtgOrigTotal_2001 / NumMrtgOrigHomePurch_2001 ) );
  PctInvestLoans_2002 = 100 * ( 1 - ( NumMrtgOrigTotal_2002 / NumMrtgOrigHomePurch_2002 ) );
  PctInvestLoans_2003 = 100 * ( 1 - ( NumMrtgOrigTotal_2003 / NumMrtgOrigHomePurch_2003 ) );

  PctSubprime_1995 = 100 * NumSubprimeMrtgOrigHomePurc_1995 / NumConvMrtgOrigHomePurch_1995;
  PctSubprime_1996 = 100 * NumSubprimeMrtgOrigHomePurc_1996 / NumConvMrtgOrigHomePurch_1996;
  PctSubprime_1997 = 100 * NumSubprimeMrtgOrigHomePurc_1997 / NumConvMrtgOrigHomePurch_1997;
  PctSubprime_1998 = 100 * NumSubprimeMrtgOrigHomePurc_1998 / NumConvMrtgOrigHomePurch_1998;
  PctSubprime_1999 = 100 * NumSubprimeMrtgOrigHomePurc_1999 / NumConvMrtgOrigHomePurch_1999;
  PctSubprime_2000 = 100 * NumSubprimeMrtgOrigHomePurc_2000 / NumConvMrtgOrigHomePurch_2000;
  PctSubprime_2001 = 100 * NumSubprimeMrtgOrigHomePurc_2001 / NumConvMrtgOrigHomePurch_2001;
  PctSubprime_2002 = 100 * NumSubprimeMrtgOrigHomePurc_2002 / NumConvMrtgOrigHomePurch_2002;
  PctSubprime_2003 = 100 * NumSubprimeMrtgOrigHomePurc_2003 / NumConvMrtgOrigHomePurch_2003;
  
run;

run;

options compress=yes;

proc download status=no
  data=Kojo_all 
  out=Requests.Kojo_02_10_06;

run;

endrsubmit;

run;

%file_info( data=Requests.Kojo_02_10_06, printobs=0 )

run;

signoff;
