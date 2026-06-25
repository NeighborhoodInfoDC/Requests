
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


*save in a .cvs formtat to read into R so I can geo-match with the areas;
proc export data = ownership
	outfile="\\sas1\DCDATA\Libraries\Requests\Prog\2026\RFK\Data\owner_data.csv"
	dbms=csv
	replace;
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

*merge RFK and Ownership Data;


/* Parcels by property type [ui_proptype] and owner type [ownercat] by areas*/
proc sql; create table proptype_ownership as select
	ui_proptype, ownercat, 
		count(ssl) as DC,
		sum(




