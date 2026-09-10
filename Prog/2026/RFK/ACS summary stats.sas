/*
Katie Visalli
5/27/26

Change Log:	9/10/2026 LH Swap out Income by Tenure to include all households and add cost burden denominators, update employment and race vars

Purpose:


Using the Acs.Acs_2020_24_dc_sum_tr_tr20 and Acs.Acs_2020_24_dc_sum_tr_wd22 data sets, 
construct the following indicators for the designated geographies.

Demographics
	Total population				totpop_2020_24
	Population under 18 years		PopUnder18Years_2020_24 
	Population 16 and over 			Pop16andOverYears_2020_24
	Population 65 years and older	pop65andoveryears_2020_24
	Population by race/ethnicity	PopWithRace_2020_24
		White 						PopWhiteNonHispBridge_2020_24
		Another, multiple, AIAN		PopOtherRaceNonHispBridg_2020_24
		latino						PopHisp_2020_24
		Black 						PopBlackNonHispBridge_2020_24
		AANHPI						 PopAsianPINonHispBridge_2020_24
	Total households				
	Households by size				
	Households by family type		
		nonfamilyhh1person_2020_24
		nonfamilyhh2person_2020_24
		nonfamilyhh3person_2020_24
		nonfamilyhh4person_2020_24
		nonfamilyhh5person_2020_24
		nonfamilyhh6person_2020_24
		nonfamilyhh7person_2020_24 (7+)
		familyhh2person_2020_24
		familyhh3person_2020_24
		familyhh4person_2020_24
		familyhh5person_2020_24
		familyhh6person_2020_24
		familyhh7person_2020_24 (7+)

Housing
	Total housing units				numhsgunits_2020_24
	Owner occupied housing units	numowneroccupiedhu_2020_24
	Renter-occupied housing units	numrenteroccupiedhu_2020_24
	Vacant housing units			numvacanthsgunits_2020_24, numvacanthsgunitsforsale_2020_24, numvacanthsgunitsforrent_2020_24

	Housing units by age of building*******COULD NOT FIND	
		
	Owner-occupied housing units by gross rent ranges
	Owner-occupied housing units by housing cost burden
		owners with 30% cost burden		numownercostburden_2020_24
		owners with 50% cost burden		numownseverecostburden_2020_24
	Renter-occupied housing units by gross rent ranges
		grossrent1000_1249_2020_24	N	Values	Renter-occupied housing units where gross rent is $1000 to $1249, 2020-24
		grossrent100_149_2020_24	N	Values	Renter-occupied housing units where gross rent is $100 to $149, 2020-24
		grossrent1250_1499_2020_24	N	Values	Renter-occupied housing units where gross rent is $1250 to $1499, 2020-24
		grossrent1500_1999_2020_24	N	Values	Renter-occupied housing units where gross rent is $1500 to $1999, 2020-24
		grossrent150_199_2020_24	N	Values	Renter-occupied housing units where gross rent is $150 to $199, 2020-24
		grossrent2000_2499_2020_24	N	Values	Renter-occupied housing units where gross rent is $2000 to $2499, 2020-24
		grossrent200_249_2020_24	N	Values	Renter-occupied housing units where gross rent is $200 to $249, 2020-24
		grossrent2500_2999_2020_24	N	Values	Renter-occupied housing units where gross rent is $2500 to $2999, 2020-24
		grossrent250_299_2020_24	N	Values	Renter-occupied housing units where gross rent is $250 to $299, 2020-24
		grossrent3000_3499_2020_24	N	Values	Renter-occupied housing units where gross rent is $3000 to $3499, 2020-24
		grossrent300_349_2020_24	N	Values	Renter-occupied housing units where gross rent is $300 to $349, 2020-24
		grossrent350_349_2020_24	N	Values	Renter-occupied housing units where gross rent is $350 to $399, 2020-24
		grossrent400_449_2020_24	N	Values	Renter-occupied housing units where gross rent is $400 to $449, 2020-24
		grossrent450_499_2020_24	N	Values	Renter-occupied housing units where gross rent is $450 to $499, 2020-24
		grossrent500_549_2020_24	N	Values	Renter-occupied housing units where gross rent is $500 to $549, 2020-24
		grossrent550_599_2020_24	N	Values	Renter-occupied housing units where gross rent is $550 to $599, 2020-24
		grossrent600_649_2020_24	N	Values	Renter-occupied housing units where gross rent is $600 to $649, 2020-24
		grossrent650_699_2020_24	N	Values	Renter-occupied housing units where gross rent is $650 to $699, 2020-24
		grossrent700_749_2020_24	N	Values	Renter-occupied housing units where gross rent is $700 to $749, 2020-24
		grossrent750_799_2020_24	N	Values	Renter-occupied housing units where gross rent is $750 to $799, 2020-24
		grossrent800_899_2020_24	N	Values	Renter-occupied housing units where gross rent is $800 to $899, 2020-24
		grossrent900_999_2020_24	N	Values	Renter-occupied housing units where gross rent is $900 to $999, 2020-24
		grossrentgt2000_2020_24	N	Values	Renter-occupied housing units where gross rent is greater than $2000, 2020-24
		grossrentgt3500_2020_24	N	Values	Renter-occupied housing units where gross rent is greater than $3500, 2020-24
	Renter-occupied housing units by housing cost burden
		renters with 30% burden			numrentercostburden_2020_24
		renters with 50% cost burden	numrentseverecostburden_2020_24
										RentCostBurdenDenom_2020_24
										OwnerCostBurdenDenom_2020_24
										NumOwnerCostBurden_2020_24
										NumOwnSevereCostBurden_2020_24

Economics
	Persons living in families below the federal poverty level		poppoorpersons_2020_24
	Households by income ranges

	RentOccHHIncL5K_2020_24 = "Household income less than 5K and renter-occ, 2020-24"
  RentOccHHInc5999K_2020_24 = "Household income between 5K and 9.99K and renter-occ, 2020-24"
  RentOccHHInc101499K_2020_24 = "Household income between 10K and 14.99K and renter-occ, 2020-24"
  RentOccHHInc151999K_2020_24 = "Household income between 15K and 19.99K and renter-occ, 2020-24"
  RentOccHHInc202499K_2020_24 = "Household income between 20K and 24.99K and renter-occ, 2020-24"
  RentOccHHInc253499K_2020_24 = "Household income between 25K and 34.99K and renter-occ, 2020-24"
  RentOccHHInc354999K_2020_24 = "Household income between 35K and 49.99K and renter-occ, 2020-24"
  RentOccHHInc507499K_2020_24 = "Household income between 50K and 74.99K and renter-occ, 2020-24"
  RentOccHHInc759999K_2020_24 = "Household income between 75K and 99.99K and renter-occ, 2020-24"
  RentOccHHInc10014999K_2020_24 = "Household income between 100K and 149.99K and renter-occ, 2020-24"
  RentOccHHInc150M_2020_24 = "Household income 150K and higher and renter-occ, 2020-24"


  OwnOccHHIncL5K_2020_24 = "Household income less than 5K and owner-occ, 2020-24"
  OwnOccHHInc5999K_2020_24 = "Household income between 5K and 9.99K and owner-occ, 2020-24"
  OwnOccHHInc101499K_2020_24 = "Household income between 10K and 14.99K and owner-occ, 2020-24"
  OwnOccHHInc151999K_2020_24 = "Household income between 15K and 19.99K and owner-occ, 2020-24"
  OwnOccHHInc202499K_2020_24 = "Household income between 20K and 24.99K and owner-occ, 2020-24"
  OwnOccHHInc253499K_2020_24 = "Household income between 25K and 34.99K and owner-occ, 2020-24"
  OwnOccHHInc354999K_2020_24 = "Household income between 35K and 49.99K and owner-occ, 2020-24"
  OwnOccHHInc507499K_2020_24 = "Household income between 50K and 74.99K and owner-occ, 2020-24"
  OwnOccHHInc759999K_2020_24 = "Household income between 75K and 99.99K and owner-occ, 2020-24"
  OwnOccHHInc10014999K_2020_24 = "Household income between 100K and 149.99K and owner-occ, 2020-24"
  OwnOccHHInc150M_2020_24 = "Household income 150K and higher and owner-occ, 2020-24"


	Persons in labor force		PopInCivLaborForce_2020_24
	Persons who are employed	Pop16andOverEmploy_2020_24
	Persons who are unemployed	PopUnemployed_2020_24
	Census Tract					geo2020
*/

