/**************************************************************************
 Program:  Voices_tables_Black_women.sas
 Library:  Voices
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/27/22
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create VoicesDMV survey tables.
 Special tabulations for Black women. 
 
 Program uses two internal macros:

 %Make_all_tables()
   Opens an output destination and creates an entire series of tables 
   for a single set of break columns (region, geo, race, etc.)
      
 %Make_one_table()
   Preps source data for table generation and produces a single
   output table.

 Modifications: 
 10/24/17 LH+PT Adjusted macros to accommodate different datasets.
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Voices )
%DCData_lib( Requests )

** Macros for table creation **;

/** Macro Make_one_table - Start Definition **/

%macro Make_one_table( where=(1), fmt=npercent., col=, colfmt=, total=y, var=, text=, text2=, vlabel=, data=Voices.Voices_2017_nonopen_recode, typefmt=$coltype_pct. );

  %local count rrden num_obs ref_rate;
  
  proc summary data=&data. nway;
    where &where;
    class &col;
    var &var;
    weight weight;
    output out=_Voices_means (drop=_type_ _freq_) mean=;
  run;

  proc summary data=&data. nway;
    where &where;
    class &col;
    var &var;
    output out=_Voices_se (drop=_type_ _freq_) stderr=;
  run;

  proc summary data=&data. nway;
    where &where;
    class &col;
    var &var;
    output out=_Voices_n (drop=_type_ _freq_) n=;
  run;
  
  data _Voices_rrden_a;
  
    set &data.;
    where &where;
    
    array a{*} &var;
    
    do i = 1 to dim( a );
      if a{i} = .n then a{i} = 0;
      else a{i} = 1;
    end;
    
    keep &col &var.;
    
  run;
  
  proc summary data=_Voices_rrden_a nway;
    class &col;
    var &var;
    output out=_Voices_rrden (drop=_type_ _freq_) sum=;
  run;  

  data _Voices_se_deff;

    merge _Voices_se deff_&col;
    by &col;
    
    array a{*} &var;
    
    do i = 1 to dim( a );
      a{i} = a{i} * deff*(1.645); *changed to 90% confidence interval;
    end;
    
    drop i;
    
  run;

  data _Voices_means_se;

    set 
      _Voices_means (in=is_mean) 
      _Voices_se_deff (in=is_deff) 
      _Voices_n (in=is_n) 
      _Voices_rrden;
    by &col;
    
    length coltype $ 8; 
    
    if is_mean then coltype = 'Mean';
    else if is_deff then coltype = 'CI'; *changed from SE;
    else if is_n then coltype = 'N';
    else coltype = 'RRDen';
    
  run;
    
  data _Voices_table_dat _Voices_table_count _Voices_table_rrden;
  
    set _Voices_means_se;
    
    length colfmtlbl $ 250;
    
    if coltype = 'Mean' then varsum = sum( of &var );
    
    if coltype = 'N' then do;
      count = min( of &var );
      colfmtlbl = trim( put( &col, &colfmt ) ) || ' \line (n=' || trim( left( put( count, comma8.0 ) ) ) || ')';
      output _Voices_table_count;
    end;
    else if coltype = 'RRDen' then do;
      rrden = max( of &var );
      output _Voices_table_rrden;
    end;
    else output _Voices_table_dat;
    
    %if %length( &vlabel ) > 0 %then %do;
      label &vlabel;
    %end;
    
  run;
  
  proc sql noprint;
    select sum(count) into :count
    from _Voices_table_count;
    select sum(rrden) into :rrden
    from _Voices_table_rrden;
  quit; 
  
  %let num_obs = %left( %nrbquote( %sysfunc( putn( &count, comma8.0 ) ) ) );
  %let ref_rate = %left( %sysfunc( putn( %sysevalf( 1 - ( &count / &rrden ) ), percent8.1 ) ) );
  
  %put _local_;

  %Data_to_format(
    FmtLib=work,
    FmtName=colfmt,
    Data=_Voices_table_count,
    Value=&col,
    Label=colfmtlbl,
    OtherLabel=,
    Print=N
  )
  
  title2 height=11pt " ";
  title3 height=11pt bold &text;
  title4 height=11pt bold color=cx95ac3b &text2;
  
  footnote1 height=9pt italic "Question refusal rate for eligible respondents = &ref_rate.. +/- column is credibility interval for response.";
  footnote2 height=9pt " ";
  footnote3 height=9pt italic "Prepared by Urban Institute, &fdate..";
  
  proc tabulate data=_Voices_table_dat format=&fmt noseps missing order=data;
    class &col;
    class coltype / preloadfmt;
    var &var varsum;
    table 
      /** Rows **/
      %if %mparam_is_yes( &total ) %then %do;
        &var varsum='\b Total',
      %end;
      %else %do;
        &var,
      %end;
      /** Columns **/
      &col=' ' * sum=' ' * coltype=' '
    ;
    format &col colfmt. coltype &typefmt;
  run;
  
  title2;
  
  ** Clean up temporary data sets **;

  proc datasets library=work nolist;
    delete _Voices_: /memtype=data;
  quit;

