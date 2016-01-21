/**************************************************************************
 Program:  Pfeiffer_10_02_13.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/02/13
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Request from meeting with Jack Pfeiffer and others for
data on housing needs for elderly households.

Uses 2009-11 ACS data set created for housing security study
(HsngSec.ACS_tables).

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\Libraries\IPUMS\Prog\Ipums_formats_2009_11.sas"; 
%include "K:\Metro\PTatian\DCData\Libraries\HsngSec\Prog\HsngSec_formats_2009_11.sas";
%include "K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\HsngSec_Macros_2009_11.sas";

/* To get HsngSec.ACS_tables, run K:\Metro\PTatian\DCData\Libraries\HsngSec\Prog\HsngSec_Data_2009_11.sas */

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HsngSec )
%DCData_lib( IPUMS )

data ACS_senior_per;

  set HsngSec.ACS_tables (keep=serial pernum statefip relate age);
  
  where statefip = 11;
  
  if ( pernum = 1 and age >= 65 ) or ( pernum > 1 and relate = 2 and age >= 65 ) then senior_hh = 1;
  else senior_hh = 0;

run;

proc summary data=ACS_senior_per;
  by serial;
  var senior_hh;
  output out=ACS_senior_hh max=;
run;

data ACS_tables_senior;

  merge
    HsngSec.ACS_tables (where=(statefip = 11))
    ACS_senior_hh;
  by serial;
  
  if senior_hh;
  
run;



***** Tables *****;



ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 1. Total Number of Housing Units.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= ,
  row_fmt= ,
  weight = HHWT,
  universe= Households with an elderly householder or spouse,
  title= "Table 1. Total Housing Units",
  out=table1);

run;
data table1_rev (drop=_type_ _page_ _table_ total_pctsum_1  total_pctsum_0);
	set table1;

	rename total_sum=tot_units;
	if _table_=2 then delete;

	if upuma =" " then upuma ="9999999";
	run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 2. Total Number of Renter Occupied Units.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 ),
  row_var= ,
  row_fmt= ,
  weight = HHWT,
  universe= Renter-Occupied Households with an elderly householder or spouse,
  title= "Table 2. Total Renter Occupied Units",
  out=table2);

run;
data table2_rev (drop=_type_ _page_ _table_ total_pctsum_1  total_pctsum_0);
	set table2;

	rename total_sum=renter_units;
	if _table_=2 then delete;
	if upuma =" " then upuma ="9999999";
	run;

/*
ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 3. Share Renter-Occupied Units by Unit Size.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 ),
  row_var= UNITSSTR,
  row_fmt= rentunit.,
  weight= HHWT, 
  universe= Renter-Occupied Households,
  title= "Table 3. Share Renter-Occupied Units by Unit Size" );

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 4. Share Renter-Occupied Households by Income.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 ),
  row_var= hud_inc,
  row_fmt= hudinc.,
  weight= HHWT, 
  universe= Renter-Occupied Households,
  title= "Table 4. Share Renter-Occupied Households by Income" );

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 5. Share Renter-Occupied Households by Number of Bedrooms.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 ),
  row_var= bedrooms,
  row_fmt= numbeds.,
  weight= HHWT, 
  universe= Renter-Occupied Households,
  title= "Table 5. Share Renter-Occupied Households by Number of Bedrooms" );

run;
*/
ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 6. Share Renter-Occupied Households by (Gross) Housing Cost.xls" style=Minimal;

%Count_table(
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2  ),
  row_var= rentgrs,
  row_fmt= grsrent.,
  weight= HHWT, 
  universe= Renter-Occupied Households with an elderly householder or spouse,
  title= "Table 6. Share Renter-Occupied Households by (Gross) Housing Cost",
	out=table6)	;

