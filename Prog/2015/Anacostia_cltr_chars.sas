/**************************************************************************
 Program:  Anacostia_cltr_chars.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/18/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Compile cluster characteristics for Anacostia Park analysis.

 Modifications: SXZ - 4/28/2015 - Added new variables, restructured tables
				JKS - 7/12/2015 - Added new variables
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital, local=n )
%DCData_lib( ACS, local=n );
%DCData_lib( requests, local=n );
%DCData_lib( TANF, local=n );

%create_summary_from_tracts( geo=cluster_tr2000,
lib=requests, data_pre=acs_sf_2008_12, count_vars= b0: b1: b2: , tract_yr=2010, register=n);

data Anacostia_cltr_chars;

  merge
    Vital.deaths_sum_cltr00 
	  (keep=cluster_tr2000  deaths_total_2007 deaths_w_cause_2007 deaths_cancer_2007 deaths_cereb_2007 deaths_diabetes_2007 deaths_heart_2007 
			deaths_hiv_2007 deaths_liver_2007 deaths_respitry_2007 deaths_suicide_2007) 
    Vital.Births_sum_cltr00 (keep=cluster_tr2000 births_total_2011 births_teen_2011 births_single_2011 births_prenat_inad_2011)
 	ACS.Acs_2008_12_sum_tr_cltr00 
      (keep=cluster_tr2000 pop25andoveryears_2008_12 pop25andoverwouths_2008_12 
			pop25andoverwhs_2008_12 pop25andoverwcollege_2008_12)
	Requests.acs_sf_2008_12_cltr00
      (keep=cluster_tr2000 b01001e: b01003e1 B11001e1 B11003e: B11013e: B17001e: B23001e: B03002: B05: B19: B17: B25: B11001e1: B11001e6: B11001e5: B11001e8: B11001e4: B19013e1:)
	TANF.tanf_sum_cltr00
	  (keep=cluster_tr2000 tanf_fulpart_2013)
	TANF.fs_sum_cltr00
	  (keep=cluster_tr2000 fs_client_2013)
	;
  by cluster_tr2000;
  
  if cluster_tr2000 ~= '99';
  if cluster_tr2000 not in ('28','29','30','32','34','37') then delete; 

 	 Perc_Teen_Births_2011 = births_teen_2011 / births_total_2011;
  	Perc_Single_Births_2011 = births_single_2011 / births_total_2011;
 	 Perc_InadCare_Births_2011 = births_prenat_inad_2011 / births_total_2011;

 	TotPop_2008_12 = B01003e1;
	 HispanicOther_2008_12 = sum(B03002e5, B03002e7, B03002e8, B03002e9, B03002e10, B03002e11) / TotPop_2008_12;

	PopUnder18Years_2008_12 = 
      sum( B01001e3, B01001e4, B01001e5, B01001e6, 
           B01001e27, B01001e28, B01001e29, B01001e30 );
	Perc_PopUnder18Years_2008_12 = PopUnder18Years_2008_12/ TotPop_2008_12;
	Pop18andOverYears_2008_12 = TotPop_2008_12- PopUnder18Years_2008_12;
	Perc_Pop65andOverYears_2008_12 = 
      sum( B01001e20, B01001e21, B01001e22, B01001e23, B01001e24, B01001e25, 
           B01001e44, B01001e45, B01001e46, B01001e47, B01001e48, B01001e49 ) / Pop18andOverYears_2008_12;
	Perc_Pop18to24ACS_2008_12 = sum(OF B01001e7-B01001e10 B01001e31-B01001e34)/ Pop18andOverYears_2008_12;

	/*NumFamiliesOwnChild_2008_12 = 
      sum( B11003e3, B11003e10, B11003e16 ) + sum( B11013e3, B11013e5, B11013e6 );
	Perc_FamiliesOwnChildFH_2008_12 = (B11003e16 + B11013e5) / NumFamiliesOwnChild_2008_12;
	Perc_FamiliesOwnChildMH_2008_12 = (B11003e10 + B11013e6) / NumFamiliesOwnChild_2008_12;
	Perc_FamiliesOwnChildMAR_2008_12= (B11003e3 + B11013e3) / NumFamiliesOwnChild_2008_12;*/

   /*New variables- Household breakdown, Median Income, TANF and SNAP rate*/

	 NumHouseholds = B11001e1;
	Perc_FemHouseholds = B11001e6 / NumHouseholds;
	Perc_MaleHouseholds = B11001e5  / NumHouseholds;
	Perc_LivAlone = B11001e8 / NumHouseholds;
	Perc_OtherHH= B11001e4 / NumHouseholds;
	
	Med_HHIncome = B19013e1;

	TANF_rate_2013 = tanf_fulpart_2013 / TotPop_2008_12;
	SNAP_rate_2013 = fs_client_2013 / TotPop_2008_12;

    PopPoorPersons_2008_12 = B17001e2;
	PersonsPovertyDefined_2008_12 = B17001e1;
    PopPoorChildren_2008_12 = 
      sum( B17001e4, B17001e5, B17001e6, B17001e7, B17001e8, B17001e9, 
           B17001e18, B17001e19, B17001e20, B17001e21, B17001e22, B17001e23 );
    PopPoorElderly_2008_12 = 
      sum( B17001e15, B17001e16, B17001e29, B17001e30 );
	ChildrenPovertyDefined_2008_12 = 
      sum( B17001e4, B17001e5, B17001e6, B17001e7, B17001e8, B17001e9, 
           B17001e18, B17001e19, B17001e20, B17001e21, B17001e22, B17001e23,
           B17001e33, B17001e34, B17001e35, B17001e36, B17001e37, B17001e38, 
           B17001e47, B17001e48, B17001e49, B17001e50, B17001e51, B17001e52
          );
    ElderlyPovertyDefined_2008_12 = 
      sum( B17001e15, B17001e16, B17001e29, B17001e30,
           B17001e44, B17001e45, B17001e58, B17001e59
      );


	PopPoorAdults_2008_12 = PopPoorPersons_2008_12 - ( PopPoorChildren_2008_12 + PopPoorElderly_2008_12);
    PopPoorAdultsDef_2008_12 = PersonsPovertyDefined_2008_12 - (ChildrenPovertyDefined_2008_12 + ElderlyPovertyDefined_2008_12);

	PovRateAll_2008_12 = PopPoorPersons_2008_12/ PersonsPovertyDefined_2008_12;
	PovRateAdult_2008_12 = PopPoorAdults_2008_12 / PopPoorAdultsDef_2008_12 ; 


	perc_pop25andoverwouths_2008_12 = pop25andoverwouths_2008_12 / pop25andoveryears_2008_12;
	perc_pop25andoverwhs_2008_12=  pop25andoverwhs_2008_12/ pop25andoveryears_2008_12;
	p_pop25andoverwcollege_2008_12= pop25andoverwcollege_2008_12/ pop25andoveryears_2008_12;

	/*deaths with cause reports*/
	p_deaths_cancer_2007 = deaths_cancer_2007 / deaths_w_cause_2007;
	p_deaths_cereb_2007 = deaths_cereb_2007/ deaths_w_cause_2007;
	p_deaths_diabetes_2007 = deaths_diabetes_2007/ deaths_w_cause_2007;
	p_deaths_heart_2007 = deaths_heart_2007/ deaths_w_cause_2007;
	p_deaths_hiv_2007 = deaths_hiv_2007/deaths_w_cause_2007; 
	p_deaths_liver_2007 = deaths_liver_2007/deaths_w_cause_2007; 
	p_deaths_respitry_2007 = deaths_respitry_2007/deaths_w_cause_2007;
	p_deaths_suicide_2007= deaths_suicide_2007/deaths_w_cause_2007; 

