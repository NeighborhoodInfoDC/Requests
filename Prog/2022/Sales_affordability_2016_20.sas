/**************************************************************************
 Program:  Sales_Affordability.sas
 Library:  Equity
 Project:  NeighborhoodInfo DC
 Author:   M. Woluchem	
 Created:  8/12/16
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description: *Methodology for affordability adapted from Zhong Yi Tong paper 
http://content.knowledgeplex.org/kp2/cache/documents/22736.pdf
Homeownership Affordability in Urban America: Past and Future;

 Modifications: 09/11/16 LH Added Price Adjustments and used 2015$ adj. income
				10/07/16 LH Added output for COMM. 
				03/18/22 LH Update for 2016-2020

**************************************************************************/


%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )

%DCData_lib( realprop );
%DCData_lib( equity );


data create_flags;
  set realpr_r.sales_res_clean (where=(ui_proptype in ('10' '11') and 2016 <= year(saledate) <= 2020))
;
  
  /*pull in effective interest rates - for example: 
  http://www.fhfa.gov/DataTools/Downloads/Documents/Historical-Summary-Tables/Table15_2018_by_State_and_Year.xls*/
  
	sale_yr = year(saledate);
  
	eff_int_rate_2016= 3.69;
	eff_int_rate_2017= 3.96;
	eff_int_rate_2018= 4.95;
	eff_int_rate_2019= 3.95;
	eff_int_rate_2020= 4.22;

		month_int_rate_2016 = (eff_int_rate_2016/12/100);
		month_int_rate_2017 = (eff_int_rate_2017/12/100); 
		month_int_rate_2018 = (eff_int_rate_2018/12/100); 
		month_int_rate_2019 = (eff_int_rate_2019/12/100); 
		month_int_rate_2020 = (eff_int_rate_2020/12/100); 
		
	loan_multiplier_2016 =  month_int_rate_2016 *	( ( 1 + month_int_rate_2016 )**360	) / ( ( ( 1+ month_int_rate_2016 )**360 )-1 );
  	loan_multiplier_2017 =  month_int_rate_2017 *	( ( 1 + month_int_rate_2017 )**360	) / ( ( ( 1+ month_int_rate_2017 )**360 )-1 );
  	loan_multiplier_2018 =  month_int_rate_2018 *	( ( 1 + month_int_rate_2018 )**360	) / ( ( ( 1+ month_int_rate_2018 )**360 )-1 );
  	loan_multiplier_2019 =  month_int_rate_2019 *	( ( 1 + month_int_rate_2019 )**360	) / ( ( ( 1+ month_int_rate_2019 )**360 )-1 );
  	loan_multiplier_2020 =  month_int_rate_2020 *	( ( 1 + month_int_rate_2020 )**360	) / ( ( ( 1+ month_int_rate_2020 )**360 )-1 );

  *calculate monthly Principal and Interest for First time Homebuyer (10% down);
    if sale_yr=2016 then PI_First2016=saleprice*.9*loan_multiplier_2016;
	if sale_yr=2017 then PI_First2017=saleprice*.9*loan_multiplier_2017;
	if sale_yr=2018 then PI_First2018=saleprice*.9*loan_multiplier_2018;
	if sale_yr=2019 then PI_First2019=saleprice*.9*loan_multiplier_2019;
	if sale_yr=2020 then PI_First2020=saleprice*.9*loan_multiplier_2020;

	%dollar_convert(PI_first2016,PI_first2016r,2016,2020, series=CUUR0000SA0L2);
	%dollar_convert(PI_first2017,PI_first2017r,2017,2020, series=CUUR0000SA0L2);
 	%dollar_convert(PI_first2018,PI_first2018r,2018,2020, series=CUUR0000SA0L2);
	%dollar_convert(PI_first2019,PI_first2019r,2019,2020, series=CUUR0000SA0L2);
	%dollar_convert(PI_first2020,PI_first2020r,2020,2020, series=CUUR0000SA0L2);

  *calculate monthly PITI (Principal, Interest, Taxes and Insurance) for First Time Homebuyer (34% of PI = TI);
	if sale_yr=2016 then PITI_First=PI_First2016r*1.34;
	if sale_yr=2017 then PITI_First=PI_First2017r*1.34;
	if sale_yr=2018 then PITI_First=PI_First2018r*1.34;
	if sale_yr=2019 then PITI_First=PI_First2019r*1.34;
	if sale_yr=2020 then PITI_First=PI_First2020r*1.34;

  *calculate monthly Principal and Interest for Repeat Homebuyer (20% down);
    if sale_yr=2016 then PI_Repeat2016=saleprice*.8*loan_multiplier_2016;
	if sale_yr=2017 then PI_Repeat2017=saleprice*.8*loan_multiplier_2017;
	if sale_yr=2018 then PI_Repeat2018=saleprice*.8*loan_multiplier_2018;
	if sale_yr=2019 then PI_Repeat2019=saleprice*.8*loan_multiplier_2019;
	if sale_yr=2020 then PI_Repeat2020=saleprice*.8*loan_multiplier_2020;

	%dollar_convert(PI_Repeat2016,PI_Repeat2016r,2016,2020,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2017,PI_Repeat2017r,2017,2020,series=CUUR0000SA0L2);
 	%dollar_convert(PI_Repeat2018,PI_Repeat2018r,2018,2020,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2019,PI_Repeat2019r,2019,2020,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2020,PI_Repeat2020r,2020,2020,series=CUUR0000SA0L2);

	*calculate monthly PITI (Principal, Interest, Taxes and Insurance) for Repeat Homebuyer (25% of PI = TI);
	if sale_yr=2016 then PITI_Repeat=PI_Repeat2016r*1.25;
	if sale_yr=2017 then PITI_Repeat=PI_Repeat2017r*1.25;
	if sale_yr=2018 then PITI_Repeat=PI_Repeat2018r*1.25;
	if sale_yr=2019 then PITI_Repeat=PI_Repeat2019r*1.25;
	if sale_yr=2020 then PITI_Repeat=PI_Repeat2020r*1.25;


	/*Here are numbers for Average Household Income at the city level. 2016-20 ACS 
	Using tables B19025(B,H, I) and B11001X (B,H,I)
	Black	NH-White	Hispanic	AIOM	 
	72915	 194743		120441 	 	 		*/


	if PITI_First <= (194743 / 12*.28) then white_first_afford=1; else white_first_afford=0; 
		if PITI_Repeat <= (194743/ 12 *.28) then white_repeat_afford=1; else white_repeat_afford=0; 
	if PITI_First <= (72915 / 12 *.28) then black_first_afford=1; else black_first_afford=0; 
		if PITI_Repeat <= (72915 / 12 *.28) then black_repeat_afford=1; else black_repeat_afford=0; 
	if PITI_First <= (120441 / 12*.28) then hispanic_first_afford=1; else hispanic_first_afford=0; 
		if PITI_Repeat <= (120441/ 12*.28 ) then hispanic_repeat_afford=1; else hispanic_repeat_afford=0; 
	/*if PITI_First <= (76271 / 12*.28 ) then aiom_first_afford=1; else aiom_first_afford=0; 
		if PITI_Repeat <= (76271 / 12*.28 ) then aiom_repeat_afford=1; else aiom_repeat_afford=0; 
	*/


	total_sales=1;

	label 	PITI_First = "Principal, Interest, Tax and Insurance for FT Homebuyer"
			PITI_Repeat = "Principal, Interest, Tax and Insurance for Repeat Homebuyer"
			white_first_afford = "Property Sale is Affordable for FT White Owners"
			black_first_afford = "Property Sale is Affordable for FT Black Owners"
			hispanic_first_afford = "Property Sale is Affordable for FT Hispanic Owners"
			/*AIOM_first_afford = "Property Sale is Affordable for FT Owners of Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"*/
			white_repeat_afford = "Property Sale is Affordable for Repeat White Owners"
			black_repeat_afford = "Property Sale is Affordable for Repeat Black Owners"
			hispanic_repeat_afford = "Property Sale is Affordable for Repeat Hispanic Owners"
			/*AIOM_repeat_afford = "Property Sale is Affordable for Repeat Owners of Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"*/
