/**************************************************************************
 Program:  Sales_Affordability_2016_22.sas
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
				09/13/22 RP Update for 2020 tracts and 2022 wards
				05/12/23 RP Update for most recent real property data

**************************************************************************/


%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( realprop );
%DCData_lib( equity );

%let firstyear = 2016;
%let lastyear = 2022;

%let yrs = %sysfunc(substr(&firstyear, 1, 4))_%sysfunc(substr(&lastyear, 3, 2));
%let yr_label = %sysfunc(substr(&firstyear, 1, 4))-%sysfunc(substr(&lastyear, 3, 2));


data create_flags;
	set realpr_r.sales_res_clean (where=(ui_proptype in ('10' '11') and &firstyear. <= year(saledate) <= &lastyear.))
	;

	sale_yr = year(saledate);
  
  /* Copy/paste in effective interest rates by downloading the Current Mortgage Rates Data Since 1971? (xlsx) from:
     https://www.freddiemac.com/pmms */;
  
	eff_int_rate_2016= 3.72;
	eff_int_rate_2017= 4.06;
	eff_int_rate_2018= 4.64;
	eff_int_rate_2019= 4.01;
	eff_int_rate_2020= 3.11;
	eff_int_rate_2021= 2.96;
	eff_int_rate_2022= 5.34;

	month_int_rate_2016 = (eff_int_rate_2016/12/100);
	month_int_rate_2017 = (eff_int_rate_2017/12/100); 
	month_int_rate_2018 = (eff_int_rate_2018/12/100); 
	month_int_rate_2019 = (eff_int_rate_2019/12/100); 
	month_int_rate_2020 = (eff_int_rate_2020/12/100); 
	month_int_rate_2021 = (eff_int_rate_2021/12/100); 
	month_int_rate_2022 = (eff_int_rate_2022/12/100); 
		
	loan_multiplier_2016 =  month_int_rate_2016 *	( ( 1 + month_int_rate_2016 )**360	) / ( ( ( 1+ month_int_rate_2016 )**360 )-1 );
  	loan_multiplier_2017 =  month_int_rate_2017 *	( ( 1 + month_int_rate_2017 )**360	) / ( ( ( 1+ month_int_rate_2017 )**360 )-1 );
  	loan_multiplier_2018 =  month_int_rate_2018 *	( ( 1 + month_int_rate_2018 )**360	) / ( ( ( 1+ month_int_rate_2018 )**360 )-1 );
  	loan_multiplier_2019 =  month_int_rate_2019 *	( ( 1 + month_int_rate_2019 )**360	) / ( ( ( 1+ month_int_rate_2019 )**360 )-1 );
  	loan_multiplier_2020 =  month_int_rate_2020 *	( ( 1 + month_int_rate_2020 )**360	) / ( ( ( 1+ month_int_rate_2020 )**360 )-1 );
	loan_multiplier_2021 =  month_int_rate_2021 *	( ( 1 + month_int_rate_2021 )**360	) / ( ( ( 1+ month_int_rate_2021 )**360 )-1 );
	loan_multiplier_2022 =  month_int_rate_2022 *	( ( 1 + month_int_rate_2022 )**360	) / ( ( ( 1+ month_int_rate_2022 )**360 )-1 );

    *calculate monthly Principal and Interest for First time Homebuyer (10% down);
    if sale_yr=2016 then PI_First2016=saleprice*.9*loan_multiplier_2016;
	if sale_yr=2017 then PI_First2017=saleprice*.9*loan_multiplier_2017;
	if sale_yr=2018 then PI_First2018=saleprice*.9*loan_multiplier_2018;
	if sale_yr=2019 then PI_First2019=saleprice*.9*loan_multiplier_2019;
	if sale_yr=2020 then PI_First2020=saleprice*.9*loan_multiplier_2020;
	if sale_yr=2021 then PI_First2021=saleprice*.9*loan_multiplier_2021;
	if sale_yr=2022 then PI_First2022=saleprice*.9*loan_multiplier_2022;

	*inflation adjust into most recent year dollars ;
	%dollar_convert(PI_first2016,PI_first2016r,2016,&lastyear., series=CUUR0000SA0L2);
	%dollar_convert(PI_first2017,PI_first2017r,2017,&lastyear., series=CUUR0000SA0L2);
 	%dollar_convert(PI_first2018,PI_first2018r,2018,&lastyear., series=CUUR0000SA0L2);
	%dollar_convert(PI_first2019,PI_first2019r,2019,&lastyear., series=CUUR0000SA0L2);
	%dollar_convert(PI_first2020,PI_first2020r,2020,&lastyear., series=CUUR0000SA0L2);
	%dollar_convert(PI_first2021,PI_first2021r,2021,&lastyear., series=CUUR0000SA0L2);
	%dollar_convert(PI_first2022,PI_first2022r,2022,&lastyear., series=CUUR0000SA0L2);

    *calculate monthly PITI (Principal, Interest, Taxes and Insurance) for First Time Homebuyer (34% of PI = TI);
	if sale_yr=2016 then PITI_First=PI_First2016r*1.34;
	if sale_yr=2017 then PITI_First=PI_First2017r*1.34;
	if sale_yr=2018 then PITI_First=PI_First2018r*1.34;
	if sale_yr=2019 then PITI_First=PI_First2019r*1.34;
	if sale_yr=2020 then PITI_First=PI_First2020r*1.34;
	if sale_yr=2021 then PITI_First=PI_First2021r*1.34;
	if sale_yr=2022 then PITI_First=PI_First2022r*1.34;

    *calculate monthly Principal and Interest for Repeat Homebuyer (20% down);
    if sale_yr=2016 then PI_Repeat2016=saleprice*.8*loan_multiplier_2016;
	if sale_yr=2017 then PI_Repeat2017=saleprice*.8*loan_multiplier_2017;
	if sale_yr=2018 then PI_Repeat2018=saleprice*.8*loan_multiplier_2018;
	if sale_yr=2019 then PI_Repeat2019=saleprice*.8*loan_multiplier_2019;
	if sale_yr=2020 then PI_Repeat2020=saleprice*.8*loan_multiplier_2020;
	if sale_yr=2021 then PI_Repeat2021=saleprice*.8*loan_multiplier_2021;
	if sale_yr=2022 then PI_Repeat2022=saleprice*.8*loan_multiplier_2022;

	*inflation adjust into most recent year dollars ;
	%dollar_convert(PI_Repeat2016,PI_Repeat2016r,2016,&lastyear.,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2017,PI_Repeat2017r,2017,&lastyear.,series=CUUR0000SA0L2);
 	%dollar_convert(PI_Repeat2018,PI_Repeat2018r,2018,&lastyear.,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2019,PI_Repeat2019r,2019,&lastyear.,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2020,PI_Repeat2020r,2020,&lastyear.,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2021,PI_Repeat2021r,2021,&lastyear.,series=CUUR0000SA0L2);
	%dollar_convert(PI_Repeat2022,PI_Repeat2022r,2022,&lastyear.,series=CUUR0000SA0L2);

	*calculate monthly PITI (Principal, Interest, Taxes and Insurance) for Repeat Homebuyer (25% of PI = TI);
	if sale_yr=2016 then PITI_Repeat=PI_Repeat2016r*1.25;
	if sale_yr=2017 then PITI_Repeat=PI_Repeat2017r*1.25;
	if sale_yr=2018 then PITI_Repeat=PI_Repeat2018r*1.25;
	if sale_yr=2019 then PITI_Repeat=PI_Repeat2019r*1.25;
	if sale_yr=2020 then PITI_Repeat=PI_Repeat2020r*1.25;
	if sale_yr=2021 then PITI_Repeat=PI_Repeat2021r*1.25;
	if sale_yr=2022 then PITI_Repeat=PI_Repeat2022r*1.25;


	/*Here are numbers for Average Household Income at the city level. 2017-21 ACS 
	Using tables B19025(B,H, I) and B11001 (B,H,I)*/
	%let hhinc_blk = 74240;
	%let hhinc_nhwht = 195681;
	%let hhinc_hisp = 138973;

	*use HH Income numbers to calculate affordable or nonaffodable sales ;
	if PITI_First <= (&hhinc_nhwht. / 12*.28) then white_first_afford=1; else white_first_afford=0; 
		if PITI_Repeat <= (194743/ 12 *.28) then white_repeat_afford=1; else white_repeat_afford=0; 
	if PITI_First <= (&hhinc_blk. / 12 *.28) then black_first_afford=1; else black_first_afford=0; 
		if PITI_Repeat <= (72915 / 12 *.28) then black_repeat_afford=1; else black_repeat_afford=0; 
	if PITI_First <= (&hhinc_hisp. / 12*.28) then hispanic_first_afford=1; else hispanic_first_afford=0; 
		if PITI_Repeat <= (120441 / 12*.28 ) then hispanic_repeat_afford=1; else hispanic_repeat_afford=0; 
	/*if PITI_First <= (76271 / 12*.28 ) then aiom_first_afford=1; else aiom_first_afford=0; 
		if PITI_Repeat <= (76271 / 12*.28 ) then aiom_repeat_afford=1; else aiom_repeat_afford=0; 
	*/

	*dummy variable to count total sales ;
	total_sales=1;

	*variable labels;
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
var ward2022 saleprice PITI_FIRST PITI_repeat white_first_afford black_first_afford hispanic_first_afford /*AIOM_first_afford*/;
run; 

