/**********************************************************************;

 Program:  BridgePark_12_23_14.sas
 Library:  REQUESTS
 Project:  Bridge Park via NeighborhoodInfo DC
 Author:   Maia Woluchem
 Created:  12/23/2014
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description: Creates a tract-level summary data set for the Bridge Park Task Force

 Modifications:
**********************************************************************/

/*For East of the River - 74.01 74.06 74.07 75.03 75.04 76.01 76.05
For West of the River - 65 66 67 68.02 69 70 71 72*/

%include "L:\SAS\Inc\StdLocal.sas"; 

**Define libraries**;
%DCData_lib(DHCD)
%DCData_lib(DMPED)
%DCData_lib(RealProp)
%DCData_lib(PresCat)
%DCData_lib(HUD)
%DCData_lib(OCC)
%DCData_lib(Requests)



**************************
	Tract-Level Datasets - 
**************************;

/**HPTF**/

*10x20 database contains HPTF data (Tract-Level)*

Create the appropriate character variable Geo2010 for merging;

data a10x20;
set dmped.a10x20_projects (keep= project_name address hptf Report__Units__Affordable Report__Units__Market
Report__Units__Total MAR_CENSUS_TRACT MAR_WARD MAR_XCOORD MAR_YCOORD MAR_ZIPCODE where=(mar_census_tract in (7401, 7406 7407 7503 7504 7601 7605 6500 6600 6700 
6802 6900 7000 7100 7200)))
;
units_aff=Report__Units__Affordable;
units_mkt=Report__Units__Market;
units_total=Report__Units__Total;
drop Report__Units__Affordable Report__Units__Market Report__Units__Total;
sscctt="1100100";
tttt=put(MAR_CENSUS_TRACT, 4.);
geo2010=sscctt||tttt;
if hptf ne . and hptf ne 0 then hptf_property=1;
	else hptf_property=0;
label units_aff="Units: Affordable"
	units_mkt="Units: Market-Rate"
	units_total="Units: Total"
	hptf_property="Number of HPTF Properties"; 
run;


*NETS data - Create Tract-Level file from Block Group file.
	NETS data was created by Tina and Helen for a separate project, and the documentation for the 
	creation of the file is located: L:\Libraries\Requests\Doc\2014\NETS Database Description2013.pdf.
	It is a block group file that is an annual snapshot of the lifecycle of business establishments from 
	1990 to 2011. This is the most recent data available, and notes the establishments present in 2011*;

data nets_tractlvl;
	set requests.nets_dc_all_bg (where=(year=2012) keep=year geoid estcount);
	geo2010_fake=substr(geoid,1,11);
	geo2010=put(geo2010_fake, $11.);
	drop geo2010_fake;
	run;

proc summary data=nets_tractlvl;
	class geo2010;
	var estcount;
	output
		out=sorted_nets_tract (drop= _type_ _freq_) 
	sum (estcount)=;
	format geo2010 $geo10a.;
	label estcount="Total Number of Establishments per Tract (2011)";
		run;


*Clean and Merge Tract-Level Files (Contains Voucher, HPTF, Establishment and Sales data)*;

proc sort data=a10x20
out=sorted_a10x20;
by geo2010;
run;

data tract_level (where=(geo2010 in ('11001007401', '11001007406', '11001007407', '11001007503', '11001007504', '11001007601', 
		'11001007605', '11001006500', '11001006600', '11001006700', '11001006802', '11001006900', '11001007000', '11001007100', 
		'11001007200')));
merge hud.vouchers_sum_tr10 sorted_a10x20 sorted_nets_tract realprop.sales_sum_tr10 (keep=geo2010 mprice_tot_2004 mprice_tot_2005 mprice_tot_2006 mprice_tot_2007 mprice_tot_2008 
	mprice_tot_2009 mprice_tot_2010 mprice_tot_2011 mprice_tot_2012 mprice_tot_2013);
by geo2010;
run;

**************************
	Parcel-Level Datasets
