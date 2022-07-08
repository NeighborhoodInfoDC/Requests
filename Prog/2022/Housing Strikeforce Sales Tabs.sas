/**************************************************************************
 Program:  Housing Strikeforce Sales Tabs.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  06/29/22
 Version:  SAS 9.4
 Environment:  Windows
 
 Description: Uses DC sales data to output tabulations about sales, median
				prices and price appreciation. 

**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( realprop );
%DCData_lib( ACS );


/* ACS data to merge for majority black neighborhoods */
proc sort data = acs.acs_2015_19_dc_sum_tr_tr10
	(keep = geo2010 PopBlackNonHispBridge_2015_19 PopWithRace_2015_19)
	out = cen_race;
	by geo2010;
run;


/* Prep sales data */
proc sort data = realprop.sales_res_clean out = sales_in; by geo2010; run;

data property_sales;
  	merge sales_in cen_race;
	by geo2010;

	sale_yr = year(saledate);
	total_sales=1;

	/* Calculate if neighborhood is majority black */
	PctBlack = PopBlackNonHispBridge_2015_19 / PopWithRace_2015_19;
	if PctBlack > .5 then MajBlack = 1;

	/* Sales per year */
	if sale_yr = 2016 then sales_2016 = 1;
		else if sale_yr = 2017 then sales_2017 = 1;
		else if sale_yr = 2018 then sales_2018 = 1;
		else if sale_yr = 2019 then sales_2019 = 1;
		else if sale_yr = 2020 then sales_2020 = 1;

	/* Price per year */
	if sale_yr = 2016 then do;
		%dollar_convert(saleprice,price_2016,2016,2020, series=CUUR0000SA0L2);
	end; 
	else if sale_yr = 2017 then do;
		%dollar_convert(saleprice,price_2017,2017,2020, series=CUUR0000SA0L2);
	end; 
	else if sale_yr = 2018 then do;
		%dollar_convert(saleprice,price_2018,2018,2020, series=CUUR0000SA0L2);
	end; 
	else if sale_yr = 2019 then do;
		%dollar_convert(saleprice,price_2019,2019,2020, series=CUUR0000SA0L2);
	end; 
	else if sale_yr = 2020 then do;
		%dollar_convert(saleprice,price_2020,2020,2020, series=CUUR0000SA0L2);
	end; 

	length ward2022 $1;
	ward2022 = put( geoblk2010, $bk1wd2f. );
	label geoblk2010 = "Ward (2012)";

	format cluster2017 clus17b. ward2022 ward12a.;

run;

%let summarygeos = cluster2017 ward2012 city;

%macro sales_tabs (housetype,nhood,tenure);

/* Filter down dataset */
data sales_filtered;
	set property_sales;

	%if %upcase(&housetype.) = CONDO %then %do;
	if ui_proptype="11";
	%end;
	%else %if %upcase(&housetype.) = SF %then %do;
	if ui_proptype="10";
	%end;

	%if %upcase(&nhood.) = BLACK %then %do;
	if MajBlack = 1;
	%end;

	%if %upcase(&tenure.) = OWNER %then %do;
	if owner_occ_sale = 1;
	%end;
run;

/* Sales trend summary */
proc summary data = sales_filtered completetypes missing;
	class &summarygeos. / order=data preloadfmt;
	var sales_2016-sales_2020;
	output out = sales_&housetype._&nhood._&tenure. (where=(_type_ in (1,2,4))) sum=;
run;

data sales_&housetype._&nhood._&tenure.;
	set sales_&housetype._&nhood._&tenure.;
	if cluster2017 ^=. then geo = vvalue(cluster2017);
		else if ward2012 ^=. then geo = vvalue(ward2012);
		else if city ^=. then geo = vvalue(city);
	if geo ^= "";
	drop &summarygeos. _type_ _freq_;
run;


/* Median price summary */
proc summary data = sales_filtered completetypes missing;
	class &summarygeos. / preloadfmt order=data;
	var price_2016-price_2020;
	output out = price_&housetype._&nhood._&tenure. (where=(_type_ in (1,2,4))) median=;
run;

data price_&housetype._&nhood._&tenure.;
	set price_&housetype._&nhood._&tenure.;
	if cluster2017 ^=. then geo = vvalue(cluster2017);
		else if ward2012 ^=. then geo = vvalue(ward2012);
		else if city ^=. then geo = vvalue(city);
	if geo ^= "";
	drop &summarygeos. _type_ _freq_;
run;


/* Price appreciation */
data appreciation_&housetype._&nhood._&tenure.;
	set price_&housetype._&nhood._&tenure. ;

	price_change = (price_2020-price_2016)/price_2016;

	drop price_2017 price_2018 price_2019;
run;


%mend sales_tabs;

%sales_tabs (SF,all,all);
%sales_tabs (Condo,all,all);
%sales_tabs (SF,Black,all);
%sales_tabs (Condo,Black,all);

%sales_tabs (SF,all,owner);
%sales_tabs (Condo,all,owner);
%sales_tabs (SF,Black,owner);
%sales_tabs (Condo,Black,owner);


/* Export tables as CSVs */
%macro export_tabs (data);

proc export data=&data.
    outfile="&_dcdata_l_path.\Requests\Prog\2022\&data..csv"
    dbms=csv
    replace;
run;

%mend export_tabs;

/* All neighborhood */
%export_tabs(Sales_sf_all_all);
%export_tabs(Sales_condo_all_all);
%export_tabs(Price_sf_all_all);
%export_tabs(Price_condo_all_all);
%export_tabs(Appreciation_sf_all_all);
%export_tabs(Appreciation_sf_all_owner);
%export_tabs(Appreciation_condo_all_all);
%export_tabs(Appreciation_condo_all_owner);

/* Majority black neighborhood */
%export_tabs(Sales_sf_black_all);
%export_tabs(Sales_condo_black_all);
%export_tabs(Price_sf_black_all);
%export_tabs(Price_condo_black_all);
%export_tabs(Appreciation_sf_black_all);
%export_tabs(Appreciation_sf_black_owner);
%export_tabs(Appreciation_condo_black_all);
%export_tabs(Appreciation_condo_black_owner);


/* End of program */
