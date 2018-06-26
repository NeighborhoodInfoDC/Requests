/**************************************************************************
 Program:  Commuting time to work.sas
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


** Define time periods  **;
%let _years = 2012_16;
%let year_lbl = 2012-16;

%macro Compile_ACS_data (geo, geosuf);

data compile_stanc_tabs_&geosuf;
	merge 
		ACS.acs_&_years._dc_sum_tr_&geosuf
			(keep= &geo
			    totpop_&_years.
                pop35_64yearsM_&_years. pop35_64yearsF_&_years. pop18_34yearsF_&_years. pop18_34yearsM_&_years. 
				pop65andoveryearsF_&_years. pop65andoveryearsM_&_years. popunder18yearsF_&_years. popunder18yearsM_&_years. 

				/*popunder5yearsM_&_years. popunder5yearsF_&_years.*/

                agghshldincome_&_years. poppoorpersons_&_years. personspovertydefined_&_years. mpopworkfth_&_years. 
				popworkftlt75k_&_years. popworkftlt35k_&_years. 
				popincivlaborforce_&_years.
				pop16andoveryears_&_years. popcivilianemployed_&_years. popunemployed_&_years. 
				poppoorpersons_&_years. personspovertydefined_&_years. popwithrace_&_years. 
				PopEmployedTravel_&_years. PopEmployedTravel_LT5_&_years.
				PopEmployedTravel_5_9_&_years. PopEmployedTravel_10_14_&_years.
				PopEmployedTravel_15_19_&_years. PopEmployedTravel_20_24_&_years. 
				PopEmployedTravel_25_29_&_years. PopEmployedTravel_30_34_&_years. 
				PopEmployedTravel_35_39_&_years. PopEmployedTravel_40_44_&_years. 
				PopEmployedTravel_45_59_&_years. PopEmployedTravel_60_89_&_years. 
				PopEmployedTravel_GT90_&_years.
				IncmByOwnerCst_LT10K_&_years. IncmByOwnerCst_10_19K_&_years.
				IncmByOwnerCst_20_34K_&_years. IncmByOwnerCst_35_49K_&_years.
				IncmByOwnerCst_50_74K_&_years. IncmByOwnerCst_75_99K_&_years.
				IncmByOwnerCst_100_149_&_years. IncmByOwnerCst_GT150K_&_years.
				NumOwnCstBurden_LT10K_&_years. NumOwnCstBurden_10_19K_&_years. 
				NumOwnCstBurden_20_34K_&_years. NumOwnCstBurden_35_49K_&_years. 
				NumOwnCstBurden_50_74K_&_years. NumOwnCstBurden_75_99K_&_years. 
				NumOwnCstBurden_100_149_&_years. NumOwnCstBurden_GT150K_&_years. 

				hshldincunder15000_&_years. hshldinc15000to34999_&_years.
				hshldinc35000to49999_&_years. hshldinc50000to74999_&_years.
                hshldinc75000to99999_&_years. hshldinc100000to124999_&_years.
				hshldinc125000to149999_&_years. hshldinc150000to199999_&_years.
                hshldinc200000plus_&_years.
                
                PopUnder18YearsM_&_years. PopUnder18YearsF_&_years. Pop18_34YearsM_&_years. Pop18_34YearsF_&_years. Pop35_64YearsM_&_years.
	            Pop35_64YearsF_&_years. Pop65andOverYearsM_&_years. Pop65andOverYearsF_&_years.

                InsCovUnder18Years_&_years. InsCov18_34Years_&_years. InsCov35_64Years_&_years. InsCov65andOverYears_&_years.
	            NInsCovUnder18Years_&_years. NInsCov18_34Years_&_years. NInsCov35_64Years_&_years. NInsCov65andOverYears_&_years.

                EarningUnder10K_&_years. Earning10to15K_&_years. Earning15to25K_&_years. Earning25to35K_&_years. Earning35to50K_&_years.
	            Earning50to65K_&_years. Earning65to75K_&_years. EarningOver75K_&_years.

                FamMarriedCouple_&_years. FamMaleholder_&_years. FamFemaleholder_&_years. Nonfamlivingalone_&_years.
                Nonfamnotlivingalone_&_years.

				pop25andoveryears_&_years. pop25andoverwhs_&_years. Pop25andOverWoutHS_&_years. pop25andoverwcollege_&_years. 

				GrossRentLT100_&_years. GrossRent100_149_&_years. GrossRent150_199_&_years.  
				GrossRent200_249_&_years. GrossRent250_299_&_years. 
				GrossRent300_349_&_years. GrossRent350_349_&_years. 
				GrossRent400_449_&_years. GrossRent450_499_&_years. 
				GrossRent500_549_&_years. GrossRent550_599_&_years. 
				GrossRent600_649_&_years. GrossRent650_699_&_years. 
				GrossRent700_749_&_years. GrossRent750_799_&_years. 
				GrossRent800_899_&_years. GrossRent900_999_&_years.
				GrossRent1000_1249_&_years. GrossRent1250_1499_&_years.
				GrossRent1500_1999_&_years. GrossRent2000_2499_&_years.
				GrossRent2500_2999_&_years. GrossRent3000_3499_&_years.
				GrossRentGT3500_&_years. GrossRentNoCash_&_years.

				IncmByRenterCst_LT10K_&_years. IncmByRenterCst_10_19K_&_years.
				IncmByRenterCst_20_34K_&_years. IncmByRenterCst_35_49K_&_years.
				IncmByRenterCst_50_74K_&_years. IncmByRenterCst_75_99K_&_years.
				IncmByRenterCst_GT100K_&_years.
				AgeByRenterCst_15_24_&_years. AgeByRenterCst_25_34_&_years.
				AgeByRenterCst_35_64_&_years. AgeByRenterCst_65Over_&_years.
				AgeByOwnerCst_15_24_&_years. AgeByOwnerCst_25_34_&_years.
				AgeByOwnerCst_35_64_&_years. AgeByOwnerCst_65Over_&_years.
				RentCostBurdenDenom_&_years. OwnerCostBurdenDenom_&_years. 
				NumRenterCostBurden_&_years. NumRentSevereCostBurden_&_years. 
				NumOwnerCostBurden_&_years. NumOwnSevereCostBurden_&_years.
				NumRentCstBurden_15_24_&_years. NumRentCstBurden_25_34_&_years. 
				NumRentCstBurden_35_64_&_years. NumRentCstBurden_65Over_&_years. 
				NumOwnCstBurden_15_24_&_years. NumOwnCstBurden_25_34_&_years. 
				NumOwnCstBurden_35_64_&_years. NumOwnCstBurden_65Over_&_years. 
				NumRentCstBurden_LT10K_&_years. NumRentCstBurden_10_19K_&_years. 
				NumRentCstBurden_20_34K_&_years. NumRentCstBurden_35_49K_&_years. 
				NumRentCstBurden_50_74K_&_years. NumRentCstBurden_75_99K_&_years. 
				NumRentCstBurden_GT100K_&_years.

				NumRenterOccupiedHU_&_years. NumOwnerOccupiedHU_&_years. NumOccupiedHsgUnits_&_years.
				)

		Acs.Acs_&_years._dc_sum_bg_&geosuf
			(keep= &geo 
				popwhitenonhispbridge_&_years. popblacknonhispbridge_&_years. pophisp_&_years. 
				popasianpinonhispbridge_&_years. popotherracenonhispbridg_&_years. 
				
				PopEmployedByInd_&_years. PopEmployedAgric_&_years. PopEmployedConstr_&_years. 
				PopEmployedManuf_&_years. PopEmployedWhlsale_&_years. PopEmployedRetail_&_years. 
				PopEmployedTransprt_&_years. PopEmployedInfo_&_years. PopEmployedFinance_&_years. 
				PopEmployedProfServ_&_years. PopEmployedEduction_&_years. PopEmployedArts_&_years. 
				PopEmployedOther_&_years. PopEmployedPubAdmin_&_years.
				PopEmployedByOcc_&_years. PopEmployedMngmt_&_years.
				PopEmployedServ_&_years. PopEmployedSales_&_years.
				PopEmployedNatRes_&_years. PopEmployedProd_&_years. 
				PopEmployedWorkers_&_years. PopEmployedWorkInState_&_years. PopEmployedWorkOutState_&_years.
				
			
					)

					
		Police.Crimes_sum_&geosuf
			(keep=&geo 
				crimes_pt1_property_2000 crimes_pt1_property_2001 
				crimes_pt1_property_2002 crimes_pt1_property_2003 crimes_pt1_property_2004 
				crimes_pt1_property_2005 crimes_pt1_property_2006 crimes_pt1_property_2007 
				crimes_pt1_property_2008 crimes_pt1_property_2009 crimes_pt1_property_2010
				crimes_pt1_property_2011 crimes_pt1_property_2012 crimes_pt1_property_2013
				crimes_pt1_property_2014 crimes_pt1_property_2015 crimes_pt1_property_2016 
				crimes_pt1_property_2017
				crimes_pt1_violent_2000 crimes_pt1_violent_2001 
				crimes_pt1_violent_2002 crimes_pt1_violent_2003 crimes_pt1_violent_2004 
				crimes_pt1_violent_2005 crimes_pt1_violent_2006 crimes_pt1_violent_2007 
				crimes_pt1_violent_2008 crimes_pt1_violent_2009 crimes_pt1_violent_2010 
				crimes_pt1_violent_2011 crimes_pt1_violent_2012 crimes_pt1_violent_2013 
				crimes_pt1_violent_2014 crimes_pt1_violent_2015 crimes_pt1_violent_2016 
				crimes_pt1_violent_2017
				crime_rate_pop_2000 crime_rate_pop_2001 crime_rate_pop_2002 crime_rate_pop_2003 
				crime_rate_pop_2004 crime_rate_pop_2005 crime_rate_pop_2006 crime_rate_pop_2007 
				crime_rate_pop_2008 crime_rate_pop_2009 crime_rate_pop_2010 crime_rate_pop_2011 
				crime_rate_pop_2012 crime_rate_pop_2013 crime_rate_pop_2014 crime_rate_pop_2015 
				crime_rate_pop_2016 crime_rate_pop_2017)
		
	      HUD.Vouchers_sum_&geosuf
		  (keep=&geo
             total_units)

		  TANF.Tanf_sum_&geosuf
		   (keep=&geo
		        tanf_case_1998 tanf_case_1999 tanf_case_2000 tanf_case_2001 tanf_case_2002
				tanf_case_2003 tanf_case_2004 tanf_case_2005 tanf_case_2006 tanf_case_2007
				tanf_case_2008 tanf_case_2009 tanf_case_2010 tanf_case_2011 tanf_case_2012
				tanf_case_2013 tanf_case_2014 tanf_case_2015 tanf_case_2016 )
 
			Tanf.Fs_sum_&geosuf
			(keep=&geo
                fs_case_2000 fs_case_2001 fs_case_2002 fs_case_2003 fs_case_2004 fs_case_2005 
				fs_case_2006 fs_case_2007 fs_case_2008 fs_case_2009 fs_case_2010 fs_case_2011
				fs_case_2012 fs_case_2013 fs_case_2014 fs_case_2015 fs_case_2016)

          
			Vital.Births_sum_&geosuf
            (keep=&geo
               /*births_total_2000 births_total_2001 births_total_2002 */births_total_2003 births_total_2004
			   births_total_2005 births_total_2006 births_total_2007 births_total_2008 births_total_2009
               births_total_2010 births_total_2011 births_total_2012 births_total_2013 births_total_2014
			   births_total_2015 births_total_2016

               /*births_prenat_adeq_2000 births_prenat_adeq_2001 births_prenat_adeq_2002*/ births_prenat_adeq_2003 births_prenat_adeq_2004
			   births_prenat_adeq_2005 births_prenat_adeq_2006 births_prenat_adeq_2007 births_prenat_adeq_2008 births_prenat_adeq_2009
               births_prenat_adeq_2010 births_prenat_adeq_2011 births_prenat_adeq_2012 births_prenat_adeq_2013 births_prenat_adeq_2014
			   births_prenat_adeq_2015 births_prenat_adeq_2016

               /*births_prenat_1st_2000 births_prenat_1st_2001 births_prenat_1st_2002*/ births_prenat_1st_2003 births_prenat_1st_2004
			   births_prenat_1st_2005 births_prenat_1st_2006 births_prenat_1st_2007 births_prenat_1st_2008 births_prenat_1st_2009
               births_prenat_1st_2010 births_prenat_1st_2011 births_prenat_1st_2012 births_prenat_1st_2013 births_prenat_1st_2014
			   births_prenat_1st_2015 births_prenat_1st_2016

			   /*births_low_wt_2000 births_low_wt_2001 births_low_wt_2002*/ births_low_wt_2003 births_low_wt_2004
			   births_low_wt_2005 births_low_wt_2006 births_low_wt_2007 births_low_wt_2008 births_low_wt_2009
               births_low_wt_2010 births_low_wt_2011 births_low_wt_2012 births_low_wt_2013 births_low_wt_2014
			   births_low_wt_2015 births_low_wt_2016

			   /*births_preterm_2000 births_preterm_2001 births_preterm_2002*/ births_preterm_2003 births_preterm_2004
			   births_preterm_2005 births_preterm_2006 births_preterm_2007 births_preterm_2008 births_preterm_2009
               births_preterm_2010 births_preterm_2011 births_preterm_2012 births_preterm_2013 births_preterm_2014
			   births_preterm_2015 births_preterm_2016
			   )

             CDC500.CDC500_2017_sum_&geosuf
			 (keep=&geo
              MHLTH_CrudePrev)

             Vital.Deaths_sum_&geosuf
            (keep=&geo
               /*deaths_total_2000 deaths_total_2001 deaths_total_2002 deaths_total_2003 deaths_total_2004
			   deaths_total_2005 deaths_total_2006 deaths_total_2007 deaths_total_2008*/ deaths_total_2009
               deaths_total_2010 deaths_total_2011 deaths_total_2012 deaths_total_2013 deaths_total_2014
			   deaths_total_2015 deaths_total_2016

               /*deaths_15to19_2000 deaths_15to19_2001 deaths_15to19_2002 deaths_15to19_2003 deaths_15to19_2004 deaths_15to19_2005 
               deaths_15to19_2006 deaths_15to19_2007 deaths_15to19_2008*/ deaths_15to19_2009 deaths_15to19_2010
			   deaths_15to19_2011 deaths_15to19_2012 deaths_15to19_2013 deaths_15to19_2014 deaths_15to19_2015
               deaths_15to19_2016

               /*deaths_20to24_2000 deaths_20to24_2001 deaths_20to24_2002 deaths_20to24_2003 deaths_20to24_2004 deaths_20to24_2005 
               deaths_20to24_2006 deaths_20to24_2007 deaths_20to24_2008*/ deaths_20to24_2009 deaths_20to24_2010
			   deaths_20to24_2011 deaths_20to24_2012 deaths_20to24_2013 deaths_20to24_2014 deaths_20to24_2015
               deaths_20to24_2016

               /*deaths_adult_2000 deaths_adult_2001 deaths_adult_2002 deaths_adult_2003 deaths_adult_2004 deaths_adult_2005 
               deaths_adult_2006 deaths_adult_2007 deaths_adult_2008*/ deaths_adult_2009 deaths_adult_2010
			   deaths_adult_2011 deaths_adult_2012 deaths_adult_2013 deaths_adult_2014 deaths_adult_2015
               deaths_adult_2016

			   /*deaths_accident_2000 deaths_accident_2001 deaths_accident_2002 deaths_accident_2003 deaths_accident_2004 deaths_accident_2005 
               deaths_accident_2006 deaths_accident_2007 deaths_accident_2008*/ deaths_accident_2009 deaths_accident_2010
			   deaths_accident_2011 deaths_accident_2012 deaths_accident_2013 deaths_accident_2014 deaths_accident_2015
               deaths_accident_2016

               /*deaths_cancer_2000 deaths_cancer_2001 deaths_cancer_2002 deaths_cancer_2003 deaths_cancer_2004 deaths_cancer_2005 
               deaths_cancer_2006 deaths_cancer_2007 deaths_cancer_2008*/ deaths_cancer_2009 deaths_cancer_2010
			   deaths_cancer_2011 deaths_cancer_2012 deaths_cancer_2013 deaths_cancer_2014 deaths_cancer_2015
               deaths_cancer_2016

               /*deaths_cereb_2000 deaths_cereb_2001 deaths_cereb_2002 deaths_cereb_2003 deaths_cereb_2004 deaths_cereb_2005 
               deaths_cereb_2006 deaths_cereb_2007 deaths_cereb_2008*/ deaths_cereb_2009 deaths_cereb_2010
			   deaths_cereb_2011 deaths_cereb_2012 deaths_cereb_2013 deaths_cereb_2014 deaths_cereb_2015
               deaths_cereb_2016

			   /*deaths_diabetes_2000 deaths_diabetes_2001 deaths_diabetes_2002 deaths_diabetes_2003 deaths_diabetes_2004 deaths_diabetes_2005 
               deaths_diabetes_2006 deaths_diabetes_2007 deaths_diabetes_2008*/ deaths_diabetes_2009 deaths_diabetes_2010
			   deaths_diabetes_2011 deaths_diabetes_2012 deaths_diabetes_2013 deaths_diabetes_2014 deaths_diabetes_2015
               deaths_diabetes_2016

               /*deaths_heart_2000 deaths_heart_2001 deaths_heart_2002 deaths_heart_2003 deaths_heart_2004 deaths_heart_2005 
               deaths_heart_2006 deaths_heart_2007 deaths_heart_2008*/ deaths_heart_2009 deaths_heart_2010
			   deaths_heart_2011 deaths_heart_2012 deaths_heart_2013 deaths_heart_2014 deaths_heart_2015
               deaths_heart_2016

               /*deaths_hiv_2000 deaths_hiv_2001 deaths_hiv_2002 deaths_hiv_2003 deaths_hiv_2004 deaths_hiv_2005 
               deaths_hiv_2006 deaths_hiv_2007 deaths_hiv_2008*/ deaths_hiv_2009 deaths_hiv_2010
			   deaths_hiv_2011 deaths_hiv_2012 deaths_hiv_2013 deaths_hiv_2014 deaths_hiv_2015
               deaths_hiv_2016

			   /*deaths_homicide_2000 deaths_homicide_2001 deaths_homicide_2002 deaths_homicide_2003 deaths_homicide_2004 deaths_homicide_2005 
               deaths_homicide_2006 deaths_homicide_2007 deaths_homicide_2008*/ deaths_homicide_2009 deaths_homicide_2010
			   deaths_homicide_2011 deaths_homicide_2012 deaths_homicide_2013 deaths_homicide_2014 deaths_homicide_2015
               deaths_homicide_2016

			   /*deaths_hypert_2000 deaths_hypert_2001 deaths_hypert_2002 deaths_hypert_2003 deaths_hypert_2004 deaths_hypert_2005 
               deaths_hypert_2006 deaths_hypert_2007 deaths_hypert_2008*/ deaths_hypert_2009 deaths_hypert_2010
			   deaths_hypert_2011 deaths_hypert_2012 deaths_hypert_2013 deaths_hypert_2014 deaths_hypert_2015
               deaths_hypert_2016

               /*deaths_liver_2000 deaths_liver_2001 deaths_liver_2002 deaths_liver_2003 deaths_liver_2004 deaths_liver_2005 
               deaths_liver_2006 deaths_liver_2007 deaths_liver_2008*/ deaths_liver_2009 deaths_liver_2010
			   deaths_liver_2011 deaths_liver_2012 deaths_liver_2013 deaths_liver_2014 deaths_liver_2015
               deaths_liver_2016

               /*deaths_oth_caus_2000 deaths_oth_caus_2001 deaths_oth_caus_2002 deaths_oth_caus_2003 deaths_oth_caus_2004 deaths_oth_caus_2005 
               deaths_oth_caus_2006 deaths_oth_caus_2007 deaths_oth_caus_2008*/ deaths_oth_caus_2009 deaths_oth_caus_2010
			   deaths_oth_caus_2011 deaths_oth_caus_2012 deaths_oth_caus_2013 deaths_oth_caus_2014 deaths_oth_caus_2015
               deaths_oth_caus_2016

			   /*deaths_suicide_2000 deaths_suicide_2001 deaths_suicide_2002 deaths_suicide_2003 deaths_suicide_2004 deaths_suicide_2005 
               deaths_suicide_2006 deaths_suicide_2007 deaths_suicide_2008*/ deaths_suicide_2009 deaths_suicide_2010
			   deaths_suicide_2011 deaths_suicide_2012 deaths_suicide_2013 deaths_suicide_2014 deaths_suicide_2015
               deaths_suicide_2016
			   )
