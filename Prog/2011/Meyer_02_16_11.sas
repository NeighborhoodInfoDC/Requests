/**************************************************************************
 Program:  Meyer_02_16_11.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/16/11
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Create data summaries for Meyer Foundation strategy
meeting. Request from Carmen, 2/16/11.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
/**%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;**/

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ipums )

proc format;

  /** PUMA to selected counties **/

  value $pumacty (notsorted)
    '1100101' = 'District of Columbia'
    '1100102' = 'District of Columbia'
    '1100103' = 'District of Columbia'
    '1100104' = 'District of Columbia'
    '1100105' = 'District of Columbia'
    '2401001' = 'Montgomery county, MD'
    '2401002' = 'Montgomery county, MD'
    '2401003' = 'Montgomery county, MD'
    '2401004' = 'Montgomery county, MD'
    '2401005' = 'Montgomery county, MD'
    '2401006' = 'Montgomery county, MD'
    '2401007' = 'Montgomery county, MD'
    '2401101' = 'Prince George''s county, MD'
    '2401102' = 'Prince George''s county, MD'
    '2401103' = 'Prince George''s county, MD'
    '2401104' = 'Prince George''s county, MD'
    '2401105' = 'Prince George''s county, MD'
    '2401106' = 'Prince George''s county, MD'
    '2401107' = 'Prince George''s county, MD'
    '5100100' = 'Arlington county, VA'
    '5100200' = 'Alexandria, VA'
    '5100301' = 'Fairfax/Falls Church, VA'
    '5100302' = 'Fairfax/Falls Church, VA'
    '5100303' = 'Fairfax/Falls Church, VA'
    '5100304' = 'Fairfax/Falls Church, VA'
    '5100305' = 'Fairfax/Falls Church, VA'
    '5100600' = 'Loudon county, VA'
    other = 'Not coded';

  value ayear (notsorted)
    0 = '2000'
    9 = '2009';
    
  value aage
    0 - 17 = '< 18'
    18 - 64 = '18 - 64'
    65 - high = '65+';
    
  value citizen
    0, 1 = 'US born'
    2 = 'Naturalized'
    3 = 'Not a citizen';
    
  value pov
    0 - 100 = 'At\~or\~below poverty'
    101 - 200 = '101\~-\~200% poverty'
    201 - high = 'Above\~200% poverty';

  value educ
    0 = 'Not applicable'
    1-9 = 'No HS diploma/GED'
    10-11 = 'Only HS diploma/GED'
    12 = 'Assoc.\~deg.'
    14 = 'Bach. deg.'
    15-17 = 'Grad. deg.';
    
  value famtype
    1 = 'Married\~couple'
    2 = 'Female-headed'
    3 = 'Male-headed';

run;

%let keep_vars = year serial pernum upuma hhwt perwt age poverty citizen labforce empstatd
                 is_: ;

data Meyer_02_16_11;

  set 
    Ipums.Ipums_2000_pmsa99_full
      (keep=&keep_vars educ99)
    Ipums.acs_2009_pmsa99_full
      (keep=&keep_vars educd hcovany);
  where put( upuma, $pumacty. ) ~= 'Not coded';
  
  total = 1;
  
  if year = 2009 then do;
    select;
      when ( educd = 1 ) educ99 = 0;
      when ( 2 <= educd <= 61 ) educ99 = 9;
      when ( 63 <= educd <= 71 ) educ99 = 10;
      when ( educd = 81 ) educ99 = 12;
      when ( educd = 101 ) educ99 = 14;
      when ( educd >= 114 ) educ99 = 15;
    end;
  end;
  
  if labforce = 1 then pct_lf = 0;
  else if labforce = 2 then pct_lf = 100;
  
  if empstatd = 20 then pct_unemp = 100;
  else if empstatd in ( 10, 12, 14, 15 ) then pct_unemp = 0;

  if hcovany = 2 then hcovrate = 100; **With health insurance coverage**;
  else if hcovany = 1 then hcovrate = 0; **Without health insurance coverage**;
  
  ** HHs for families with children **;
  
  if is_mrdwkids then fam_type = 1;
  else if is_sfemwkids then fam_type = 2;
  else if is_smalwkids then fam_type = 3;
  else fam_type = .n;

  format upuma $pumacty. year ayear.;
  