**************************;

/**Rent Controlled (Parcel-Level)**/

data rent_control ;
	set dhcd.parcels_rent_control (keep=ssl rent_controlled units_full ui_proptype);
	if put(rent_controlled, DYESNO.)='Yes' then rent_controlled_units=units_full;
		else rent_controlled_units=0;
	flag_rent_control=1;
	label 	rent_controlled_units = "Number of Rent Controlled Units"
			rent_controlled = "Rent Control Flag";
	run;

/*DC-Owned Properties, Recent Land Purchases and Vacant Land (parcel-level)*/

data master_realprop(where=(in_last_ownerpt=1));
merge realprop.parcel_base (keep=ssl saledate in_last_ownerpt ui_proptype saleprice no_units) realprop.parcel_base_who_owns 
(keep=ssl ui_proptype ownercat owner_occ_sale ownername_full);
by ssl;
flag_realprop=1;
if ui_proptype='50' then vacant_land=1; 
	else vacant_land=0;
if ui_proptype='51' then vacant_structure=1;
	else vacant_structure=0;
if put( OwnerCat, $owncat. ) = 'DC government' then dc_owned=1;
	else dc_owned=0;
if year(saledate)=2009 and year(saledate) ne . then sale_2009=1 ;
	else sale_2009=0;
if year(saledate)=2010 and year(saledate) ne . then sale_2010=1 ;
	else sale_2010=0;
if year(saledate)=2011 and year(saledate) ne . then sale_2011=1 ;
	else sale_2011=0;
if year(saledate)=2012 and year(saledate) ne . then sale_2012=1 ;
	else sale_2012=0;
if year(saledate)=2013 and year(saledate) ne . then sale_2013=1 ;
	else sale_2013=0;
if year(saledate)>=2010 and year(saledate) ne . then sale_last5=1;
	else sale_last5=0;
Objectid = 1 * put( ssl, $ssl2ply. );
  label Objectid = 'Unique polygon ID in OwnerPly';
  if Objectid > 0;
label 	dc_owned="Number of DC-Owned Properties"
 		vacant_land="Number of Vacant Parcels: Unimproved Land"
		vacant_structure="Number of Vacant Parcels: With Structure"
		sale_2009="Number of properties purchased in 2009"
		sale_2010="Number of properties purchased in 2010"
		sale_2011="Number of properties purchased in 2011"
		sale_2012="Number of properties purchased in 2012"
		sale_2013="Number of properties purchased in 2013"
		sale_last5="Number of properties purchased in 2010 or later";
run;

/*Expiring Properties (Parcel-level)*/

data prescat_subsidy;
set prescat.subsidy (where=(Subsidy_Active=1) keep= subsidy_active nlihc_id compl_end portfolio );
if portfolio='LIHTC' then tax_prop=1;
	else tax_prop=0;
if portfolio='LIHTC' and year(compl_end)>=2014 and year(compl_end)<=2019 and year(compl_end) ne . then expiring_14to19=1;
	else expiring_14to19=0;
if portfolio='LIHTC' and year(compl_end)>=2020 and year(compl_end)<=2024 and year(compl_end) ne . then expiring_20to24=1;
	else expiring_20to24=0;
if portfolio='LIHTC' and year(compl_end)>=2025 and year(compl_end)<=2029 and year(compl_end) ne . then expiring_25to29=1;
	else expiring_25to29=0;
if portfolio='LIHTC' and year(compl_end)>=2030 and year(compl_end) ne . then expiring_30plus=1;
	else expiring_30plus=0;
year=year(compl_end);
label 	tax_prop="Number of tax-credit properties"
		expiring_14to19 = "Number of tax-credit properties that expire between 2014 and 2019"
		expiring_20to24 = "Number of tax-credit properties that expire between 2020 and 2024";
run;

