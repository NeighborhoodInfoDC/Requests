/**************************************************************************
 Program:  Cost burden.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/26/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )

data ACSallstates;
	  set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600", "51610") then innercounty = 1;
run;
proc sort data=ACSallstates;
by county;
run;

proc summary data = ACSallstates (where=(metro15="47900"));
	var numrentercostburden_2012_16 numrentseverecostburden_2012_16 rentcostburdendenom_2012_16 numownercostburden_2012_16 numownseverecostburden_2012_16 ownercostburdendenom_2012_16;
    by county;
    output out = ACS_MSACounty_rentburdened_2016 sum = ;
run;

data ACS_MSACounty_rentburdened_2016;
    set ACS_MSACounty_rentburdened_2016;
	renterburdened = numrentercostburden_2012_16/rentcostburdendenom_2012_16;
	rentersevereburdened = numrentseverecostburden_2012_16/rentcostburdendenom_2012_16;
	ownerburdened = numownercostburden_2012_16/ownercostburdendenom_2012_16;
	ownersevereburdened = numownseverecostburden_2012_16/ownercostburdendenom_2012_16;
run;

proc export data=ACS_MSACounty_rentburdened_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_MSACounty_rentburdened_2016.csv'
   dbms=csv
   replace;
run;

proc summary data = ACSallstates;
    class metro15;
	var numrentercostburden_2012_16 numrentseverecostburden_2012_16 rentcostburdendenom_2012_16 numownercostburden_2012_16 numownseverecostburden_2012_16 ownercostburdendenom_2012_16;
    output out = ACS_MSAall_rentburdened_2016 sum = ;
run;
data ACS_MSAall_rentburdened_2016;
    set ACS_MSAall_rentburdened_2016;
	renterburdened = numrentercostburden_2012_16/rentcostburdendenom_2012_16;
	rentersevereburdened = numrentseverecostburden_2012_16/rentcostburdendenom_2012_16;
	ownerburdened = numownercostburden_2012_16/ownercostburdendenom_2012_16;
	ownersevereburdened = numownseverecostburden_2012_16/ownercostburdendenom_2012_16;
run;

proc export data=ACS_MSACounty_rentburdened_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_MSAall_rentburdened_2016.csv'
   dbms=csv
   replace;
run;

proc summary data = ACSallstates;
    class innercounty;
	var numrentercostburden_2012_16 numrentseverecostburden_2012_16 rentcostburdendenom_2012_16 numownercostburden_2012_16 numownseverecostburden_2012_16 ownercostburdendenom_2012_16;
    output out = ACS_Innerall_rentburdened_2016 sum = ;
run;
data ACS_Innerall_rentburdened_2016;
    set ACS_Innerall_rentburdened_2016;
	renterburdened = numrentercostburden_2012_16/rentcostburdendenom_2012_16;
	rentersevereburdened = numrentseverecostburden_2012_16/rentcostburdendenom_2012_16;
	ownerburdened = numownercostburden_2012_16/ownercostburdendenom_2012_16;
	ownersevereburdened = numownseverecostburden_2012_16/ownercostburdendenom_2012_16;
run;

proc export data=ACS_Innerall_rentburdened_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_Innerall_rentburdened_2016.csv'
   dbms=csv
   replace;
run;

data ACSallstates_2010;
	  set acs.acs_2006_10_va_sum_regcnt_regcnt acs.acs_2006_10_dc_sum_regcnt_regcnt acs.acs_2006_10_md_sum_regcnt_regcnt acs.acs_2006_10_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600", "51610") then innercounty = 1;
run;
proc sort data=ACSallstates_2010;
by county;
run;

proc summary data = ACSallstates_2010 (where=(metro15="47900"));
	var numrentercostburden_2006_10 numrentseverecostburden_2006_10 rentcostburdendenom_2006_10 numownercostburden_2006_10 numownseverecostburden_2006_10 ownercostburdendenom_2006_10;
    by county;
    output out = ACS_MSACounty_rentburdened_2010 sum = ;
run;

data ACS_MSACounty_rentburdened_2010;
    set ACS_MSACounty_rentburdened_2010;
	renterburdened = numrentercostburden_2006_10/rentcostburdendenom_2006_10;
	rentersevereburdened = numrentseverecostburden_2006_10/rentcostburdendenom_2006_10;
	ownerburdened = numownercostburden_2006_10/ownercostburdendenom_2006_10;
	ownersevereburdened = numownseverecostburden_2006_10/ownercostburdendenom_2006_10;
run;

proc export data=ACS_MSACounty_rentburdened_2010
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_MSACounty_rentburdened_2010.csv'
   dbms=csv
   replace;
run;

proc summary data = ACSallstates_2010;
    class metro15;
	var numrentercostburden_2006_10 numrentseverecostburden_2006_10 rentcostburdendenom_2006_10 numownercostburden_2006_10 numownseverecostburden_2006_10 ownercostburdendenom_2006_10;
    output out = ACS_MSAall_rentburdened_2010 sum = ;
run;
data ACS_MSAall_rentburdened_2010;
    set ACS_MSAall_rentburdened_2010;
	renterburdened = numrentercostburden_2006_10/rentcostburdendenom_2006_10;
	rentersevereburdened = numrentseverecostburden_2006_10/rentcostburdendenom_2006_10;
	ownerburdened = numownercostburden_2006_10/ownercostburdendenom_2006_10;
	ownersevereburdened = numownseverecostburden_2006_10/ownercostburdendenom_2006_10;
run;

proc export data=ACS_MSACounty_rentburdened_2010
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_MSAall_rentburdened_2010.csv'
   dbms=csv
   replace;
run;

proc summary data = ACSallstates_2010;
    class innercounty;
	var numrentercostburden_2006_10 numrentseverecostburden_2006_10 rentcostburdendenom_2006_10 numownercostburden_2006_10 numownseverecostburden_2006_10 ownercostburdendenom_2006_10;
    output out = ACS_Innerall_rentburdened_2010 sum = ;
run;
data ACS_Innerall_rentburdened_2010;
    set ACS_Innerall_rentburdened_2010;
	renterburdened = numrentercostburden_2006_10/rentcostburdendenom_2006_10;
	rentersevereburdened = numrentseverecostburden_2006_10/rentcostburdendenom_2006_10;
	ownerburdened = numownercostburden_2006_10/ownercostburdendenom_2006_10;
	ownersevereburdened = numownseverecostburden_2006_10/ownercostburdendenom_2006_10;
run;

proc export data=ACS_Innerall_rentburdened_2010
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_Innerall_rentburdened_2010.csv'
   dbms=csv
   replace;
run;


data NCDBcostburden;
      set ncdb.ncdb_master_update ;
	  m30pi0= spownoc0-m20pi0-M29PI0;
	  r30pi0= rntocc0-R20PI0-R29PI0;
      metro15 = put( ucounty, $ctym15f. );
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;
run;

proc summary data = NCDBcostburden(where=(metro15="47900"));
      var  m50pi0 m29pi0 m20pi0 spownoc0 R50Pi0 R20Pi0 R29Pi0 rntocc0 ;
	  by ucounty;
      output out = NCDB_msabycounty_costburden_2000 sum=;
run;
data NCDB_msabycounty_costburden_2000;
  set NCDB_msabycounty_costburden_2000;
      renterburdened = (rntocc0-R20Pi0-R29Pi0)/rntocc0;
      rentersevereburdened = R50Pi0/rntocc0;
      ownerburdened = (spownoc0-m29pi0-m20pi0)/spownoc0;
	  ownersevereburdened = m50pi0/spownoc0;
run;


proc export data=NCDB_msabycounty_costburden_2000
   outfile='L:\Libraries\Requests\Data\washington region feature\NCDB_msabycounty_costburden_2000.csv'
   dbms=csv
   replace;
run;

proc summary data = NCDBcostburden;
      class metro15;
      var  m50pi0 m29pi0 m20pi0 spownoc0 R50Pi0 R20Pi0 R29Pi0 rntocc0 ;
      output out = NCDB_msaall_costburden_2000 sum=;
run;

data NCDB_msaall_costburden_2000;
  set NCDB_msaall_costburden_2000;
      renterburdened = (rntocc0-R20Pi0-R29Pi0)/rntocc0;
      rentersevereburdened = R50Pi0/rntocc0;
      ownerburdened = (spownoc0-m29pi0-m20pi0)/spownoc0;
	  ownersevereburdened = m50pi0/spownoc0;
run;
proc export data=NCDB_msaall_costburden_2000
   outfile='L:\Libraries\Requests\Data\washington region feature\NCDB_msaall_costburden_2000.csv'
   dbms=csv
   replace;
run;

proc summary data = NCDBcostburden;
      class innercounty;
      var  m50pi0 m29pi0 m20pi0 spownoc0 R50Pi0 R20Pi0 R29Pi0 rntocc0 ;
      output out = NCDB_innerall_costburden_2000 sum=;
run;

data NCDB_innerall_costburden_2000;
  set NCDB_innerall_costburden_2000;
      renterburdened = (rntocc0-R20Pi0-R29Pi0)/rntocc0;
      rentersevereburdened = R50Pi0/rntocc0;
      ownerburdened = (spownoc0-m29pi0-m20pi0)/spownoc0;
	  ownersevereburdened = m50pi0/spownoc0;
run;
proc export data=NCDB_innerall_costburden_2000
   outfile='L:\Libraries\Requests\Data\washington region feature\NCDB_innerall_costburden_2000.csv'
   dbms=csv
   replace;
run;

