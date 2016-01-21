/**************************************************************************
 Program:  Carmen_04_09_2007.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/13/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summary loan data for Fremont Investment and Loan for
 2004 & 2005 for request from Evelyn Carmen, DC Department of
 Insurance, Securities and Banking, 04/09/07.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HMDA )

%let lender = 30000025653;

*options obs=100;

data A (compress=no);

  set 
    Hmda.Loans_2004 
      (keep=year geo2000 ulender action purpose type loantype
       where=(geo2000 =: "11" and action = "1" and ulender = "2004&lender"))
    Hmda.Loans_2005 
      (keep=year geo2000 ulender action purpose type loantype
       where=(geo2000 =: "11" and action = "1" and ulender = "2005&lender"))
    ;
  
run;

%fdate()

options nodate nonumber;

ods rtf file="&_dcdata_path\requests\prog\2007\Carmen_04_09_07.rtf" style=Styles.Rtf_arial_9pt bodytitle;

proc tabulate data=A format=comma10.0 noseps missing;
  class year purpose type loantype;
  table 
    /** Rows **/
    all='Total' 
    purpose='\line\i Purpose of loan'
    ,
    /** Columns **/
    n='Number\~of Loans\~Originated'*Year=' '
  ;
  title1 "Conventional Mortgage Loans Issued by Fremont Investment & Loan";
  title2 "Washington, D.C.";
  footnote1 height=9pt "\i\b0 Source: Home Mortgage Disclosure Act data tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org).";
  footnote2 height=9pt " ";
  footnote3 height=9pt "\i\b0 Updated &fdate.";
  *footnote4 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;

