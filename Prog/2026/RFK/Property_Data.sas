/**************************************************************************
 Program:  Property_Data.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   K. Visalli
 Created:  6/12/26
 Version:  SAS 9.4
 Environment:  Remote session (SAS1)
 
 Description: Property data to compile for RFK stadium analysis.

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

 Modifications:
**************************************************************************/

%include "F:\DCDATA\SAS\Inc\StdRemote.sas";

* Data Libraries ;
%DCData_lib(REALPROP)

%let MIN_SALES = 10;

* load Data and filter to saledate from 2000-2025;
data sales;
set REALPROP.sales_res_clean (keep=ssl saledate saleprice geo2020 Ward2022 ui_proptype);
*esale_date = input(SALEDATE, ddmmyy10.);
sale_year = year(SALEDATE);
if sale_year <= 2025 AND sale_year >= 2000; 

*Convert dollar values to 2025 for sales price;
	%dollar_convert(SALEPRICE, SALEPRICE_2025, 
					sale_year, 2025, 
					series = CUUR0000SA0L2, 
					quiet=N);
run;



* Read in RFK tracts;
proc import 
	out = rfk_tracts 
	datafile = "&_dcdata_r_path/Requests/Prog/2026/RFK/Result/rfk_tracts.csv"
	DBMS = csv REPLACE;
run;

%File_info( data=rfk_tracts, freqvars=rfk_sub_group2 rfk_group )

*merge RFK tracts with property data;
proc sql; create table sales_rfk as select
	*
	from rfk_tracts as a left join sales as b
  on a.geoid = b.geo2020
  where not( missing( saleprice_2025 ) or missing( sale_year ) );
quit;

%File_info( data=sales_rfk, freqvars=rfk_sub_group2 rfk_group, printobs=0 )


* stats by RFK sub group;
* East of Anacostia;
proc sql; create table sumstats_east as select
	sale_year, ui_proptype,
	count(ssl) as sales_east,
	/* median sales price */
	median(saleprice_2025) as med_price_east
	from sales_rfk
  where east_of_anacostia = 1
	group by ui_proptype, sale_year;
quit;

* West of Anacostia;
proc sql; create table sumstats_west as select
	sale_year, ui_proptype,
	count(ssl) as sales_west,
	/* median sales price */
	median(saleprice_2025) as med_price_west
	from sales_rfk
  where west_of_anacostia = 1
	group by ui_proptype, sale_year;
quit;

* RFK Area;
proc sql; create table sumstats_rfk as select
	sale_year, ui_proptype,
	count(ssl) as sales_rfk,
	/* median sales price */
	median(saleprice_2025) as med_price_rfk
	from sales_rfk
  where rfk_sub_group2 = 'RF'
	group by ui_proptype, sale_year;
quit;

* Ward 7;
proc sql; create table sumstats_w7 as select
	sale_year, ui_proptype,
	count(ssl) as sales_w7,
	/* median sales price */
	median(saleprice_2025) as med_price_w7
	from sales_rfk
  where ward2022 = '7'
	group by ui_proptype, sale_year;
quit;

* DC;
proc sql; create table sumstats_dc as select
	sale_year, ui_proptype,
	count(ssl) as sales_dc,
	/* median sales price */
	median(saleprice_2025) as med_price_dc
	from sales_rfk
	group by ui_proptype, sale_year;
quit;

* Combine data sets;

data sumstats_all;

  merge 
    sumstats_east
    sumstats_west
    sumstats_rfk
    sumstats_w7
    sumstats_dc;
  by ui_proptype sale_year;
  
  ** Suppress price if below sales threshold **;
  
  array asales{*} sales_east sales_west sales_rfk sales_w7 sales_dc;
  array aprice{*} med_price_east med_price_west med_price_rfk med_price_w7 med_price_dc;
  
  do i = 1 to dim( asales );
    if missing( asales{i} ) then asales{i} = 0;
    if asales{i} < &MIN_SALES then aprice{i} = .;
  end;
  
  drop i;
  
run;

options missing=' ';

ods csvall body="&_dcdata_default_path\Requests\Prog\2026\RFK\Property_Data_Sales.csv";

proc print data=sumstats_all noobs label;
  var sale_year ui_proptype sales_: ;
  label
    sales_east = "East of Anacostia"
    sales_west = "West of Anacostia"
    sales_rfk = "RFK"
    sales_w7 = "Ward 7"
    sales_dc = "DC";
run;

ods csvall close;

ods csvall body="&_dcdata_default_path\Requests\Prog\2026\RFK\Property_Data_Med_price.csv";

proc print data=sumstats_all noobs label;
  var sale_year ui_proptype med_price_: ;
  label
    med_price_east = "East of Anacostia"
    med_price_west = "West of Anacostia"
    med_price_rfk = "RFK"
    med_price_w7 = "Ward 7"
    med_price_dc = "DC";
run;

ods csvall close;


** Create tract-level data for mapping **;

data sales_rfk_map;

  set sales_rfk;
  
  if 2023 <= sale_year <= 2025 then do;
    sales_2023_2025 = 1;
    saleprice_2023_2025 = saleprice_2025;
  end;
  else if 2013 <= sale_year <= 2015 then do;
    sales_2013_2015 = 1;
    saleprice_2013_2015 = saleprice_2025;
  end;
  else if 2003 <= sale_year <= 2005 then do;
    sales_2003_2005 = 1;
    saleprice_2003_2005 = saleprice_2025;
  end;
  
run;

%File_info( data=sales_rfk_map )

proc sql; create table sumstats_tract as select
  geo2020, ui_proptype, 
  /* number of sales */
  sum( sales_2023_2025 ) as sales_2023_2025,
  sum( sales_2013_2015 ) as sales_2013_2015,
  sum( sales_2003_2005 ) as sales_2003_2005,
  /* median sales price */
  median( saleprice_2023_2025 ) as saleprice_2023_2025,
  median( saleprice_2013_2015 ) as saleprice_2013_2015,
  median( saleprice_2003_2005 ) as saleprice_2003_2005
  from sales_rfk_map
  /*where not( missing( sale_year ) )*/
  group by ui_proptype, geo2020;
quit;

%File_info( data=sumstats_tract, freqvars=ui_proptype sales_2003_2005 sales_2013_2015 sales_2023_2025 )
