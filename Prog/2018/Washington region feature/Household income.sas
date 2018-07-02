/**************************************************************************
 Program:  Household income.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  6/28/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description: Pull income distribution and agg hh income for ACS and NCDB for 
 	      Washington Affordable Housing feature. 

**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";
%dcdata_lib( requests )
%dcdata_lib( acs )
%dcdata_lib( ncdb );

data ACSallstates ( where=(metro15="47900") keep=metro15 county innercounty  hshldinc: mhshldinc: agghshldincome_2012_16 numhshlds_2012_16);
	  set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;
run;



proc summary data = ACSallstates;
	class  metro15;
	var   hshldinc: agghshldincome_2012_16 numhshlds_2012_16;
	output out = ACS_msa_hhinc_2016 sum = ;
run;

proc export data= ACS_msa_hhinc_2016
   outfile="&_dcdata_default_path\Requests\Prog\2018\Washington region feature\ACS_msa_hhinc_2016.csv"
   dbms=csv
   replace;
run;

proc summary data = ACSallstates;
	class  innercounty;
	var   hshldinc: agghshldincome_2012_16 numhshlds_2012_16;
	output out = ACS_inner_hhinc_2016 sum = ;
run;

proc export data= ACS_inner_hhinc_2016 
   outfile="&_dcdata_default_path\Requests\Prog\2018\Washington region feature\ACS_inner_hhinc_2016.csv"
   dbms=csv
   replace;
run;

data ACSallstates_2010 ( where=(metro15="47900") keep=metro15 county innercounty  hshldinc: mhshldinc:  agghshldincome_2006_10 numhshlds_2006_10);
	  set acs.acs_2006_10_va_sum_regcnt_regcnt acs.acs_2006_10_dc_sum_regcnt_regcnt acs.acs_2006_10_md_sum_regcnt_regcnt acs.acs_2006_10_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;
run;

data adjust;
	set ACSallstates_2010;

%dollar_convert(agghshldincome_2006_10,ADJagghshldincome_2006_10,2010,2016);
run;


proc summary data = adjust ;
	class  metro15;
	var   hshldinc: ADJagghshldincome_2006_10 numhshlds_2006_10;
	output out = ACS_msa_hhinc_2010 sum = ;
run;

proc export data= ACS_msa_hhinc_2010
   outfile="&_dcdata_default_path\Requests\Prog\2018\Washington region feature\ACS_msa_hhinc_2010.csv"
   dbms=csv
   replace;
run;

proc summary data = adjust ;
	class  innercounty;
	var   hshldinc: ADJagghshldincome_2006_10 numhshlds_2006_10;
	output out = ACS_inner_hhinc_2010 sum = ;
run;

proc export data= ACS_inner_hhinc_2010 
   outfile="&_dcdata_default_path\\Requests\Prog\2018\Washington region feature\ACS_inner_hhinc_2010.csv"
   dbms=csv
   replace;
run;



data NCDBMaster;
      set ncdb.ncdb_master_update;
      metro15 = put( ucounty, $ctym15f. );
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600") then innercounty = 1;
    if metro15 = "47900";
run;


proc summary data = NCDBMaster;
      var  avhhin9n avhhin0n numhhs9 numhhs0;
      output out = msa_income sum=;
run;
data msa_income_adj;

	set msa_income;

	%dollar_convert(avhhin9n,avhhin9n_adj,1989,2016);
	%dollar_convert(avhhin0n,avhhin0n_adj,1999,2016);

	run;

proc print data=msa_income_adj;
  title2 "MSA income";
run;

proc summary data = NCDBMaster (where=(innercounty=1));
      var avhhin9n avhhin0n numhhs9 numhhs0;
      output out = inner_income sum=;
run;
data inner_income_adj;

	set inner_income;

	%dollar_convert(avhhin9n,avhhin9n_adj,1989,2016);
	%dollar_convert(avhhin0n,avhhin0n_adj,1999,2016);

	run;
proc print data=inner_income_adj;
  title2 "Inner region income";
run;

title2;