%mend Make_one_table;

/** End Macro Definition **/


/** Macro Make_all_tables - Start Definition **/

%macro Make_all_tables( indata=, list=, col=, colfmt=, title=, where= );

  %fdate()

  options orientation=landscape;
  options nodate nonumber;
  options missing='-';

  ods listing close;
  
  ods rtf file="&_dcdata_default_path\Requests\Prog\2022\Voices_tables_&col..rtf" style=Styles.Voices_style_rtf
      bodytitle;
      
  title1 height=14pt bold "2017 VOICESDMV SURVEY: %upcase(&title)";

  %Make_one_table( 
    data=Voices.Voices_2017_q1_q2_recode,
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=y,
    var=uQ1_1 uQ1_2 uQ1_3 uQ1_4 uQ1_5 uQ1_6 uQ1_7 uQ1_8 uQ1_9 uQ1_11 uQ1_10,
    text="Q1. If someone WHO LIVED IN THE WASHINGTON AREA asked you, where would you say you were from?",
  	vlabel=
      uQ1_1 = "Washington, DC (or neighborhood within DC)"
      uQ1_2 = "Montgomery Co (or place within county)"
      uQ1_3 = "Prince George's Co (or place within county)"
      uQ1_4 = "Fairfax Co (or place within county)"
      uQ1_5 = "Other Northern Virginia (outside Fairfax Co)"
      uQ1_6 = "Maryland (no specific place inside region)"
      uQ1_7 = "Virginia (no specific place inside region)"
      uQ1_8 = "DMV/Washington region/area/suburbs"
      uQ1_9 = "Somewhere outside DMV"
      uQ1_10 = "Answer did not identify a place"
      uQ1_11 = "Answer included multiple places"
  )

  %Make_one_table( 
    data=Voices.Voices_2017_q1_q2_recode,
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=y,
    var=rQ1_same rQ1_dc rQ1_oth_juris rQ1_dmv rQ1_md rQ1_va rQ1_out rQ1_mult rQ1_none,
    text="Q1. If someone WHO LIVED IN THE WASHINGTON AREA asked you, where would you say you were from?",
    text2="Relative to where respondent actually lives",
    vlabel=
      rQ1_same = "Same jurisdiction where person lives"
      rQ1_oth_juris = "Different jurisdiction in DMV (except DC)"
      rQ1_dc = "Washington, DC (non-DC residents only)"
      rQ1_md = "Maryland (no specific place inside region)"
      rQ1_va = "Virginia (no specific place inside region)"
      rQ1_dmv = "DMV/Washington region/area/suburbs"
      rQ1_out = "Somewhere outside DMV"
      rQ1_none = "Answer did not identify a place"
      rQ1_mult = "Answer included multiple places"
  )

  %Make_one_table( 
    data=Voices.Voices_2017_q1_q2_recode,
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=y,
    var=uQ2_1 uQ2_2 uQ2_3 uQ2_4 uQ2_5 uQ2_6 uQ2_7 uQ2_8 uQ2_9 uQ2_11 uQ2_10,
    text="Q2. If someone WHO LIVED OUTSIDE THE WASHINGTON AREA asked you, where would you say you were from?",
    vlabel=
      uQ2_1 = "Washington, DC (or neighborhood within DC)"
      uQ2_2 = "Montgomery Co (or place within county)"
      uQ2_3 = "Prince George's Co (or place within county)"
      uQ2_4 = "Fairfax Co (or place within county)"
      uQ2_5 = "Other Northern Virginia (outside Fairfax Co)"
      uQ2_6 = "Maryland (no specific place inside region)"
      uQ2_7 = "Virginia (no specific place inside region)"
      uQ2_8 = "DMV/Washington region/area/suburbs"
      uQ2_9 = "Somewhere outside DMV"
      uQ2_10 = "Answer did not identify a place"
      uQ2_11 = "Answer included multiple places"
  )

  %Make_one_table( 
    data=Voices.Voices_2017_q1_q2_recode,
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=y,
    var=rQ2_same rQ2_dc rQ2_oth_juris rQ2_dmv rQ2_md rQ2_va rQ2_out rQ2_mult rQ2_none,
    text="Q2. If someone WHO LIVED OUTSIDE THE WASHINGTON AREA asked you, where would you say you were from?",
    text2="Relative to where respondent actually lives",
    vlabel=
      rQ2_same = "Same jurisdiction where person lives"
      rQ2_oth_juris = "Different jurisdiction in DMV (except DC)"
      rQ2_dc = "Washington, DC (non-DC residents only)"
      rQ2_md = "Maryland (no specific place inside region)"
      rQ2_va = "Virginia (no specific place inside region)"
      rQ2_dmv = "DMV/Washington region/area/suburbs"
      rQ2_out = "Somewhere outside DMV"
      rQ2_none = "Answer did not identify a place"
      rQ2_mult = "Answer included multiple places"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    fmt=comma10.1,
    typefmt=$coltype_mean.,
    total=n,
    var=Q3_Years_months_recode Q4_Years_months_recode Q5_Years_months_recode, 
    text="Q3-Q5. How long have you lived in..." 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q3_cat_:, 
    text="Q3. How long have you lived in the Washington area?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q4_cat_:, 
    text="Q4. How long have you lived in [city/county]?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q5_cat_:, 
    text="Q5. How long have you lived in your current home?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q6_:, 
    text="Q6. How often do you talk to or visit with your immediate neighbors?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q7_:, 
    text="Q7. In the place that you live, how much do you feel like you fit in?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q8_:, 
    text="Q8. How would you rate the Washington area in general as a place to live?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q9_:, 
    text="Q9. How likely are you to recommend [city/county] to a friend or co-worker as a place to live?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q10_:, 
    text="Q10. If you had the choice of where to live, would you rather..." 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q11, 
    text="Q11. In the next 12 months, are you likely to move away from the area where you live?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q12, 
    text="Q12. Are you registered to vote?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q13_1-Q13_8, 
    text="Q13. Have you, yourself, done any of the following in the last 12 months?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
  fmt=comma10.1,
    typefmt=$coltype_mean.,
    var=Q13_count,
    text="Q13. Count: Have you, yourself, done any of the following in the last 12 months?" 
  )

  ** Omit Q14_10 (other) for now **;
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q14_1-Q14_9, 
    text="Q14. Could you tell me whether you are a member of each type?" 
  )
 
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
  fmt=comma10.1,
    typefmt=$coltype_mean.,
    var=Q14_count,
    text="Q14. Count: Could you tell me whether you are a member of each type?" 
  )
  
 %Make_one_table( 
    data=Voices.Voices_Q15_recode_sum,
	col=&col, 
    colfmt=&colfmt,
    total=n,
    var=sQ15_3:,
    text="Q15.What are the three best things about living in the Washington area?",
	text2="Response given at least once",
	vlabel=
     		  sQ15_3a="Food"
			  sQ15_3b="Entertainment"
			  sQ15_3c="Jobs"
			  sQ15_3d="Diversity"
			  sQ15_3e="Location"
			  sQ15_3f="Culture"
			  sQ15_3g="Monuments and history"
			  sQ15_3h="People"
			  sQ15_3i="Nature"
			  sQ15_3j="Museums"
			  sQ15_3k="Transportation"
			  sQ15_3l="Schools"
			  sQ15_3m="Community"
	)

 %Make_one_table( 
    data=Voices.Voices_Q15_recode,
	col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q15_1e Q15_1c Q15_1f Q15_1b Q15_1a Q15_1d Q15_1j Q15_1g Q15_1h Q15_1k Q15_1i Q15_1l Q15_1m,
    text="Q15. What are the three best things about living in the Washington area?",
	text2="First response given",
    vlabel=
     		  Q15_1a="Food"
			  Q15_1b="Entertainment"
			  Q15_1c="Jobs"
			  Q15_1d="Diversity"
			  Q15_1e="Location"
			  Q15_1f="Culture"
			  Q15_1g="Monuments and history"
			  Q15_1h="People"
			  Q15_1i="Nature"
			  Q15_1j="Museums"
			  Q15_1k="Transportation"
			  Q15_1l="Schools"
			  Q15_1m="Community"
	)

  	%Make_one_table( 
    data=Voices.Voices_Q16_recode_sum,
	col=&col, 
    colfmt=&colfmt,
    total=n,
    var=sQ16_3a sQ16_3b sQ16_3c sQ16_3d sQ16_3f sQ16_3e sQ16_3g sQ16_3h sQ16_3i sQ16_3j sQ16_3k sQ16_3l,
    text="Q16. What are the three worst things about living in the Washington area?",
	text2="Response given at least once",
    vlabel=
     		  sQ16_3a="Traffic"
			  sQ16_3b="Cost of living"
			  sQ16_3c="Crime and safety"
			  sQ16_3d="Weather"
			  sQ16_3e="Politics"
			  sQ16_3f="People"
			  sQ16_3g="Housing"
			  sQ16_3h="Too many people"
			  sQ16_3i="Transportation"
			  sQ16_3j="Taxes"
			  sQ16_3k="METRO"
			  sQ16_3l="Nothing"
	)


