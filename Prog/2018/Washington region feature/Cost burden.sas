


data allstats;
	set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;

	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600") then innercounty = 1;
run;


proc summary data = allstats ;
	class metro15 ;
	var TotPop_2012_16;
	output out = tp sum = ;
run;

proc summary data = allstats ;
	class innercounty ;
	var TotPop_2012_16;
	output out = tp sum = ;
run;