;


run;
proc print data= create_flags (obs=25);
var saleprice PITI_FIRST PITI_repeat white_first_afford black_first_afford hispanic_first_afford /*AIOM_first_afford*/;
run;
proc freq data=create_flags; 
tables white_first_afford black_first_afford hispanic_first_afford /*AIOM_first_afford*/; 
run;
*proc summary at city, ward, tract, and cluster levels - so you could get % of sales in Ward 7 affordable to 
median white family vs. median black family.;

	
/*Proc Summary: Affordability for Owners by Race*/

proc summary data=create_flags;
	class city;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford /*AIOM_first_afford AIOM_repeat_afford*/;
	output	out=City_level (where=(_type_^=0))	sum= ;
	
	format city $CITY16.;
		run;

proc summary data=create_flags;
	class ward2012;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford /*AIOM_first_afford AIOM_repeat_afford*/;
	output 	out=Ward_Level (where=(_type_^=0)) 
	sum= ; 
	format ward2012 $wd12.;
;
		run;

proc summary data=create_flags;
	class geo2010;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford /*AIOM_first_afford AIOM_repeat_afford*/;
	output out=Tract_Level (where=(_type_^=0)) sum= ;
		run;

proc summary data=create_flags;
	class cluster_tr2000;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford /*AIOM_first_afford AIOM_repeat_afford*/;
	output 		out=Cluster_Level (where=(_type_^=0)) 	sum= ;
	
		run;



	data requests.sales_afford_all_2016_20 (label="DC Homes Sales Affordabilty for Average Household Income, 2016-20" drop=_type_ _freq_);

	set city_level ward_level cluster_level tract_level; 

	tractlabel=geo2010; 
	clustername=cluster_tr2000; 
	clusterlabel=cluster_tr2000;

	format tractlabel $GEO10A11. Clusterlabel $CLUS00A16. clustername $clus00s. geo2010 cluster_tr2000; 

	PctAffordFirst_White=white_first_afford/total_sales*100; 
	PctAffordFirst_Black=Black_first_afford/total_sales*100; 
	PctAffordFirst_Hispanic=Hispanic_first_afford/total_sales*100;
	*PctAffordFirst_AIOM= AIOM_first_afford/total_sales*100;


	PctAffordRepeat_White=white_Repeat_afford/total_sales*100; 
	PctAffordRepeat_Black=Black_Repeat_afford/total_sales*100; 
	PctAffordRepeat_Hispanic=Hispanic_Repeat_afford/total_sales*100;
	*PctAffordRepeat_AIOM= AIOM_repeat_afford/total_sales*100;

	label PctAffordFirst_White="Pct. of SF/Condo Sales 2016-20 Affordable to First-time Buyer at Avg. Household Inc. NH White"
		  PctAffordFirst_Black="Pct. of SF/Condo Sales 2016-20 Affordable to First-time Buyer at Avg. Household Inc. Black Alone"
		  PctAffordFirst_Hispanic="Pct. of SF/Condo Sales 2016-20 Affordable to First-time Buyer at Avg. Household Inc. Hispanic"
		/* PctAffordFirst_AIOM="Pct. of SF/Condo Sales 2016-20 Affordable to First-time Buyer at Avg. Household Inc. Asian, Native American, Other, Multiple Race"*/
	
		PctAffordRepeat_White="Pct. of SF/Condo Sales 2016-20 Affordable to Repeat Buyer at Avg. Household Inc. NH White"
		PctAffordRepeat_Black="Pct. of SF/Condo Sales 2016-20 Affordable to Repeat Buyer at Avg. Household Inc. Black Alone"
		PctAffordRepeat_Hispanic="Pct. of SF/Condo Sales 2016-20 Affordable to Repeat Buyer at Avg. Household Inc. Hispanic"
		/*PctAffordRepeat_AIOM="Pct. of SF/Condo Sales 2016-20 Affordable to First-time Buyer at Avg. Household Inc. Asian, Native American, Other, Multiple Race"*/
	clusterlabel="Neighborhood Cluster Label" 
