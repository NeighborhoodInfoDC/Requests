/**************************************************************************
 Program:  CNP_2019_10.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  10/11/19	
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Tables for Mary's Center project.
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DCRA )
%DCData_lib( Realprop )
%DCData_lib( ACS )

%let ziplist = "20019","20020","20032";
%let cllist = "28","29","30","31","32","33","34","35","36","37","38","39","43";

/* Permits */
data permits_cnp;
	set dcra.permits_sum_city dcra.permits_sum_zip dcra.permits_sum_cl17;
	keep zip cluster2017 permits_2010 permits_2011 permits_2012 permits_2013 permits_2014 permits_2015 permits_2016 permits_2017 permits_2018;
	if zip in ("",&ziplist.);
	if cluster2017 in ("",&cllist.);
run;


/* Home prices */
data realprop_cnp;
	set realprop.sales_sum_city realprop.sales_sum_zip realprop.sales_sum_cl17;
	keep zip mprice_tot_2008 mprice_tot_2009 mprice_tot_2010 mprice_tot_2011 mprice_tot_2012 mprice_tot_2013 mprice_tot_2014 mprice_tot_2015 mprice_tot_2016;
	if zip in ("",&ziplist.);
	if cluster2017 in ("",&cllist.);
run;


/* Demographics */
data acs_cnp;
	set acs.acs_2013_17_dc_sum_regcnt_regcnt acs.acs_2013_17_dc_sum_tr_zip acs.acs_2013_17_dc_sum_tr_cl17;
	if zip in ("",&ziplist.);
	if cluster2017 in ("",&cllist.);
	keep zip totpop_2013_17 
		popnonenglish_2013_17 pcteng pctnongen	
		popunder18years_2013_17	pop25_64years_2013_17 pop65andoveryears_2013_17	pctunder18 pct25_64 pct65over
		popwithrace_2013_17 popwhitenonhispbridge_2013_17 popblacknonhispbridge_2013_17	pophisp_2013_17	pctwhite pctblk pcthisp pctoth
		medfamincm_2013_17	
	;

	pctnongen = popnonenglish_2013_17 / totpop_2013_17;
	pcteng = 1 - pctnongen;

	pctunder18 = popunder18years_2013_17 / totpop_2013_17;
	pct25_64 = pop25_64years_2013_17 / totpop_2013_17;
	pct65over = pop65andoveryears_2013_17 / totpop_2013_17;

	pctwhite = popwhitenonhispbridge_2013_17 / popwithrace_2013_17;
	pctblk = popblacknonhispbridge_2013_17 / popwithrace_2013_17;
	pcthisp = pophisp_2013_17 / popwithrace_2013_17;
	pctoth = 1 - pctwhite - pctblk - pcthisp;


run;

