/**************************************************************************
 Program:  Subprime_NOVA.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/28/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description: Request for HMDA data on N. Virginia for Martin Trimble, WIN.
 Project no: 08301-000-01
 
 NOTE: Martin wanted the data in Excel, but I could not get the ODS EXCELXP
 tagset to work here. So, I manually copied the tables from the 3 RTF files
 to 3 Excel workbooks: Subprime_NOVA.xls, High_interest_by_lender.xls, and
 Subprime_lender_by_lender.xls.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HMDA )

%fdate()

** Create format from subprime list **;

data Blank_lender;
  length ulender $15 rsp_name $30;
  ulender = "";
  rsp_name = "\b TOTAL";
run;

data Lenders_all;

  set 
    Hmda.Lenders_2004 (keep=ulender rsp_name)
    Hmda.Lenders_2005 (keep=ulender rsp_name)
    Hmda.Lenders_2006 (keep=ulender rsp_name)
    Hmda.Lenders_2007 (keep=ulender rsp_name)
    Blank_lender;
    
run;

proc sort data=Lenders_all nodupkey;
  by ulender; 

%Data_to_format(
  FmtLib=work,
  FmtName=$lender,
  Desc=,
  Data=Lenders_all,
  Value=ulender,
  Label=rsp_name,
  OtherLabel="",
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

proc format;
  picture thous (round) 
    low-high='0,000,000' (multiplier=0.001);
  picture mill (round) 
    low-high='0,000,000' (multiplier=0.000001);

** Compile loan data **;

%let keep_vars = year loantype type action lien high_interest subprime_lender 
                 ulender ucounty purpose amount;
                 
%let counties = '51013', '51059', '51107', '51153', '51510', '51600', '51630', '51683', '51685';

*options obs=1000;

data Hmda_all / view=Hmda_all;

  set 
    Hmda.Loans_2004 (keep=&keep_vars)
    Hmda.Loans_2005 (keep=&keep_vars)
    Hmda.Loans_2006 (keep=&keep_vars)
    Hmda.Loans_2007 (keep=&keep_vars);
    
  where ucounty in ( &counties ) and
        loantype = '1' and type = '1' and action = '1' and lien = '1';

  retain total 1;

  %dollar_convert( amount, amount_adj, year, 2007 )

run;

proc format;
  value $purpose (notsorted)
    '1' = 'Home purchase'
    '3' = 'Refinance'
    '2' = 'Home improvement';

options nodate nonumber;

options orientation=landscape;

ods rtf file="D:\DCData\Libraries\Requests\Prog\2009\Subprime_NOVA.rtf" style=Styles.Rtf_arial_9pt;

***ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2009\Subprime_NOVA.xls" style=minimal
    options( sheet_interval='page' );

proc tabulate data=Hmda_all format=comma10.0 noseps missing;
  class ucounty year;
  class purpose / preloadfmt order=data;
  var total high_interest subprime_lender;
  table 
    /** Pages **/
    ucounty=' ',
    /** Rows **/
    all='Total' year=' ',
    /** Columns **/
    ( all='Total' purpose=' ' ) * 
      ( sum=' ' * total='Total loans' 
        mean=' ' * ( subprime_lender='Subprime lender' high_interest='High interest' ) * f=percent10.1 )
  ;
  title "Share of Subprime and High Interest Mortgage Lending, 2004-2007";
  footnote1 height=9pt "Home Mortgage Disclosure Act data tabulated by NeighborhoodInfo DC (&fdate)";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;

***ods tagsets.excelxp close;

** List of top subprime lenders **;

/** Macro Lender_list - Start Definition **/

%macro Lender_list( select=, title=, num= );

  proc summary data=Hmda_all;
    where (&select.) and ulender ~= "";
    var total amount_adj;
    class ucounty ulender;
    output out=&select._totals (where=(_type_ in ( 2, 3 ) )) 
      sum= ;
    format ulender $lender.;

  run;

  proc sort data=&select._totals;
    by ucounty _type_ descending amount_adj;

  run;
  
  data &select._table;
  
    set &select._totals;
    by ucounty;
    
    retain _count;
    
    if first.ucounty then _count = 0;
    
    if _count <= &num then output;
    
    _count + 1;
    
  run;
  
  options orientation=portrait;

  ods rtf file="D:\DCData\Libraries\Requests\Prog\2009\&select._by_lender.rtf" style=Styles.Rtf_arial_9pt;

  ***ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2009\&select._by_lender.xls" style=minimal
      options( sheet_interval='page' );

  proc report data=&select._table nowd;
    by ucounty;
    column ulender total amount_adj;
    define ulender / display "Lender";
    define total / analysis sum "No. Mortgages Issued";
    define amount_adj / analysis sum "Total Value (thous. $ 2007)";
    format ulender $lender. total comma10. amount_adj thous.;
    label ucounty = "Jurisdiction";
    title "&title, 2004-2007";
    footnote1 height=9pt "Home Mortgage Disclosure Act data tabulated by NeighborhoodInfo DC (&fdate)";
    footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
  run;
  
  ods rtf close;
  
  ***ods tagsets.excelxp close;

%mend Lender_list;

/** End Macro Definition **/


%Lender_list( select=Subprime_lender, num=30, title=Top 30 Subprime Lenders )

%Lender_list( select=High_interest, num=30, title=Top 30 High Interest Mortgage Lenders )