proc freq data=create_flags; 
tables white_first_afford black_first_afford hispanic_first_afford /*AIOM_first_afford*/; 
run;
*testing*;
proc sort data=create_flags;
by ward2022;
proc univariate data=create_flags;
by ward2022;
var saleprice;
run;
proc print data =create_flags;
var saleprice PITI_FIRST PITI_repeat white_first_afford black_first_afford hispanic_first_afford ;
where ward2022="2" and PITI_FIRST <1701.35;
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
	class ward2022;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford /*AIOM_first_afford AIOM_repeat_afford*/;
	output 	out=Ward_Level (where=(_type_^=0)) 
	sum= ; 
	format ward2022 $ward22a.;
;
run;

proc summary data=create_flags;
	class geo2020;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford /*AIOM_first_afford AIOM_repeat_afford*/;
	output out=Tract_Level (where=(_type_^=0)) sum= ;
run;

proc summary data=create_flags;
	class cluster2017;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford /*AIOM_first_afford AIOM_repeat_afford*/;
	output 		out=Cluster_Level (where=(_type_^=0)) 	sum= ;
	
run;



data sales_afford_all_&yrs. (drop=_type_ _freq_);

	set city_level ward_level cluster_level tract_level; 

	tractlabel=geo2020; 
	clustername=cluster2017; 
	clusterlabel=cluster2017;

	format tractlabel $GEO20A11. Clusterlabel $CLUS17A. clustername $CLUS17B. geo2020 cluster2017; 

	PctAffordFirst_White=white_first_afford/total_sales*100; 
	PctAffordFirst_Black=Black_first_afford/total_sales*100; 
	PctAffordFirst_Hispanic=Hispanic_first_afford/total_sales*100;
	*PctAffordFirst_AIOM= AIOM_first_afford/total_sales*100;

	PctAffordRepeat_White=white_Repeat_afford/total_sales*100; 
	PctAffordRepeat_Black=Black_Repeat_afford/total_sales*100; 
	PctAffordRepeat_Hispanic=Hispanic_Repeat_afford/total_sales*100;
	*PctAffordRepeat_AIOM= AIOM_repeat_afford/total_sales*100;

	label 
	PctAffordFirst_White="Pct. of SF/Condo Sales &yr_label. Affordable to First-time Buyer at Avg. Household Inc. NH White"
	PctAffordFirst_Black="Pct. of SF/Condo Sales &yr_label. Affordable to First-time Buyer at Avg. Household Inc. Black Alone"
	PctAffordFirst_Hispanic="Pct. of SF/Condo Sales &yr_label. Affordable to First-time Buyer at Avg. Household Inc. Hispanic"
	/* PctAffordFirst_AIOM="Pct. of SF/Condo Sales &yr_label. Affordable to First-time Buyer at Avg. Household Inc. Asian, Native American, Other, Multiple Race"*/

	PctAffordRepeat_White="Pct. of SF/Condo Sales &yr_label. Affordable to Repeat Buyer at Avg. Household Inc. NH White"
	PctAffordRepeat_Black="Pct. of SF/Condo Sales &yr_label. Affordable to Repeat Buyer at Avg. Household Inc. Black Alone"
	PctAffordRepeat_Hispanic="Pct. of SF/Condo Sales &yr_label. Affordable to Repeat Buyer at Avg. Household Inc. Hispanic"
	/*PctAffordRepeat_AIOM="Pct. of SF/Condo Sales &yr_label. Affordable to First-time Buyer at Avg. Household Inc. Asian, Native American, Other, Multiple Race"*/

	clusterlabel="Neighborhood Cluster Label" 
	clustername="Name of Neighborhood Cluster"
	total_sales="Total Number of Sales of Single Family Homes and Condiminium Units in Geography, 2016-20"
	tractlabel="Census Tract Label"

	white_first_afford = "Number of SF/Condo Sales &yr_label. Affordable for FT White Owners"
	black_first_afford = "Number of SF/Condo Sales &yr_label. Affordable for FT Black Owners"
	hispanic_first_afford = "Number of SF/Condo Sales &yr_label. Affordable for FT Hispanic Owners"
	/*AIOM_first_afford = "Number of SF/Condo Sales &yr_label. Affordable for FT Owners of Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"*/
	white_repeat_afford = "Number of SF/Condo Sales &yr_label. Affordable for Repeat White Owners"
	black_repeat_afford = "Number of SF/Condo Sales &yr_label. Affordable for Repeat Black Owners"
	hispanic_repeat_afford = "Number of SF/Condo Sales &yr_label. Affordable for Repeat Hispanic Owners"
	/*AIOM_repeat_afford = "AffordableProperty Sale is Affordable Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"*/
	;