;
by &geo.;
format deaths_: suppr5f.;
format births_: suppr5f.;
run;

data calc_stanc_tabs_&geosuf;
	set compile_stanc_tabs_&geosuf;
        /*Population by Age and Sex*/
               PopUnder18Years_&_years. = PopUnder18YearsM_&_years. + PopUnder18YearsF_&_years.;
               Pop18_34Years_&_years. = Pop18_34YearsM_&_years.+ Pop18_34YearsF_&_years.;
               Pop35_64Years_&_years. = Pop35_64YearsM_&_years. + Pop35_64YearsF_&_years.;
               Pop65andOverYears_&_years. = Pop65andOverYearsM_&_years. + Pop65andOverYearsF_&_years.;

			   PopFemale_&_years. = PopUnder18YearsF_&_years.+ Pop18_34YearsF_&_years. + Pop35_64YearsF_&_years. + Pop65andOverYearsF_&_years.;
               PopMale_&_years. = PopUnder18YearsM_&_years.+ Pop18_34YearsM_&_years. + Pop35_64YearsM_&_years. + Pop65andOverYearsM_&_years.;

		/*Labor force, employment, and poverty*/
			PctLaborForce_&_years. = popincivlaborforce_&_years. / pop16andoveryears_&_years.;
			PctPopEmployed_&_years. = popcivilianemployed_&_years. / popincivlaborforce_&_years.;
			PctPopUnemployed_&_years. = popunemployed_&_years. / popincivlaborforce_&_years.;
			PctPoorPersons_&_years. = poppoorpersons_&_years. / personspovertydefined_&_years.;

		/*Employment by major occupations*/
			PctEmpMngmt_&_years. = popemployedmngmt_&_years. / popemployedbyocc_2011_15;
			PctEmpNatRes_&_years. = popemployednatres_&_years. / popemployedbyocc_2011_15;
			PctEmpProd_&_years. = popemployedprod_&_years. / popemployedbyocc_2011_15;
			PctEmpSales_&_years. = popemployedsales_&_years. / popemployedbyocc_2011_15;
			PctEmpServ_&_years. = popemployedserv_&_years. / popemployedbyocc_2011_15;

		/*Homeownership, rent, and cost burden by age of householder and household income*/
			PctHomeownership_&_years. = numowneroccupiedhu_&_years. / numoccupiedhsgunits_&_years.;
			PctRenterCostBurden_&_years. = NumRenterCostBurden_&_years./RentCostBurdenDenom_&_years.;
			PctRentSevereCostBurden_&_years. = NumRentSevereCostBurden_&_years./RentCostBurdenDenom_&_years.;
			PctOwnerCostBurden_&_years. = NumOwnerCostBurden_&_years./OwnerCostBurdenDenom_&_years.;
			PctOwnSevereCostBurden_&_years. = NumOwnSevereCostBurden_&_years./OwnerCostBurdenDenom_&_years.;

			PctRentCstBurden_15_24_&_years. = NumRentCstBurden_15_24_&_years. / AgeByRenterCst_15_24_&_years.;
			PctRentCstBurden_25_34_&_years. = NumRentCstBurden_25_34_&_years. / AgeByRenterCst_25_34_&_years.;
			PctRentCstBurden_35_64_&_years. = NumRentCstBurden_35_64_&_years. / AgeByRenterCst_35_64_&_years.;
			PctRentCstBurden_65Over_&_years. = NumRentCstBurden_65Over_&_years. / AgeByRenterCst_65Over_&_years.;

			PctOwnCstBurden_15_24_&_years. = NumOwnCstBurden_15_24_&_years. / AgeByOwnerCst_15_24_&_years.;
			PctOwnCstBurden_25_34_&_years. = NumOwnCstBurden_25_34_&_years. / AgeByOwnerCst_25_34_&_years.;
			PctOwnCstBurden_35_64_&_years. = NumOwnCstBurden_35_64_&_years. / AgeByOwnerCst_35_64_&_years.;
			PctOwnCstBurden_65Over_&_years. = NumOwnCstBurden_65Over_&_years. / AgeByOwnerCst_65Over_&_years.;

			PctRentCstBurden_LT10K_&_years. = NumRentCstBurden_LT10K_&_years. / IncmByRenterCst_LT10K_&_years.;
			PctRentCstBurden_10_19K_&_years. = NumRentCstBurden_10_19K_&_years. / IncmByRenterCst_10_19K_&_years.;
			PctRentCstBurden_20_34K_&_years. = NumRentCstBurden_20_34K_&_years. / IncmByRenterCst_20_34K_&_years.;
			PctRentCstBurden_35_49K_&_years. = NumRentCstBurden_35_49K_&_years. / IncmByRenterCst_35_49K_&_years.;
			PctRentCstBurden_50_74K_&_years. = NumRentCstBurden_50_74K_&_years. / IncmByRenterCst_50_74K_&_years.;
			PctRentCstBurden_75_99K_&_years. = NumRentCstBurden_75_99K_&_years. / IncmByRenterCst_75_99K_&_years.;
			PctRentCstBurden_GT100K_&_years. = NumRentCstBurden_GT100K_&_years. / IncmByRenterCst_GT100K_&_years.;

			PctOwnCstBurden_LT10K_&_years. = NumOwnCstBurden_LT10K_&_years. / IncmByOwnerCst_LT10K_&_years.;
			PctOwnCstBurden_10_19K_&_years. = NumOwnCstBurden_10_19K_&_years. / IncmByOwnerCst_10_19K_&_years.;
			PctOwnCstBurden_20_34K_&_years. = NumOwnCstBurden_20_34K_&_years. / IncmByOwnerCst_20_34K_&_years.;
			PctOwnCstBurden_35_49K_&_years. = NumOwnCstBurden_35_49K_&_years. / IncmByOwnerCst_35_49K_&_years.;
			PctOwnCstBurden_50_74K_&_years. = NumOwnCstBurden_50_74K_&_years. / IncmByOwnerCst_50_74K_&_years.;
			PctOwnCstBurden_75_99K_&_years. = NumOwnCstBurden_75_99K_&_years. / IncmByOwnerCst_75_99K_&_years;
			PctOwnCstBurden_100_149_&_years. = NumOwnCstBurden_100_149_&_years. / IncmByOwnerCst_100_149_&_years.;
			PctOwnCstBurden_GT150K_&_years. = NumOwnCstBurden_GT150K_&_years. / IncmByOwnerCst_GT150K_&_years.;

		/*Education*/
			PctHS_&_years. = pop25andoverwhs_&_years. / pop25andoveryears_&_years.;
			PctCol_&_years. = pop25andoverwcollege_&_years. / pop25andoveryears_&_years.;
			PctWoutHS_&_years. = Pop25andOverWoutHS_&_years. / pop25andoveryears_&_years.;

		/*Race and ethnicity*/
			PctWht_&_years. = popwhitenonhispbridge_&_years. / popwithrace_&_years.;
			PctBlk_&_years. = popblacknonhispbridge_&_years. / popwithrace_&_years.;
			PctHisp_&_years. = pophisp_&_years. / popwithrace_&_years.;
			PctAsn_&_years. = popasianpinonhispbridge_&_years. / popwithrace_&_years.;
			PctOth_&_years. = popotherracenonhispbridg_&_years. / popwithrace_&_years.;

		/*Property crime rates*/
			property_crime_rate_2000 = crimes_pt1_property_2000 / crime_rate_pop_2000;
			property_crime_rate_2001 = crimes_pt1_property_2001 / crime_rate_pop_2001;
			property_crime_rate_2002 = crimes_pt1_property_2002 / crime_rate_pop_2002;
			property_crime_rate_2003 = crimes_pt1_property_2003 / crime_rate_pop_2003;
			property_crime_rate_2004 = crimes_pt1_property_2004 / crime_rate_pop_2004;
			property_crime_rate_2005 = crimes_pt1_property_2005 / crime_rate_pop_2005;
			property_crime_rate_2006 = crimes_pt1_property_2006 / crime_rate_pop_2006;
			property_crime_rate_2007 = crimes_pt1_property_2007 / crime_rate_pop_2007;
			property_crime_rate_2008 = crimes_pt1_property_2008 / crime_rate_pop_2008;
			property_crime_rate_2009 = crimes_pt1_property_2009 / crime_rate_pop_2009;
			property_crime_rate_2010 = crimes_pt1_property_2010 / crime_rate_pop_2010;
			property_crime_rate_2011 = crimes_pt1_property_2011 / crime_rate_pop_2011;
			property_crime_rate_2012 = crimes_pt1_property_2012 / crime_rate_pop_2012;
			property_crime_rate_2013 = crimes_pt1_property_2013 / crime_rate_pop_2013;
			property_crime_rate_2014 = crimes_pt1_property_2014 / crime_rate_pop_2014;
			property_crime_rate_2015 = crimes_pt1_property_2015 / crime_rate_pop_2015;
			property_crime_rate_2016 = crimes_pt1_property_2016 / crime_rate_pop_2016;
            property_crime_rate_2017 = crimes_pt1_property_2017 / crime_rate_pop_2017;
		/*Violent crime rates*/
			violent_crime_rate_2000 = crimes_pt1_violent_2000 / crime_rate_pop_2000;
			violent_crime_rate_2001 = crimes_pt1_violent_2001 / crime_rate_pop_2001;
			violent_crime_rate_2002 = crimes_pt1_violent_2002 / crime_rate_pop_2002;
			violent_crime_rate_2003 = crimes_pt1_violent_2003 / crime_rate_pop_2003;
			violent_crime_rate_2004 = crimes_pt1_violent_2004 / crime_rate_pop_2004;
			violent_crime_rate_2005 = crimes_pt1_violent_2005 / crime_rate_pop_2005;
			violent_crime_rate_2006 = crimes_pt1_violent_2006 / crime_rate_pop_2006;
			violent_crime_rate_2007 = crimes_pt1_violent_2007 / crime_rate_pop_2007;
			violent_crime_rate_2008 = crimes_pt1_violent_2008 / crime_rate_pop_2008;
			violent_crime_rate_2009 = crimes_pt1_violent_2009 / crime_rate_pop_2009;
			violent_crime_rate_2010 = crimes_pt1_violent_2010 / crime_rate_pop_2010;
			violent_crime_rate_2011 = crimes_pt1_violent_2011 / crime_rate_pop_2011;
			violent_crime_rate_2012 = crimes_pt1_violent_2012 / crime_rate_pop_2012;
			violent_crime_rate_2013 = crimes_pt1_violent_2013 / crime_rate_pop_2013;
			violent_crime_rate_2014 = crimes_pt1_violent_2014 / crime_rate_pop_2014;
			violent_crime_rate_2015 = crimes_pt1_violent_2015 / crime_rate_pop_2015;
			violent_crime_rate_2016 = crimes_pt1_violent_2016 / crime_rate_pop_2016;
            violent_crime_rate_2017 = crimes_pt1_violent_2017 / crime_rate_pop_2017;

