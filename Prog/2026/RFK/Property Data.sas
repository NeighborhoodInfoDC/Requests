/*
Project: RFK Stadium DCData
Author: Katie Visalli
Date: 6/12/26

Property data to compile for RFK stadium analysis.

Property sales
Source: Realprop.Sales_res_clean
Universe: Residential property sales, 2000 - 2025 [saledate]

Single family houses [ui_proptype=10]
Number of sales by year
Median sales price (2025 $) by year
Condominiums [ui_proptype=11]
Number of sales by year
Median sales price (2025 $) by year

on RFK areas and Ward2022
*/


* Set Up;
%include "F:\DCDATA\SAS\Inc\StdRemote.sas";

* Data Libraries ;
%DCData_lib(REALPROP)

* load Data and filter to saledate from 2000-2025;
data sales;
set REALPROP.sales_res_clean;
*esale_date = input(SALEDATE, ddmmyy10.);
sale_year = year(SALEDATE);
if sale_year <= 2025 AND sale_year >= 2000; 
censustract = input(geo2020, 10.);
run;

*Convert dollar values to 2025 for sales price;
data sales2;
set sales;
	%dollar_convert(SALEPRICE, SALEPRICE_2025, 
					sale_year, 2025, 
					series = CUUR0000SA0L2, 
					quiet=N);
run;



* Read in RFK tracts;
proc import 
	out = rfk_tracts 
	datafile = "//sas1/dcdata/Libraries/Requests/Prog/2026/RFK/Result/rfk_tracts.csv"
	DBMS = csv REPLACE;
run;

data rfk_tracts;
set rfk_tracts;
censustract = input(geoid, 10.);
run;

*merge RFK tracts with property data;
proc sql; create table sales_rfk as select
	*
	from rfk_tracts as a left join sales2 as b
	on a.censustract = b.censustract;
quit;


* stats by RFK sub group;
proc sql; create table sumstats_subgroup as select
	rfk_sub_group2, sale_year, ui_proptype,
	count(ssl) as sales,
	/* median sales price */
	median(saleprice_2025) as med_price
	from sales_rfk
	group by rfk_sub_group2, sale_year, ui_proptype;
quit;

proc print data=sumstats_subgroup;
run;

* stats by RFK full group;
proc sql; create table sumstats_rfk as select
	rfk_group, sale_year, ui_proptype,
	/* number of sales */
	count(ssl) as sales,
	/* median sales price*/
	median(saleprice_2025) as med_price
	from sales_rfk
	group by rfk_group, sale_year, ui_proptype;
quit;

proc print data=sumstats_rfk;
run;

* stats by ward;
proc sql; create table sumstats_ward as select
	ward2022, sale_year, ui_proptype,
	/* number of sales */
	count(ssl) as sales,
	/* median sales price */
	median(saleprice_2025) as med_price
	from sales_rfk
	group by ward2022, sale_year, ui_proptype;
quit;

proc print data=sumstats_ward;
run;

* stats in all of DC;
proc sql; create table sumstats_dc as select
	sale_year, ui_proptype,
	/* number of sales */
	count(ssl) as sales,
	/* median sales price*/
	median(saleprice_2025) as med_price
	from sales_rfk
	group by sale_year, ui_proptype;
quit;

proc print data=sumstats_dc;
run;