clustername="Name of Neighborhood Cluster"
total_sales="Total Number of Sales of Single Family Homes and Condiminium Units in Geography, 2016-20"
tractlabel="Census Tract Label"
		white_first_afford = "Number of SF/Condo Sales 2016-20 Affordable for FT White Owners"
			black_first_afford = "Number of SF/Condo Sales 2016-20 Affordable for FT Black Owners"
			hispanic_first_afford = "Number of SF/Condo Sales 2016-20 Affordable for FT Hispanic Owners"
			/*AIOM_first_afford = "Number of SF/Condo Sales 2016-20 Affordable for FT Owners of Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"*/
			white_repeat_afford = "Number of SF/Condo Sales 2016-20  Affordable for Repeat White Owners"
			black_repeat_afford = "Number of SF/Condo Sales 2016-20 Affordable for Repeat Black Owners"
			hispanic_repeat_afford = "Number of SF/Condo Sales 2016-20 Affordable for Repeat Hispanic Owners"
			/*AIOM_repeat_afford = "AffordableProperty Sale is Affordable Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"*/
			;


	
	run;
	
	/** Register metadata **;

%Dc_update_meta_file(
      ds_lib=Equity,
      ds_name=sales_afford_all,
      creator_process=Sales_Affordability.sas,
      restrictions=None,
      revisions=New file.
      )*/

data wardonly;
	set requests.sales_afford_all_2016_20 (where=(ward2012~=" ") keep=ward2012 pct:); 
	run; 
	proc transpose data=wardonly out=ward_long prefix=Ward_;
	id ward2012;
	run;

data cityonly;
	set requests.sales_afford_all_2016_20 (where=(city~=" ") keep=city pct:); 
	city=0;
	rename city=ward2012;
	run; 

	proc transpose data=cityonly out=city_long prefix=Ward_;
	id ward2012;
	run;
proc sort data=city_long;
by _name_;
proc sort data=ward_long;
by _name_; 

	data output_table;
	merge city_long ward_long;
	by _name_;
	run;

