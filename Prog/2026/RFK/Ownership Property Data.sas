
/*
Project: RFK Stadium DCData
Author: Katie Visalli
Date: 6/24/26

Property ownership
Source: Realprop.Parcel_base_who_owns
Universe: All active [in_last_ownerpt=1] residential [ui_proptype=10,11,12,13,19] property parcels

Parcels by property type [ui_proptype] and owner type [ownercat]
Single family houses [ui_proptype=10] by owner-occupancy [owner_occ_sale]
Single family houses [ui_proptype=10] with senior homestead exemption [hstd_code=5]
Condominium units [ui_proptype=11] by owner-occupancy [owner_occ_sale]
Condominium units [ui_proptype=11] with senior homestead exemption [hstd_code=5]

on RFK areas and Ward2022
*/

* Set Up;
%include "F:\DCDATA\SAS\Inc\StdRemote.sas";

* Data Libraries ;
%DCData_lib(REALPROP)

*Load data
Universe: All active [in_last_ownerpt=1] residential [ui_proptype=10,11,12,13,19] property parcels;
data ownership;
	set REALPROP.Parcel_base_who_owns;
	where in_last_ownerpt=1 AND ui_proptype IN ("10","11","12","13","19");
run;

* Load Geo data;
data parcel_geo;
	set REALPROP.parcel_geo;
	census_tract = input(geo2020, 10.);
run;

* merge geo to ownership data;
proc sql; create table ownership_geo as select
	*
	from Ownership as a left join parcel_geo as b
	on a.ssl = b.ssl;
quit;

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

*merge RFK and Ownership Data;
proc sql; create table rfk_ownership as select
	*
	from Ownership_geo as a left join rfk_tracts as b
	on a.census_tract = b.censustract;
quit;

*dummy variables for each area;
data rfk_ownership2;
	set rfk_ownership;
	dc = 1;
	if ward2022 = 7 then ward7 = 1;
	else ward7 = 0;
run;

* Parcels by property type [ui_proptype] by areas;
proc sql; create table proptype as select
	ui_proptype,  
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_ownership2 
	group by ui_proptype;
quit;

proc print data = proptype;
run;

* Parcels by owner type [ownercat] by areas;
proc sql; create table owner as select
	ownercat, 
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_ownership2 
	group by ownercat;
quit;

proc print data = owner;
run;

* Parcels by property type [ui_proptype] and owner type [ownercat] by areas;
proc sql; create table proptype_owner as select
	ui_proptype, ownercat, 
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_ownership2 
	group by ui_proptype, ownercat;
quit;

proc print data = proptype_owner;
run;

proc export data=proptype_owner
	outfile="\\sas1\dcdata\Libraries\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="proptype_owner";
run;

*Single family houses [ui_proptype=10] by owner-occupancy [owner_occ_sale];
proc sql; create table sf_ownership as select
	owner_occ_sale, 
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_ownership2(where = (input(ui_proptype, 10.)=10)) 
	group by owner_occ_sale;
quit;

proc print data = sf_ownership;
run;

proc export data=sf_ownership
	outfile="\\sas1\dcdata\Libraries\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="sf_ownership";
run;

*Single family houses [ui_proptype=10] with senior homestead exemption [hstd_code=5];
proc sql; create table sf_homestead as select
		hstd_code,
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_ownership2(where =((input(ui_proptype, 10.)=10))) /*AND (input(hstd_code, 10.)=5));*/
	group by hstd_code;
quit;

proc print data = sf_homestead;
run;

proc export data=sf_homestead
	outfile="\\sas1\dcdata\Libraries\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="sf_homestead";
run;


*Condominium units [ui_proptype=11] by owner-occupancy [owner_occ_sale];
proc sql; create table co_ownership as select
		owner_occ_sale,
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_ownership2(where =((input(ui_proptype, 10.)=11))) /*AND (input(hstd_code, 10.)=5));*/
	group by owner_occ_sale;
quit;

proc print data = co_ownership;
run;

proc export data=co_ownership
	outfile="\\sas1\dcdata\Libraries\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="co_ownership";
run;

*Condominium units [ui_proptype=11] with senior homestead exemption [hstd_code=5];
proc sql; create table co_homestead as select
		hstd_code,
		sum(dc) as DC,
		sum(ward7) as Ward7,
		sum(rfk_group) as RFK,
		sum(east_of_anacostia) as East_RFK,
		sum(west_of_anacostia) as West_RFK
	from rfk_ownership2(where =((input(ui_proptype, 10.)=11))) /*AND (input(hstd_code, 10.)=5));*/
	group by hstd_code;
quit;

proc print data = co_homestead;
run;

proc export data=co_homestead
	outfile="\\sas1\dcdata\Libraries\Requests\Prog\2026\RFK\Result\property_ownership_result.xlsx"
	dbms=xlsx
	replace;
	sheet="co_homestead";
run;

/* save in a .cvs formtat to read into R so I can geo-match with the areas;
proc export data = ownership
	outfile="\\sas1\DCDATA\Libraries\Requests\Prog\2026\RFK\Data\owner_data.csv"
	dbms=csv
	replace;
run;
