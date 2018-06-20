/**********************************************************************;

 Program:  Byrne_MW.sas
 Library:  REQUESTS
 Project:  Byrne Grant via NeighborhoodInfo DC
 Author:   Maia Woluchem
 Created:  06/23/2016
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description: Creates a PSA-level summary data set for the Byrne Community Empowerment Team

 Modifications:
**********************************************************************/

/*For PSAs 602 and 608, Ward 7 and city*/

%include "L:\SAS\Inc\StdLocal.sas"; 

**Define libraries**;
%DCData_lib(Schools)
%DCData_lib(General)
%DCData_lib(ACS)
%DCData_lib(Requests)
%DCData_lib(HUD)
%DCData_lib(TANF)
%DCData_lib(Vital)

options nofmterr;

********************
PSA-Level Datasets
********************;

/*Check for relevant datapoints in the Schools and ACS Directories*/

proc contents data=schools.msf_sum_psa12;
run;

proc contents data=acs.acs_2010_14_sum_bg_psa12;
run;

proc contents data=acs.acs_2010_14_sum_tr_psa12;
run;

proc contents data=tanf.fs_sum_psa12;
run;

proc contents data=tanf.tanf_sum_psa12;
run;

proc contents data=vital.births_sum_psa12;
run;

proc contents data=vital.deaths_sum_psa12;
run;

/*Schools data - Create PSA-Level file taken from schools.msf_sum_psa12

	Variables: 
		aud_xxx: 				Total Enrolled at All Schools
		aud_charter_xxx:		Total Enrolled at Charter Schools
		aud_dcps_xxx:			Total Enrolled at DCPS Schools
		charter_present_xxxx:	Number of Charter Schools Open
		dcps_present_xxxx:		Number of DCPS Schools Open
		school_present_xxxx:	Number of Schools Open*/

data schools;
	set schools.msf_sum_psa12 (where=(PSA2012="602" or PSA2012="608") keep= PSA2012
		aud_2010 aud_2011 aud_2012 aud_2013 aud_2014
		aud_charter_2010 aud_charter_2011 aud_charter_2012 aud_charter_2013 aud_charter_2014
		aud_dcps_2010 aud_dcps_2011 aud_dcps_2012 aud_dcps_2013 aud_dcps_2014
		charter_present_2010 charter_present_2011 charter_present_2012 charter_present_2013 charter_present_2014
		dcps_present_2010 dcps_present_2011 dcps_present_2012 dcps_present_2013 dcps_present_2014
		school_present_2010 school_present_2011 school_present_2012 school_present_2013 school_present_2014)
	schools.msf_sum_wd12 (where=(WARD2012="7") keep= ward2012
		aud_2010 aud_2011 aud_2012 aud_2013 aud_2014
		aud_charter_2010 aud_charter_2011 aud_charter_2012 aud_charter_2013 aud_charter_2014
		aud_dcps_2010 aud_dcps_2011 aud_dcps_2012 aud_dcps_2013 aud_dcps_2014
		charter_present_2010 charter_present_2011 charter_present_2012 charter_present_2013 charter_present_2014
		dcps_present_2010 dcps_present_2011 dcps_present_2012 dcps_present_2013 dcps_present_2014
		school_present_2010 school_present_2011 school_present_2012 school_present_2013 school_present_2014)
	schools.msf_sum_city (keep= city
		aud_2010 aud_2011 aud_2012 aud_2013 aud_2014
		aud_charter_2010 aud_charter_2011 aud_charter_2012 aud_charter_2013 aud_charter_2014
		aud_dcps_2010 aud_dcps_2011 aud_dcps_2012 aud_dcps_2013 aud_dcps_2014
		charter_present_2010 charter_present_2011 charter_present_2012 charter_present_2013 charter_present_2014
		dcps_present_2010 dcps_present_2011 dcps_present_2012 dcps_present_2013 dcps_present_2014
		school_present_2010 school_present_2011 school_present_2012 school_present_2013 school_present_2014)
		;
	if PSA2012="602" then geography = "PSA 602";
	if PSA2012="608" then geography = "PSA 608";
	if ward2012="7" then geography = "Ward 7";
	if city^=. then geography = "City";
	label geography = "Geography";
	run;

