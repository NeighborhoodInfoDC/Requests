/**************************************************************************
 Program:  HHinc_renter_2000_2016.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  6/30/2018
 Version:  SAS 9.4
 Environment:  Windows
 
 Description: Adapted from PT's Gross_rent_2005_2016.sas

 Creates adjusted hhincome ranges for 
 Inner region jurisdictions with 1 yr est available for Renter Occupied Units. 

 Data from ACS 1-year table B25118 downloaded from American
 Factfinder (and Census 2000 SF3 HCT011
 
 Copy and paste lastest ACS data into DATALINES statement below.
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )

%let START_YR = 1999;
%let END_YR = 2016;
%let output_path = &_dcdata_default_path\Requests\Prog\2018\Washington region feature;


%macro rename_all( varA, varB );

  %do i = &START_YR %to &END_YR;
    &varA.&i=&varB.&i 
  %end;
  
%mend rename_all;

%macro enum_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i 
  %end;
  
%mend enum_all;

%macro label_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i = "&i"
  %end;
  
%mend label_all;

	data 
	  Base
	    (keep=rcount_output low high Hshlds&START_YR-Hshlds&END_YR HshldsAdj&START_YR-HshldsAdj&END_YR
	     Low&START_YR-Low&END_YR High&START_YR-High&END_YR)
	  Carry_fwd
	    (keep=rcount_output Carry_fwd&START_YR-Carry_fwd&END_YR
	     rename=(%rename_all(Carry_fwd, HshldsAdj)))
	  Carry_bck
	    (keep=rcount_output Carry_bck&START_YR-Carry_bck&END_YR
	     rename=(%rename_all(Carry_bck, HshldsAdj)))
	  ;

	    rcount_input + 1;

	    infile datalines missover dlm=',';

	    input
	      %enum_all( Hshlds )
	      Low
	      High
	     ;
	     
	   ** Create low and high rent levels adjusted for inflation **;
	   
	   array a_low{&START_YR:&END_YR} Low&START_YR-Low&END_YR;
	   array a_high{&START_YR:&END_YR} High&START_YR-High&END_YR;
	   
	   do i = &START_YR to &END_YR;
	   
	     %dollar_convert( Low, a_low{i}, i, &END_YR)
	     %dollar_convert( High, a_high{i}, i, &END_YR)
	        
	   end;
	   
	   **retain Carry&START_YR-Carry&END_YR 0;
	   
	   array a_units{&START_YR:&END_YR} Hshlds&START_YR-Hshlds&END_YR;
	   array a_unitsadj{&START_YR:&END_YR} HshldsAdj&START_YR-HshldsAdj&END_YR;
	   array a_carry_fwd{&START_YR:&END_YR} Carry_fwd&START_YR-Carry_fwd&END_YR;
	   array a_carry_bck{&START_YR:&END_YR} Carry_bck&START_YR-Carry_bck&END_YR;
	   array a_rcount{&START_YR:&END_YR} Rcount&START_YR-Rcount&END_YR;
	   
	   do i = &START_YR to &END_YR;
	   
	     if high = . then do;
	     
	       if a_low{i} < low then do;
	       
	         a_unitsadj{i} = a_units{i} * 0.5;
	         a_carry_bck{i} = a_units{i} * 0.5;
	           
	       end;
	       else do;
	       
	         a_unitsadj{i} = a_units{i};
	         
	       end;
	     
	     end;
	     else if a_high{i} > high then do;
	     
	       a_unitsadj{i} = a_units{i} * ( ( high - a_low{i} ) / ( a_high{i} - a_low{i} ) );
	       a_carry_fwd{i} = a_units{i} * ( ( a_high{i} - high ) / ( a_high{i} - a_low{i} ) );
	         
	     end;
	     else if a_high{i} <= high then do;
	     
	       a_unitsadj{i} = a_units{i} * ( ( a_high(i) - low ) / ( a_high{i} - a_low{i} ) );
	       a_carry_bck{i} = a_units{i} * ( ( low - a_low{i} ) / ( a_high{i} - a_low{i} ) );

	     end;
	     
	   end;
	   
	   rcount_output = rcount_input;
	   output base;
	   
	   if rcount_input > 1 then do;
	     rcount_output = rcount_input - 1;
	     output carry_bck;
	   end;
	   
	   if high ~= . then do;
	     rcount_output = rcount_input + 1;
	     output carry_fwd;
	   end;
	   
	   *drop i Low&START_YR-Low&END_YR High&START_YR-High&END_YR Carry&START_YR-Carry&END_YR;

	datalines;
	32037,.,.,.,.,.,27631,23732,24393,23813,22817,26491,26376,23963,29682,28619,25902,31579,0,5000
	32286,.,.,.,.,.,32913,30224,25118,28165,28977,28586,29316,28500,29376,29566,26552,26821,5000,10000
	29374,.,.,.,.,.,30999,25749,26251,21006,26123,27892,28980,25141,24606,25847,25181,29216,10000,15000
	29904,.,.,.,.,.,24922,24038,24235,22287,23852,24839,25971,25900,25881,23610,25247,22292,15000,20000
	35602,.,.,.,.,.,30428,24810,24292,22582,24221,30171,28622,30157,25411,29333,25251,29399,20000,25000
	79352,.,.,.,.,.,62120,57989,52690,52031,54165,54760,52880,56925,56417,57492,57755,55465,25000,35000
	100831,.,.,.,.,.,96974,84640,83659,82439,89567,84680,89054,91095,81334,82202,85348,75172,35000,50000
	110738,.,.,.,.,.,106370,106245,106095,105728,110841,124819,118545,123833,122526,124415,125696,120845,50000,75000
	54325,.,.,.,.,.,59909,57299,65734,73605,72289,77029,83943,82320,87474,89970,94046,96281,75000,100000
	37499,.,.,.,.,.,52964,53541,61887,69074,67182,81445,85564,92230,100901,103038,106906,109658,100000,150000
	16453,.,.,.,.,.,20272,28119,30830,35556,40574,46397,56328,62401,68858,71192,77704,81095,150000,.
	;
	run;

	data All;

	  set Base Carry_fwd Carry_bck;
	  
	run;

	proc summary data=All nway;
	  class rcount_output;
	  id low high Hshlds&START_YR-Hshlds&END_YR;
	  var Hshldsadj: ;
	  output out=Renter_inc_&START_YR._&END_YR. sum=;
	run;

	/*** UNCOMMENT TO CHECK ****

	%let testyr = 2012;

	proc print data=Base;
	  id rcount_output;
	  var low high low&testyr high&testyr Hshlds&testyr Hshldsadj&testyr;
	  sum Hshlds&testyr;
	run;

	proc print data=Carry_fwd;
	  id rcount_output;
	  var Hshldsadj&testyr ;
	run;

	proc print data=Carry_bck;
	  id rcount_output;
	  var Hshldsadj&testyr ;
	run;

	proc print data=All_sum;
	  id rcount_output low high;
	  var Hshldsadj&testyr ;
	  sum Hshldsadj&testyr ;
	run;

	/**********************************/


	%File_info( data=Renter_inc_&START_YR._&END_YR., printobs=50 )

	proc format;
	  value incrang
	    0-24999 = 'Under $25,000'
	    25000-49999 = '$25,000 to $49,999'
	    50000-74999 = '$50,000 to $74,999'
	    75000-99999 = '$75,000 to $99,999'
	    100000-149999 = '$100,000 to $149,999'
	    150000-300000 = '$150,000 or more';
	run;

	proc tabulate data=Renter_inc_&START_YR._&END_YR. format=comma10.0 noseps missing;
	  class low;
	  var Hshlds&START_YR.-Hshlds&END_YR.;
	  table 
	    /** Rows **/
	    Low=' ' all='TOTAL',
	    /** Columns **/
	    sum=' ' * ( Hshlds&START_YR.-Hshlds&END_YR. )
	  ;
	  format low incrang.;
	  label 
	    %label_all( Hshlds )
	  ;
	  title2 "Household Income for Renter-Occupied Housing Units, Inner region (UNADJUSTED)";
	run;
	    
	ods csvall body="&output_path\Renter_inc_&START_YR._&END_YR..csv";

	proc tabulate data=Renter_inc_&START_YR._&END_YR. format=comma10.0 noseps missing;
	  class low;
	  var HshldsAdj&START_YR.-HshldsAdj&END_YR.;
	  table 
	    /** Rows **/
	    Low=' ' all='TOTAL',
	    /** Columns **/
	    sum=' ' * ( HshldsAdj&START_YR.-HshldsAdj&END_YR. )
	  ;
	  format low incrang.;
	  label 
	    %label_all( HshldsAdj )
	  ;
	  title2 "Household Income for Renter-Occupied Housing Units, Inner region  (constant &END_YR. $)";
	run;

	ods csvall close;