run;

	

data wardonly;
	set sales_afford_all_&yrs. (where=(ward2022~=" ") keep=ward2022 pct:); 
run; 
proc transpose data=wardonly out=ward_long prefix=Ward_;
	id ward2022;
run;

data cityonly;
	set sales_afford_all_&yrs. (where=(city~=" ") keep=city pct:); 
	city=0;
	rename city=ward2022;
run; 

proc transpose data=cityonly out=city_long prefix=Ward_;
	id ward2022;
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
	outfile="&_dcdata_default_path\Requests\Prog\2023\profile_tabs_aff_&lastyear..csv"
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
	set sales_afford_all_&yrs. (drop= PctAffordFirst_Black PctAffordFirst_Hispanic /*PctAffordFirst_AIOM*/
									PctAffordRepeat_Black PctAffordRepeat_Hispanic /*PctAffordRepeat_AIOM*/
									black_first_afford Hispanic_first_afford /*AIOM_first_afford*/
									black_Repeat_afford Hispanic_Repeat_afford /*AIOM_Repeat_afford*/ );
	length race $10. ID $11.;
	race="White"; 

	if city="1" then ID="0";
	if Ward2022~=" " then ID=Ward2022;
	if cluster2017~=" " then ID=Cluster2017;
	if geo2020~=" " then ID=geo2020; 

	Rename PctAffordFirst_White=PctAffordFirst
		   PctAffordRepeat_White=PctAffordRepeat
		   white_first_afford=first_afford
		   white_Repeat_afford=repeat_afford;
