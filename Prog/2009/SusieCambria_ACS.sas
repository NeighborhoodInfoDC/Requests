/**************************************************************************
 Program:  susie_income_pop_ACS.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  07/08/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Identify the population size and HH income by PUMA using 2005-2007 ACS. Data downloaded
	from ACS website. Not IPUMS

 Modifications:
**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( IPUMS )
proc contents data=IPUMS.PUMS_200507; run;
*Confirmed that this is just DC data;
proc freq data=IPUMS.PUMS_200507;
table st;
run;
**Running the number of people per PUMA;

proc freq data=IPUMS.PUMS_200507;
table agep;
weight PWGTP ;
title "Number of people citywide in the District 2005-2007 micro level ACS, weighted";
run;
proc freq data=IPUMS.PUMS_200507;
table puma;
weight PWGTP ;
title "Number of people (all ages) by PUMA as of 2005-2007 micro level ACS, weighted";
run;
proc sort data=IPUMS.PUMS_200507;
by puma;
run;

proc means data=IPUMS.PUMS_200507 ;
var PINCP;
by puma;
weight PWGTP ;
title "Average income by PUMA as of 2005-2007 micro level ACS, weighted";
run;

proc means data=IPUMS.PUMS_200507 median ;
var PINCP;
by puma;
weight PWGTP ;
title "Median income by PUMA as of 2005-2007 micro level ACS, weighted";
run;
