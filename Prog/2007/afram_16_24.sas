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


/*where are these libraries being defined?*/

** Define libraries **;

%DCData_lib( vital )
%DCData_lib( TANF )
%DCData_lib( Requests )
rsubmit;



data vitala;

set vital.Deaths_sum_city (keep = deaths_15to19_2004 deaths_20to24_2004 deaths_20to24_blk_2004 deaths_15to19_blk_2004 city);
label deaths_15to19_2004 = 'Deaths to persons 15-19 years old, 2004'
	  deaths_20to24_2004 = 'Deaths to persons 20-24 years old, 2004'
	  deaths_15to19_blk_2004 = 'Deaths to non-Hispanic black persons 15-19 years old, 2004'
	  deaths_20to24_blk_2004 = 'Deaths to non-Hispanic black persons 20-24 years old, 2004';
run;
data tanfa;
*/ should I make percent black variables? */ ; 
set tanf.Tanf_sum_city  (keep = tanf_13to17_blk_2007 tanf_18to24_blk_2007 tanf_13to17_2007 tanf_18to24_2007 city);
label
	  tanf_13to17_2007 = 'Teens 13-17 years old receiving TANF, 2007'
	  tanf_18to24_2007 = 'Young adults 18-24 years old receiving TANF, 2007'
	  tanf_13to17_blk_2007 = 'Non-Hispanic black teens 13-17 years old receiving TANF, 2007'
	  tanf_18to24_blk_2007 = 'Non-Hispanic black young adults 18-24 years old receiving TANF';
run;
proc download data=vitala out=requests.vital;
    run;
 proc download data = tanfa out=requests.tanf;
 run;


endrsubmit;

proc sort data = requests.vital;
by city;
run;
proc sort data =requests.tanf;
by city;
run;
data requests.afram1;
merge requests.vital requests.tanf;
by city;
run;


/* take out proc contents? 
proc contents requests.afram;
			run;*/

*ouput to Excel using ODS and proc print?;
ODS rtf FILE="D:\DCData\Libraries\Requests\Doc\afram.rtf";

proc print data=requests.afram1 label noobs; 
title1 'Washington D.C. city level data';
title2  'NeighborhoodInfo DC,';
title3 'a project of The Urban Institute and Washington DC Local Initiatives Support Corporation (LISC)';
title4 'P: 202-261-5760 / E: info@neighborhoodinfodc.org '; 
var deaths_15to19_2004 deaths_15to19_blk_2004 deaths_20to24_2004 deaths_20to24_blk_2004 tanf_13to17_2007
tanf_13to17_blk_2007 tanf_18to24_2007 tanf_18to24_blk_2007;
RUN;
 
ODS rtf close;


   
*output to Excel using outexc dde, how to put labels?
filename outexc dde "D:\DCData\Libraries\Requests\Data\afram.xls" notab;
*NOTAB – allows an entire character string including embedded blanks to be stored in a cell.
“09”x – means tab delimited;
/*data _null_ ;
	file outexc lrecl=65000;
	set requests.afram;
	 put  AGE '09'x SEX '09'x RACBLK '09'x  deaths_15to19_2004 '09'x  deaths_15to19_blk_2004  '09'x deaths_20to24_2004 '09'x 
  deaths_20to24_blk_2004 '09'x tanf_13to17_2007 '09'x tanf_13to17_blk_2007 '09'x tanf_18to24_2007
  '09'x tanf_18to24_blk_2007 '09'x EDUCREC '09'x EMPSTAT '09'x  SCHLTYPE '09'x  LIT '09'x  HHINCOME 
'09'x POPLOC;

run;*/
signoff;