%Make_one_table( 
    data=Voices.Voices_Q16_recode,
	col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q16_1a Q16_1b Q16_1c Q16_1d Q16_1f Q16_1l Q16_1g Q16_1h Q16_1e Q16_1i Q16_1j Q16_1k,
    text="Q16. What are the three worst things about living in the Washington area?",
	text2="First response given",
    vlabel=
     		  Q16_1a="Traffic"
			  Q16_1b="Cost of living"
			  Q16_1c="Crime and safety"
			  Q16_1d="Weather"
			  Q16_1e="Politics"
			  Q16_1f="People"
			  Q16_1g="Housing"
			  Q16_1h="Too many people"
			  Q16_1i="Transportation"
			  Q16_1j="Taxes"
			  Q16_1k="METRO"
			  Q16_1l="Nothing"
			  
	)


  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q17_:, 
    text="Q17. ...do you think living conditions in the Washington area will be better than they are today, worse, or about the same as today?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q18_:, 
    text="Q18. How safe would you feel walking in the place where you live after dark?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q19_:, 
    text="Q19. How safe do you feel the place where you live is for children?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_a_:, 
    text="Q20a. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="Public transportation was inconvenient",
    vlabel=
      Q20_a_1 = "Never"
      Q20_a_2 = "Less than once per month"
      Q20_a_3 = "Monthly"
      Q20_a_4 = "Weekly"
      Q20_a_5 = "Daily"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_b_:, 
    text="Q20b. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="You were unable to afford public transportation",
    vlabel=
      Q20_b_1 = "Never"
      Q20_b_2 = "Less than once per month"
      Q20_b_3 = "Monthly"
      Q20_b_4 = "Weekly"
      Q20_b_5 = "Daily"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_c_:, 
    text="Q20c. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="You did not have a car",
    vlabel=
      Q20_c_1 = "Never"
      Q20_c_2 = "Less than once per month"
      Q20_c_3 = "Monthly"
      Q20_c_4 = "Weekly"
      Q20_c_5 = "Daily"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_d_:, 
    text="Q20d. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="You did not have enough money for gas",
    vlabel=
      Q20_d_1 = "Never"
      Q20_d_2 = "Less than once per month"
      Q20_d_3 = "Monthly"
      Q20_d_4 = "Weekly"
      Q20_d_5 = "Daily"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_e_:, 
    text="Q20e. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="You did not have enough money to repair your car",
    vlabel=
      Q20_e_1 = "Never"
      Q20_e_2 = "Less than once per month"
      Q20_e_3 = "Monthly"
      Q20_e_4 = "Weekly"
      Q20_e_5 = "Daily"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_f_:, 
    text="Q20f. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="Of traffic",
    vlabel=
      Q20_f_1 = "Never"
      Q20_f_2 = "Less than once per month"
      Q20_f_3 = "Monthly"
      Q20_f_4 = "Weekly"
      Q20_f_5 = "Daily"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_g_:, 
    text="Q20g. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="Of construction",
    vlabel=
      Q20_g_1 = "Never"
      Q20_g_2 = "Less than once per month"
      Q20_g_3 = "Monthly"
      Q20_g_4 = "Weekly"
      Q20_g_5 = "Daily"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q20_h_:, 
    text="Q20h. In the past year, how often have you had trouble getting to where you need to go because:",
    text2="Of poor road conditions (e.g., potholes; does not include snow)",
    vlabel=
      Q20_h_1 = "Never"
      Q20_h_2 = "Less than once per month"
      Q20_h_3 = "Monthly"
      Q20_h_4 = "Weekly"
      Q20_h_5 = "Daily"
  )
  
  ** SKIP Q20i. Other FOR NOW **;

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ21_a:, 
    text="Q21a. How would you rate these aspects of life in the place where you live?",
    text2="As a place to raise children",
    vlabel=
      dQ21_a1 = "Excellent"
      dQ21_a2 = "Good"
      dQ21_a3 = "Fair"
      dQ21_a4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ21_b:, 
    text="Q21b. How would you rate these aspects of life in the place where you live?",
    text2="The availability of the goods and services that meet your needs (for example, grocery stores, shopping, restaurants, doctors, etc.)",
    vlabel=
      dQ21_b1 = "Excellent"
      dQ21_b2 = "Good"
      dQ21_b3 = "Fair"
      dQ21_b4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ21_c:, 
    text="Q21c. How would you rate these aspects of life in the place where you live?",
    text2="The overall quality of public schools",
    vlabel=
      dQ21_c1 = "Excellent"
      dQ21_c2 = "Good"
      dQ21_c3 = "Fair"
      dQ21_c4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ21_d:, 
    text="Q21d. How would you rate these aspects of life in the place where you live?",
    text2="The availability of good jobs",
    vlabel=
      dQ21_d1 = "Excellent"
      dQ21_d2 = "Good"
      dQ21_d3 = "Fair"
      dQ21_d4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ21_e:, 
    text="Q21e. How would you rate these aspects of life in the place where you live?",
    text2="The availability of arts and cultural opportunities",
    vlabel=
      dQ21_e1 = "Excellent"
      dQ21_e2 = "Good"
      dQ21_e3 = "Fair"
      dQ21_e4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ21_f:, 
    text="Q21f. How would you rate these aspects of life in the place where you live?",
    text2="Access to transportation options",
    vlabel=
      dQ21_f1 = "Excellent"
      dQ21_f2 = "Good"
      dQ21_f3 = "Fair"
      dQ21_f4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q22_:, 
    text="Q22. How often do you use services provided by nongovernmental, nonprofit organizations?" 
  )


  ** Omit Q23_6 (other) for now **;
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q23_1-Q23_5, 
    text="Q23. [Persons who never used nonprofit services (Q22)] Why do you never use services provided by nongovernmental, nonprofit organizations?"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q24_:, 
    text="Q24. [Persons who used nonprofit services (Q22)] How satisfied are you that the services you receive from nongovernmental, nonprofit organizations meet your needs?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q25_:, 
    text="Q25. When you think about the place where you live now, do you think that it is changing a lot, changing a little, or not changing much at all?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q26_:, 
    text="Q26. When you think about the changes going on in the place where you live, would you say that those changes..." 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q27, 
    text="Q27. In the past two years, do you know anyone who had to move from the place where they lived in [city/county] to somewhere else for a reason other than their own choice?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q28_:, 
    text="Q28. [Persons who had to move (Q27)] For what reason(s) did this person have to move?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q29_:, 
    text="Q29. [Persons who had to move (Q27)] Do you know where this person moved to?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q30_a_1-Q30_a_4, 
    text="Q30a How would you rate the following in [city/county]?...",
    text2="The leadership of [city/county] officials",
    vlabel=
      Q30_a_1 = "Excellent"
      Q30_a_2 = "Good"
      Q30_a_3 = "Fair"
      Q30_a_4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q30_b_1-Q30_b_4, 
    text="Q30b How would you rate the following in [city/county]?...",
    text2="The responsiveness of [city/county] government to the needs of residents",
    vlabel=
      Q30_b_1 = "Excellent"
      Q30_b_2 = "Good"
      Q30_b_3 = "Fair"
      Q30_b_4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q31, 
    text="Q31. Do you live in a place that has elected city officials, in addition to county officials?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q32_a_1-Q32_a_4, 
    text="Q32a. [Lives in a place that has elected city officials (Q31)] How would you rate the following in the city where you live?",
    text2="The leadership of elected city officials",
    vlabel=
      Q32_a_1 = "Excellent"
      Q32_a_2 = "Good"
      Q32_a_3 = "Fair"
      Q32_a_4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q32_b_1-Q32_b_4, 
    text="Q32b. [Lives in a place that has elected city officials (Q31)] How would you rate the following in the city where you live?",
    text2="The responsiveness of city government to the needs of residents",
    vlabel=
      Q32_b_1 = "Excellent"
      Q32_b_2 = "Good"
      Q32_b_3 = "Fair"
      Q32_b_4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q33_:, 
    text="Q33. How would you describe your ability to influence local-government decision-making?..." 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q34_:, 
    text="Q34. How much trust and confidence do you have in the local government in the place where you live when it comes to handling local problems?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_a:, 
    text="Q35a. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Developing parks and open spaces",
    vlabel=
      dQ35_a1 = "Extremely high priority"
      dQ35_a2 = "High priority"
      dQ35_a3 = "Medium priority"
      dQ35_a4 = "Low priority"
      dQ35_a5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_b:, 
    text="Q35b. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Maintaining roads, sidewalks, and other basic infrastructure",
    vlabel=
      dQ35_b1 = "Extremely high priority"
      dQ35_b2 = "High priority"
      dQ35_b3 = "Medium priority"
      dQ35_b4 = "Low priority"
      dQ35_b5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_c:, 
    text="Q35c. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Making it safer to get around by bicycle",
    vlabel=
      dQ35_c1 = "Extremely high priority"
      dQ35_c2 = "High priority"
      dQ35_c3 = "Medium priority"
      dQ35_c4 = "Low priority"
      dQ35_c5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_d:, 
    text="Q35d. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Protecting people from crime",
    vlabel=
      dQ35_d1 = "Extremely high priority"
      dQ35_d2 = "High priority"
      dQ35_d3 = "Medium priority"
      dQ35_d4 = "Low priority"
      dQ35_d5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_e:, 
    text="Q35e. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Protecting people from pollution and environmental hazards",
    vlabel=
      dQ35_e1 = "Extremely high priority"
      dQ35_e2 = "High priority"
      dQ35_e3 = "Medium priority"
      dQ35_e4 = "Low priority"
      dQ35_e5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_f:, 
    text="Q35f. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Making sure all children get a quality education",
    vlabel=
      dQ35_f1 = "Extremely high priority"
      dQ35_f2 = "High priority"
      dQ35_f3 = "Medium priority"
      dQ35_f4 = "Low priority"
      dQ35_f5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_g:, 
    text="Q35g. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Addressing affordable housing",
    vlabel=
      dQ35_g1 = "Extremely high priority"
      dQ35_g2 = "High priority"
      dQ35_g3 = "Medium priority"
      dQ35_g4 = "Low priority"
      dQ35_g5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_h:, 
    text="Q35h. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Preventing discrimination",
    vlabel=
      dQ35_h1 = "Extremely high priority"
      dQ35_h2 = "High priority"
      dQ35_h3 = "Medium priority"
      dQ35_h4 = "Low priority"
      dQ35_h5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_i:, 
    text="Q35i. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Helping poor people",
    vlabel=
      dQ35_i1 = "Extremely high priority"
      dQ35_i2 = "High priority"
      dQ35_i3 = "Medium priority"
      dQ35_i4 = "Low priority"
      dQ35_i5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_j:, 
    text="Q35j. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Helping the homeless",
    vlabel=
      dQ35_j1 = "Extremely high priority"
      dQ35_j2 = "High priority"
      dQ35_j3 = "Medium priority"
      dQ35_j4 = "Low priority"
      dQ35_j5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_k:, 
    text="Q35k. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Helping the unemployed",
    vlabel=
      dQ35_k1 = "Extremely high priority"
      dQ35_k2 = "High priority"
      dQ35_k3 = "Medium priority"
      dQ35_k4 = "Low priority"
      dQ35_k5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=dQ35_l:, 
    text="Q35l. How much of a priority do you think each of the following should be for the local government in the place where you live?",
    text2="Helping people without health insurance",
    vlabel=
      dQ35_l1 = "Extremely high priority"
      dQ35_l2 = "High priority"
      dQ35_l3 = "Medium priority"
      dQ35_l4 = "Low priority"
      dQ35_l5 = "Not a priority at all"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q36_:, 
    text="Q36. How would you rate your overall health?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=phy_health_:, 
    text="Q37. ...for how many days during the past 30 days was your physical health not good?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=ment_health_:, 
    text="Q38. ...for how many days during the past 30 days was your mental health not good?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=satisf_:, 
    text="Q39A. Overall, how satisfied are you with your life nowadays?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=worth_:, 
    text="Q39B. Overall, to what extent do you feel the things you do in your life are worthwhile?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=happy_:, 
    text="Q39C. Overall, how happy did you feel yesterday?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=anxious_:, 
    text="Q39D. Overall, how anxious did you feel yesterday?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q40, 
    text="Q40. Do you have relatives or friends who you can count on to help you when you need them?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=thriving suffering struggling, 
    text="Q41. On which step of the ladder would you say you personally feel you stand at this time/five years from now?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q42, 
    text="Q42. In the past year, have you ever felt discriminated against while in the Washington area?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q43_:, 
    text="Q43. [Persons who experienced discrimination (Q42)] In the past year, how often have you felt discriminated against?" 
  )

  ** Omit Q44_n (other) for now **;
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q44_a--Q44_m, 
    text="Q44. [Persons who experienced discrimination (Q42)] For what reasons did you feel discriminated against?" 
  )

  ** Omit Q45_i (other) for now **;
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q45_a--Q45_h, 
    text="Q45. [Persons who experienced discrimination (Q42)] In which systems or situations did you experience discrimination?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_a_:, 
    text="Q46a. How good is the place where you live for different groups of people?",
    text2="Families with children",
    vlabel=
      Q46_a_1 = "Very good"
      Q46_a_2 = "Good"
      Q46_a_3 = "Neither good nor bad"
      Q46_a_4 = "Bad"
      Q46_a_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_b_:, 
    text="Q46b. How good is the place where you live for different groups of people?",
    text2="Single adults",
    vlabel=
      Q46_b_1 = "Very good"
      Q46_b_2 = "Good"
      Q46_b_3 = "Neither good nor bad"
      Q46_b_4 = "Bad"
      Q46_b_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_c_:, 
    text="Q46c. How good is the place where you live for different groups of people?",
    text2="Seniors or elderly people",
    vlabel=
      Q46_c_1 = "Very good"
      Q46_c_2 = "Good"
      Q46_c_3 = "Neither good nor bad"
      Q46_c_4 = "Bad"
      Q46_c_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_d_:, 
    text="Q46d. How good is the place where you live for different groups of people?",
    text2="Immigrants from other countries",
    vlabel=
      Q46_d_1 = "Very good"
      Q46_d_2 = "Good"
      Q46_d_3 = "Neither good nor bad"
      Q46_d_4 = "Bad"
      Q46_d_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_e_:, 
    text="Q46e. How good is the place where you live for different groups of people?",
    text2="Racial and ethnic minorities",
    vlabel=
      Q46_e_1 = "Very good"
      Q46_e_2 = "Good"
      Q46_e_3 = "Neither good nor bad"
      Q46_e_4 = "Bad"
      Q46_e_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_f_:, 
    text="Q46f. How good is the place where you live for different groups of people?",
    text2="Religious minorities",
    vlabel=
      Q46_f_1 = "Very good"
      Q46_f_2 = "Good"
      Q46_f_3 = "Neither good nor bad"
      Q46_f_4 = "Bad"
      Q46_f_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_g_:, 
    text="Q46g. How good is the place where you live for different groups of people?",
    text2="Gay, lesbian, and transgender people",
    vlabel=
      Q46_g_1 = "Very good"
      Q46_g_2 = "Good"
      Q46_g_3 = "Neither good nor bad"
      Q46_g_4 = "Bad"
      Q46_g_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_h_:, 
    text="Q46h. How good is the place where you live for different groups of people?",
    text2="Women and girls",
    vlabel=
      Q46_h_1 = "Very good"
      Q46_h_2 = "Good"
      Q46_h_3 = "Neither good nor bad"
      Q46_h_4 = "Bad"
      Q46_h_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_i_:, 
    text="Q46i. How good is the place where you live for different groups of people?",
    text2="Poor people",
    vlabel=
      Q46_i_1 = "Very good"
      Q46_i_2 = "Good"
      Q46_i_3 = "Neither good nor bad"
      Q46_i_4 = "Bad"
      Q46_i_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_j_:, 
    text="Q46j. How good is the place where you live for different groups of people?",
    text2="Working class people",
    vlabel=
      Q46_j_1 = "Very good"
      Q46_j_2 = "Good"
      Q46_j_3 = "Neither good nor bad"
      Q46_j_4 = "Bad"
      Q46_j_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_k_:, 
    text="Q46k. How good is the place where you live for different groups of people?",
    text2="Middle class people",
    vlabel=
      Q46_k_1 = "Very good"
      Q46_k_2 = "Good"
      Q46_k_3 = "Neither good nor bad"
      Q46_k_4 = "Bad"
      Q46_k_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_l_:, 
    text="Q46l. How good is the place where you live for different groups of people?",
    text2="Wealthy people",
    vlabel=
      Q46_l_1 = "Very good"
      Q46_l_2 = "Good"
      Q46_l_3 = "Neither good nor bad"
      Q46_l_4 = "Bad"
      Q46_l_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_m_:, 
    text="Q46m. How good is the place where you live for different groups of people?",
    text2="Non-English speakers",
    vlabel=
      Q46_m_1 = "Very good"
      Q46_m_2 = "Good"
      Q46_m_3 = "Neither good nor bad"
      Q46_m_4 = "Bad"
      Q46_m_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_n_:, 
    text="Q46n. How good is the place where you live for different groups of people?",
    text2="People with disabilities",
    vlabel=
      Q46_n_1 = "Very good"
      Q46_n_2 = "Good"
      Q46_n_3 = "Neither good nor bad"
      Q46_n_4 = "Bad"
      Q46_n_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_o_:, 
    text="Q46o. How good is the place where you live for different groups of people?",
    text2="Renters",
    vlabel=
      Q46_o_1 = "Very good"
      Q46_o_2 = "Good"
      Q46_o_3 = "Neither good nor bad"
      Q46_o_4 = "Bad"
      Q46_o_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q46_p_:, 
    text="Q46p. How good is the place where you live for different groups of people?",
    text2="Homeowners",
    vlabel=
      Q46_p_1 = "Very good"
      Q46_p_2 = "Good"
      Q46_p_3 = "Neither good nor bad"
      Q46_p_4 = "Bad"
      Q46_p_5 = "Very bad"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q47_a_:, 
    text="Q47a. How would you rate the relations among different racial or ethnic groups...",
    text2="In the US as a whole",
    vlabel=
      Q47_a_1 = "Excellent"
      Q47_a_2 = "Good"
      Q47_a_3 = "Fair"
      Q47_a_4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q47_b_:, 
    text="Q47b. How would you rate the relations among different racial or ethnic groups...",
    text2="In the Washington area",
    vlabel=
      Q47_b_1 = "Excellent"
      Q47_b_2 = "Good"
      Q47_b_3 = "Fair"
      Q47_b_4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q47_c_:, 
    text="Q47c. How would you rate the relations among different racial or ethnic groups...",
    text2="In the place where you live",
    vlabel=
      Q47_c_1 = "Excellent"
      Q47_c_2 = "Good"
      Q47_c_3 = "Fair"
      Q47_c_4 = "Poor"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q48_:, 
    text="Q48. How much is your daily life affected by the fear that you or a loved one would be arrested or questioned by the police?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q49_:, 
    text="Q49. Do you think the police in your community treat people of color less favorably, more favorably, or equally to white people?" 
  )

 
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q50_:, 
    text="Q50. How would you rate the economic conditions in the Washington area today?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q51_:, 
    text="Q51. Do you think the economic conditions in the Washington area are getting better, getting worse, or staying about the same?" 
  )

  
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q52_:, 
    text="Q52. How well would you say you are managing financially these days? Would you say you are..." 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q53_:, 
    text="Q53. Think of your parents when they were your age. Would you say you are better off financially than they were?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q54_:, 
    text="Q54. If you lost all your current sources of household income... about how long do you think you could continue to live as you live today? " 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q55, 
    text="Q55. Have there been times in the past 12 months when you did not have enough money to buy food that you or your family needed?" 
  )

  
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q56_:, 
    text="Q56. [Did not have enough money to buy food (Q55)] How often in the past 12 months did you not have enough money to buy food that you or your family needed?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q57, 
    text="Q57. Have there been times in the past 12 months when you did not have enough money to pay the rent, mortgage, or utilities for housing for you or your family?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q58_:, 
    text="Q58. [Did not have enough money for housing (Q57)] Have there been times in the past 12 months when you did not have enough money to pay the rent, mortgage, or utilities for housing for you or your family?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q59, 
    text="Q59. Are you currently working at a paid job?" 
  )
  
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q60_:, 
    text="Q60. [Persons currently working (Q59)] How strongly do you agree that your current job or jobs provide you with the income needed to support you and your family?" 
  )

  ** Omit Q61_j (other) for now **;
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q61_a--Q61_i, 
    text="Q61. [Persons currently working (Q59)] Does your current job(s) offer any of the following benefits?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q62, 
    text="Q62. [Persons not currently working (Q59)] Are you currently looking for work or do you want to find a job?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q63_a_:, 
    text="Q63a. [Persons currently looking for work (Q62)] How important for you are the following as barriers in finding or keeping a good job?",
    text2="Access to child care",
    vlabel=
      Q63_a_1 = "Not a barrier"
      Q63_a_2 = "Minor barrier"
      Q63_a_3 = "Major barrier"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q63_b_:, 
    text="Q63b. [Persons currently looking for work (Q62)] How important for you are the following as barriers in finding or keeping a good job?",
    text2="Access to a car",
    vlabel=
      Q63_b_1 = "Not a barrier"
      Q63_b_2 = "Minor barrier"
      Q63_b_3 = "Major barrier"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q63_c_:, 
    text="Q63c. [Persons currently looking for work (Q62)] How important for you are the following as barriers in finding or keeping a good job?",
    text2="Convenient public transportation",
    vlabel=
      Q63_c_1 = "Not a barrier"
      Q63_c_2 = "Minor barrier"
      Q63_c_3 = "Major barrier"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q63_d_:, 
    text="Q63d. [Persons currently looking for work (Q62)] How important for you are the following as barriers in finding or keeping a good job?",
    text2="Level of education or training",
    vlabel=
      Q63_d_1 = "Not a barrier"
      Q63_d_2 = "Minor barrier"
      Q63_d_3 = "Major barrier"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q63_e_:, 
    text="Q63e. [Persons currently looking for work (Q62)] How important for you are the following as barriers in finding or keeping a good job?",
    text2="Past work experience",
    vlabel=
      Q63_e_1 = "Not a barrier"
      Q63_e_2 = "Minor barrier"
      Q63_e_3 = "Major barrier"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q63_f_:, 
    text="Q63f. [Persons currently looking for work (Q62)] How important for you are the following as barriers in finding or keeping a good job?",
    text2="Criminal background or past problems with law enforcement",
    vlabel=
      Q63_f_1 = "Not a barrier"
      Q63_f_2 = "Minor barrier"
      Q63_f_3 = "Major barrier"
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q63_g_:, 
    text="Q63g. [Persons currently looking for work (Q62)] How important for you are the following as barriers in finding or keeping a good job?",
    text2="Credit history or financial problems",
    vlabel=
      Q63_g_1 = "Not a barrier"
      Q63_g_2 = "Minor barrier"
      Q63_g_3 = "Major barrier"
  )

  ** SKIP Q63h. Other FOR NOW **;

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    total=n,
    var=Q77, 
    text="Q77. Were you born in the United States?" 
  )
    **look into**;
  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q78_:, 
    text="Q78. [Persons not born in the U.S. (Q77)] Are you...?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=Q79_:, 
    text="Q79. How would you describe your sexual orientation?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=DOV_REL1_:, 
    text="Q80. What is your religion?" 
  )

  %Make_one_table( 
    where=%str(&where),
    col=&col, 
    colfmt=&colfmt,
    var=DOV_IDEO_:, 
    text="Q81. In general, do you think of yourself as..." 
  )

  ods rtf close;
  ods listing;
  
  title1;
  footnote1;