/*ACS Data - Creates a PSA-Level File taken from acs.acs_2010_14 Summary file

	Variables: 
		AggFamilyIncome_2010_14 			Aggregate family income ($ 2014), 2010-14 
		NumFamilies_2010_14 				Family HHs, 2010-14 
		NumHshlds_2010_14 		  			Total HHs, 2010-14 
		NumOccupiedHsgUnits_2010_14 		Occupied housing units, 2010-14 
		NumOwnerOccupiedHsgUnits_2010_14 	Owner-occupied housing units, 2010-14 
		NumRenterHsgUnits_2010_14 			Total rental housing units, 2010-14 
		NumRenterOccupiedHsgUnit_2010_14 	Renter-occupied housing units, 2010-14 
		NumVacantHsgUnitsForRent_2010_14 	Vacant housing units for rent, 2010-14 
		NumVacantHsgUnitsForSale_2010_14 	Vacant housing units for sale, 2010-14 
		NumVacantHsgUnits_2010_14 		 	Vacant housing units, 2010-14 
		Pop25andOverWCollege_2010_14 		Persons 25+ years old with a bachelors or graduate/prof degree, 2010-14 
		Pop25andOverWHS_2010_14 		  	Persons 25 years old and over with a high school diploma or GED, 2010-14 
		Pop25andOverWoutHS_2010_14 		   	Persons 25 years old and over without high school diploma, 2010-14 
		Pop25andOverYears_2010_14 		  	Persons 25 years old and over, 2010-14 
		Pop65andOverYears_2010_14 			Persons 65 years old and over, 2010-14 
		PopUnder18Years_2010_14				Persons under 18 years old, 2010-14 
		PopUnder5Years_2010_14 				Persons under 5 years old, 2010-14 
		TotPop_2010_14 						Total population, 2010-14 
		NumFamiliesOwnChildrenFH_2010_14 	Female-headed families and subfamilies with own children, 2010-14 
		NumFamiliesOwnChildren_2010_14 		Total families and subfamilies with own children, 2010-14 
		NumFamilies_2010_14  				Family HHs, 2010-14 
		PersonsPovertyDefined_2010_14 		Persons with poverty status determined, 2010-14 
		PopCivilianEmployed_2010_14 		Persons 16+ years old in the civilian labor force and employed, 2010-14 
		PopInCivLaborForce_2010_14			Persons 16+ years old in the civilian labor force, 2010-14 
		PopPoorChildren_2010_14 			Children under 18 years old below the poverty level last year, 2010-14 
		PopPoorElderly_2010_14 				Persons 65 years old and over below the poverty level last year, 2010-14 
		PopPoorPersons_2010_14 				Persons below the poverty level last year, 2010-14 
		PopUnemployed_2010_14 				Persons 16+ years old in the civilian labor force and unemployed, 2010-14 
	*/

data acs_allgeo;
	set acs.acs_2010_14_sum_bg_psa12 (where=(PSA2012="602" or PSA2012="608") keep=PSA2012
			aggfamilyincome_2010_14 numhshlds_2010_14  numfamilies: numoccupiedhsgunits_2010_14
			numowneroccupiedhsgunits_2010_14 numrenterhsgunits_2010_14 numrenteroccupiedhsgunit_2010_14
			numvacanthsgunitsforrent_2010_14 numvacanthsgunitsforsale_2010_14 numvacanthsgunits_2010_14
			totpop_2010_14 pop:)
		acs.acs_2010_14_sum_tr_psa12 (where=(PSA2012="602" or PSA2012="608") keep=PSA2012 numfamilies: 
			personspovertydefined_2010_14 popcivilianemployed_2010_14 popincivlaborforce_2010_14 poppoor: popunemployed_2010_14)
		acs.acs_2010_14_sum_bg_wd12 (where=(WARD2012="7") keep=WARD2012
			aggfamilyincome_2010_14 numhshlds_2010_14  numfamilies: numoccupiedhsgunits_2010_14
			numowneroccupiedhsgunits_2010_14 numrenterhsgunits_2010_14 numrenteroccupiedhsgunit_2010_14
			numvacanthsgunitsforrent_2010_14 numvacanthsgunitsforsale_2010_14 numvacanthsgunits_2010_14
			totpop_2010_14 pop:)
		acs.acs_2010_14_sum_tr_wd12 (where=(WARD2012="7") keep=WARD2012 numfamilies: 
			personspovertydefined_2010_14 popcivilianemployed_2010_14 popincivlaborforce_2010_14 poppoor: popunemployed_2010_14)
		acs.acs_2010_14_sum_bg_city (keep=city
			aggfamilyincome_2010_14 numhshlds_2010_14 numfamilies: numoccupiedhsgunits_2010_14
			numowneroccupiedhsgunits_2010_14 numrenterhsgunits_2010_14 numrenteroccupiedhsgunit_2010_14
			numvacanthsgunitsforrent_2010_14 numvacanthsgunitsforsale_2010_14 numvacanthsgunits_2010_14
			totpop_2010_14 pop:)
		acs.acs_2010_14_sum_tr_city (keep=city 
			numhshlds_2010_14 numfamilies: personspovertydefined_2010_14 popcivilianemployed_2010_14 
			popincivlaborforce_2010_14 poppoor: popunemployed_2010_14)
		;
	if PSA2012="602" then geography = "PSA 602";
	if PSA2012="608" then geography = "PSA 608";
	if WARD2012="7" then geography = "Ward 7";
	if city^=. then geography = "City";
	label geography = "Geography";
	run;

