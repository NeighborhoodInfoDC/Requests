/**************************************************************************
 Program:  Census Trends.sas
 Library:  Requests 2026 RFK
 Project:  Urban-Greater DC RFK Analysis
 Author:   Leah Hendey
 Created:  
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  https://github.com/NeighborhoodInfoDC/Requests/issues/122
  
 Description: Pull census trends for DC for the RFK analysis

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Census )
%DCData_lib( NCDB )
%DCData_lib( Requests )

data WORK.RFK_TRACTS    ;

infile '//sas1/dcdata/Libraries/Requests/Prog/2026/RFK/Result/rfk_distance_tracts.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
 informat VAR1 $4. ;
informat TRACT $8. ;
 informat Geo2020 $13. ;
informat rfk_group best32. ;
informat rfk_sub_group $25. ;
format VAR1 $4. ;
format TRACT $8. ;
format Geo2020 $13. ;
format rfk_group best12. ;
format rfk_sub_group $25. ;
 input
 VAR1 $
TRACT $
Geo2020 $
rfk_group
rfk_sub_group $
 ;

 run;
%macro chgvars;
%let varlist =TotPop PopWithRace BlackNHBridge WhiteNHBridge PopHisp AAPINHBridge PopORaceNHBridge NumHsgUnits NumOccHsgUnits;

%do i=1 %to 9;
%let var=%scan(&varlist.,&i.," "); 

    if &var._2000 > 0 then PctChg&var._2000_2010 = %pctchg( &var._2000, &var._2010 );
	if &var._2010 > 0 then PctChg&var._2010_2020 = %pctchg( &var._2010, &var._2020 );
	if &var._2000 > 0 then PctChg&var._2000_2020 = %pctchg( &var._2000, &var._2020 );

	Chg&var._2000_2010=&var._2010-&var._2000; 
	Chg&var._2000_2020=&var._2020-&var._2000;
	Chg&var._2010_2020=&var._2020-&var._2010;

%end; 
%mend chgvars;

%macro justpctchg;
%let varlist =TotPop PopWithRace BlackNHBridge WhiteNHBridge PopHisp AAPINHBridge PopORaceNHBridge NumHsgUnits NumOccHsgUnits;

%do i=1 %to 9;
%let var=%scan(&varlist.,&i.," "); 

    if &var._2000 > 0 then PctChg&var._2000_2010 = %pctchg( &var._2000, &var._2010 );
	if &var._2010 > 0 then PctChg&var._2010_2020 = %pctchg( &var._2010, &var._2020 );
	if &var._2000 > 0 then PctChg&var._2000_2020 = %pctchg( &var._2000, &var._2020 );

%end; 
%mend justpctchg;

%macro getyear;

%let yearlist=2000 2010 2020;

%do i=1 %to 1; 

%let year=%scan(&yearlist.,&i.," ");

 data ncdb_&year. (rename=(NumOccupiedHsgUnits_&year.=NumOccHsgUnits_&year. PopWhiteNonHispBridge_&year.=WhiteNHBridge_&year. PopBlackNonHispBridge_&year.=BlackNHBridge_&year.
		PopAsianPINonHispBridge_&year.=AAPINHBridge_&year. PopOtherRaceNonHispBridge_&year.=PopORaceNHBridge_&year.));
 set ncdb.ncdb_sum_tr20;
 keep geo2020 TotPop_&year. PopWithRace_&year.  PopBlackNonHispBridge_&year.
           PopWhiteNonHispBridge_&year. PopHisp_&year. PopAsianPINonHispBridge_&year.
           PopOtherRaceNonHispBridge_&year.
		   NumHsgUnits_&year. NumOccupiedHsgUnits_&year.;

run; 

 data ncdb_&year._wd22 (rename=(NumOccupiedHsgUnits_&year.=NumOccHsgUnits_&year. PopWhiteNonHispBridge_&year.=WhiteNHBridge_&year. PopBlackNonHispBridge_&year.=BlackNHBridge_&year.
		PopAsianPINonHispBridge_&year.=AAPINHBridge_&year. PopOtherRaceNonHispBridge_&year.=PopORaceNHBridge_&year.));
 set ncdb.ncdb_sum_wd22;
 keep ward2022 TotPop_&year. PopWithRace_&year.  PopBlackNonHispBridge_&year.
           PopWhiteNonHispBridge_&year. PopHisp_&year. PopAsianPINonHispBridge_&year.
           PopOtherRaceNonHispBridge_&year.
		   NumHsgUnits_&year. NumOccupiedHsgUnits_&year.;

run; 

 data ncdb_&year._city (rename=(NumOccupiedHsgUnits_&year.=NumOccHsgUnits_&year. PopWhiteNonHispBridge_&year.=WhiteNHBridge_&year. PopBlackNonHispBridge_&year.=BlackNHBridge_&year.
		PopAsianPINonHispBridge_&year.=AAPINHBridge_&year. PopOtherRaceNonHispBridge_&year.=PopORaceNHBridge_&year.));
 set ncdb.ncdb_sum_city;
 keep city TotPop_&year. PopWithRace_&year.  PopBlackNonHispBridge_&year.
           PopWhiteNonHispBridge_&year. PopHisp_&year. PopAsianPINonHispBridge_&year.
           PopOtherRaceNonHispBridge_&year.
		   NumHsgUnits_&year. NumOccupiedHsgUnits_&year.;

run; 

%end;

%do i=2 %to 3; 

%let year=%scan(&yearlist.,&i.," ");

data ncdb_&year. (rename=(NumOccupiedHsgUnits_&year.=NumOccHsgUnits_&year. PopWhiteNonHispBridge_&year.=WhiteNHBridge_&year. PopBlackNonHispBridge_&year.=BlackNHBridge_&year.
		PopAsianPINonHispBridge_&year.=AAPINHBridge_&year. PopOtherRaceNonHispBridge_&year.=PopORaceNHBridge_&year.)); 
	set ncdb.ncdb_sum_&year._tr20;

 keep geo2020 TotPop_&year. PopWithRace_&year. PopBlackNonHispBridge_&year.
           PopWhiteNonHispBridge_&year. PopHisp_&year. PopAsianPINonHispBridge_&year.
           PopOtherRaceNonHispBridge_&year.
		   NumHsgUnits_&year. NumOccupiedHsgUnits_&year.;

run; 

data ncdb_&year._wd22 (rename=(NumOccupiedHsgUnits_&year.=NumOccHsgUnits_&year. PopWhiteNonHispBridge_&year.=WhiteNHBridge_&year. PopBlackNonHispBridge_&year.=BlackNHBridge_&year.
		PopAsianPINonHispBridge_&year.=AAPINHBridge_&year. PopOtherRaceNonHispBridge_&year.=PopORaceNHBridge_&year.)); 
	set ncdb.ncdb_sum_&year._wd22;

 keep ward2022 TotPop_&year. PopWithRace_&year. PopBlackNonHispBridge_&year.
           PopWhiteNonHispBridge_&year. PopHisp_&year. PopAsianPINonHispBridge_&year.
           PopOtherRaceNonHispBridge_&year.
		   NumHsgUnits_&year. NumOccupiedHsgUnits_&year.;

run; 

data ncdb_&year._city (rename=(NumOccupiedHsgUnits_&year.=NumOccHsgUnits_&year. PopWhiteNonHispBridge_&year.=WhiteNHBridge_&year. PopBlackNonHispBridge_&year.=BlackNHBridge_&year.
		PopAsianPINonHispBridge_&year.=AAPINHBridge_&year. PopOtherRaceNonHispBridge_&year.=PopORaceNHBridge_&year.)); 
	set ncdb.ncdb_sum_&year._city;

 keep city TotPop_&year. PopWithRace_&year. PopBlackNonHispBridge_&year.
           PopWhiteNonHispBridge_&year. PopHisp_&year. PopAsianPINonHispBridge_&year.
           PopOtherRaceNonHispBridge_&year.
		   NumHsgUnits_&year. NumOccupiedHsgUnits_&year.;

run; 

%end; 

run;
%mend;

%getyear;
 
proc sort data=ncdb_2000;
by geo2020;
proc sort data=ncdb_2010;
by geo2020;
proc sort data=ncdb_2020;
by geo2020;
proc sort data=rfk_tracts;
by geo2020;
data rfk_censustrend;
merge ncdb_2000 ncdb_2010 ncdb_2020 rfk_tracts (in=a drop=var1);
by geo2020;
if a;

%chgvars;


run; 

proc sort data=rfk_censustrend;
by rfk_sub_group;
proc summary data=rfk_censustrend;
by rfk_sub_group;
var TotPop: Num: Pop: White: Black: AAPI: Chg: ;
output out=rfk_censustrend_subarea sum=;
run;

data rfk_censustrend_subarea1;
 set rfk_censustrend_subarea;

%justpctchg;

run; 


proc sort data=rfk_censustrend;
by rfk_group;
proc summary data=rfk_censustrend;
by rfk_group;
var TotPop: Num: Pop: White: Black: AAPI: Chg: ;
output out=rfk_censustrend_area sum=;
run;

data rfk_censustrend_area1;
 set rfk_censustrend_area;

%justpctchg;

run; 


*wards;
proc sort data=ncdb_2000_wd22;
by ward2022;
proc sort data=ncdb_2010_wd22;
by ward2022;
proc sort data=ncdb_2020_wd22;
by ward2022;
data rfk_censustrend_wd22;
merge ncdb_2000_wd22 ncdb_2010_wd22 ncdb_2020_wd22 ;
by ward2022;

%chgvars;


run; 
*city;

proc sort data=ncdb_2000_city;
by city;
proc sort data=ncdb_2010_city;
by city;
proc sort data=ncdb_2020_city;
by city;
data rfk_censustrend_city;
merge ncdb_2000_city ncdb_2010_city ncdb_2020_city ;
by city;

%chgvars;


run; 

*combine;

data all_ncdb;

set rfk_censustrend_city rfk_censustrend_wd22 rfk_censustrend_area1 rfk_censustrend_subarea1 rfk_censustrend;
run;

proc export data=all_ncdb
	outfile="&_dcdata_default_path.\Requests\Prog\2026\RFK\census_trends_2000_2020..csv"
	dbms=csv replace;
	run;

