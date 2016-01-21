/**************************************************************************
 Program:  dc parks.sas
 Library:  requests 
 Project:  NeighborhoodInfo DC
 Author:   Megan Gallagher
 Created:  6/20/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Produce selected demographic characteristics for clusters

 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

/* Note: K:\Metro\PTatian\DCData\Procedures\addingdata.html */
** Define libraries **;
%DCData_lib( requests ) /*request library */
%DCData_lib( general ) /*cluster-tract weighting file location*/

/* create vars and add macro for transform */
data temp2;
set requests.dcparksdata;
/* number of people in each age group */
	age0_4	=fem40 + men40;
	age5_9	=fem90 + men90;
	age10_14=fem140 + men140;
	age15_19=fem190 + men190;
	age20_24=fem240 + men240;
	age25_44=fem290 + fem340 + fem440 + men290 + men340 + men440;
	age45_64=fem540 + fem640 + men540 + men640;
	age65plus=fem740 + fem750 + men740 + men750;
/* number of households in each income group */
	inc0_20=thy0100 + thy0150 + thy0200; 
	inc20_30=thy0250 + thy0300;
	inc30_40=thy0350 + thy0400;
	inc40_50=thy0450 + thy0500;
	inc50_75=thy0600 + thy0750;
	inc75plus=thy01000 + thy01250 + thy01500 + thy02000 + thy0m200;
run;

*******************************************************************
CLUSTER-LEVEL ANALYSES
******************************************************************;
*load file with cluster/type formats*;
%include 'k:\metro\maturner\hnc2005\programs\hncformats.sas';

/* transforms tracts to clusters */
%Transform_geo_data(
    dat_ds_name = temp2,
    dat_org_geo = geo2000, 

/* add in vars here count->counts prop->medians*/	
    dat_count_vars = MINWHT0N MINBLK0N MINAMI0N MINAPI0N MINOTH0N mrapop0n shrhsp0n
	age0_4 age5_9 age10_14 age15_19 age20_24 age25_44 age45_64 age65plus
	inc0_20 inc20_30 inc30_40 inc40_50 inc50_75 inc75plus 
	AVHHIN0N WELFAR0D 
	prsocu0 occhu0 ,

	dat_prop_vars = MDHHY0 , /* median age not available */

calc_vars = 
	hhavginc = AVHHIN0N / WELFAR0D;
	hhavgsiz = prsocu0 / occhu0; 
	,

calc_vars_labels = 
	hhavginc = "Average Household Income"
	hhavgsiz = "Average Household Size" 
	,
	
	wgt_ds_name = general.wt_tr00_cltr00,
	wgt_org_geo=geo2000,
	wgt_new_geo=cluster_tr2000,
    wgt_wgt_var = popwt,
	
    out_ds_name = general.dc_clusters,
    out_ds_label = DC Parks Request, keep_nonmatch=Y);

run;

proc sort data=general.dc_clusters;
by cluster_tr2000;
run;

filename outexc dde "Excel|D:\DC Parks\[Demographics by cluster.xls]Sheet1!R3C3:R42C27"; 

data _null_ ;
	file outexc lrecl=65000;
	set general.dc_clusters;
	put cluster_tr2000 MINWHT0N MINBLK0N MINAMI0N MINAPI0N MINOTH0N mrapop0n shrhsp0n
	age0_4 age5_9 age10_14 age15_19 age20_24 age25_44 age45_64 age65plus
	hhavginc hhavgsiz WELFAR0D
	inc0_20 inc20_30 inc30_40 inc40_50 inc50_75 inc75plus;
	run;
	