proc summary data=acs_allgeo nway completetypes;
      class geography;
      *format psa2012;
    	var aggfamilyincome_2010_14 numhshlds_2010_14 numfamilies: numoccupiedhsgunits_2010_14
			numowneroccupiedhsgunits_2010_14 numrenterhsgunits_2010_14 numrenteroccupiedhsgunit_2010_14
			numvacanthsgunitsforrent_2010_14 numvacanthsgunitsforsale_2010_14 numvacanthsgunits_2010_14
			totpop_2010_14 pop:
			personspovertydefined_2010_14 popcivilianemployed_2010_14 popincivlaborforce_2010_14 poppoor: popunemployed_2010_14;
    output 
		out=acs (drop= _type_ _freq_) 
      sum ( aggfamilyincome_2010_14 numhshlds_2010_14 numfamilies: numoccupiedhsgunits_2010_14
			numowneroccupiedhsgunits_2010_14 numrenterhsgunits_2010_14 numrenteroccupiedhsgunit_2010_14
			numvacanthsgunitsforrent_2010_14 numvacanthsgunitsforsale_2010_14 numvacanthsgunits_2010_14
			totpop_2010_14 pop:
			personspovertydefined_2010_14 popcivilianemployed_2010_14 popincivlaborforce_2010_14 poppoor: popunemployed_2010_14)=
	  ;
  run;

/*Housing - 
	
	Variables:
		total_units							Voucher Count
	*/

data housing;
	set hud.vouchers_sum_psa12 (where=(PSA2012="602" or PSA2012="608"))
		hud.vouchers_sum_wd12 (where=(ward2012="7"))
		hud.vouchers_sum_city;
	if PSA2012="602" then geography = "PSA 602";
	if PSA2012="608" then geography = "PSA 608";
	if WARD2012="7" then geography = "Ward 7";
	if city^=. then geography = "City";
	label geography = "Geography";
	run;

