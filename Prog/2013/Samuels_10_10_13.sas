/**************************************************************************
 Program:  Roberts_10_10_13.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/10/13
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Compile data on poverty and non-hispanic white
population by neighborhood cluster for Robert Samuels, Washington
Post, 10/10/13.

 Modifications:
  10/11/13 PAT Added 2000 poverty data.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ACS )
%DCData_lib( NCDB )

** Start submitting commands to remote server **;

rsubmit;

%let geo = cluster_tr2000;
%let geosuf = _cltr00;

data Samuels_10_10_13;

    merge
      Ncdb.Ncdb_sum&geosuf
        (keep=&geo
           TotPop: PopUnder18Years: PopForeignBorn: Pop5andOverYears:
           PopSameHouse5YearsAgo: PopWithRace: PopBlackNonHispBridge:
           PopWhiteNonHispBridge: PopHisp: PopAsianPINonHispBridge:
           PopOtherRaceNonHispBridge: PersonsPovertyDefined:
           PopPoorPersons: PopInCivLaborForce: PopUnemployed:
           Pop16andOverYears: Pop16andOverEmployed: Pop25andOverYears:
           Pop25andOverWoutHS: NumFamiliesOwnChildren:
           NumFamiliesOwnChildrenFH: NumOccupiedHsgUnits:
           NumHshldPhone: NumHshldCar:
           ChildrenPovertyDefined: PopPoorChildren: NumFamilies:
           AggFamilyIncome: NumRenterHsgUnits:
           NumVacantHsgUnitsForRent: NumOwnerOccupiedHsgUnits: )
      ACS.Acs_2007_11_sum_bg&geosuf
        (keep=&geo TotPop: mTotPop: PopUnder18Years: mPopUnder18Years: PopWithRace: PopBlackNonHispBridge:
           PopWhiteNonHispBridge: PopHisp: PopAsianPINonHispBridge:
           PopOtherRaceNonHispBridg: 
           Pop25andOverYears: mPop25andOverYears: 
           NumOccupiedHsgUnits: mNumOccupiedHsgUnits:
           Pop25andOverWoutHS: mPop25andOverWoutHS: 
           NumHshldPhone: mNumHshldPhone: 
           NumHshldCar: mNumHshldCar: 
           NumFamilies_: mNumFamilies_:
           AggFamilyIncome: mAggFamilyIncome: 
           NumRenterHsgUnits: mNumRenterHsgUnits:
           NumVacantHsgUnitsForRent: mNumVacantHUForRent: 
           NumOwnerOccupiedHsgUnits: mNumOwnerOccupiedHU: )
      ACS.Acs_2007_11_sum_tr&geosuf
        (keep=&geo TotPop: mTotPop: 
           PopForeignBorn: mPopForeignBorn: 
           PersonsPovertyDefined: mPersonsPovertyDefined:
           PopPoorPersons: mPopPoorPersons: 
           PopInCivLaborForce: mPopInCivLaborForce: 
           PopUnemployed: mPopUnemployed:
           Pop16andOverYears: mPop16andOverYears: 
           Pop16andOverEmployed: mPop16andOverEmployed: 
           NumFamiliesOwnChildren: mNumFamiliesOwnChildren:
           NumFamiliesOwnChildrenFH: mNumFamiliesOwnChildFH: 
           ChildrenPovertyDefined: mChildrenPovertyDefined: 
           PopPoorChildren: mPopPoorChildren: 
         rename=(TotPop_2007_11=TotPop_tr_2007_11 mTotPop_2007_11=mTotPop_tr_2007_11));
     by &geo;

  keep &geo PopWhiteNonHispBridge: PopWithRace: PopPoorPersons: PersonsPovertyDefined:;

run;

proc download status=no
  data=Samuels_10_10_13 
  out=Samuels_10_10_13;
run;


run;

endrsubmit;

** End submitting commands to remote server **;

%fdate()

ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2013\Samuels_10_10_13.xls" style=Minimal options(sheet_interval='Proc' );

proc print data=Samuels_10_10_13 noobs;
  id cluster_tr2000;
  var PopWhiteNonHispBridge: PopWithRace: PopPoorPersons: PersonsPovertyDefined:;
  format PopWhiteNonHispBridge: PopWithRace: PopPoorPersons: PersonsPovertyDefined: comma12.0;
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt "Sources: Neighborhood Change Database (1980-2000); American Community Survey (2007-11).";
run;

ods tagsets.excelxp close;

signoff;
