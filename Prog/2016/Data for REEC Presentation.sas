/***********************************************************************
 Program:  Data for REEC Presentation.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  11/2/2015
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Compile data for jobs, diploma and homeowners to create analysis of gaps EOR. 

 Modifications: 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";
%DCData_lib( ACS )
%dcdata_lib (NCDB)

proc contents data=acs.Acs_2009_13_dc_sum_tr_wd12;
run;

data ncdb; 
set Ncdb.Ncdb_sum_wd12
        (keep=ward2012
           TotPop: PopUnder18Years: Pop65andOverYears: PopForeignBorn: Pop5andOverYears:
           PopSameHouse5YearsAgo: PopWithRace: PopBlackNonHispBridge:
           PopWhiteNonHispBridge: PopHisp: PopAsianPINonHispBridge:
           PopOtherRaceNonHispBridge: PersonsPovertyDefined:
           PopPoorPersons: PopInCivLaborForce: PopUnemployed:
           Pop16andOverYears: Pop16andOverEmployed: Pop25andOverYears:
           Pop25andOverWoutHS: NumFamiliesOwnChildren:
           NumFamiliesOwnChildrenFH: NumOccupiedHsgUnits:
           NumHshldPhone: NumHshldCar:
           ChildrenPovertyDefined: ElderlyPovertyDefined: PopPoorChildren: PopPoorElderly: NumFamilies:
           AggFamilyIncome: NumRenterHsgUnits:
           NumVacantHsgUnitsForRent: NumOwnerOccupiedHsgUnits: );

run; 

data wards;

set acs.Acs_2009_13_dc_sum_tr_wd12(keep=ward2012 Pop25andOverYears_2009_13 Pop25andOverWoutHS_2009_13 NumOccupiedHsgUnits_2009_13
PopInCivLaborForce_2009_13 PopCivilianEmployed_2009_13 NumOwnerOccupiedHsgUnits_2009_13 AggFamilyIncome_2009_13 NumFamilies_2009_13);


run;

data acs_ncdb;
merge ncdb wards;
by ward2012; 

%Pct_calc( var=Pct25andOverWoutHS, label=% persons without HS diploma, num=Pop25andOverWoutHS, den=Pop25andOverYears, years=2009_13 )
%Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=2009_13)
%Pct_calc( var=EmploymentRate, label=Employment rate (pop 16+ yrs.), num=PopCivilianEmployed, den=PopInCivLaborForce, years=2009_13 )
     %Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=1980 1990 2000 2009_13)


	   
    %dollar_convert( AvgFamilyIncome_1980, AvgFamilyIncAdj_1980, 1979, 2013 )
    %dollar_convert( AvgFamilyIncome_1990, AvgFamilyIncAdj_1990, 1989, 2013 )
    %dollar_convert( AvgFamilyIncome_2000, AvgFamilyIncAdj_2000, 1999, 2013 )
    %dollar_convert( AvgFamilyIncome_2009_13, AvgFamilyIncAdj_2009_13, 2013, 2013 )
    
    label
      AvgFamilyIncAdj_1980 = "Avg. family income, 1979"
      AvgFamilyIncAdj_1990 = "Avg. family income, 1989"
      AvgFamilyIncAdj_2000 = "Avg. family income, 1999"
      AvgFamilyIncAdj_2009_13 = "Avg. family income, 2009-13"
      ;
      run;

proc print data= acs_ncdb;
var ward2012 AvgFamilyIncAdj_1980 AvgFamilyIncAdj_1990 AvgFamilyIncAdj_2000 AvgFamilyIncAdj_2009_13 AvgFamilyIncome_2009_13;
run;