/*Food Stamps - 
	
	Variables:
		Fs_0to1 							Infants <2 years old (excluding unborn) receiving food stamps 
		Fs_2to5    							Toddlers 2-5 years old receiving food stamps 
		Fs_6to12    						Preteens 6-12 years old receiving food stamps 
		Fs_13to17    						Teens 13-17 years old receiving food stamps
		Fs_18to24    						Young adults 18-24 years old receiving food stamps 
		Fs_adult    						Adults 18+ years old receiving food stamps 
		Fs_adult_fch    					Adults 18+ years old in adult-only cases receiving food stamps 
		Fs_adult_fcp   						Adults 18+ years old in couple families receiving food stamps 
		Fs_adult_fot    					Adults 18+ years old in other families receiving food stamps 
		Fs_adult_fsf    					Adults 18+ years old in single-female families receiving food stamps
		Fs_adult_fsm    					Adults 18+ years old in single-male families receiving food stamps 
		Fs_case    							food stamps cases 
		Fs_case_fch    						food stamps child-only cases 
		Fs_case_fcp    						food stamps cases, couple families 
		Fs_case_fot    						food stamps cases, other family types 
		Fs_case_fsf    						food stamps cases, single-female families
		Fs_case_fsm    						food stamps cases, single-male families 
		Fs_child_fch    					Children <18 years old (excl. unborn) in child-only cases receiving food stamps 
		Fs_child_fcp    					Children <18 years old (excl. unborn) in couple families receiving food stamps 
		Fs_child_fot    					Children <18 years old (excl. unborn) in other families receiving food stamps 
		Fs_child_fsf    					Children <18 years old (excl. unborn) in single-female families receiving food stamps 
		Fs_child_fsm    					Children <18 years old (excl. unborn) in single-male families receiving food stamps 
		Fs_client_fch    					Persons in child-only cases receiving food stamps 
		Fs_client_fcp    					Persons in couple families receiving food stamps 
		Fs_client_fot    					Persons in other families receiving food stamps 
		Fs_client_fsf    					Persons in single-female families receiving food stamps
		Fs_client_fsm    					Persons in single-male families receiving food stamps 
		Fs_unborn_fch    					Unborn children in child-only cases receiving food stamps 
		Fs_unborn_fcp    					Unborn children in couple families receiving food stamps 
		Fs_unborn_fot    					Unborn children in other families receiving food stamps 
		Fs_unborn_fsf    					Unborn children in single-female families receiving food stamps 
		Fs_unborn_fsm    					Unborn children in single-male families receiving food stamps */

data foodstamps;
	set TANF.FS_SUM_PSA12 (where=(Psa2012="602" or PSA2012="608") keep=psa2012 fs_0to1_2014 fs_2to5_2014 fs_6to12_2014 fs_13to17_2014
			fs_adult_2014 fs_adult_fch_2014 fs_adult_fcp_2014 fs_adult_fot_2014 fs_adult_fsf_2014 fs_adult_fsm_2014 
			fs_case_2014 fs_case_fch_2014 fs_case_fcp_2014 fs_case_fot_2014 fs_case_fsf_2014 fs_case_fsm_2014
			fs_child_2014 fs_child_fch_2014 fs_child_fcp_2014 fs_child_fot_2014 fs_child_fsf_2014 fs_child_fsm_2014
			fs_client_2014 fs_client_fch_2014 fs_client_fcp_2014 fs_client_fot_2014 fs_client_fsf_2014 fs_client_fsm_2014
			fs_unborn_2014 fs_unborn_fch_2014 fs_unborn_fcp_2014 fs_unborn_fot_2014 fs_unborn_fsf_2014 fs_unborn_fsm_2014)
		TANF.FS_SUM_WD12 (where=(ward2012="7") keep=ward2012 fs_0to1_2014 fs_2to5_2014 fs_6to12_2014 fs_13to17_2014
			fs_adult_2014 fs_adult_fch_2014 fs_adult_fcp_2014 fs_adult_fot_2014 fs_adult_fsf_2014 fs_adult_fsm_2014 
			fs_case_2014 fs_case_fch_2014 fs_case_fcp_2014 fs_case_fot_2014 fs_case_fsf_2014 fs_case_fsm_2014
			fs_child_2014 fs_child_fch_2014 fs_child_fcp_2014 fs_child_fot_2014 fs_child_fsf_2014 fs_child_fsm_2014
			fs_client_2014 fs_client_fch_2014 fs_client_fcp_2014 fs_client_fot_2014 fs_client_fsf_2014 fs_client_fsm_2014
			fs_unborn_2014 fs_unborn_fch_2014 fs_unborn_fcp_2014 fs_unborn_fot_2014 fs_unborn_fsf_2014 fs_unborn_fsm_2014)
		TANF.FS_SUM_city (keep=city fs_0to1_2014 fs_2to5_2014 fs_6to12_2014 fs_13to17_2014
			fs_adult_2014 fs_adult_fch_2014 fs_adult_fcp_2014 fs_adult_fot_2014 fs_adult_fsf_2014 fs_adult_fsm_2014 
			fs_case_2014 fs_case_fch_2014 fs_case_fcp_2014 fs_case_fot_2014 fs_case_fsf_2014 fs_case_fsm_2014
			fs_child_2014 fs_child_fch_2014 fs_child_fcp_2014 fs_child_fot_2014 fs_child_fsf_2014 fs_child_fsm_2014
			fs_client_2014 fs_client_fch_2014 fs_client_fcp_2014 fs_client_fot_2014 fs_client_fsf_2014 fs_client_fsm_2014
			fs_unborn_2014 fs_unborn_fch_2014 fs_unborn_fcp_2014 fs_unborn_fot_2014 fs_unborn_fsf_2014 fs_unborn_fsm_2014)
			;
		if PSA2012="602" then geography = "PSA 602";
		if PSA2012="608" then geography = "PSA 608";
		if WARD2012="7" then geography = "Ward 7";
		if city^=. then geography = "City";
		label geography = "Geography";
		run;

