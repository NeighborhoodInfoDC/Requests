/**************************************************************************
 Program:  HHinc_owner_2000_2016.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  6/30/2018
 Version:  SAS 9.4
 Environment:  Windows
 
 Description: Adapted from PT's Gross_rent_2005_2016.sas

 Creates adjusted hhincome ranges for 
 Inner region jurisdictions with 1 yr est available for owner-occupied household. 

 Data from ACS 1-year table B25118 downloaded from American
 Factfinder (and Census 2000 SF3 HCT011)
 
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
	9652,.,.,.,.,.,10947,10992,9403,8734,9560,10114,7855,9500,9407,10657,9696,12791,0,5000
	8947,.,.,.,.,.,7826,8684,6590,6508,7383,7926,7119,5922,7969,7455,7760,8897,5000,10000
	12643,.,.,.,.,.,11497,10904,10342,10935,10936,10742,10505,11098,10786,11466,8984,10064,10000,15000
	14222,.,.,.,.,.,10641,13448,11799,12804,12916,13208,13832,11563,13146,10638,11581,10771,15000,20000
	18339,.,.,.,.,.,15359,16877,15541,16604,13031,16340,16250,13263,14024,14596,14390,13546,20000,25000
	46394,.,.,.,.,.,42477,38573,38330,30985,30410,34770,31642,31499,30170,28986,30546,29994,25000,35000
	92193,.,.,.,.,.,85622,75747,72595,69156,64266,63583,60691,59142,57364,56226,53955,49244,35000,50000
	175491,.,.,.,.,.,147967,146916,139643,133267,134644,129016,129883,122598,121261,116721,108179,108364,50000,75000
	151756,.,.,.,.,.,149533,150005,137859,132815,133479,125779,122418,124105,119960,116177,115676,111417,75000,100000
	183971,.,.,.,.,.,224597,228818,223587,230681,223481,217740,221130,212577,218103,217372,215017,212232,100000,150000
	146359,.,.,.,.,.,240378,267916,307521,322721,315719,327197,337003,348393,357569,372629,392209,410694,150000,.
	;
	run;

	data All;

	  set Base Carry_fwd Carry_bck;
	  
	run;

	proc summary data=All nway;
	  class rcount_output;
	  id low high Hshlds&START_YR-Hshlds&END_YR;
	  var Hshldsadj: ;
	  output out=owner_inc_&START_YR._&END_YR. sum=;
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


	%File_info( data=owner_inc_&START_YR._&END_YR., printobs=50 )

	proc format;
	  value incrang
	    0-24999 = 'Under $25,000'
	    25000-49999 = '$25,000 to $49,999'
	    50000-74999 = '$50,000 to $74,999'
	    75000-99999 = '$75,000 to $99,999'
	    100000-149999 = '$100,000 to $149,999'
	    150000-300000 = '$150,000 or more';
	run;

	proc tabulate data=owner_inc_&START_YR._&END_YR. format=comma10.0 noseps missing;
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
	  title2 "Household Income for Owner-Occupied Housing Units, Inner region (UNADJUSTED)";
	run;
	    
	ods csvall body="&output_path\owner_inc_&START_YR._&END_YR..csv";

	proc tabulate data=Owner_inc_&START_YR._&END_YR. format=comma10.0 noseps missing;
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
	  title2 "Household Income for Owner-Occupied Housing Units, Inner region  (constant &END_YR. $)";
	run;

	ods csvall close;
