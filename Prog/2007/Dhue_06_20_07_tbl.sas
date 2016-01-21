/**************************************************************************
 Program:  Dhue_06_20_07_tbl.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/22/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create table of subprime lending data for P.G. County
 and Capitol Heights, MD area.

 Request from Stephanie Dhue, Nightly Business Report 
 [stephanie_dhue@nbr.com].

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

proc format;
  value $area (notsorted)
    "24033802103" = "Capitol Heights"
    "24033802203" = "Capitol Heights"
    "24033802204" = "Capitol Heights"
    "24033802301" = "Capitol Heights"
    "24033802403" = "Capitol Heights"
    "24033802404" = "Capitol Heights"
    "24033802502" = "Capitol Heights"
    "24033802600" = "Capitol Heights"
    "24033802700" = "Capitol Heights"
    "24033802803" = "Capitol Heights"
    "24033802804" = "Capitol Heights"
    "24033802805" = "Capitol Heights"
    "24033802901" = "Capitol Heights"
    "24033803001" = "Capitol Heights"
    "24033803002" = "Capitol Heights"
    "24033803401" = "Capitol Heights"
    "24033803402" = "Capitol Heights"
    "24033803508" = "Capitol Heights"
    "24033803518" = "Capitol Heights"
    "24033803519" = "Capitol Heights"
    other = "Rest of P.G. County"
  ;

%fdate()

options nodate nonumber;

ods rtf file="&_dcdata_path\requests\prog\2007\Dhue_06_20_07_tbl.rtf" style=Styles.Rtf_arial_9pt bodytitle;

proc tabulate data=Requests.Dhue_06_20_07 format=comma10. noseps missing;
  class geo2000 / preloadfmt order=data;
  var numconvmrtgorighomepurch_2005 NumSubprimeConvOrigHomePur_2005
      numconvmrtgorigrefin_2005 NumSubprimeConvOrigrefin_2005 ;
  table 
    /** Rows **/
    ( numconvmrtgorighomepurch_2005 NumSubprimeConvOrigHomePur_2005 ) * sum=' '
    NumSubprimeConvOrigHomePur_2005="\~\~Percent"
      * pctsum<numconvmrtgorighomepurch_2005>=' '*f=comma10.1
    ( numconvmrtgorigrefin_2005 NumSubprimeConvOrigrefin_2005 ) * sum=' '
    NumSubprimeConvOrigrefin_2005="\~\~Percent"
      * pctsum<numconvmrtgorigrefin_2005>=' '*f=comma10.1
    ,
    /** Columns **/
    all="Prince George's County"
    geo2000=' '
    ;
  format geo2000 $area.;
  label 
    numconvmrtgorighomepurch_2005 = "Conventional home purchase loans"
    NumSubprimeConvOrigHomePur_2005 = "Conventional home purchase loans from subprime lenders"
    numconvmrtgorigrefin_2005 = "\line Conventional refinance loans"
    NumSubprimeConvOrigrefin_2005 = "Conventional refinance loans from subprime lenders"
  ;
  title "Subprime Mortgage Lending in Prince George's County and Capitol Heights, MD, 2005";
  footnote1 height=9pt "\b0 Source:  Home Mortgage Disclosure Act data tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate";
  *footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;