/*TANF Cases - 
	
	Variables:
		Tanf_0to1 							Infants <2 years old (excluding unborn) receiving TANF 
		Tanf_2to5    						Toddlers 2-5 years old receiving TANF 
		Tanf_6to12    						Preteens 6-12 years old receiving TANF 
		Tanf_13to17    						Teens 13-17 years old receiving TANF
		Tanf_18to24    						Young adults 18-24 years old receiving TANF 
		Tanf_adult    						Adults 18+ years old receiving TANF 
		Tanf_adult_fch    					Adults 18+ years old in adult-only cases receiving TANF 
		Tanf_adult_fcp   					Adults 18+ years old in couple families receiving TANF 
		Tanf_adult_fot    					Adults 18+ years old in other families receiving TANF 
		Tanf_adult_fsf    					Adults 18+ years old in single-female families receiving TANF
		Tanf_adult_fsm    					Adults 18+ years old in single-male families receiving TANF 
		Tanf_case    						TANF cases 
		Tanf_case_fch    					TANF child-only cases 
		Tanf_case_fcp    					TANF cases, couple families 
		Tanf_case_fot    					TANF cases, other family types 
		Tanf_case_fsf    					TANF cases, single-female families
		Tanf_case_fsm    					TANF cases, single-male families 
		Tanf_child_fch    					Children <18 years old (excl. unborn) in child-only cases receiving TANF 
		Tanf_child_fcp    					Children <18 years old (excl. unborn) in couple families receiving TANF 
		Tanf_child_fot    					Children <18 years old (excl. unborn) in other families receiving TANF 
		Tanf_child_fsf    					Children <18 years old (excl. unborn) in single-female families receiving TANF 
		Tanf_child_fsm    					Children <18 years old (excl. unborn) in single-male families receiving TANF 
		Tanf_client_fch    					Persons in child-only cases receiving TANF 
		Tanf_client_fcp    					Persons in couple families receiving TANF 
		Tanf_client_fot    					Persons in other families receiving TANF 
		Tanf_client_fsf    					Persons in single-female families receiving TANF
		Tanf_client_fsm    					Persons in single-male families receiving TANF 
		Tanf_fulpart						Full TANF Participants
		Tanf_unborn_fch    					Unborn children in child-only cases receiving TANF 
		Tanf_unborn_fcp    					Unborn children in couple families receiving TANF 
		Tanf_unborn_fot    					Unborn children in other families receiving TANF 
		Tanf_unborn_fsf    					Unborn children in single-female families receiving TANF 
		Tanf_unborn_fsm    					Unborn children in single-male families receiving TANF */

