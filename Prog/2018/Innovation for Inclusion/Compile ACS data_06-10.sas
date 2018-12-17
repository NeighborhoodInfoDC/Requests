/**************************************************************************
 Program:  Commuting time to work.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng 
 Created:  9/19/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )
%DCData_lib( police )

%let _years=2006_10;

%macro Compile_ACS_data (geo, geosuf);

data ACS;
length indicator $80;
set ACS.Acs_2006_10_dc_sum_tr_&geosuf;
keep &geo popaloneb_&_years. popaloneh_2012_16 popalonew_2012_16 popasianpinonhispbridge_2012_16 unemploymentrate PctCol Tothousing ownership pctfamover75K familyhhtot_&_years. pctabovepov pctearningover75K pctchildabovepov pctcostburden commuteunder45 ;
unemploymentrate = popunemployed_&_years./popincivlaborforce_&_years.;
PctCol = pop25andoverwcollege_&_years. / pop25andoveryears_&_years.;
Tothousing= numowneroccupiedhsgunits_&_years.+ numrenteroccupiedhu_&_years.;
ownership= numowneroccupiedhsgunits_&_years./ (numowneroccupiedhsgunits_&_years.+ numrenteroccupiedhu_&_years.);
pctfamover75K= (familyhhtot_&_years.- famincomelt75k_&_years.) /familyhhtot_&_years.; 
popabovepov= personspovertydefined_&_years. - poppoorpersons_&_years.;
pctabovepov= popabovepov/personspovertydefined_&_years.;
pctearningover75K=earningover75k_&_years./popemployedworkers_&_years.;
pctchildabovepov = poppoorchildren_&_years./childrenpovertydefined_&_years.;
pctcostburden = (numownercostburden_&_years.+ numrentercostburden_&_years.)/(rentcostburdendenom_&_years.+ ownercostburdendenom_&_years.);
commuteunder45 = (popemployedtravel_lt5_&_years. + popemployedtravel_10_14_&_years.+ popemployedtravel_15_19_&_years.+ popemployedtravel_20_24_&_years. + popemployedtravel_25_29_&_years. )/popemployedworkers_&_years. ;

run;

data violentcrime;
length indicator $80;
set police.crimes_sum_&geosuf;
keep &geo violentcrimerate;
violentcrimerate = crimes_pt1_violent_2010/crime_rate_pop_2010*1000;
run;

data ACS_&geosuf;
merge ACS violentcrime ;
by &geo;
geoid= &geo;
run; 

proc export data=ACS_&geosuf
	outfile="&_dcdata_default_path.\Requests\Prog\2018\ACS_data_&geosuf._06-10.csv"
	dbms=csv replace;
	run;

%mend Compile_ACS_data;

%Compile_ACS_data (cluster2017, cl17);

%Compile_ACS_data (geo2010, tr10);