run;

%File_info( data=Anacostia_cltr_chars, printobs=0 )

** Summary tables **;

ods listing close;

ods tagsets.excelxp file="L:\Libraries\Requests\Data\Anacostia_cltr_chars.xls" style=Printer options(sheet_interval='Proc' );

proc tabulate data=Anacostia_cltr_chars;
  class cluster_tr2000;
  var B01001e1 B01001e2 HispanicOther_2008_12 
   Pop18andOverYears_2008_12 Perc_Pop18to24ACS_2008_12 Perc_Pop65andOverYears_2008_12 
   PopUnder18Years_2008_12

   /*NumFamiliesOwnChild_2008_12 Perc_FamiliesOwnChildFH_2008_12 Perc_FamiliesOwnChildMH_2008_12 Perc_FamiliesOwnChildMAR_2008_12*/

   NumHouseholds Perc_FemHouseholds Perc_MaleHouseholds Perc_LivAlone Perc_OtherHH

   Med_HHIncome 

   TANF_rate_2013 SNAP_rate_2013

   births_total_2011 Perc_Teen_Births_2011 Perc_Single_Births_2011 Perc_InadCare_Births_2011

   PovRateAll_2008_12 PovRateAdult_2008_12 

   pop25andoveryears_2008_12 perc_pop25andoverwouths_2008_12 perc_pop25andoverwhs_2008_12 p_pop25andoverwcollege_2008_12

   deaths_total_2007 deaths_w_cause_2007 p_deaths_cancer_2007 p_deaths_cereb_2007 p_deaths_diabetes_2007 p_deaths_heart_2007 p_deaths_hiv_2007 
	p_deaths_liver_2007 p_deaths_respitry_2007 p_deaths_suicide_2007 ;

table B01001e1 B01001e2 HispanicOther_2008_12 
   Pop18andOverYears_2008_12 Perc_Pop18to24ACS_2008_12 Perc_Pop65andOverYears_2008_12 
   PopUnder18Years_2008_12

   /*NumFamiliesOwnChild_2008_12 Perc_FamiliesOwnChildFH_2008_12 Perc_FamiliesOwnChildMH_2008_12 Perc_FamiliesOwnChildMAR_2008_12*/

   NumHouseholds Perc_FemHouseholds Perc_MaleHouseholds Perc_LivAlone Perc_OtherHH

   Med_HHIncome 

   TANF_rate_2013 SNAP_rate_2013

   births_total_2011 Perc_Teen_Births_2011 Perc_Single_Births_2011 Perc_InadCare_Births_2011

   PovRateAll_2008_12 PovRateAdult_2008_12 

   pop25andoveryears_2008_12 perc_pop25andoverwouths_2008_12 perc_pop25andoverwhs_2008_12 p_pop25andoverwcollege_2008_12

   deaths_total_2007 deaths_w_cause_2007 p_deaths_cancer_2007 p_deaths_cereb_2007 p_deaths_diabetes_2007 p_deaths_heart_2007 p_deaths_hiv_2007 
	p_deaths_liver_2007 p_deaths_respitry_2007 p_deaths_suicide_2007, cluster_tr2000;
  format cluster_tr2000 $clus00f. _numeric_ comma10.5;
run;

ods tagsets.excelxp close;

ods listing;

filename fexport "L:\Libraries\Requests\Data\Anacostia_cltr_chars.csv" lrecl=2000;

proc export data=Summit_cltr_chars
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