* Set Up;
*%include "F:\DCDATA\SAS\Inc\StdRemote.sas";
%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";


* Data Libraries ;
%DCData_lib( ACS )

* load census tract -based data;
data tracts;
	length tract $100;
set acs.acs_2020_24_dc_sum_tr_tr20;
	tract = transtrn(geo2020, 'DC Tract ', trimn(''));
	tract2 = tract * 1;
run;


* load ward data;
data wards;
set acs.acs_2020_24_dc_sum_tr_wd22;
run;

* Merge RFK identified census tracts with ACS data;
proc import 
	out = rfk_tracts 
	datafile = "//sas1/dcdata/Libraries/Requests/Prog/2026/RFK/Result/rfk_distance_tracts.csv"
	DBMS = csv;
run;

data rfk_tracts2;
set rfk_tracts;
tract2 = GEOID * 1;
run;

proc sql; create table tracts2 as select
a.*, b.*
from tracts as a
left join rfk_tracts2 as b
on a.tract2 = b.tract2;
quit;

*dummy variables for each area;
data tracts3;
	set tracts2;
	dc = 1;
	if ward2022 = 7 then ward7 = 1;
	else ward7 = 0;
run;

*create Summary Statistics, census tracts in RFK sub groups (East & West of Anacostia);
proc sql; create table sub_summary_stats as select
/* census tract */
	rfk_sub_group, count(tract2) as tracts,
