/**************************************************************************
 Program:  Rental and for-sale vacancy.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  7/2/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

data ACSallstates;
	  set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;
	  metro15 = put( county, $ctym15f. );
      if county in ("11001","24031","24033","51013","51059","51107","51510","51600", "51610") then innercounty = 1;
run;

proc summary data = ACSallstates;
    class innercounty;
	var numvacanthsgunitsforrent_2012_16 numvacanthsgunitsforsale_2012_16 numrenterhsgunits_2012_16 numowneroccupiedhu_2012_16;
    output out = ACS_innerregion_vacancy_2016 sum = ;
run;

data ACS_innerregion_vacancy_2016;
    set ACS_innerregion_vacancy_2016;
	rentalvacancy= numvacanthsgunitsforrent_2012_16/numrenterhsgunits_2012_16;
	numvacanthuforsale_2012_16 = numvacanthsgunitsforsale_2012_16/(numvacanthsgunitsforsale_2012_16 + numowneroccupiedhu_2012_16);
run;

proc export data = ACS_innerregion_vacancy_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\ACS_innerregion_vacancy_2016.csv'
   dbms=csv
   replace;
run;
