/**************************************************************************
 Program:  Data for Equity Summit.sas
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

proc contents data=acs.Acs_2008_12_sum_tr_wd12_2;
run;
proc contents data=acs.Acs_2008_12_sum_tr_wd12;
run;
proc print data=acs.Acs_2008_12_sum_tr_wd12;
var ward2012
Pop25andOverYears_2008_12
Pop25andOverWoutHS_2008_12
NumOccupiedHsgUnits_2008_12
PopInCivLaborForce_2008_12
PopCivilianEmployed_2008_12
NumOccupiedHsgUnits_2008_12
;
run;

data wards;

set acs.Acs_2008_12_sum_tr_wd12 (keep=ward2012 Pop25andOverYears_2008_12 Pop25andOverWoutHS_2008_12 NumOccupiedHsgUnits_2008_12 
PopInCivLaborForce_2008_12 PopCivilianEmployed_2008_12 NumOwnerOccupiedHsgUnits_2008_12 );

%Pct_calc( var=Pct25andOverWoutHS, label=% persons without HS diploma, num=Pop25andOverWoutHS, den=Pop25andOverYears, years=2008_12 )
%Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=2008_12 )
%Pct_calc( var=EmploymentRate, label=Employment rate (pop 16+ yrs.), num=PopCivilianEmployed, den=PopInCivLaborForce, years=2008_12 )
run;


data ngh_cltr00;
set acs.Acs_2008_12_sum_tr_cltr00 (keep=Cluster_tr2000 Pop25andOverYears_2008_12 Pop25andOverWoutHS_2008_12 NumOccupiedHsgUnits_2008_12 
PopInCivLaborForce_2008_12 PopCivilianEmployed_2008_12 NumOwnerOccupiedHsgUnits_2008_12 );

%Pct_calc( var=Pct25andOverWoutHS, label=% persons without HS diploma, num=Pop25andOverWoutHS, den=Pop25andOverYears, years=2008_12 )
%Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=2008_12 )
%Pct_calc( var=EmploymentRate, label=Employment rate (pop 16+ yrs.), num=PopCivilianEmployed, den=PopInCivLaborForce, years=2008_12 )
run;


data city; 

set acs.Acs_2008_12_sum_tr_city (keep=City Pop25andOverYears_2008_12 Pop25andOverWoutHS_2008_12 NumOccupiedHsgUnits_2008_12 
PopInCivLaborForce_2008_12 PopCivilianEmployed_2008_12 NumOwnerOccupiedHsgUnits_2008_12 );

%Pct_calc( var=Pct25andOverWoutHS, label=% persons without HS diploma, num=Pop25andOverWoutHS, den=Pop25andOverYears, years=2008_12 )
%Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=2008_12 )
%Pct_calc( var=EmploymentRate, label=Employment rate (pop 16+ yrs.), num=PopCivilianEmployed, den=PopInCivLaborForce, years=2008_12 )
run;

data stack;
set ngh_cltr00 wards city;
run;

proc export data=stack outfile="L:\Libraries\Requests\Prog\2015\EquitySummitGaps.csv" DBMS=CSV replace;
run;
