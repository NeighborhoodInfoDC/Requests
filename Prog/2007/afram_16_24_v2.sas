/**************************************************************************
 Program:  Afram_16_24.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   BChang
 Created:  10/02/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  
 Request from Anne Bouie, 09/27/07.
"Any neighborhood profile data, summarized at city level, that can be broken down form African_American males ages 16-24"
 Modifications:
**************************************************************************/



%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib( IPUMS )
%DCData_lib( Requests )
rsubmit;
data afram2;

set IPUMS.Acs_2005_dc (keep = AGE SEX RACBLK EDUCREC EMPSTAT SCHLTYPE  HHINCOME CITIZEN POPLOC perwt);
where 16<= age <=24 and racblk =2 ;
 label
	AGE= 'Age'
	  SEX= 'Gender'
	  RACBLK  ='Black or African American'
	  EDUCREC ='Educational attainment'
	  EMPSTAT ='Employment status'
	  SCHLTYPE ='School type'
	  
	 HHINCOME ='Total household income'
	CITIZEN ='Citizenship status'
	POPLOC ='Presence of father in household';
run;
proc download data=afram2 out=requests.afram2;
    run;
	endrsubmit;
libname ipums 'D:\DCData\Libraries\IPUMS';


proc format;
value hhincomef
0 - 9999 = 'under $10,000'
10000 - 19999 = '$10,000 - $19,999'
20000 - 29999 = '$20,000 - $29,999'
30000 - 39999 = '$30,000 - $39,999'
40000 - 49999 = '$40,000 - $49,999'
50000 - 59999 = '$50,000 - $59,999'
60000 - 69999 = '$60,000 - $69,999'
70000 - 79999 = '$70,000 - $79,999'
80000 - 89999 = '$80,000 - $89,999'
90000 - 99999 = '$90,000 - $99,999'
100000 - 149999 = '$100,000 - $149,999'
150000 - 199999 = '$150,000 - $199,999'
200000 - 299999 = '$200,000 - $299,999'
300000 - 399999 = '$300,000 - $399,999'
400000 - 499999 = '$400,000 - $499,999'
;

value empstatf
0 = 'N/A'
1 = 'Employed'
2 = 'Unemployed'
3 = 'Not in labor force';

value poplocf
0 = 'No father of this person present in household'
1 - 100000000 = 'Father is present in household';
run;
ODS rtf FILE="D:\DCData\Libraries\Requests\Doc\afram1.rtf";
proc means data =requests.afram2 n sum;
freq perwt;
var Educrec empstat schltype hhincome citizen poploc;
run;
ODS rtf close;

ODS rtf FILE="D:\DCData\Libraries\Requests\Doc\afram2.rtf";

	 proc freq data=requests.afram2;
       tables  Educrec empstat schltype hhincome citizen poploc;
	    format hhincome hhincomef. edurec edurec. empstat empstatf.
		schltype schltype. citizen citizen. poploc poplocf.;

		 
       *weight var. = perwt;
    weight  perwt;
	title1 'Washington D.C. city level data for African-Americans ages 16-24';
title2  'NeighborhoodInfo DC,';
title3 'a project of The Urban Institute and Washington DC Local Initiatives Support Corporation (LISC)';
title4 'P: 202-261-5760 / E: info@neighborhoodinfodc.org ';
 
    run;
ODS rtf close;
signoff;