/*population, age*/
	sum(totpop_2020_24) as total_population, sum(PopUnder18Years_2020_24) as population_under18, sum(Pop16andOverYears_2020_24) as population_16over, sum(pop65andoveryears_2020_24) as population_65over,
/* work Force */
	sum(Pop16andOverEmploy_2020_24) as employed, 
	sum(popunemployed_2020_24) as unemployed,
	sum(PopInCivLaborForce_2020_24) as laborforce,
/*Race & Ethnicity*/
	sum(PopWithRace_2020_24) as poprace, sum(PopWhiteNonHispBridge_2020_24) as white, sum(PopOtherRaceNonHispBridg_2020_24) as another_race, sum(PopHisp_2020_24) as latino, sum(PopBlackNonHispBridge_2020_24) as black, sum(PopAsianPINonHispBridge_2020_24) as AANHPI,
/* Households by size and family type */
	sum(nonfamilyhh1person_2020_24) as nonfam1,
	sum(nonfamilyhh2person_2020_24) as nonfam2,
	sum(nonfamilyhh3person_2020_24) as nonfam3,
	sum(nonfamilyhh4person_2020_24) as nonfam4,
	sum(nonfamilyhh5person_2020_24) as nonfam5,
	sum(nonfamilyhh6person_2020_24) as nonfam6,
	sum(nonfamilyhh7person_2020_24) as nonfam7,
	sum(familyhh2person_2020_24) as family2,
	sum(familyhh3person_2020_24) as family3,
	sum(familyhh4person_2020_24) as family4,
	sum(familyhh5person_2020_24) as family5,
	sum(familyhh6person_2020_24) as family6,
	sum(familyhh7person_2020_24) as family7,
/* Housing Units */
	sum(numhsgunits_2020_24) as housing_units, sum(numrenteroccupiedhu_2020_24) as renter_occupied_units, sum(numowneroccupiedhu_2020_24) as owner_occupied_units,
	sum(numvacanthsgunits_2020_24) as vacant_units, sum(numvacanthsgunitsforsale_2020_24) as vacant_owner_units, sum(numvacanthsgunitsforrent_2020_24) as vacant_rent_units,