data PresCat_parcel_unique;
  set PresCat.Parcel 
    (keep=nlihc_id ssl in_last_ownerpt parcel_owner_name
    where=(in_last_ownerpt=1));
  by nlihc_id;
  if first.nlihc_id then output;
  flag_prescat=1;
  keep nlihc_id ssl parcel_owner_name  flag_prescat;
run;

proc sort data=prescat_parcel_unique
out=nlihc_to_parcel;
by nlihc_id;
run;

proc sort data=prescat_subsidy
out=prescat_subsidy_sorted;
by nlihc_id;
run;

data expiring_properties;
	merge prescat_subsidy_sorted nlihc_to_parcel;
	by nlihc_id;
	run;

**Merge parcel-level files and keep only those observations within Bridge Park**;

proc sort data=rent_control
out=sorted_rent_control;
by ssl;
run;

proc sort data=expiring_properties
out=sorted_expiring_properties;
by ssl;
run;

data parcel_level (where=(in_last_ownerpt=1 and geo2010 in ('11001007401', '11001007406', '11001007407', '11001007503', '11001007504', 
		'11001007601', '11001007605', '11001006500', '11001006600', '11001006700', '11001006802', '11001006900', '11001007000', 
		'11001007100', '11001007200')));
merge  sorted_rent_control master_realprop sorted_expiring_properties realprop.parcel_geo;
by ssl;
	if ui_proptype="12" then unit_count=no_units;
	else if ui_proptype="10" then unit_count=1;
	else if ui_proptype="11" then unit_count=1;
	else unit_count=units_full;
label unit_count = "Number of Units Per Parcel";
run;

%File_info( data=parcel_level)
%File_info( data=tract_level)

/**************************************************************
	Summarize Parcel and Tract-Level data at the Tract Level
**************************************************************;

/** Use Macro Summarize to Summarize Parcel-Level and Tract-Level File at the Tract level**/

%macro Summarize_tr10( level= );

  %local filesuf level_lbl level_fmt file_lbl;

  %** Get standard geography information **;

  %let level = %upcase( &level );

  %if &level = GEO2010 %then %do;
    %let filesuf = tr10;
    %let level_lbl = Tracts (2010);
    %let level_fmt = $GEO10A11.;
  %end;
  %else %do;
    %err_mput( macro=Summarize, 
               msg=Level (LEVEL=&level) is not recognized. )
    %goto exit;
  %end;

  %let file_lbl = "Tract Profile, Bridge Park Variables, &level_lbl";

  ** Summarize by tract all parcel-level variables**;

  proc summary data=parcel_level nway completetypes;
      class &level /preloadfmt;
      format &level &level_fmt;
    	var  unit_count rent_controlled_units dc_owned vacant_land vacant_structure sale_2009 sale_2010 sale_2011 sale_2012 sale_2013
			sale_last5 tax_prop expiring_14to19 expiring_20to24;
    output 
		out=parcel_level_sum_&filesuf (drop= _type_ _freq_) 
      sum ( unit_count rent_controlled_units dc_owned vacant_land vacant_structure sale_2009 sale_2010 sale_2011 sale_2012 sale_2013
			sale_last5 tax_prop expiring_14to19 expiring_20to24)=
	  ;
  run;

 ** Summarize by tract all tract-level variables**;

    proc summary data=tract_level nway completetypes;
      class &level /preloadfmt;
      format &level &level_fmt;
    	var total_units hptf_property mprice_tot_2004 mprice_tot_2005 mprice_tot_2006 mprice_tot_2007 mprice_tot_2008 mprice_tot_2009 
				mprice_tot_2010 mprice_tot_2011  mprice_tot_2012 mprice_tot_2013 estcount;
    output 
		out=tract_level_sum_&filesuf (drop= _type_ _freq_) 
      sum (total_units hptf_property estcount)=
	  median (mprice_tot_2004 mprice_tot_2005 mprice_tot_2006 mprice_tot_2007 mprice_tot_2008 mprice_tot_2009 mprice_tot_2010
 				mprice_tot_2011  mprice_tot_2012  mprice_tot_2013)=
	  ;
  run;

  %file_info( data=parcel_level_sum_&filesuf, printobs=5 )
  %file_info( data=tract_level_sum_&filesuf, printobs=5 )

  run;

  %exit:

