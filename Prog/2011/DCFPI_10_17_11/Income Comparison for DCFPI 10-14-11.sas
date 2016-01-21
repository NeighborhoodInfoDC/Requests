/**************************************************************************
 Program:  Income Comparison for DCFPI.sas
 Project:  NIDC
 Author:   Rob Pitingolo
 Created:  10-14-11

 Description:  Pulls the number and share of households earning over $60,000 in 2000
			   and $75,000 in 2005-9 by DC neighborhood cluster.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
	options nofmterr ;

** Define libraries **;
%DCData_lib( general )
libname cen "D:\2000 Census Datasets";
libname acs "D:\ACS Datasets";


** Import 2000 Census data from spreadsheet **;

proc import out = work.DC_2000_IncomeHH
			datafile = "D:\DCData\Requests\raw\DC_2000_IncomeHH.csv" 
			dbms = csv replace ;
	getnames = yes ;
	datarow = 2 ;
run;

** For 2000, define "Wealthy" as income $60,000 and above **;

data income_2000;
	set DC_2000_IncomeHH;

	geo2000 = put(geoID2,11.);

	NumHshlds_2000 = t1;
	WealthyHshlds_2000 = sum(of t12 t13 t14 t15 t16 t17);

run;

** For 2005-9, define "Wealthy" as income $75,000 and above ** ;

data income_acs;
	set acs.Nat_acs20095_tr00_new
		(keep = geoid NumHshldsWInc75000to99999 NumHshldsWInc100000plus NumHshlds);

	geo2000 = substr(geoid,8,11);

	WealthyHshlds_acs = sum(of NumHshldsWInc75000to99999 NumHshldsWInc100000plus);
	NumHshlds_acs = NumHshlds ;

run;

** Transform tract-data into cluster data ** ;

%Transform_geo_data(
    dat_ds_name=income_2000,
    dat_org_geo=Geo2000,
    dat_count_vars=WealthyHshlds_2000 NumHshlds_2000,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_tr00_cl00,
    wgt_org_geo=Geo2000,
    wgt_new_geo=Cluster2000,
    wgt_id_vars=,
    wgt_wgt_var=PopWt,
    out_ds_name=income_2000_clusters,
    out_ds_label=%str(Wealthy HHs by Neighborhood Cluster),
    calc_vars=PctWealthyHshlds_2000 = WealthyHshlds_2000 / NumHshlds_2000,
    calc_vars_labels=
  )

%Transform_geo_data(
    dat_ds_name=income_acs,
    dat_org_geo=Geo2000,
    dat_count_vars=WealthyHshlds_acs NumHshlds_acs,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_tr00_cl00,
    wgt_org_geo=Geo2000,
    wgt_new_geo=Cluster2000,
    wgt_id_vars=,
    wgt_wgt_var=PopWt,
    out_ds_name=income_acs_clusters,
    out_ds_label=%str(Wealthy HHs by Neighborhood Cluster),
    calc_vars=PctWealthyHshlds_acs = WealthyHshlds_acs / NumHshlds_acs,
    calc_vars_labels=
  )

** Merge both years into a single dataset ** ;

data compare_wealth ;
	merge Income_2000_clusters Income_acs_clusters;
	by Cluster2000 ;
run;