data TANF;
	set TANF.tanf_SUM_PSA12 (where=(Psa2012="602" or PSA2012="608") keep=psa2012 
			tanf_0to1_2014 tanf_2to5_2014 tanf_6to12_2014 tanf_13to17_2014
			tanf_adult_2014 tanf_adult_fch_2014 tanf_adult_fcp_2014 tanf_adult_fot_2014 tanf_adult_fsf_2014 tanf_adult_fsm_2014 
			tanf_case_2014 tanf_case_fch_2014 tanf_case_fcp_2014 tanf_case_fot_2014 tanf_case_fsf_2014 tanf_case_fsm_2014
			tanf_child_2014 tanf_child_fch_2014 tanf_child_fcp_2014 tanf_child_fot_2014 tanf_child_fsf_2014 tanf_child_fsm_2014
			tanf_client_2014 tanf_client_fch_2014 tanf_client_fcp_2014 tanf_client_fot_2014 tanf_client_fsf_2014 tanf_client_fsm_2014
			tanf_fulpart_2014
			tanf_unborn_2014 tanf_unborn_fch_2014 tanf_unborn_fcp_2014 tanf_unborn_fot_2014 tanf_unborn_fsf_2014 tanf_unborn_fsm_2014)
		TANF.tanf_SUM_WD12 (where=(ward2012="7") keep=ward2012 
			tanf_0to1_2014 tanf_2to5_2014 tanf_6to12_2014 tanf_13to17_2014
			tanf_adult_2014 tanf_adult_fch_2014 tanf_adult_fcp_2014 tanf_adult_fot_2014 tanf_adult_fsf_2014 tanf_adult_fsm_2014 
			tanf_case_2014 tanf_case_fch_2014 tanf_case_fcp_2014 tanf_case_fot_2014 tanf_case_fsf_2014 tanf_case_fsm_2014
			tanf_child_2014 tanf_child_fch_2014 tanf_child_fcp_2014 tanf_child_fot_2014 tanf_child_fsf_2014 tanf_child_fsm_2014
			tanf_client_2014 tanf_client_fch_2014 tanf_client_fcp_2014 tanf_client_fot_2014 tanf_client_fsf_2014 tanf_client_fsm_2014
			tanf_fulpart_2014
			tanf_unborn_2014 tanf_unborn_fch_2014 tanf_unborn_fcp_2014 tanf_unborn_fot_2014 tanf_unborn_fsf_2014 tanf_unborn_fsm_2014)
		TANF.tanf_SUM_city(keep=city
			tanf_0to1_2014 tanf_2to5_2014 tanf_6to12_2014 tanf_13to17_2014
			tanf_adult_2014 tanf_adult_fch_2014 tanf_adult_fcp_2014 tanf_adult_fot_2014 tanf_adult_fsf_2014 tanf_adult_fsm_2014 
			tanf_case_2014 tanf_case_fch_2014 tanf_case_fcp_2014 tanf_case_fot_2014 tanf_case_fsf_2014 tanf_case_fsm_2014
			tanf_child_2014 tanf_child_fch_2014 tanf_child_fcp_2014 tanf_child_fot_2014 tanf_child_fsf_2014 tanf_child_fsm_2014
			tanf_client_2014 tanf_client_fch_2014 tanf_client_fcp_2014 tanf_client_fot_2014 tanf_client_fsf_2014 tanf_client_fsm_2014
			tanf_fulpart_2014
			tanf_unborn_2014 tanf_unborn_fch_2014 tanf_unborn_fcp_2014 tanf_unborn_fot_2014 tanf_unborn_fsf_2014 tanf_unborn_fsm_2014)
			;
		if PSA2012="602" then geography = "PSA 602";
		if PSA2012="608" then geography = "PSA 608";
		if ward2012="7" then geography = "Ward 7";
		if city^=. then geography = "City";
		label geography = "Geography";
		run;

/*Births - 
	
	Variables:
		Births_0to14_2011    				Births to mothers under 15 years old, 2011 
		Births_15to19_2011    				Births to mothers 15-19 years old, 2011 
		Births_20to24_2011    				Births to mothers 20-24 years old, 2011 
		Births_25to29_2011    				Births to mothers 25-29 years old, 2011 
		Births_30to34_2011    				Births to mothers 30-34 years old, 2011 
		Births_35to39_2011    				Births to mothers 35-39 years old, 2011 
		Births_40to44_2011    				Births to mothers 40-44 years old, 2011 
		Births_45plus_2011    				Births to mothers 45 and over years old, 2011 
		Births_low_wt_2011    				Births with low birth weight (<5.5 lbs), 2011 
		Births_prenat_1st_2011    			Births with prenatal care visit in 1st trimester, 2011 
		Births_prenat_adeq_2011    			Births with adequate prenatal care (Kessner index), 2011 
		Births_prenat_inad_2011    			Births with inadequate prenatal care (Kessner index), 2011 
		Births_prenat_intr_2011   			Births with intermediate prenatal care (Kessner index), 2011 
		Births_preterm_2011    				Preterm births (<37 gestational weeks), 2011 
		Births_single_2011   				Births to unmarried mothers, 2011 
		Births_teen_2011    				Births to mothers under 20 years old, 2011 
		Births_total_2011    				Total births, 2011 
		Births_total_3yr_2011    			Total births, 3-year avg., 2011 
		Births_under18_2011    				Births to mothers under 18 years old, 2011 
		Births_w_age_2011    				Births with mother's age reported, 2011 
		Births_w_gest_age_2011    			Births with gestational age reported, 2011 
		Births_w_mstat_2011    				Births with mother's marital status reported, 2011 
		Births_w_prenat_2011    			Births with prenatal care reported (Kessner index), 2011 
		Births_w_weight_2011    			Births with birth weight reported, 2011 

*/