run;	

data black;
	set sales_afford_all_&yrs. (drop= PctAffordFirst_white PctAffordFirst_Hispanic /*PctAffordFirst_AIOM*/
										PctAffordRepeat_white PctAffordRepeat_Hispanic /*PctAffordRepeat_AIOM*/
										white_first_afford Hispanic_first_afford /*AIOM_first_afford*/ 
										white_Repeat_afford Hispanic_Repeat_afford /*AIOM_Repeat_afford*/ );
	length race $10. ID $11.;
	race="Black"; 

	if city="1" then ID="0";
	if Ward2022~=" " then ID=Ward2022;
	if cluster2017~=" " then ID=Cluster2017;
	if geo2020~=" " then ID=geo2020; 

	Rename PctAffordFirst_black=PctAffordFirst
		   PctAffordRepeat_black=PctAffordRepeat
		   black_first_afford=first_afford
		   black_Repeat_afford=repeat_afford;
run;	

	
data hispanic;
	set sales_afford_all_&yrs. (drop= PctAffordFirst_white PctAffordFirst_black /*PctAffordFirst_AIOM*/
										PctAffordRepeat_white PctAffordRepeat_black /*PctAffordRepeat_AIOM*/
										white_first_afford black_first_afford /*AIOM_first_afford*/ 
										white_Repeat_afford black_Repeat_afford /*AIOM_Repeat_afford*/ );
	length race $10. ID $11.;
	race="Hispanic"; 

	if city="1" then ID="0";
	if Ward2022~=" " then ID=Ward2022;
	if cluster2017~=" " then ID=Cluster2017;
	if geo2020~=" " then ID=geo2020; 

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
	PctAffordFirst_dec="Pct. of SF/Condo Sales &yr_label. Affordable to First-time Buyer at Avg. Household Inc."
	PctAffordRepeat_dec="Pct. of SF/Condo Sales &yr_label. Affordable to Repeat Buyer at Avg. Household Inc."
	first_afford = "Number of SF/Condo Sales &yr_label. Affordable for First Time Buyer"
	repeat_afford = "Number of SF/Condo Sales &yr_label.  Affordable for Repeat Owners"
	race="Race of Householder";

		
run;

proc sort data=all_race;
	by  geo2020 cluster2017 ward2022 city  ;
run;

proc export data=all_race 
	outfile="&_dcdata_default_path\Requests\Prog\2023\Sales_affordability_allgeo_&lastyear..csv"
	dbms=csv replace;
run;
proc contents data=all_race;
run; 

/*don't really need a permanent dataset
	%Finalize_data_set(

  data=sales_afford_all_2016_20,
  out=sales_afford_all_2016_20,
  outlib=requests,
  label="DC Homes Sales Affordability for Average Household Income, 2016-20",
  sortby=ssl,

  restrictions=None,
  revisions=%str(New file DC Homes Sales Affordability, 2016-20),
  printobs=5,
  freqvars=white_first_afford black_first_afford hispanic_first_afford
);	
*/