run;

proc transpose data=calc_stanc_tabs_&geosuf out=stanc_tabs_&geosuf(label="Stanton Commons Tabulations, &geo");
	var 	&geo 	

		/*ACS Population 2012-2016*/
			totpop_&_years.
            PopUnder18Years_&_years.
            Pop18_34Years_&_years.
			Pop35_64Years_&_years.
			Pop65andOverYears_&_years.
			PopFemale_&_years.
			PopMale_&_years.
			FamMarriedCouple_&_years.
			FamMaleholder_&_years.
			FamFemaleholder_&_years.
			Nonfamlivingalone_&_years.
			Nonfamnotlivingalone_&_years.

		/*ACS Homeownership, rent, and cost burden*/
			NumOwnerOccupiedHU_&_years.
			NumRenterOccupiedHU_&_years. 
			PctHomeownership_&_years. 

			NumRenterCostBurden_&_years. 
			NumRentSevereCostBurden_&_years. 
			PctRenterCostBurden_&_years. 
			PctRentSevereCostBurden_&_years.

			NumOwnerCostBurden_&_years. 
			NumOwnSevereCostBurden_&_years. 
			PctOwnerCostBurden_&_years. 
			PctOwnSevereCostBurden_&_years. 

			PctRentCstBurden_15_24_&_years. 
			PctRentCstBurden_25_34_&_years. 
			PctRentCstBurden_35_64_&_years. 
			PctRentCstBurden_65Over_&_years. 

			PctOwnCstBurden_15_24_&_years. 
			PctOwnCstBurden_25_34_&_years. 
			PctOwnCstBurden_35_64_&_years. 
			PctOwnCstBurden_65Over_&_years. 

			GrossRentLT100_&_years. GrossRent100_149_&_years. GrossRent150_199_&_years.  
			GrossRent200_249_&_years. GrossRent250_299_&_years. 
			GrossRent300_349_&_years. GrossRent350_349_&_years. 
			GrossRent400_449_&_years. GrossRent450_499_&_years. 
			GrossRent500_549_&_years. GrossRent550_599_&_years. 
			GrossRent600_649_&_years. GrossRent650_699_&_years. 
			GrossRent700_749_&_years. GrossRent750_799_&_years. 
			GrossRent800_899_&_years. GrossRent900_999_&_years.
			GrossRent1000_1249_&_years. GrossRent1250_1499_&_years.
			GrossRent1500_1999_&_years. GrossRent2000_2499_&_years.
			GrossRent2500_2999_&_years. GrossRent3000_3499_&_years.
			GrossRentGT3500_&_years. 


		/*ACS Household by Income*/
				hshldincunder15000_&_years. hshldinc15000to34999_&_years.
				hshldinc35000to49999_&_years. hshldinc50000to74999_&_years.
                hshldinc75000to99999_&_years. hshldinc100000to124999_&_years.
				hshldinc125000to149999_&_years. hshldinc150000to199999_&_years.
                hshldinc200000plus_&_years.

		/*ACS Poverty*/		
			PctPoorPersons_&_years.
			poppoorpersons_&_years. 
			personspovertydefined_&_years. 

		/*ACS Education*/
			Pop25andoveryears_&_years.
			PctHS_&_years. 
			PctCol_&_years. 
			PctWoutHS_&_years.

		/*ACS Labor force and employment*/
			PctLaborForce_&_years.
			PctPopEmployed_&_years. 
			PctPopUnemployed_&_years. 
			popincivlaborforce_&_years.
			pop16andoveryears_&_years. 
			popcivilianemployed_&_years. 
			popunemployed_&_years. 
			
		/*ACS Employment by major occupations*/
			PopEmployedByOcc_&_years. 
			PopEmployedMngmt_&_years.
			PopEmployedServ_&_years. 
			PopEmployedSales_&_years.
			PopEmployedNatRes_&_years. 
			PopEmployedProd_&_years. 
    
       /*ACS employed person by annual earning*/ 
            EarningUnder10K_&_years. 
            Earning10to15K_&_years. 
            Earning15to25K_&_years. 
            Earning25to35K_&_years. 
            Earning35to50K_&_years.
	        Earning50to65K_&_years. 
            Earning65to75K_&_years. 
            EarningOver75K_&_years.

       /*ACS Persons by health insurance coverage by age*/
            InsCovUnder18Years_&_years. 
            InsCov18_34Years_&_years. 
            InsCov35_64Years_&_years. 
            InsCov65andOverYears_&_years.
	        NInsCovUnder18Years_&_years. 
            NInsCov18_34Years_&_years. 
            NInsCov35_64Years_&_years.
            NInsCov65andOverYears_&_years.

		/*Police and property crime rates: 2000 - 2016*/ 		
            property_crime_rate_2000			
            property_crime_rate_2001 property_crime_rate_2002 
			property_crime_rate_2003 property_crime_rate_2004
			property_crime_rate_2005 property_crime_rate_2006
			property_crime_rate_2007 property_crime_rate_2008
			property_crime_rate_2009 property_crime_rate_2010
			property_crime_rate_2011 property_crime_rate_2012 
			property_crime_rate_2013 property_crime_rate_2014
			property_crime_rate_2015 property_crime_rate_2016 
            property_crime_rate_2017
			
			violent_crime_rate_2000
			violent_crime_rate_2001 violent_crime_rate_2002 
			violent_crime_rate_2003 violent_crime_rate_2004
			violent_crime_rate_2005 violent_crime_rate_2006
			violent_crime_rate_2007 violent_crime_rate_2008
			violent_crime_rate_2009 violent_crime_rate_2010
			violent_crime_rate_2011 violent_crime_rate_2012 
			violent_crime_rate_2013 violent_crime_rate_2014
			violent_crime_rate_2015 violent_crime_rate_2016 
	        violent_crime_rate_2017 

  /*Vital Births and Deaths*/
               /*births_total_2000 births_total_2001 births_total_2002*/ births_total_2003 births_total_2004
			   births_total_2005 births_total_2006 births_total_2007 births_total_2008 births_total_2009
               births_total_2010 births_total_2011 births_total_2012 births_total_2013 births_total_2014
			   births_total_2015 births_total_2016

               /*births_prenat_adeq_2000 births_prenat_adeq_2001 births_prenat_adeq_2002*/ births_prenat_adeq_2003 births_prenat_adeq_2004
			   births_prenat_adeq_2005 births_prenat_adeq_2006 births_prenat_adeq_2007 births_prenat_adeq_2008 births_prenat_adeq_2009
               births_prenat_adeq_2010 births_prenat_adeq_2011 births_prenat_adeq_2012 births_prenat_adeq_2013 births_prenat_adeq_2014
			   births_prenat_adeq_2015 births_prenat_adeq_2016

               /*births_prenat_1st_2000 births_prenat_1st_2001 births_prenat_1st_2002 */ births_prenat_1st_2003 births_prenat_1st_2004
			   births_prenat_1st_2005 births_prenat_1st_2006 births_prenat_1st_2007 births_prenat_1st_2008 births_prenat_1st_2009
               births_prenat_1st_2010 births_prenat_1st_2011 births_prenat_1st_2012 births_prenat_1st_2013 births_prenat_1st_2014
			   births_prenat_1st_2015 births_prenat_1st_2016

			   /*births_low_wt_2000 births_low_wt_2001 births_low_wt_2002*/ births_low_wt_2003 births_low_wt_2004
			   births_low_wt_2005 births_low_wt_2006 births_low_wt_2007 births_low_wt_2008 births_low_wt_2009
               births_low_wt_2010 births_low_wt_2011 births_low_wt_2012 births_low_wt_2013 births_low_wt_2014
			   births_low_wt_2015 births_low_wt_2016

			   /*births_preterm_2000 births_preterm_2001 births_preterm_2002*/ births_preterm_2003 births_preterm_2004
			   births_preterm_2005 births_preterm_2006 births_preterm_2007 births_preterm_2008 births_preterm_2009
               births_preterm_2010 births_preterm_2011 births_preterm_2012 births_preterm_2013 births_preterm_2014
			   births_preterm_2015 births_preterm_2016

        /*TANF SNAP caseload*/

                tanf_case_1998 tanf_case_1999 tanf_case_2000 tanf_case_2001 tanf_case_2002
				tanf_case_2003 tanf_case_2004 tanf_case_2005 tanf_case_2006 tanf_case_2007
				tanf_case_2008 tanf_case_2009 tanf_case_2010 tanf_case_2011 tanf_case_2012
				tanf_case_2013 tanf_case_2014 tanf_case_2015 tanf_case_2016 
                fs_case_2000 fs_case_2001 fs_case_2002 fs_case_2003 fs_case_2004 fs_case_2005 
				fs_case_2006 fs_case_2007 fs_case_2008 fs_case_2009 fs_case_2010 fs_case_2011
				fs_case_2012 fs_case_2013 fs_case_2014 fs_case_2015 fs_case_2016

        /*HUD HCV counts*/
               total_units
 
        /*BRFS family emotional well being*/
			   MHLTH_CrudePrev
   