/* Gross Rent */
	sum(grossrent100_149_2020_24) as grossrent100_149_2020_24,
	sum(grossrent150_199_2020_24) as grossrent150_199_2020_24,
	sum(grossrent200_249_2020_24) as grossrent200_249_2020_24,
	sum(grossrent250_299_2020_24) as grossrent250_299_2020_24,
	sum(grossrent300_349_2020_24) as grossrent300_349_2020_24,
	sum(grossrent350_349_2020_24) as grossrent350_349_2020_24,
	sum(grossrent400_449_2020_24) as grossrent400_449_2020_24,
	sum(grossrent450_499_2020_24) as grossrent450_499_2020_24,
	sum(grossrent500_549_2020_24) as grossrent500_549_2020_24,
	sum(grossrent550_599_2020_24) as grossrent550_599_2020_24,	
	sum(grossrent600_649_2020_24) as grossrent600_649_2020_24,
	sum(grossrent650_699_2020_24) as grossrent650_699_2020_24,
	sum(grossrent700_749_2020_24) as grossrent700_749_2020_24,
	sum(grossrent750_799_2020_24) as grossrent750_799_2020_24,
	sum(grossrent800_899_2020_24) as grossrent800_899_2020_24,
	sum(grossrent900_999_2020_24) as grossrent900_999_2020_24,
	sum(grossrent1000_1249_2020_24) as grossrent1000_1249_2020_24,
	sum(grossrent1250_1499_2020_24) as grossrent1250_1499_2020_24,
	sum(grossrent1500_1999_2020_24) as grossrent1500_1999_2020_24,
	sum(grossrent2000_2499_2020_24) as grossrent2000_2499_2020_24,
	sum(grossrent2500_2999_2020_24) as grossrent2500_2999_2020_24,
	sum(grossrent3000_3499_2020_24) as grossrent3000_3499_2020_24,
	sum(grossrentgt3500_2020_24) as grossrentgt3500_2020_24,
/* Cost Burdens */
	sum(numrentercostburden_2020_24) as renters_costburden_30, sum(numrentseverecostburden_2020_24) as renters_cost_burden_50, sum(RentCostBurdenDenom_2020_24) as rentCBdenom,
	sum(numownercostburden_2020_24) as owners_costburden_30, sum(numownseverecostburden_2020_24) as owners_cost_burden_50, sum(OwnerCostBurdenDenom_2020_24) as ownCBdenom, 
/* Incomes by Tenure */
	sum(OwnOccHHIncL5K_2020_24) as ownerinc_lt5k, 
	sum(OwnOccHHInc5999K_2020_24 ) as ownerinc_5_9k,
	sum(OwnOccHHInc101499K_2020_24) as ownerinc_10_14k,
	sum(OwnOccHHInc151999K_2020_24 ) as ownerinc_15_19k,
	sum(OwnOccHHInc202499K_2020_24 ) as ownerinc_20_24k,
	sum(OwnOccHHInc253499K_2020_24 ) as ownerinc_25_34k,
	sum(OwnOccHHInc354999K_2020_24 ) as ownerinc_35_49k,
	sum(OwnOccHHInc507499K_2020_24 ) as ownerinc_50_74k,
	sum(OwnOccHHInc759999K_2020_24 ) as ownerinc_75_99k,
	sum(OwnOccHHInc10014999K_2020_24) as ownerinc_100_149k,
	sum(OwnOccHHInc150M_2020_24) as ownerinc_150kplus,
	sum(RentOccHHIncL5K_2020_24) as renterinc_lt5k, 
	sum(RentOccHHInc5999K_2020_24 ) as renterinc_5_9k,
	sum(RentOccHHInc101499K_2020_24) as renterinc_10_14k,
	sum(RentOccHHInc151999K_2020_24 ) as renterinc_15_19k,
	sum(RentOccHHInc202499K_2020_24 ) as renterinc_20_24k,
	sum(RentOccHHInc253499K_2020_24 ) as renterinc_25_34k,
	sum(RentOccHHInc354999K_2020_24 ) as renterinc_35_49k,
	sum(RentOccHHInc507499K_2020_24 ) as renterinc_50_74k,
	sum(RentOccHHInc759999K_2020_24 ) as renterinc_75_99k,
	sum(RentOccHHInc10014999K_2020_24) as renterinc_100_149k,
	sum(RentOccHHInc150M_2020_24) as renterinc_150kplus

from tracts2
group by rfk_sub_group;
quit;

proc print data = sub_summary_stats;
run;

*create Summary Statistics, census tracts in and out of the RFK area;
proc sql; create table summary_stats as select
/* census tract */
	rfk_group, count(tract2) as tracts,
/*population, age*/
	sum(totpop_2020_24) as total_population, sum(PopUnder18Years_2020_24) as population_under18, sum(Pop16andOverYears_2020_24) as population_16over, sum(pop65andoveryears_2020_24) as population_65over,
/* work Force */
	sum(Pop16andOverEmploy_2020_24) as employed, 
	sum(popunemployed_2020_24) as unemployed,
	sum(PopInCivLaborForce_2020_24) as laborforce,
