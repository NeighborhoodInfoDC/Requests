/**************************************************************************
 Program:  Household income.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  6/28/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";
%dcdata_lib( requests )
%dcdata_lib( acs )


data ACSallstates ( where=(metro15="47900") keep=metro15 county innercounty  hshldinc: mhshldinc:);
	  set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;
run;



proc summary data = ACSallstates;
	class  metro15;
	var   hshldinc:;
	output out = ACS_msa_hhinc_2016 sum = ;
run;

proc export data= ACS_msa_hhinc_2016
   outfile='D:\DCDATA\Libraries\Requests\Prog\2018\Washington region feature\ACS_msa_hhinc_2016.csv'
   dbms=csv
   replace;
run;

proc summary data = ACSallstates;
	class  innercounty;
	var   hshldinc:;
	output out = ACS_inner_hhinc_2016 sum = ;
run;

proc export data= ACS_inner_hhinc_2016 
   outfile='D:\DCDATA\Libraries\Requests\Prog\2018\Washington region feature\ACS_inner_hhinc_2016.csv'
   dbms=csv
   replace;
run;

data ACSallstates_2010 ( where=(metro15="47900") keep=metro15 county innercounty  hshldinc: mhshldinc:);
	  set acs.acs_2006_10_va_sum_regcnt_regcnt acs.acs_2006_10_dc_sum_regcnt_regcnt acs.acs_2006_10_md_sum_regcnt_regcnt acs.acs_2006_10_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;
run;



proc summary data = ACSallstates_2010 ;
	class  metro15;
	var   hshldinc:;
	output out = ACS_msa_hhinc_2010 sum = ;
run;

proc export data= ACS_msa_hhinc_2010
   outfile='D:\DCDATA\Libraries\Requests\Prog\2018\Washington region feature\ACS_msa_hhinc_2010.csv'
   dbms=csv
   replace;
run;

proc summary data = ACSallstates_2010 ;
	class  innercounty;
	var   hshldinc:;
	output out = ACS_inner_hhinc_2010 sum = ;
run;

proc export data= ACS_inner_hhinc_2010 
   outfile='D:\DCDATA\Libraries\Requests\Prog\2018\Washington region feature\ACS_inner_hhinc_2010.csv'
   dbms=csv
   replace;
run;