%mend Make_all_tables;

/** End Macro Definition **/


** Column type format **;

proc format;
  value $coltype_mean (notsorted)
    'Mean' = '\qr Mean'
    'CI' = '\qr +/-';
  value $coltype_pct (notsorted)
    'Mean' = '\qr Pct.'
    'CI' = '\qr +/-';
  picture npercent (round)
    low-high = '0000009.9' (mult=1000);
  value region
    1 = 'Washington\~Area';
run;


** Create data sets with design effect corrections **;

%Create_deff_2017( var=race )

/*
%Create_deff_2017( var=region )
%Create_deff_2017( var=geo )
%Create_deff_2017( var=race )
%Create_deff_2017( var=educ )
%Create_deff_2017( var=income )
%Create_deff_2017( var=age )
%Create_deff_2017( var=gender )
%Create_deff_2017( var=homeown )
%Create_deff_2017( var=children )
*/

** Create tables **;

%Make_all_tables( col=race, colfmt=race., where=(race=2 and gender=1), title=Summary Tables by Race )

/*
%Make_all_tables( col=region, colfmt=region., title=Summary Tables for Entire Region )
%Make_all_tables( col=geo, colfmt=geo., title=Summary Tables by Jurisdiction )
%Make_all_tables( col=educ, colfmt=educ., title=Summary Tables by Education )
%Make_all_tables( col=income, colfmt=income., title=Summary Tables by Income )
%Make_all_tables( col=age, colfmt=age., title=Summary Tables by Age )
%Make_all_tables( col=gender, colfmt=gender., title=Summary Tables by Gender )
%Make_all_tables( col=homeown, colfmt=homeown., title=Summary Tables by Homeownership Status )
%Make_all_tables( col=children, colfmt=children., title=Summary Tables by Presence of Children in Household )
*/