run;
/*
ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 6a. Share Renter-Occupied Efficiency Households by (Gross) Housing Cost.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 and bedrooms = 1 ),
  row_var= rentgrs,
  row_fmt= grsrent.,
  weight= HHWT, 
  universe= Renter-Occupied Efficiency Households,
  title= "Table 6a. Share Renter-Occupied Efficiency Households by (Gross) Housing Cost" );

run;


ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 6b. Share Renter-Occupied One Bedroom Households by (Gross) Housing Cost.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 and bedrooms = 2 ),
  row_var= rentgrs,
  row_fmt= grsrent.,
  weight= HHWT, 
  universe= Renter-Occupied One Bedroom Households,
  title= "Table 6b. Share Renter-Occupied One Bedroom Households by (Gross) Housing Cost" );

run;


ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 6c. Share Renter-Occupied Two Bedroom Households by (Gross) Housing Cost.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 and bedrooms = 3 ),
  row_var= rentgrs,
  row_fmt= grsrent.,
  weight= HHWT, 
  universe= Renter-Occupied Two Bedroom Households,
  title= "Table 6c. Share Renter-Occupied Two Bedroom Households by (Gross) Housing Cost" );

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 6d. Share Renter-Occupied Three or More Bedroom Households by (Gross) Housing Cost.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 and bedrooms > 3 ),
  row_var= rentgrs,
  row_fmt= grsrent.,
  weight= HHWT, 
  universe= Renter-Occupied Three or More Bedroom Households,
  title= "Table 6d. Share Renter-Occupied Three or More Bedroom Households by (Gross) Housing Cost" );

run;
*/
ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 7. Median Rent for Renter-Occupied Households.xls" style=Minimal;

%Count_table_med( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 ),
  row_var= ,
  row_fmt= ,
  weight= HHWT, 
  universe= Renter-Occupied Households with an elderly householder or spouse,
  title= "Table 7. Median Rent for Renter-Occupied Households" ,
	out=table7);

run;

data table7_rev (drop=_type_ _page_ _table_);
	set table7; 
if upuma =" " then upuma ="9999999";
	run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 8. Monthly Housing Costs as a Percent of Household Income for Renter Occupied Units.xls" style=Minimal;

%Count_table4(  
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 2),
  row_var= affprob,
  row_fmt= affprob.,
  weight= HHWT, 
  universe= Renter-Occupied Households with an elderly householder or spouse,
  title= "Table 8. Monthly Housing Costs as a Percent of Household Income for Renter Occupied Units",
  out=table8);

run;


ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 9. Share of Occupied Units by Tenure.xls" style=Minimal;

%Count_table4(  
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= OWNERSHP,
  row_fmt= OWNERSHP_f.,
weight= HHWT, 
  universe= Occupied Housing Units for Households with an elderly householder or spouse,
  title= "Table 9. Share of Occupied Units by Tenure" , 
  out=table9);

run;
  

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 10. Share of Owner Occupied Units without a mortgage.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 ),
  row_var= mortgage,
  row_fmt= mortform.,
  weight= HHWT, 
  universe= Owner-Occupied Housing Units for Households with an elderly householder or spouse,
  title= "Table 10. Share of Owner Occupied Units without a mortgage",
  out=table10);

run;

data table10_rev (drop = _type_ _page_ _table_ total_pctsum_01 total_pctsum_00 mortgage);
	set table10 (where=(mortgage=. and _table_=1)); 

	rename total_sum=owner_units;
if upuma =" " then upuma ="9999999";
	run;
/*
ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 11. Share Owner-Occupied Units by Unit Size.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 ),
  row_var= UNITSSTR,
  row_fmt= rentunit.,
  weight= HHWT, 
  universe= Owner-Occupied Households,
  title= "Table 11. Share Owner-Occupied Units by Unit Size" );

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 12. Share Owner-Occupied Households by Income.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 ),
  row_var= hud_inc,
  row_fmt= hudinc.,
  weight= HHWT, 
  universe= Owner-Occupied Households,
  title= "Table 12. Share Owner-Occupied Households by Income" );

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 13. Share Owner-Occupied Households by Home Value.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 ),
  row_var= valueh,
  row_fmt= hvalue.,
  weight= HHWT, 
  universe= Owner-Occupied Households,
  title= "Table 13. Share Owner-Occupied Households by Home Value" );

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 14. Median Value of Owner-Occupied Households.xls" style=Minimal;

%Count_table_med2( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 and valueh ~= 9999999 ),
  row_var= ,
  row_fmt= ,
  weight= HHWT, 
  universe= Owner-Occupied Households,
  title= "Table 14. Median Value of Owner-Occupied Households" );

run;

*/

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 15. Monthly Housing Costs as a Percent of Household Income for Owner-Occupied Units, all owner households.xls" style=Minimal;