proc export data=output_table 
	outfile="&_dcdata_default_path\Requests\Prog\2022\profile_tabs_aff.csv"
	dbms=csv replace;
	run;


/***
	create out put file for comms
Geography	Race	Var1	Var2	Var3
City		All		Value	Value	Value
City		White	Value	Value	Value
City		Black	Value	Value	Value
City		Hispanic	Value	Value	Value
Ward 1		All	Value	Value	Value
Ward 1		White	Value	Value	Value
Ward 1		Black	Value	Value	Value
Ward 1		Hispanic	Value	Value	Value
*/
	

	data white;
		set requests.sales_afford_all_2016_20 (drop= PctAffordFirst_Black PctAffordFirst_Hispanic /*PctAffordFirst_AIOM*/
											PctAffordRepeat_Black PctAffordRepeat_Hispanic /*PctAffordRepeat_AIOM*/
											black_first_afford Hispanic_first_afford /*AIOM_first_afford*/
											black_Repeat_afford Hispanic_Repeat_afford /*AIOM_Repeat_afford*/ );

	length race $10. ID $11.;
	race="White"; 

	if city="1" then ID="0";
	if Ward2012~=" " then ID=Ward2012;
	if cluster_tr2000~=" " then ID=Cluster_Tr2000;
	if geo2010~=" " then ID=geo2010; 

	Rename PctAffordFirst_White=PctAffordFirst
		   PctAffordRepeat_White=PctAffordRepeat
		   white_first_afford=first_afford
		   white_Repeat_afford=repeat_afford;
	run;	

		data black;
		set requests.sales_afford_all_2016_20 (drop= PctAffordFirst_white PctAffordFirst_Hispanic /*PctAffordFirst_AIOM*/
											PctAffordRepeat_white PctAffordRepeat_Hispanic /*PctAffordRepeat_AIOM*/
											white_first_afford Hispanic_first_afford /*AIOM_first_afford*/ 
											white_Repeat_afford Hispanic_Repeat_afford /*AIOM_Repeat_afford*/ );

	length race $10. ID $11.;
	race="Black"; 

	if city="1" then ID="0";
	if Ward2012~=" " then ID=Ward2012;
	if cluster_tr2000~=" " then ID=Cluster_Tr2000;
	if geo2010~=" " then ID=geo2010; 

	Rename PctAffordFirst_black=PctAffordFirst
		   PctAffordRepeat_black=PctAffordRepeat
		   black_first_afford=first_afford
		   black_Repeat_afford=repeat_afford;
	run;	

	
		data hispanic;
		set requests.sales_afford_all_2016_20 (drop= PctAffordFirst_white PctAffordFirst_black /*PctAffordFirst_AIOM*/
											PctAffordRepeat_white PctAffordRepeat_black /*PctAffordRepeat_AIOM*/
											white_first_afford black_first_afford /*AIOM_first_afford*/ 
											white_Repeat_afford black_Repeat_afford /*AIOM_Repeat_afford*/ );

	length race $10. ID $11.;
	race="Hispanic"; 

	if city="1" then ID="0";
	if Ward2012~=" " then ID=Ward2012;
	if cluster_tr2000~=" " then ID=Cluster_Tr2000;
	if geo2010~=" " then ID=geo2010; 

	Rename PctAffordFirst_Hispanic=PctAffordFirst
		   PctAffordRepeat_Hispanic=PctAffordRepeat
		   Hispanic_first_afford=first_afford
		   Hispanic_Repeat_afford=repeat_afford;
	run;	

	data all_race (label="DC Sales Affordability for COMM" drop=PctAffordFirst PctAffordRepeat);
	set white black hispanic;
	
	 PctAffordFirst_dec= PctAffordFirst/100; 
	PctAffordRepeat_dec=PctAffordRepeat/100; 
	label 
	 PctAffordFirst_dec="Pct. of SF/Condo Sales 2016-20 Affordable to First-time Buyer at Avg. Household Inc."
		 PctAffordRepeat_dec="Pct. of SF/Condo Sales 2016-20 Affordable to Repeat Buyer at Avg. Household Inc."
		
		first_afford = "Number of SF/Condo Sales 2016-20 Affordable for First Time Buyer"
		repeat_afford = "Number of SF/Condo Sales 2016-20  Affordable for Repeat Owners"
		race="Race of Householder";

	
	
	run;

	proc sort data=all_race;
	by  geo2010 cluster_tr2000 ward2012 city  ;
	run;
proc export data=all_race 
	outfile="&_dcdata_default_path\Requests\Prog\2022\Sales_affordability_allgeo.csv"
	dbms=csv replace;
	run;
	proc contents data=all_race;
	run; 