/*Race & Ethnicity*/
	sum(PopWithRace_2020_24) as poprace, sum(PopWhiteNonHispBridge_2020_24) as white, sum(PopOtherRaceNonHispBridg_2020_24) as another_race, sum(PopHisp_2020_24) as latino, sum(PopBlackNonHispBridge_2020_24) as black, sum(PopAsianPINonHispBridge_2020_24) as AANHPI,
/* Households by size and family type */
	sum(nonfamilyhh1person_2020_24) as nonfam1,
	sum(nonfamilyhh2person_2020_24) as nonfam2,
	sum(nonfamilyhh3person_2020_24) as nonfam3,
	sum(nonfamilyhh4person_2020_24) as nonfam4,
	sum(nonfamilyhh5person_2020_24) as nonfam5,
	sum(nonfamilyhh6person_2020_24) as nonfam6,
	sum(nonfamilyhh7person_2020_24) as nonfam7,
	sum(familyhh2person_2020_24) as family2,
	sum(familyhh3person_2020_24) as family3,
	sum(familyhh4person_2020_24) as family4,
	sum(familyhh5person_2020_24) as family5,
	sum(familyhh6person_2020_24) as family6,
	sum(familyhh7person_2020_24) as family7,
/* Housing Units */
	sum(numhsgunits_2020_24) as housing_units, sum(numrenteroccupiedhu_2020_24) as renter_occupied_units, sum(numowneroccupiedhu_2020_24) as owner_occupied_units,
	sum(numvacanthsgunits_2020_24) as vacant_units, sum(numvacanthsgunitsforsale_2020_24) as vacant_owner_units, sum(numvacanthsgunitsforrent_2020_24) as vacant_rent_units,
/* Gross Rent */
	sum(grossrent100_149_2020_24) as grossrent100_149_2020_24,
	sum(grossrent150_199_2020_24) as grossrent150_199_2020_24,
	sum(grossrent200_249_2020_24) as grossrent200_249_2020_24,
	sum(grossrent250_299_2020_24) as grossrent250_299_2020_24,
	sum(grossrent300_349_2020_24) as grossrent300_349_2020_24,
	sum(grossrent350_349_2020_24) as grossrent350_349_2020_24,
	sum(grossrent400_449_2020_24) as grossrent400_449_2020_24,
	sum(grossrent450_499_2020_24) as grossrent450_499_2020_24,
	sum(grossrent500_549_2020_24) as grossrent500_549_2020_24,
	sum(grossrent550_599_2020_24) as grossrent550_599_2020_24,	
	sum(grossrent600_649_2020_24) as grossrent600_649_2020_24,
	sum(grossrent650_699_2020_24) as grossrent650_699_2020_24,
	sum(grossrent700_749_2020_24) as grossrent700_749_2020_24,
	sum(grossrent750_799_2020_24) as grossrent750_799_2020_24,
	sum(grossrent800_899_2020_24) as grossrent800_899_2020_24,
	sum(grossrent900_999_2020_24) as grossrent900_999_2020_24,
	sum(grossrent1000_1249_2020_24) as grossrent1000_1249_2020_24,
	sum(grossrent1250_1499_2020_24) as grossrent1250_1499_2020_24,
	sum(grossrent1500_1999_2020_24) as grossrent1500_1999_2020_24,
	sum(grossrent2000_2499_2020_24) as grossrent2000_2499_2020_24,
	sum(grossrent2500_2999_2020_24) as grossrent2500_2999_2020_24,
	sum(grossrent3000_3499_2020_24) as grossrent3000_3499_2020_24,
	sum(grossrentgt3500_2020_24) as grossrentgt3500_2020_24,
/* Cost Burdens */
	sum(numrentercostburden_2020_24) as renters_costburden_30, sum(numrentseverecostburden_2020_24) as renters_cost_burden_50, sum(RentCostBurdenDenom_2020_24) as rentCBdenom,
	sum(numownercostburden_2020_24) as owners_costburden_30, sum(numownseverecostburden_2020_24) as owners_cost_burden_50, sum(OwnerCostBurdenDenom_2020_24) as ownCBdenom, 