%Count_table4( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 and valueh ~= 9999999 ),
  row_var= affprob,
  row_fmt= affprob.,
  weight= HHWT, 
  universe= Owner-Occupied Households with an elderly householder or spouse, 
  title= "Table 15a. Monthly Housing Costs as a Percent of Household Income for Owner-Occupied Units" ,
	out=table15);

run;


ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 16. Monthly Housing Costs for Owner-Occupied Units.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 ),
  row_var= owncost,
  row_fmt= owncost.,
  weight= HHWT, 
  universe= Owner-Occupied Households (with or without mortgage) with an elderly householder or spouse,
  title= "Table 16. Monthly Housing Costs for Owner-Occupied Units",
  out=table16);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 17. Share Population by Age.xls" style=Minimal;

%Count_table( 
  where= ,
  row_var= age,
  row_fmt= agecat.,
  weight= perwt, 
  universe= All Persons in Households with an elderly householder or spouse,
  title= "Table 17. Share Population by Age",
  out=table17);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 18. Share Households by Living Arrangement.xls" style=Minimal;

%Count_table4(  
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= hhtype_new,
  row_fmt= hhtype_new.,
weight= HHWT, 
  universe= Occupied Households with an elderly householder or spouse,
  title= "Table 18. Share Households by Living Arrangement" ,
  out=table18);

run;


ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 19a. Share Households with Elderly Members.xls" style=Minimal;

%Count_table4(  
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= haveelderly,
  row_fmt= haveelderly.,
weight= HHWT, 
  universe= Occupied Households with an elderly householder or spouse,
  title= "Table 19a. Share Households with Elderly Members",
   out=table19a);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 19b. Share Households with Disabled Members.xls" style=Minimal;

%Count_table4(  
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= hasdis,
  row_fmt= hasdis.,
weight= HHWT, 
  universe= Occupied Households with an elderly householder or spouse,
  title= "Table 19b. Share Households with Disabled Members",
  out=table19b);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 19c. Share Households with Elderly and Disabled Members.xls" style=Minimal;

%Count_table4(  
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= haselddis,
  row_fmt= haselddis.,
weight= HHWT, 
  universe= Occupied Households with an elderly householder or spouse,
  title= "Table 19c. Share Households with Elderly and Disabled Members",
	out=table19c);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 20. Share Households by Household Size.xls" style=Minimal;

%Count_table4( 
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= numprec,
  row_fmt= hhsize.,
weight= HHWT, 
  universe= Occupied Households with an elderly householder or spouse,
  title= "Table 20. Share Households by Household Size",
   out=table20);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 21. Share Households by Employment and Age.xls" style=Minimal;

%Count_table4( 
  where= %str( pernum=1 and GQ in (1,2) ),
  row_var= emp_age,
  row_fmt= emp_age.,
weight= HHWT, 
  universe= Occupied Households with an elderly householder or spouse,
  title= "Table 21. Share Households by Employment and Age" ,
	out=table21);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 22. Households by HUD Area Median Income Level.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2)),
  row_var= hud_inc,
  row_fmt= hudinc.,
  weight= HHWT, 
  universe= All households with an elderly householder or spouse,
  title= "Table 22. Households by HUD Area Median Income Level" ,
  out=table22);

run;


ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 23 Monthly Housing Costs First Time Homebuyer.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 ),
  row_var= monthly_payment_first,
  row_fmt= owncost.,
  weight= HHWT, 
  universe= Owner-Occupied Households (with or without mortgage) with an elderly householder or spouse,
  title= "Table 23. Monthly Housing Costs for Owner-Occupied Units - Assume First-Time Homebuyer",
  out=table23);

run;

ods html file="K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Pfeiffer Tables\Table 24 Monthly Housing Costs Repeat Homebuyer.xls" style=Minimal;

%Count_table( 
  where= %str( pernum=1 and GQ in (1,2) and ownershp = 1 ),
  row_var= monthly_payment_repeat,
  row_fmt= owncost.,
  weight= HHWT, 
  universe= Owner-Occupied Households (with or without mortgage) with an elderly householder or spouse,
  title= "Table 24. Monthly Housing Costs for Owner-Occupied Units - Assume Repeat Homebuyer",
  out=table24);

run;

%count_table4(
 where= %str( pernum=1 and GQ in (1,2) and ownershp = 2 ),
 row_var=rentgrs,
 row_fmt=grsrent.,
 weight=HHWT,
 universe=Renter-occupied Households with an elderly householder or spouse,
 title="Table 25",
 out=table25);