data births;
	set VITAL.BIRTHS_SUM_PSA12 (where=(Psa2012="602" or PSA2012="608") keep=psa2012 
			Births_0to14_2011    	Births_15to19_2011    	Births_20to24_2011    	Births_25to29_2011    	Births_30to34_2011    	
			Births_35to39_2011    	Births_40to44_2011    	Births_45plus_2011    	Births_low_wt_2011    	
			Births_prenat_1st_2011  Births_prenat_adeq_2011 Births_prenat_inad_2011 Births_prenat_intr_2011 Births_preterm_2011    	
			Births_single_2011   	Births_teen_2011    	Births_total_2011    	Births_total_3yr_2011   Births_under18_2011    	
			Births_w_age_2011    	Births_w_gest_age_2011  Births_w_mstat_2011    	Births_w_prenat_2011    Births_w_weight_2011)   
	VITAL.BIRTHS_SUM_WD12 (where=(WARD2012="7") keep=ward2012 
			Births_0to14_2011    	Births_15to19_2011    	Births_20to24_2011    	Births_25to29_2011    	Births_30to34_2011    	
			Births_35to39_2011    	Births_40to44_2011    	Births_45plus_2011    	Births_low_wt_2011    	
			Births_prenat_1st_2011  Births_prenat_adeq_2011 Births_prenat_inad_2011 Births_prenat_intr_2011 Births_preterm_2011    	
			Births_single_2011   	Births_teen_2011    	Births_total_2011    	Births_total_3yr_2011   Births_under18_2011    	
			Births_w_age_2011    	Births_w_gest_age_2011  Births_w_mstat_2011    	Births_w_prenat_2011    Births_w_weight_2011)  
		VITAL.BIRTHS_SUM_city (keep=city 
			Births_0to14_2011    	Births_15to19_2011    	Births_20to24_2011    	Births_25to29_2011    	Births_30to34_2011    	
			Births_35to39_2011    	Births_40to44_2011    	Births_45plus_2011    	Births_low_wt_2011    	
			Births_prenat_1st_2011  Births_prenat_adeq_2011 Births_prenat_inad_2011 Births_prenat_intr_2011 Births_preterm_2011    	
			Births_single_2011   	Births_teen_2011    	Births_total_2011    	Births_total_3yr_2011   Births_under18_2011    	
			Births_w_age_2011    	Births_w_gest_age_2011  Births_w_mstat_2011    	Births_w_prenat_2011    Births_w_weight_2011)    
		;
		if PSA2012="602" then geography = "PSA 602";
		if PSA2012="608" then geography = "PSA 608";
		if WARD2012="7" then geography = "Ward 7";
		if city^=. then geography = "City";
		label geography = "Geography";
		run;



/*NETS data - Create Tract-Level file from Block Group file.
	NETS data was created by Tina and Helen for a separate project, and the documentation for the 
	creation of the file is located: L:\Libraries\Requests\Doc\2014\NETS Database Description2013.pdf.
	It is a block group file that is an annual snapshot of the lifecycle of business establishments from 
	1990 to 2011. This is the most recent data available, and notes the establishments present in 2011*;

data nets_tractlvl;
	set requests.nets_dc_all_bg (where=(year=2012) keep=year geoid estcount);
	geo2010_fake=substr(geoid,1,11);
	geo2010=put(geo2010_fake, $11.);
	drop geo2010_fake;
	run;

proc summary data=nets_tractlvl;
	class geo2010;
	var estcount;
	output
		out=sorted_nets_tract (drop= _type_ _freq_) 
	sum (estcount)=;
	format geo2010 $geo10a.;
	label estcount="Total Number of Establishments per Tract (2011)"
		run;*/


**Sort and Merge files**;

proc sort data=acs
	out=sorted_acs;
	by geography;
	run;