/* Incomes by Tenure */
	sum(OwnOccHHIncL5K_2020_24) as ownerinc_lt5k, 
	sum(OwnOccHHInc5999K_2020_24 ) as ownerinc_5_9k,
	sum(OwnOccHHInc101499K_2020_24) as ownerinc_10_14k,
	sum(OwnOccHHInc151999K_2020_24 ) as ownerinc_15_19k,
	sum(OwnOccHHInc202499K_2020_24 ) as ownerinc_20_24k,
	sum(OwnOccHHInc253499K_2020_24 ) as ownerinc_25_34k,
	sum(OwnOccHHInc354999K_2020_24 ) as ownerinc_35_49k,
	sum(OwnOccHHInc507499K_2020_24 ) as ownerinc_50_74k,
	sum(OwnOccHHInc759999K_2020_24 ) as ownerinc_75_99k,
	sum(OwnOccHHInc10014999K_2020_24) as ownerinc_100_149k,
	sum(OwnOccHHInc150M_2020_24) as ownerinc_150kplus,
	sum(RentOccHHIncL5K_2020_24) as renterinc_lt5k, 
	sum(RentOccHHInc5999K_2020_24 ) as renterinc_5_9k,
	sum(RentOccHHInc101499K_2020_24) as renterinc_10_14k,
	sum(RentOccHHInc151999K_2020_24 ) as renterinc_15_19k,
	sum(RentOccHHInc202499K_2020_24 ) as renterinc_20_24k,
	sum(RentOccHHInc253499K_2020_24 ) as renterinc_25_34k,
	sum(RentOccHHInc354999K_2020_24 ) as renterinc_35_49k,
	sum(RentOccHHInc507499K_2020_24 ) as renterinc_50_74k,
	sum(RentOccHHInc759999K_2020_24 ) as renterinc_75_99k,
	sum(RentOccHHInc10014999K_2020_24) as renterinc_100_149k,
	sum(RentOccHHInc150M_2020_24) as renterinc_150kplus

from tracts2
group by rfk_group;
quit;

proc print data = summary_stats;
run;

*create Summary Statistics, by Ward;
proc sql; create table summary_stats_ward as select
/* census tract */
	ward2022,
/*population, age*/
	sum(totpop_2020_24) as total_population, sum(PopUnder18Years_2020_24) as population_under18, sum(Pop16andOverYears_2020_24) as population_16over, sum(pop65andoveryears_2020_24) as population_65over,
/* work Force */
	sum(Pop16andOverEmploy_2020_24) as employed, 
	sum(popunemployed_2020_24) as unemployed,
	sum(PopInCivLaborForce_2020_24) as laborforce,
/*Race & Ethnicity*/
	sum(PopWithRace_2020_24) as poprace, sum(PopWhiteNonHispBridge_2020_24) as white, sum(PopOtherRaceNonHispBridg_2020_24) as another_race, sum(PopHisp_2020_24) as latino, sum(PopBlackNonHispBridge_2020_24) as black, sum(PopAsianPINonHispBridge_2020_24) as AANHPI,
/* Households by size and family type */
	sum(nonfamilyhh1person_2020_24) as nonfam1,
	sum(nonfamilyhh2person_2020_24) as nonfam2,
	sum(nonfamilyhh3person_2020_24) as nonfam3,
	sum(nonfamilyhh4person_2020_24) as nonfam4,
	sum(nonfamilyhh5person_2020_24) as nonfam5,
	sum(nonfamilyhh6person_2020_24) as nonfam6,
	sum(nonfamilyhh7person_2020_24) as nonfam7,
	sum(familyhh2person_2020_24) as family2,
	sum(familyhh3person_2020_24) as family3,
	sum(familyhh4person_2020_24) as family4,
	sum(familyhh5person_2020_24) as family5,
	sum(familyhh6person_2020_24) as family6,
	sum(familyhh7person_2020_24) as family7,
/* Housing Units */
	sum(numhsgunits_2020_24) as housing_units, sum(numrenteroccupiedhu_2020_24) as renter_occupied_units, sum(numowneroccupiedhu_2020_24) as owner_occupied_units,
	sum(numvacanthsgunits_2020_24) as vacant_units, sum(numvacanthsgunitsforsale_2020_24) as vacant_owner_units, sum(numvacanthsgunitsforrent_2020_24) as vacant_rent_units,