%mend Summarize_tr10;

/** End Macro Definition **/
%Summarize_tr10( level=geo2010 )


************************************
	Summarize Parcel Data by ObjectID
************************************;


  proc summary data=parcel_level nway completetypes;
      class objectid;
    	var unit_count rent_controlled_units dc_owned vacant_land vacant_structure sale_2009 sale_2010 sale_2011 sale_2012 sale_2013
			sale_last5 tax_prop expiring_14to19 expiring_20to24;
    output 
		out=parcel_level_sum_objid (drop= _type_ _freq_) 
      sum (unit_count rent_controlled_units dc_owned vacant_land vacant_structure sale_2009 sale_2010 sale_2011 sale_2012 sale_2013
			sale_last5 tax_prop expiring_14to19 expiring_20to24)=
	  ;
  run;



/*Merge tract and parcel-level files for complete Bridge Park tract-level files*/

proc sort data=tract_level_sum_tr10
out=tract_summary_sorted;
by geo2010;
run;

proc sort data=parcel_level_sum_tr10
out=parcel_summary_sorted;
by geo2010;
run;

ODS LISTING;
ODS HTML FILE = "L:\Libraries\Requests\Data\bridge_park_tr10.xls" ;
TITLE1 "Bridge Park Data: Tract-Level";
data requests.bridge_park_12_23_14_tr10 (where=(geo2010 in ('11001007401', '11001007406', '11001007407', '11001007503', '11001007504', '11001007601', 
		'11001007605', '11001006500', '11001006600', '11001006700', '11001006802', '11001006900', '11001007000', '11001007100', 
		'11001007200')));
merge tract_summary_sorted parcel_summary_sorted;
by geo2010;
if total_units=. then total_units=0;
if hptf_property=. then hptf_property=0;
if tax_prop=. then tax_prop=0;
if expiring_14to19=. then expiring_14to19=0;
if expiring_20to24=. then expiring_20to24=0;
run;
ods html close;

ODS LISTING;
ODS HTML FILE = "L:\Libraries\Requests\Data\bridge_park_xy.xls" ;
TITLE1 "Bridge Park Data: Parcel-Level (X-Y)";
data requests.bridge_park_12_23_14_xy;
	set parcel_level (keep=ssl ownername_full ownercat owner_occ_sale unit_count rent_controlled rent_controlled_units dc_owned vacant_land vacant_structure 
	 ui_proptype saledate saleprice sale_2009 sale_2010 sale_2011 sale_2012 sale_2013
			sale_last5 portfolio compl_end tax_prop expiring_14to19 expiring_20to24);
	if tax_prop=. then tax_prop=0;
	if expiring_14to19=. then expiring_14to19=0;
	if expiring_20to24=. then expiring_20to24=0;
			run;
ods html close;

ODS LISTING;
ODS HTML FILE = "L:\Libraries\Requests\Data\bridge_park_objid.xls" ;
TITLE1 "Bridge Park Data: Parcel-Level (Polygon)";
data requests.bridge_park_12_23_14_objid;
	set parcel_level_sum_objid (keep=objectid unit_count rent_controlled_units dc_owned vacant_land vacant_structure sale_2009 sale_2010 sale_2011 sale_2012 sale_2013
			sale_last5 tax_prop expiring_14to19 expiring_20to24);
	if tax_prop=. then tax_prop=0;
	if expiring_14to19=. then expiring_14to19=0;
	if expiring_20to24=. then expiring_20to24=0;
			run;
ods html close;

%file_info( data=requests.bridge_park_12_23_14_tr10, printobs=5 )
%file_info( data=requests.bridge_park_12_23_14_xy, printobs=5 )
%file_info( data=requests.bridge_park_12_23_14_objid, printobs=5 )
