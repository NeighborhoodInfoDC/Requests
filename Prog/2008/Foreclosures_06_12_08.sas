/**************************************************************************
 Program:  Foreclosures_06_12_08.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/12/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  %DCData_lib( ROD )

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ROD )
%DCData_lib( RealProp )

** Start submitting commands to remote server **;

rsubmit;

data all_years;

  set     
    Rod.Foreclosures_2006
    Rod.Foreclosures_2007;

run;

proc tabulate data=all_years format=comma12.0 noseps missing;
  class FilingDate UI_Instrument;
  class ui_proptype;
  table
    /** Pages **/
    UI_Instrument=' '
    ,
    /** Rows **/
    all='D.C.\~Total'
    ui_proptype=' '
    ,
    /** Columns **/
    n='Number of Notices Issued by Year' * (
    all='Total'
    FilingDate=' '
    )
    / /*box=_page_*/ printmiss;
  format FilingDate year4.0 ward2002 $wards. ui_proptype $uiprtyp.;
  title1 "Notices of Foreclosure by Type of Notice, Year of Issue, and Property Type";
  title2 "Washington, D.C.";
  footnote1 height=9pt "Note:  Notices issued during calendar year.";
  footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org).";
  *footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;


endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