run;

%File_info( data=Meyer_02_16_11, freqvars=year upuma )

%fdate()

options nodate nonumber orientation=landscape;

ods csvall file="D:\DCData\Libraries\Requests\Prog\2011\Meyer_02_16_11.csv";
ods rtf file="D:\DCData\Libraries\Requests\Prog\2011\Meyer_02_16_11.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Meyer_02_16_11 format=comma12.0 noseps missing;
  class upuma year / preloadfmt order=data;
  class age citizen;
  var total;
  weight perwt;
  table 
    /** Rows **/
    all='\b Total' upuma=' ',
    /** Columns **/
    total='Population' * year=' ' * sum=' '
    total='Population by age (%)' * age=' ' * year=' ' * pctsum<age>=' ' * f=comma10.1
  ;
  table 
    /** Rows **/
    all='\b Total' upuma=' ',
    /** Columns **/
    total='Population by citizenship (%)' * citizen=' ' * year=' ' * pctsum<citizen>=' ' * f=comma10.1
  ;
  format age aage. citizen citizen.;
  title1 'Census 2000 and American Community Survey 2009 Characteristics for';
  title2 'Selected Jurisdications in the Washington, D.C., Region';
  footnote1 height=9pt "Prepared for the Meyer Foundation by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

proc tabulate data=Meyer_02_16_11 format=comma12.0 noseps missing;
  where fam_type > 0 and pernum = 1;
  class upuma year / preloadfmt order=data;
  class fam_type;
  var total;
  weight perwt;
  table 
    /** Rows **/
    all='\b Total' upuma=' ',
    /** Columns **/
    total='Families with related children' * year=' ' * sum=' '
    total='Families with related children by type (%)' * fam_type=' ' * year=' ' * pctsum<fam_type>=' ' * f=comma10.1
  ;
  format fam_type famtype.;
run;

proc tabulate data=Meyer_02_16_11 format=comma12.0 noseps missing;
  where poverty > 0;
  class upuma year / preloadfmt order=data;
  class poverty;
  var total;
  weight perwt;
  table 
    /** Rows **/
    all='\b Total' upuma=' ',
    /** Columns **/
    total='Population by poverty (%)' * poverty=' ' * year=' ' * pctsum<poverty>=' ' * f=comma10.1
  ;
  format poverty pov.;
run;

proc tabulate data=Meyer_02_16_11 format=comma12.0 noseps missing;
  where age >= 25;
  class upuma year / preloadfmt order=data;
  class educ99;
  var total;
  weight perwt;
  table 
    /** Rows **/
    all='\b Total' upuma=' ',
    /** Columns **/
    total='Population 25+' * year=' ' * sum=' '
    total='Population 25+ by education (%)' * educ99=' ' * year=' ' * pctsum<educ99>=' ' * f=comma10.1
  ;
  format educ99 educ.;
run;

proc tabulate data=Meyer_02_16_11 format=comma12.0 noseps missing;
  where age >= 16;
  class upuma year / preloadfmt order=data;
  var total pct_lf pct_unemp;
  weight perwt;
  table 
    /** Rows **/
    all='\b Total' upuma=' ',
    /** Columns **/
    total='Population 16+' * year=' ' * sum=' '
    pct_lf='Population\~16+ in\~labor\~force\~(%)' * year=' ' * mean=' ' * f=comma10.1
    pct_unemp='Population\~16+ unemployed\~(%)' * year=' ' * mean=' ' * f=comma10.1
  ;
run;

proc tabulate data=Meyer_02_16_11 format=comma12.0 noseps missing;
  where year = 2009;
  class upuma year / preloadfmt order=data;
  var hcovrate;
  weight perwt;
  table 
    /** Rows **/
    all='\b Total' upuma=' ',
    /** Columns **/
    hcovrate='Population\~with health\~insurance\~(%)' * year=' ' * mean=' ' * f=comma10.1
  ;
run;

ods csvall close;
ods rtf close;