proc sort data=housing
	out=sorted_housing;
	by geography;
	run;

proc sort data=schools
	out=sorted_schools;
	by geography;
	run;

proc sort data=foodstamps
	out=sorted_foodstamps;
	by geography;
	run;

proc sort data=tanf 
	out=sorted_tanf;
	by geography;
	run;

proc sort data=births
	out=sorted_births;
	by geography;
	run;

data psa_level;
	merge  sorted_acs sorted_housing sorted_schools sorted_foodstamps sorted_tanf sorted_births;
	by geography;
	run;

proc contents data=psa_level;
	run;

data createindicators;
	set psa_level;
		pct_births_0to14=births_0to14_2011/births_w_age_2011;
		pct_births_15to19=births_15to19_2011/births_w_age_2011;
		pct_births_20to24=births_20to24_2011/births_w_age_2011;
		pct_births_25to29=births_25to29_2011/births_w_age_2011;
		pct_births_30to34=births_30to34_2011/births_w_age_2011;
		pct_births_35to39=births_35to39_2011/births_w_age_2011;
		pct_births_40to44=births_40to44_2011/births_w_age_2011;
		pct_births_45plus=births_45plus_2011/births_w_age_2011;
		pct_births_under18=births_under18_2011/births_w_age_2011;
		pct_births_teen=births_teen_2011/births_w_age_2011;
		pct_births_single=births_single_2011/births_w_mstat_2011;
		family_income=aggfamilyincome_2010_14/numfamilies_2010_14;
		pct_fs_0to1=fs_0to1_2014/fs_client_2014;
		pct_fs_2to5=fs_2to5_2014/fs_client_2014;
		pct_fs_6to12=fs_6to12_2014/fs_client_2014;
		pct_fs_13to17=fs_13to17_2014/fs_client_2014;
		pct_fs_adult=fs_adult_2014/fs_client_2014;
		pct_fs_childonly=fs_client_fch_2014/fs_client_2014;
		pct_fs_couples=fs_client_fcp_2014/fs_client_2014;
		pct_fs_otherfams=fs_client_fot_2014/fs_client_2014;
		pct_fs_singfem=fs_client_fsf_2014/fs_client_2014;
		pct_fs_singmal=fs_client_fsm_2014/fs_client_2014;
	label 
		pct_births_0to14 = "Percent Births: Age 0 to 14"
		pct_births_15to19 = "Percent Births: Age 15 to 19"
		pct_births_20to24 = "Percent Births: Age 20 to 24"
		pct_births_25to29 = "Percent Births: Age 25 to 29"
		pct_births_30to34 = "Percent Births: Age 30 to 34"
		pct_births_35to39 = "Percent Births: Age 35 to 39"
		pct_births_45plus = "Percent Births: Age 45 plus"
		pct_births_under18 = "Percent Births: Age Under 18"
		pct_births_teen = "Percent Births: to Teens"
		pct_births_single = "Percent Births: to Single Mothers"
		family_income = "Average Family Income"
		pct_fs_0to1= "Percent Food Stamps: Ages 0 to 1"
		pct_fs_2to5= "Percent Food Stamps: Ages 2 to 5"
		pct_fs_6to12= "Percent Food Stamps: Ages 6 to 12"
		pct_fs_13to17= "Percent Food Stamps: Ages 13 to 17"
		pct_fs_adult= "Percent Food Stamps: Adults"
		pct_fs_childonly= "Percent Food Stamps: Child only Cases"
		pct_fs_couples= "Percent Food Stamps: Couple Families"
		pct_fs_otherfams="Percent Food Stamps: Other Families"
		pct_fs_singfem= "Percent Food Stamps: Single Female Families"
		pct_fs_singmal= "Percent Food Stamps: Single Male Families";
		run;


*data finalindicators;
	*set createindicators (keep=geography pct_births_0to14 pct_births_15to19 pct_births_20to24 pct_births_25to29 pct_births_30to34 
		pct_births_35to39 pct_births_45plus pct_births_under18 pct_births_teen pct_births_single ;

ODS LISTING;
ODS HTML FILE = "D:\DCData\Libraries\Byrne\Byrne_Indicators.xls" ;
TITLE1 "Byrne Indicators: PSA, Ward and City-Level";
data finalindicators;
	set createindicators;
run;
ods html close;