/*wait till death data is ready*/
               /*deaths_total_2000 deaths_total_2001 deaths_total_2002 deaths_total_2003 deaths_total_2004
			   deaths_total_2005 deaths_total_2006 deaths_total_2007 deaths_total_2008*/ deaths_total_2009
               deaths_total_2010 deaths_total_2011 deaths_total_2012 deaths_total_2013 deaths_total_2014
			   deaths_total_2015 deaths_total_2016

               /*deaths_15to19_2000 deaths_15to19_2001 deaths_15to19_2002 deaths_15to19_2003 deaths_15to19_2004 deaths_15to19_2005 
               deaths_15to19_2006 deaths_15to19_2007 deaths_15to19_2008*/ deaths_15to19_2009 deaths_15to19_2010
			   deaths_15to19_2011 deaths_15to19_2012 deaths_15to19_2013 deaths_15to19_2014 deaths_15to19_2015
               deaths_15to19_2016

               /*deaths_20to24_2000 deaths_20to24_2001 deaths_20to24_2002 deaths_20to24_2003 deaths_20to24_2004 deaths_20to24_2005 
               deaths_20to24_2006 deaths_20to24_2007 deaths_20to24_2008 */deaths_20to24_2009 deaths_20to24_2010
			   deaths_20to24_2011 deaths_20to24_2012 deaths_20to24_2013 deaths_20to24_2014 deaths_20to24_2015
               deaths_20to24_2016

               /*deaths_adult_2000 deaths_adult_2001 deaths_adult_2002 deaths_adult_2003 deaths_adult_2004 deaths_adult_2005 
               deaths_adult_2006 deaths_adult_2007 /*deaths_adult_2008*/ deaths_adult_2009 deaths_adult_2010
			   deaths_adult_2011 deaths_adult_2012 deaths_adult_2013 deaths_adult_2014 deaths_adult_2015
               deaths_adult_2016

			   /*deaths_accident_2000 deaths_accident_2001 deaths_accident_2002 deaths_accident_2003 deaths_accident_2004 deaths_accident_2005 
               deaths_accident_2006 deaths_accident_2007 deaths_accident_2008*/ deaths_accident_2009 deaths_accident_2010
			   deaths_accident_2011 deaths_accident_2012 deaths_accident_2013 deaths_accident_2014 deaths_accident_2015
               deaths_accident_2016

               /*deaths_cancer_2000 deaths_cancer_2001 deaths_cancer_2002 deaths_cancer_2003 deaths_cancer_2004 deaths_cancer_2005 
               deaths_cancer_2006 deaths_cancer_2007 deaths_cancer_2008*/ deaths_cancer_2009 deaths_cancer_2010
			   deaths_cancer_2011 deaths_cancer_2012 deaths_cancer_2013 deaths_cancer_2014 deaths_cancer_2015
               deaths_cancer_2016

               /*deaths_cereb_2000 deaths_cereb_2001 deaths_cereb_2002 deaths_cereb_2003 deaths_cereb_2004 deaths_cereb_2005 
               deaths_cereb_2006 deaths_cereb_2007 deaths_cereb_2008*/ deaths_cereb_2009 deaths_cereb_2010
			   deaths_cereb_2011 deaths_cereb_2012 deaths_cereb_2013 deaths_cereb_2014 deaths_cereb_2015
               deaths_cereb_2016

			   /*deaths_diabetes_2000 deaths_diabetes_2001 deaths_diabetes_2002 deaths_diabetes_2003 deaths_diabetes_2004 deaths_diabetes_2005 
               deaths_diabetes_2006 deaths_diabetes_2007 deaths_diabetes_2008*/ deaths_diabetes_2009 deaths_diabetes_2010
			   deaths_diabetes_2011 deaths_diabetes_2012 deaths_diabetes_2013 deaths_diabetes_2014 deaths_diabetes_2015
               deaths_diabetes_2016

               /*deaths_heart_2000 deaths_heart_2001 deaths_heart_2002 deaths_heart_2003 deaths_heart_2004 deaths_heart_2005 
               deaths_heart_2006 deaths_heart_2007 deaths_heart_2008*/ deaths_heart_2009 deaths_heart_2010
			   deaths_heart_2011 deaths_heart_2012 deaths_heart_2013 deaths_heart_2014 deaths_heart_2015
               deaths_heart_2016

               /*deaths_hiv_2000 deaths_hiv_2001 deaths_hiv_2002 deaths_hiv_2003 deaths_hiv_2004 deaths_hiv_2005 
               deaths_hiv_2006 deaths_hiv_2007 deaths_hiv_2008*/ deaths_hiv_2009 deaths_hiv_2010
			   deaths_hiv_2011 deaths_hiv_2012 deaths_hiv_2013 deaths_hiv_2014 deaths_hiv_2015
               deaths_hiv_2016

			   /*deaths_homicide_2000 deaths_homicide_2001 deaths_homicide_2002 deaths_homicide_2003 deaths_homicide_2004 deaths_homicide_2005 
               deaths_homicide_2006 deaths_homicide_2007 deaths_homicide_2008*/ deaths_homicide_2009 deaths_homicide_2010
			   deaths_homicide_2011 deaths_homicide_2012 deaths_homicide_2013 deaths_homicide_2014 deaths_homicide_2015
               deaths_homicide_2016

			   /*deaths_hypert_2000 deaths_hypert_2001 deaths_hypert_2002 deaths_hypert_2003 deaths_hypert_2004 deaths_hypert_2005 
               deaths_hypert_2006 deaths_hypert_2007 deaths_hypert_2008*/ deaths_hypert_2009 deaths_hypert_2010
			   deaths_hypert_2011 deaths_hypert_2012 deaths_hypert_2013 deaths_hypert_2014 deaths_hypert_2015
               deaths_hypert_2016

               /*deaths_liver_2000 deaths_liver_2001 deaths_liver_2002 deaths_liver_2003 deaths_liver_2004 deaths_liver_2005 
               deaths_liver_2006 deaths_liver_2007 deaths_liver_2008*/ deaths_liver_2009 deaths_liver_2010
			   deaths_liver_2011 deaths_liver_2012 deaths_liver_2013 deaths_liver_2014 deaths_liver_2015
               deaths_liver_2016

               /*deaths_oth_caus_2000 deaths_oth_caus_2001 deaths_oth_caus_2002 deaths_oth_caus_2003 deaths_oth_caus_2004 deaths_oth_caus_2005 
               deaths_oth_caus_2006 deaths_oth_caus_2007 deaths_oth_caus_2008*/ deaths_oth_caus_2009 deaths_oth_caus_2010
			   deaths_oth_caus_2011 deaths_oth_caus_2012 deaths_oth_caus_2013 deaths_oth_caus_2014 deaths_oth_caus_2015
               deaths_oth_caus_2016

			   /*deaths_suicide_2000 deaths_suicide_2001 deaths_suicide_2002 deaths_suicide_2003 deaths_suicide_2004 deaths_suicide_2005 
               deaths_suicide_2006 deaths_suicide_2007 deaths_suicide_2008*/ deaths_suicide_2009 deaths_suicide_2010
			   deaths_suicide_2011 deaths_suicide_2012 deaths_suicide_2013 deaths_suicide_2014 deaths_suicide_2015
               deaths_suicide_2016 
		;

id &geo; 
run; 

%File_info( data=compile_stanc_tabs_&geosuf, contents=n, printobs=0 )

proc export data=stanc_tabs_&geosuf
	outfile="L:\Libraries\StanC\Doc\Stanctabs_format_&geosuf..csv"
	dbms=csv replace;
	run;


%mend Compile_stanc_data;


%Compile_stanc_data (stantoncommons, stanc);
%Compile_stanc_data (ward2012, wd12);
%Compile_stanc_data (city, city);


