/*
Katie Visalli
5/27/26

Change Log:

Purpose:


Using the Acs.Acs_2020_24_dc_sum_tr_tr20 and Acs.Acs_2020_24_dc_sum_tr_wd22 data sets, 
construct the following indicators for the designated geographies.

Demographics
	Total population				totpop_2020_24
	Population under 18 years		totalcivhhpop_2020_24 (16+)
	Population 65 years and older	pop65andoveryears_2020_24
	Population by race/ethnicity	
		White 						popalonew_2020_24
		Another, multiple, AIAN		popaloneiom_2020_24
		latino						popaloneh_2020_24
		Black 						popaloneb_2020_24
		AANHPI						popalonea_2020_24
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

Economics
	Persons living in families below the federal poverty level		poppoorpersons_2020_24
	Households by income ranges
		incmbyownercst_100_149_2020_24	N	Values	Owner-occupied housing units with household income $100,000 to $149,999, excluding units where owner cost burden is not computed, 2020-24
		incmbyownercst_10_19k_2020_24	N	Values	Owner-occupied housing units with household income less than $10,000, excluding units where owner cost burden is not computed, 2020-24
		incmbyownercst_20_34k_2020_24	N	Values	Owner-occupied housing units with household income $20,000 to $34,999, excluding units where owner cost burden is not computed, 2020-24
		incmbyownercst_35_49k_2020_24	N	Values	Owner-occupied housing units with household income $35,000 to $49,999, excluding units where owner cost burden is not computed, 2020-24
		incmbyownercst_50_74k_2020_24	N	Values	Owner-occupied housing units with household income $50,000 to $74,999, excluding units where owner cost burden is not computed, 2020-24
		incmbyownercst_75_99k_2020_24	N	Values	Owner-occupied housing units with household income $75,000 to $99,999, excluding units where owner cost burden is not computed, 2020-24
		incmbyownercst_gt150k_2020_24	N	Values	Owner-occupied housing units with household income $150,000 or more, excluding units where owner cost burden is not computed, 2020-24
		incmbyownercst_lt10k_2020_24	N	Values	Owner-occupied housing units with household income less than $10,000, excluding units where owner cost burden is not computed, 2020-24
		incmbyrentercst_10_19k_2020_24	N	Values	Renter-occupied housing units with household income less than $10,000, excluding units where renter cost burden is not computed, 2020-24
		incmbyrentercst_20_34k_2020_24	N	Values	Renter-occupied housing units with household income $20,000 to $34,999, excluding units where renter cost burden is not computed, 2020-24
		incmbyrentercst_35_49k_2020_24	N	Values	Renter-occupied housing units with household income $35,000 to $49,999, excluding units where renter cost burden is not computed, 2020-24
		incmbyrentercst_50_74k_2020_24	N	Values	Renter-occupied housing units with household income $50,000 to $74,999, excluding units where renter cost burden is not computed, 2020-24
		incmbyrentercst_75_99k_2020_24	N	Values	Renter-occupied housing units with household income $75,000 to $99,999, excluding units where renter cost burden is not computed, 2020-24
		incmbyrentercst_gt100k_2020_24	N	Values	Renter-occupied housing units with household income $100,000 or more, excluding units where renter cost burden is not computed, 2020-24
		incmbyrentercst_lt10k_2020_24	N	Values	Renter-occupied housing units with household income less than $10,000, excluding units where renter cost burden is not computed, 2020-24
	Persons in labor force		
	Persons who are employed	popemployedworkers_2020_24
	Persons who are unemployed	popunemployed_2020_24
	Census Tract					geo2020
*/

* Set Up;
%include "F:\DCDATA\SAS\Inc\StdRemote.sas";

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

data rfk_tracts;
set rfk_tracts;
tract2 = GEOID * 1;
run;

proc sql; create table tracts2 as select
a.*, b.*
from tracts as a
left join rfk_tracts as b
on a.tract2 = b.tract2;
quit;

*create Summary Statistics, census tracts in RFK sub groups (East & West of Anacostia);
proc sql; create table sub_summary_stats as select
/* census tract */
	rfk_sub_group, count(tract) as tracts,
/*population, age*/
	sum(totpop_2020_24) as total_population, sum(totalcivhhpop_2020_24) as population_16over, sum(pop65andoveryears_2020_24) as population_65over,
/* work Force */
	sum(popemployedworkers_2020_24) as employed, 
	sum(popunemployed_2020_24) as unemployed,
/*Race & Ethnicity*/
	sum(popalonew_2020_24) as white, sum(popaloneiom_2020_24) as another_race, sum(popaloneh_2020_24) as latino, sum(popaloneb_2020_24) as black, sum(popalonea_2020_24) as AANHPI,
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
	sum(numrentercostburden_2020_24) as renters_costburden_30, sum(numrentseverecostburden_2020_24) as renters_cost_burden_50,
	sum(numownercostburden_2020_24) as owners_costburden_30, sum(numownseverecostburden_2020_24) as owners_cost_burden_50,
