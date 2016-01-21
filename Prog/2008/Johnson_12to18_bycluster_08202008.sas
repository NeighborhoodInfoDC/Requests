/**************************************************************************
 Program:  Cluster_23_12to18.sas
 Library:  DCData\Libraries\Requests
 Project:  NeighborhoodInfo DC - Data Request
 Author:   Lesley Freiman	
 Created:  8/20/2008
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Pull male/females 12-18 and convert to clusters 
 
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( census )
%DCData_lib( general )
%DCData_lib( requests );
 
rsubmit;

data age_12to18 ;/* creates a file on the alpha - temp */
set census.Cen2000_sf1_dc_ph
(keep= geo2000 sumlev p14i36 p14i37 p14i38 p14i39 p14i40 p14i41 
	p14i42 p14i15 p14i16 p14i17 p14i18 p14i19 p14i20 
	p14i21)
	;
where sumlev="140";
run;

data sum_age_12to18;
set age_12to18;
youth = p14i36 + p14i37 + p14i38 + p14i39 + p14i40 + p14i41 + p14i42 +
		 p14i15 + p14i16 + p14i17 + p14i18 + p14i19 + p14i20 + p14i21;
label youth = "Youth age 12 to 18";
drop p14i36 p14i37 p14i38 p14i39 p14i40 p14i41 p14i42
		 p14i15 p14i16 p14i17 p14i18 p14i19 p14i20 p14i21;
run;

/*downloads to PC*/
proc download inlib=work outlib=requests;
select sum_age_12to18;
run;
endrsubmit;

data sum_age_12to18;
set requests.sum_age_12to18;
run;
/* transforms tracts to wards */

%Transform_geo_data(
    dat_ds_name = sum_age_12to18,
    dat_org_geo = geo2000, 


/* add in vars here count*/	
    dat_count_vars = /*2000 variables*/ youth
    ,

/* add in vars here proportion*/
/*,*/
	
	wgt_ds_name = general.Wt_tr00_cltr00,
	wgt_org_geo=geo2000,
	wgt_new_geo=cluster_tr2000,
    wgt_wgt_var = popwt,
	
    out_ds_name = requests.sum_age12to18_cluster,
    out_ds_label = Number of youth by cluster
  );
run;

**OUTPUT to spreadsheet;
filename fexport "D:\DCDATA\Libraries\Requests\Data\age12to18_cluster.csv" lrecl=2000;

proc export data=Requests.sum_age12to18_cluster
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;


