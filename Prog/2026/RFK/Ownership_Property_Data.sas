/**************************************************************************
 Program:  Property_Data.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   K. Visalli
 Created:  6/24/26
 Version:  SAS 9.4
 Environment:  Remote session (SAS1)
 
 Description: Property data to compile for RFK stadium analysis.

  Property ownership
  Source: Realprop.Parcel_base_who_owns
  Universe: All active [in_last_ownerpt=1] residential [ui_proptype=10,11,12,13,19] property parcels

  Parcels by property type [ui_proptype] and owner type [ownercat]
  Single family houses [ui_proptype=10] by owner-occupancy [owner_occ_sale]
  Single family houses [ui_proptype=10] with senior homestead exemption [hstd_code=5]
  Condominium units [ui_proptype=11] by owner-occupancy [owner_occ_sale]
  Condominium units [ui_proptype=11] with senior homestead exemption [hstd_code=5]

  on RFK areas and Ward2022

 Modifications:
**************************************************************************/

%include "F:\DCDATA\SAS\Inc\StdRemote.sas";

* Data Libraries ;
%DCData_lib(REALPROP)
%DCData_lib(DHCD)

*Load data
Universe: All active [in_last_ownerpt=1] residential [ui_proptype=10,11,12,13,19] property parcels;
data ownership;
	set REALPROP.Parcel_base_who_owns (keep=ssl in_last_ownerpt ui_proptype hstd_code ownercat owner_occ_sale no_units usecode premiseadd);
	where in_last_ownerpt=1 AND ui_proptype IN ("10","11","12","13","19") AND hstd_code ~= "3";
run;

* merge geo to ownership data;
proc sql; create table ownership_geo as select
	*
	from Ownership as a left join REALPROP.parcel_geo as b
	on a.ssl = b.ssl;
quit;

%File_info( data=ownership_geo, printobs=0, freqvars=hstd_code )


* Read in RFK tracts;
proc import 
	out = rfk_tracts 
	datafile = "&_dcdata_r_path/Requests/Prog/2026/RFK/Result/rfk_tracts.csv"
	DBMS = csv REPLACE;
run;

*merge RFK and Ownership Data;
proc sql; create table rfk_ownership as select
	*
	from Ownership_geo as a left join rfk_tracts as b
	on a.Geo2020 = b.geoid;
quit;

*dummy variables for each area;
data rfk_ownership2;
	set rfk_ownership;
	dc = 1;
	if ward2022 = 7 then ward7 = 1;
	else ward7 = 0;
	if ownercat IN ("010", "020") then owner_occupied = 1;
	else owner_occupied = 0;
run;


* Load rent control data;
data rent_control;
set dhcd.parcels_rent_control (keep=ssl units_mar units_full Rent_controlled);
run;


