**************************************************************************
Program: Elderly_byPUMA_2006.sas
Library: requests
Project: NighborhoodInfo DC Technical Assistance: Prepared for Marlene Berlin
Author: Lesley Freiman
Created: 8/14/2008
Version: SAS 9.1
Environment: Windows with SAS/Connect
Description: Number of Elderly (65+) in 2006
Modifications:

**************************************************************************/;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

*/ Defines libraries /*;
%DCData_lib( Ipums );
%DCData_lib( Requests );
%DCData_lib( General );

rsubmit;

*/creates a file with puma and age (temp) */;
data age_puma_2006; 
set ipums.acs_2006_dc (keep= puma age perwt);
run;

proc download inlib=work outlib=requests; 
select age_puma_2006; 
run;

endrsubmit;
proc sort data=requests.age_puma_2006;
by puma;
run;

proc freq data=requests.age_puma_2006 (where=(age > 64));
weight perwt;
tables puma;
output out=requests.elderly_puma_sum2006;
run;



