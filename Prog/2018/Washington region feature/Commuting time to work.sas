/**************************************************************************
 Program:  Commuting time to work.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng and Rob
 Created:  6/26/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )

data NCDBTravel;
      set ncdb.ncdb_master_update;
      metro15 = put( ucounty, $ctym15f. );
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600") then innercounty = 1;
run;
proc freq data=NCDBTravel;
tables ucounty COUNTY;
run;

proc summary data = NCDBTravel;
      var commut20 commut40 commutx0;
	  by ucounty;
      output out = msa_travel_2000 sum=;
run;

proc export data=msa_travel_2000
   outfile='L:\Libraries\Requests\Data\washington region feature\NCDB_msa_travel_2000.csv'
   dbms=csv
   replace;
run;


proc summary data = NCDBTravel (where=(innercounty=1));
      var commut20 commut40 commutx0;
	  by ucounty;
      output out = inner_travel_2000 sum=;
run;

proc export data=inner_travel_2000
   outfile='L:\Libraries\Requests\Data\washington region feature\NCDB_inner_travel_2000.csv'
   dbms=csv
   replace;
run;

data ACSallstates;
	  set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
	  lessthan25= popemployedtravel_lt5_2012_16+ popemployedtravel_5_9_2012_16+ popemployedtravel_10_14_2012_16+ popemployedtravel_15_19_2012_16 +
                   popemployedtravel_20_24_2012_16;
	  morethan25lessthan44 = popemployedtravel_25_29_2012_16 + popemployedtravel_30_34_2012_16 + popemployedtravel_35_39_2012_16 + popemployedtravel_40_44_2012_16;
	  morethan45= popemployedtravel_45_59_2012_16 + popemployedtravel_60_89_2012_16 + popemployedtravel_gt90_2012_16 ;
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600") then innercounty = 1;
run;

proc summary data = ACSallstates ;
	class metro15 ;
	var    popemployedtravel_lt5_2012_16  popemployedtravel_5_9_2012_16 popemployedtravel_10_14_2012_16 popemployedtravel_15_19_2012_16 
           popemployedtravel_20_24_2012_16 popemployedtravel_25_29_2012_16
           popemployedtravel_30_34_2012_16  popemployedtravel_35_39_2012_16 popemployedtravel_40_44_2012_16 popemployedtravel_45_59_2012_16
           popemployedtravel_60_89_2012_16 popemployedtravel_gt90_2012_16 lessthan25 morethan25lessthan44 morethan45;
	output out = ACS_msa_travel_2016 sum = ;
run;

proc export data=ACS_msa_travel_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_msa_travel_2016.csv'
   dbms=csv
   replace;
run;
proc sort data=ACSallstates;
by county;
run;

proc summary data = ACSallstates (where=(metro15="47900"));
	var    popemployedtravel_lt5_2012_16  popemployedtravel_5_9_2012_16 popemployedtravel_10_14_2012_16 popemployedtravel_15_19_2012_16 
           popemployedtravel_20_24_2012_16 popemployedtravel_25_29_2012_16
           popemployedtravel_30_34_2012_16  popemployedtravel_35_39_2012_16 popemployedtravel_40_44_2012_16 popemployedtravel_45_59_2012_16
           popemployedtravel_60_89_2012_16 popemployedtravel_gt90_2012_16 lessthan25 morethan25lessthan44 morethan45;
	by county;
	output out = ACS_MSAbycounty_travel_2016 sum = ;
run;

proc export data=ACS_innercounty_travel_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_MSAbycounty_2016.csv'
   dbms=csv
   replace;
run;