*merge multifamily properties to rent conrol data (Residential-multifamily, ;
proc sql; create table rfk_rent_control as select
	* 
	from rfk_ownership2 as a left join rent_control as b
	on a.ssl = b.ssl;
quit;


*assign number of units as 1 when singlefamily or condo;
*recode ui_proptype=19 to either SF or multifamily rental;
data rfk_ui_proptype_recode;
	set rfk_rent_control;
  
  * Recode ui_proptype=19;
  length ui_proptype_recode $ 2;
  if ui_proptype = '19' then do;
    if usecode in ( '015', '029' ) then do;
      if units_full = 1 then ui_proptype_recode = '10';
      else if units_full > 1 then ui_proptype_recode = '13';
      else if usecode = '015' then ui_proptype_recode = '10';
      else if usecode = '029' then ui_proptype_recode = '13';
    end;
  end;
  else do;
    ui_proptype_recode = ui_proptype;
  end;
  
	if ui_proptype_recode IN ("10", "11") then unit_count = 1;
  else if ui_proptype_recode = "12" and no_units > 0 then unit_count = no_units;
    
	if missing( unit_count ) then unit_count = units_full;
  
  label 
    unit_count = "Number of residential units"
    ui_proptype_recode = "UI property type code (recode)";
  
  format ui_proptype_recode $UIPRTYP.;
	
run;


*add mean unit counts by property type to property records;
proc sql noprint;
  create table rfk_unit_count_mean as 
  select *
  from rfk_ui_proptype_recode as a left join 
    ( select ui_proptype_recode, mean( unit_count ) as unit_count_mean from rfk_ui_proptype_recode
      group by ui_proptype_recode
    ) as b
  on a.ui_proptype_recode = b.ui_proptype_recode;
quit;

*use means to fill in missing unit counts;
data rfk_full;

  set rfk_unit_count_mean;
  
  if missing( unit_count ) then unit_count = unit_count_mean;
  
run;

%File_info( data=rfk_full, printobs=0 )

%Dup_check(
  data=rfk_full,
  by=ssl,
  id=geo2020,
  listdups=Y
)

proc format;
  value rfk_group (notsorted)
    1 = 'RFK Area'
    other = 'Outside RFK Area';
run;

proc tabulate data=rfk_full format=comma12.0 noseps missing order=data;
  class ui_proptype_recode / preloadfmt;
  class rfk_group / preloadfmt;
  var unit_count;
  table 
    /** Pages **/
    all='DC' rfk_group=' ',
    /** Rows **/
    all='Total' ui_proptype_recode=' ',
    /** Columns **/
    unit_count * ( n nmiss sum mean min max )
  / rts=40 condense
  ;
  format rfk_group rfk_group.;
run;


*check owner occupancy vars;
proc sql; create table ownerocc_check as select
	owner_occ_sale, owner_occupied, sum(rfk_group) as rfk
from rfk_full
group by owner_occ_sale, owner_occupied;
quit;

proc print data = ownerocc_check;
run;


/************************************************************** Property Type & Ownership Tables **************************************************************/

title2 "Number of Units by property Type and area";
proc sql; create table proptype_units as select
	ui_proptype_recode, 
		sum(dc * unit_count) as DC,
		sum(ward7 * unit_count) as Ward7,
		sum(rfk_group * unit_count) as RFK,
		sum(east_of_anacostia * unit_count) as East_RFK,
		sum(west_of_anacostia * unit_count) as West_RFK
	from rfk_full
	group by ui_proptype_recode;
quit;

proc print data = proptype_units noobs;
run;

title2 "Number of Units by owner type and area";
proc sql; create table owner_units as select
	ownercat, 
		sum(dc * unit_count) as DC,
		sum(ward7 * unit_count) as Ward7,
		sum(rfk_group * unit_count) as RFK,
		sum(east_of_anacostia * unit_count) as East_RFK,
		sum(west_of_anacostia * unit_count) as West_RFK
	from rfk_full(where = (ui_proptype_recode ~= "12"))
	group by ownercat;
quit;

proc report data = owner_units;
run;


title2 "Parcels by property type [ui_proptype_recode] and owner type [ownercat] by areas";
proc sql; create table proptype_owner_units as select
	ui_proptype_recode, ownercat, 
		sum(dc * unit_count) as DC,
		sum(ward7 * unit_count) as Ward7,
		sum(rfk_group * unit_count) as RFK,
		sum(east_of_anacostia * unit_count) as East_RFK,
		sum(west_of_anacostia * unit_count) as West_RFK
	from rfk_full 
	group by ui_proptype_recode, ownercat;
quit;

proc print data = proptype_owner_units;
run;

/************************************************************** Homestead Exemptions **************************************************************/

title2 "Single family houses [ui_proptype_recode=10] by owner-occupancy [owner_occ_sale]";
proc sql; create table sf_ownership as select
	owner_occ_sale, 
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_full(where = (ui_proptype_recode ="10")) 
	group by owner_occ_sale;
quit;

proc print data = sf_ownership;
run;

proc export data=sf_ownership
	outfile="&_dcdata_default_path\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="sf_ownership";
run;

title2 "Single family houses [ui_proptype_recode=10] with senior homestead exemption [hstd_code=5]";
proc sql; create table sf_homestead as select
		owner_occ_sale, hstd_code,
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_full(where = (ui_proptype_recode ="10"))  /*AND (input(hstd_code, 10.)=5));*/
	group by owner_occ_sale, hstd_code;
quit;

proc print data = sf_homestead;
run;

proc export data=sf_homestead
	outfile="&_dcdata_default_path\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="sf_homestead";
run;


title2 "Condominium units [ui_proptype_recode=11] by owner-occupancy [owner_occ_sale]";
proc sql; create table co_ownership as select
		owner_occ_sale,
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_full(where =((input(ui_proptype_recode, 10.)=11))) /*AND (input(hstd_code, 10.)=5));*/
	group by owner_occ_sale;
quit;

proc print data = co_ownership;
run;

proc export data=co_ownership
	outfile="&_dcdata_default_path\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="co_ownership";
run;

title2 "Condominium units [ui_proptype_recode=11] with senior homestead exemption [hstd_code=5]";
proc sql; create table co_homestead as select
		owner_occ_sale, hstd_code,
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_full(where =((input(ui_proptype_recode, 10.)=11))) /*AND (input(hstd_code, 10.)=5));*/
	group by owner_occ_sale, hstd_code;
quit;

proc print data = co_homestead;
run;

proc export data=co_homestead
	outfile="&_dcdata_default_path\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="co_homestead";
run;


/************************************************************** Rent Control **************************************************************/
title2 "shares of rental properties that have rent control by area";
proc sql; create table rent_control as select
	Rent_controlled, 
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
from rfk_full (where = (ui_proptype_recode = "13"))
group by Rent_controlled;
quit;

proc export data=rent_control
	outfile="&_dcdata_default_path\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="rent_control";
run;

title2;


/************************************************************** Length of Ownership **************************************************************/
*Year breakdown of last saledate;
*get year;
data ownerhip_length_data;
set rfk_full;
sale_year = year(SALEDATE);
if DC =0 then DC = .;
if Ward7 =0 then Ward7 = .;
if rfk_group =0 then rfk_group = .;
if east_of_anacostia =0 then east_of_anacostia = .;
if west_of_anacostia =0 then west_of_anacostia = .;
run;

*find quantiles of last sale year;
proc univariate data=ownerhip_length_data;
    var sale_year;
    output out=stats pctlpts=10 25 50 75 90 pctlpre=p;
run;

*define categorical variable;
data ownerhip_length_data2;
set ownerhip_length_data;
length own_length_cat $ 20 ;
if sale_year <2000 then own_length_cat = "a.1999 and earlier";
	else if sale_year >= 2000 & sale_year <2010 then own_length_cat = "b.2000-2009";
	else if sale_year >= 2010 & sale_year <2015 then own_length_cat = "c.2010-2014";
	else if sale_year >= 2015 & sale_year <2020 then own_length_cat = "d.2015-2019";
	else if sale_year >= 2020 & sale_year <2023 then own_length_cat = "e.2020-2022";
	else if sale_year >= 2023 then own_length_cat = "f.2023 and after";
if owner_occ_sale = 1 then owner_occ = "yes";
	else if owner_occ_sale IN ("N", "0") then owner_occ = "no";
run;

*table results;
proc sql; create table length_of_ownership as select
	owner_occ, own_length_cat,  
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from ownerhip_length_data2 (where = (owner_occ ~=""))
group by owner_occ, own_length_cat;
quit;

proc export data=length_of_ownership
	outfile="&_dcdata_default_path\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="length_of_ownership";
run;

*median length of ownership;
proc sql; create table median_length_of_ownership as select
	owner_occ, 
		median(sale_year * DC) as DC,
		median(sale_year * Ward7) as Ward7,
		median(sale_year * rfk_group) as RFK,
		median(sale_year * east_of_anacostia) as East_RFK,
		median(sale_year * west_of_anacostia) as West_RFK
	from ownerhip_length_data2 (where = (owner_occ ~=""))
group by owner_occ;
quit;

proc export data=median_length_of_ownership
	outfile="&_dcdata_default_path\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="med_length_of_ownership";
run;
