/**************************************************************************
 Program:  Tobey_05_26_10.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/01/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Request from Pamela Tobey, The Washington Post, 5/26/10.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ipums )

%let keep_vars = year serial pernum perwt hhwt upuma gq poverty hhincome;

data Acs;

  set
    Ipums.Ipums_2000_dc (keep=&keep_vars)
    Ipums.Acs_2008_dc (keep=&keep_vars);
  by serial;

  where gq in (1,2);
  
  ** Convert 2000 income to 2008 dollars **;

  if year = 0 then do;
    %Dollar_convert( hhincome, hhincome_adj, 2000, 2008 )
  end;
  else do;
    hhincome_adj = hhincome;
  end;
  
  label hhincome_adj = "HH income adjusted to 2008 $";
  
  ** Poverty rate **;
  
  if 1 <= poverty <= 99 then poor = 1;
  else if poverty >= 100 then poor = 0;
  
  total = 1;

run;

%File_info( data=ACS, freqvars=year )

%fdate()

options nodate nonumber;

ods rtf file="D:\DCData\Libraries\Requests\Prog\2010\Tobey_05_26_10.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=ACS format=comma12.0 noseps missing;
  where not( missing( poor ) );
  class year upuma;
  var total poor;
  table 
    /** Pages **/
    year='Year = ',
    /** Rows **/
    all='District of Columbia' upuma='\i PUMA',
    /** Columns **/
    total='Persons' *sum=' ' poor='Persons below poverty' * ( sum=' ' mean=' ' * f=percent12.1 )
    /condense
  ;
  weight perwt;
  title 'Persons Below Poverty, 2000 and 2008, District of Columbia by PUMA';
  footnote1 height=9pt "Census 2000 and American Community Survey 2008 data prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;


proc tabulate data=ACS format=comma12.0 noseps missing;
  where pernum = 1 and not( missing( hhincome ) );
  class year upuma;
  var total hhincome hhincome_adj;
  table 
    /** Pages **/
    year='Year = ',
    /** Rows **/
    all='District of Columbia' upuma='\i PUMA',
    /** Columns **/
    total='Households' * sum=' ' 
    median='Median HH Income' *
      ( hhincome='Unadjusted\~$' 
        hhincome_adj='Constant\~2008\~$' ) 
    /condense
  ;
  weight hhwt;
  title 'Median Household Income, 2000 and 2008, District of Columbia by PUMA';
  footnote1 height=9pt "Census 2000 and American Community Survey 2008 data prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;