/* Incomes by Tenure */
	sum(incmbyownercst_lt10k_2020_24) as ownerinc_lt10k, 
	sum(incmbyownercst_10_19k_2020_24) as ownerinc_10_19k,
	sum(incmbyownercst_20_34k_2020_24) as ownerinc_20_34k,
	sum(incmbyownercst_35_49k_2020_24) as ownerinc_35_49k,
	sum(incmbyownercst_50_74k_2020_24) as ownerinc_50_74k,
	sum(incmbyownercst_75_99k_2020_24) as ownerinc_75_99k,
	sum(incmbyownercst_100_149_2020_24) as ownerinc_100_149k,
	sum(incmbyownercst_gt150k_2020_24) as ownerinc_gt150k, 
	sum(incmbyrentercst_lt10k_2020_24) as renterinc_lt10k, 
	sum(incmbyrentercst_10_19k_2020_24) as renterinc_10_19k,
	sum(incmbyrentercst_20_34k_2020_24) as renterinc_20_34k,
	sum(incmbyrentercst_35_49k_2020_24) as renterinc_35_49k,
	sum(incmbyrentercst_50_74k_2020_24) as renterinc_50_74k,
	sum(incmbyrentercst_75_99k_2020_24) as renterinc_75_99k,
	sum(incmbyrentercst_gt100k_2020_24) as renterinc_gt100k
from tracts2
group by rfk_sub_group;
quit;

proc print data = sub_summary_stats;
run;

*create Summary Statistics, census tracts in and out of the RFK area;
proc sql; create table summary_stats as select
/* census tract */
	rfk_group, count(tract) as tracts,
/*population, age*/
	sum(totpop_2020_24) as total_population, sum(totalcivhhpop_2020_24) as population_16over, sum(pop65andoveryears_2020_24) as population_65over,
/* work Force */
	sum(popemployedworkers_2020_24) as employed, 
	sum(popunemployed_2020_24) as unemployed,
/*Race & Ethnicity*/
	sum(popalonew_2020_24) as white, sum(popaloneiom_2020_24) as another_race, sum(popaloneh_2020_24) as latino, sum(popaloneb_2020_24) as black, sum(popalonea_2020_24) as AANHPI,
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
	sum(numrentercostburden_2020_24) as renters_costburden_30, sum(numrentseverecostburden_2020_24) as renters_cost_burden_50,
	sum(numownercostburden_2020_24) as owners_costburden_30, sum(numownseverecostburden_2020_24) as owners_cost_burden_50,
/* Incomes by Tenure */
	sum(incmbyownercst_lt10k_2020_24) as ownerinc_lt10k, 
	sum(incmbyownercst_10_19k_2020_24) as ownerinc_10_19k,
	sum(incmbyownercst_20_34k_2020_24) as ownerinc_20_34k,
	sum(incmbyownercst_35_49k_2020_24) as ownerinc_35_49k,
	sum(incmbyownercst_50_74k_2020_24) as ownerinc_50_74k,
	sum(incmbyownercst_75_99k_2020_24) as ownerinc_75_99k,
	sum(incmbyownercst_100_149_2020_24) as ownerinc_100_149k,
	sum(incmbyownercst_gt150k_2020_24) as ownerinc_gt150k, 
	sum(incmbyrentercst_lt10k_2020_24) as renterinc_lt10k, 
	sum(incmbyrentercst_10_19k_2020_24) as renterinc_10_19k,
	sum(incmbyrentercst_20_34k_2020_24) as renterinc_20_34k,
	sum(incmbyrentercst_35_49k_2020_24) as renterinc_35_49k,
	sum(incmbyrentercst_50_74k_2020_24) as renterinc_50_74k,
	sum(incmbyrentercst_75_99k_2020_24) as renterinc_75_99k,
	sum(incmbyrentercst_gt100k_2020_24) as renterinc_gt100k
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
	sum(totpop_2020_24) as total_population, sum(totalcivhhpop_2020_24) as population_16over, sum(pop65andoveryears_2020_24) as population_65over,
/* work Force */
	sum(popemployedworkers_2020_24) as employed, 
	sum(popunemployed_2020_24) as unemployed,
/*Race & Ethnicity*/
	sum(popalonew_2020_24) as white, sum(popaloneiom_2020_24) as another_race, sum(popaloneh_2020_24) as latino, sum(popaloneb_2020_24) as black, sum(popalonea_2020_24) as AANHPI,
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
	sum(numrentercostburden_2020_24) as renters_costburden_30, sum(numrentseverecostburden_2020_24) as renters_cost_burden_50,
	sum(numownercostburden_2020_24) as owners_costburden_30, sum(numownseverecostburden_2020_24) as owners_cost_burden_50,
/* Incomes by Tenure */
	sum(incmbyownercst_lt10k_2020_24) as ownerinc_lt10k, 
	sum(incmbyownercst_10_19k_2020_24) as ownerinc_10_19k,
	sum(incmbyownercst_20_34k_2020_24) as ownerinc_20_34k,
	sum(incmbyownercst_35_49k_2020_24) as ownerinc_35_49k,
	sum(incmbyownercst_50_74k_2020_24) as ownerinc_50_74k,
	sum(incmbyownercst_75_99k_2020_24) as ownerinc_75_99k,
	sum(incmbyownercst_100_149_2020_24) as ownerinc_100_149k,
	sum(incmbyownercst_gt150k_2020_24) as ownerinc_gt150k, 
	sum(incmbyrentercst_lt10k_2020_24) as renterinc_lt10k, 
	sum(incmbyrentercst_10_19k_2020_24) as renterinc_10_19k,
	sum(incmbyrentercst_20_34k_2020_24) as renterinc_20_34k,
	sum(incmbyrentercst_35_49k_2020_24) as renterinc_35_49k,
	sum(incmbyrentercst_50_74k_2020_24) as renterinc_50_74k,
	sum(incmbyrentercst_75_99k_2020_24) as renterinc_75_99k,
	sum(incmbyrentercst_gt100k_2020_24) as renterinc_gt100k
from wards
group by ward2022 ;
quit;

proc print data = summary_stats_ward;
run;

*test in and out of RFK crosswalk;
proc sql; create table 
	rfk_test as select rfk_group, in_a_mile, 