/* Gross Rent */
	sum(grossrent100_149_2020_24) as grossrent100_149_2020_24,
	sum(grossrent150_199_2020_24) as grossrent150_199_2020_24,
	sum(grossrent200_249_2020_24) as grossrent200_249_2020_24,
	sum(grossrent250_299_2020_24) as grossrent250_299_2020_24,
	sum(grossrent300_349_2020_24) as grossrent300_349_2020_24,
	sum(grossrent350_349_2020_24) as grossrent350_349_2020_24,
	sum(grossrent400_449_2020_24) as grossrent400_449_2020_24,
	sum(grossrent450_499_2020_24) as grossrent450_499_2020_24,
	sum(grossrent500_549_2020_24) as grossrent500_549_2020_24,
	sum(grossrent550_599_2020_24) as grossrent550_599_2020_24,	
	sum(grossrent600_649_2020_24) as grossrent600_649_2020_24,
	sum(grossrent650_699_2020_24) as grossrent650_699_2020_24,
	sum(grossrent700_749_2020_24) as grossrent700_749_2020_24,
	sum(grossrent750_799_2020_24) as grossrent750_799_2020_24,
	sum(grossrent800_899_2020_24) as grossrent800_899_2020_24,
	sum(grossrent900_999_2020_24) as grossrent900_999_2020_24,
	sum(grossrent1000_1249_2020_24) as grossrent1000_1249_2020_24,
	sum(grossrent1250_1499_2020_24) as grossrent1250_1499_2020_24,
	sum(grossrent1500_1999_2020_24) as grossrent1500_1999_2020_24,
	sum(grossrent2000_2499_2020_24) as grossrent2000_2499_2020_24,
	sum(grossrent2500_2999_2020_24) as grossrent2500_2999_2020_24,
	sum(grossrent3000_3499_2020_24) as grossrent3000_3499_2020_24,
	sum(grossrentgt3500_2020_24) as grossrentgt3500_2020_24,
/* Cost Burdens */
	sum(numrentercostburden_2020_24) as renters_costburden_30, sum(numrentseverecostburden_2020_24) as renters_cost_burden_50, sum(RentCostBurdenDenom_2020_24) as rentCBdenom,
	sum(numownercostburden_2020_24) as owners_costburden_30, sum(numownseverecostburden_2020_24) as owners_cost_burden_50, sum(OwnerCostBurdenDenom_2020_24) as ownCBdenom, 
/* Incomes by Tenure */
	sum(OwnOccHHIncL5K_2020_24) as ownerinc_lt5k, 
	sum(OwnOccHHInc5999K_2020_24 ) as ownerinc_5_9k,
	sum(OwnOccHHInc101499K_2020_24) as ownerinc_10_14k,
	sum(OwnOccHHInc151999K_2020_24 ) as ownerinc_15_19k,
	sum(OwnOccHHInc202499K_2020_24 ) as ownerinc_20_24k,
	sum(OwnOccHHInc253499K_2020_24 ) as ownerinc_25_34k,
	sum(OwnOccHHInc354999K_2020_24 ) as ownerinc_35_49k,
	sum(OwnOccHHInc507499K_2020_24 ) as ownerinc_50_74k,
	sum(OwnOccHHInc759999K_2020_24 ) as ownerinc_75_99k,
	sum(OwnOccHHInc10014999K_2020_24) as ownerinc_100_149k,
	sum(OwnOccHHInc150M_2020_24) as ownerinc_150kplus,
	sum(RentOccHHIncL5K_2020_24) as renterinc_lt5k, 
	sum(RentOccHHInc5999K_2020_24 ) as renterinc_5_9k,
	sum(RentOccHHInc101499K_2020_24) as renterinc_10_14k,
	sum(RentOccHHInc151999K_2020_24 ) as renterinc_15_19k,
	sum(RentOccHHInc202499K_2020_24 ) as renterinc_20_24k,
	sum(RentOccHHInc253499K_2020_24 ) as renterinc_25_34k,
	sum(RentOccHHInc354999K_2020_24 ) as renterinc_35_49k,
	sum(RentOccHHInc507499K_2020_24 ) as renterinc_50_74k,
	sum(RentOccHHInc759999K_2020_24 ) as renterinc_75_99k,
	sum(RentOccHHInc10014999K_2020_24) as renterinc_100_149k,
	sum(RentOccHHInc150M_2020_24) as renterinc_150kplus

from wards
group by ward2022 ;
quit;

proc print data = summary_stats_ward;
run;

