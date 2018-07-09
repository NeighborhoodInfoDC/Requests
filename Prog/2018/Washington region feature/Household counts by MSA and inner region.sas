/**************************************************************************
 Program:  Household Counts for MSA and inner regions.sas
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

data NCDBMaster;
      set ncdb.ncdb_master_update;
      metro15 = put( ucounty, $ctym15f. );
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600", "51610") then innercounty = 1;
run;


proc summary data = NCDBMaster;
      var numhhs9 numhhs0 numhhs1;
      output out = NCDB_msa_hh sum=;
run;

proc export data=NCDB_msa_hh
   outfile='L:\Libraries\Requests\Data\washington region feature\NCDB_msa_hh.csv'
   dbms=csv
   replace;
run;


proc summary data = NCDBMaster (where=(innercounty=1));
      var numhhs9 numhhs0 numhhs1;
      output out = NCDB_inner_hh sum=;
run;

proc freq data=ncdb.ncdb_master_update;
tables ucounty;
run;

proc export data=NCDB_inner_hh
   outfile='L:\Libraries\Requests\Data\washington region feature\NCDB_inner_hh.csv'
   dbms=csv
   replace;
run;

data ACSallstates;
	  set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;
run;

proc summary data = ACSallstates;
	class  metro15;
	var   numhshlds_2012_16;
	output out = ACS_msa_hh_2016 sum = ;
run;

proc export data= ACS_msa_hh_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_msa_hh_2016.csv'
   dbms=csv
   replace;
run;

proc summary data = ACSallstates(where=(innercounty=1));
	var   numhshlds_2012_16;
	output out = ACS_inner_hh_2016 sum = ;
run;

proc export data= ACS_inner_hh_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_inner_hh_2016.csv'
   dbms=csv
   replace;
run;
