/**************************************************************************
 Program:  cost burden for 80% median income.sas
 Library:  IPUMS
 Project:  NeighborhoodInfo DC
 Author:   Yipeng
 Created:  7/2/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Among [inner region] households with incomes below 80% of the area median, XX percent of renters and YY percent of owners have unaffordable cost burdens [30% of income].

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( IPUMS )

data hhwts;
	set ipums.acs_2012_16_dc ipums.Acs_2012_16_md ipums.Acs_2012_16_va ipums.Acs_2012_16_wv;
	if pernum = 1;
	if gq in (1,2);
	keep serial hhwt;
run;

data allstates;
	set ipums.acs_2012_16_dc ipums.Acs_2012_16_md ipums.Acs_2012_16_va ipums.Acs_2012_16_wv ;
	if puma in (101,102,103,104,105,1001,1002,1003,1004,1005,1006,1007,1101,1102,1103,1104,1105,1106,1107,1301,1302,10701,10702,10703,51255,59301,59302,59303,59304,59305,59306,59307,59308,59309) then innercounty = 1;
run;

data allstates;
set allstates;
	if (numprec = 1 and hhincome <= 108600*0.8*0.7) or (numprec=2 and hhincome <= 108600*0.8*0.8) or  (numprec=3 and hhincome <= 108600*0.8*0.9)
       or (numprec=4 and hhincome <= 108600*0.8) or (numprec=5 and hhincome <= 108600*0.8*1.1) or (numprec=6 and hhincome <= 108600*0.8*1.2 ) 
       or (numprec=7 and hhincome <= 108600*0.8*1.3) or (numprec=8 and hhincome <= 108600*0.8*1.4) then income80=1;                                                                               
	   else income80 = 0;

    if ownershp = 2 and rent*12> HHINCOME*0.3 then rentburdened=1;
	   else rentburdened=0;

    if ownershp = 1 and owncost*12> HHINCOME*0.3 then ownerburdened=1;
	   else ownerburdened=0;

run;

proc summary data = allstates (where=(ownershp = 2));
	class innercounty;
	var ownerburdened_inner_2016  income80;
	weight hhwt;
	output out = IPUMS_rentburdened_inner_2016 sum=;
run;

proc summary data = allstates (where=(ownershp = 1));
	class innercounty;
	var ownerburdened income80;
	weight hhwt;
	output out = IPUMS_ownerburdened_inner_2016  sum=;
run;

proc export data = IPUMS_rentburdened_inner_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\IPUMS_rentburdened_inner_2016.csv'
   dbms=csv
   replace;
run;

proc export data = IPUMS_ownerburdened_inner_2016
   outfile='L:\Libraries\Requests\Data\washington region feature\IPUMS_ownerburdened_inner_2016.csv'
   dbms=csv
   replace;
run;



