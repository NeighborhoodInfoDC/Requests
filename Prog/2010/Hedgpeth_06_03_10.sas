/**************************************************************************
 Program:  Hedgpeth_06_03_10.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/01/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Request from Dana Hedgpeth, The Washington Post, 6/3/10.
 Educational attainment by PUMA.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ipums )

%let keep_vars = year serial pernum perwt hhwt upuma gq age;

data Acs;

  set
    Ipums.Ipums_2000_dc (keep=&keep_vars educ99)
    Ipums.Acs_2008_dc (keep=&keep_vars educd);
  by serial;

  where gq in (1,2) and age >= 25;
  
  ed_nohs = 0;
  ed_hsonly = 0;
  ed_assoc = 0;
  ed_bach = 0;
  ed_adv = 0;
  
  if year = 0 then do;
  
    if missing( educ99 ) or educ99 = 0 then delete;
    else if 1 <= educ99 <= 9 then ed_nohs = 1;
    else if 10 <= educ99 <= 11 then ed_hsonly = 1;
    else if educ99 = 12 then ed_assoc = 1;
    else if educ99 = 14 then ed_bach = 1;
    else if 15 <= educ99 then ed_adv = 1;
    
  end;
  else do;
    
    if missing( educd ) or educd = 1 then delete;
    else if 2 <= educd <= 61 then ed_nohs = 1;
    else if 63 <= educd <= 71 then ed_hsonly = 1;
    else if educd = 81 then ed_assoc = 1;
    else if educd = 101 then ed_bach = 1;
    else if 114 <= educd then ed_adv = 1;

  end;
  
  total = 1;

run;

%File_info( data=ACS, freqvars=year educ99 educd )

proc means data=ACS n nmiss min max;
  var age educ99 educd ed_nohs;
  by descending year;
run;

%fdate()

options nodate nonumber;

ods rtf file="D:\DCData\Libraries\Requests\Prog\2010\Hedgpeth_06_03_10.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=ACS format=comma12.0 noseps missing;
  class year upuma;
  var ed_: total;
  table 
    /** Pages **/
    year='Year = ',
    /** Rows **/
    all='District of Columbia' upuma='\i PUMA',
    /** Columns **/
    total='Adults 25+\~years' *sum=' ' 
    mean='Educational attainment' * f=percent12.1 *
    ( ed_nohs = 'No HS diploma/GED'
      ed_hsonly = 'HS diploma/GED only'
      ed_assoc = 'Associates deg'
      ed_bach  = 'Bachelors deg'
      ed_adv = 'Advanced deg'
    )
    /condense
  ;
  weight perwt;
  title 'Educational Attainment for Adults 25 Years and Older, 2000 and 2008, District of Columbia by PUMA';
  footnote1 height=9pt "Census 2000 and American Community Survey 2008 data prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;

