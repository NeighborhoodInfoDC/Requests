/**************************************************************************
 Program:  Mantell_07_10_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/10/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description: Number of HHs by HUD income category for 2000 and 2005.
 Request from Ruth Mantell, Market Watch, 7/10/07

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( IPums )

*options obs=0;

proc format;
  value hud_inc
    1 = 'Extremely low (30% median)'
    2 = 'Very low (31-50% median)'
    3 = 'Low (51-80% median)'
    4 = 'Moderate (81-120% median)'
    5 = 'High (Over 120% median)'
    6 = 'Not applicable';

data HudInc_1999 (compress=no);

  set Ipums.Ipums_2000_dc (keep=year serial numprec hhwt hhincome);
  by serial;
  
  if first.serial;

  %Hud_inc_1999()
  
  if hud_inc < 6;
  
  format hud_inc hud_inc.;

run;

proc sql noprint;
  select count(*) into: nobs_2000
  from HudInc_1999;
  quit;
run;

data HudInc_2005 (compress=no);

  set Ipums.Acs_2005_dc (keep=year serial numprec hhwt hhincome);
  by serial;
  
  if first.serial;

  %Hud_inc_2005()
  
  if hud_inc < 6;
  
  format hud_inc hud_inc.;

run;

data HudInc (compress=no);

  set HudInc_1999 HudInc_2005;
  
  households = 1;
  
run;

proc sql noprint;
  select count(*) into: nobs_2005
  from HudInc_2005;
  quit;
run;

** Create table **;

%fdate()

options nodate nonumber;

ods rtf file="&_dcdata_path\requests\prog\2007\Mantell_07_10_07.rtf" style=Styles.Rtf_arial_9pt bodytitle;

proc tabulate data=HudInc format=comma12.0 noseps missing;
  class year hud_inc;
  var households;
  weight hhwt;
  table 
    /** Rows **/
    all='Total' hud_inc='\line\i By HUD Income Category'
    ,
    /** Columns **/
    households='Number of Households'*year=' '*sum=' '
    households='% Households'*year=' '*colpctsum=' '*f=comma12.1
    ;
  title1 "Number of Households by HUD Income Categories, 2000 and 2005";
  title2 "Washington, D.C.";
  footnote1 height=9pt "\b0 Source:  U.S. Census and American Community Survey data";
  footnote2 height=9pt "\b0 tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate";
  footnote3 height=9pt " ";
  footnote4 height=9pt "\b0 Note:  Unweighted sample sizes: %left(%nrstr(%sysfunc(putn(&nobs_2000,comma8.0)))) (2000); %left(%nrstr(%sysfunc(putn(&nobs_2005,comma8.0)))) (2005).";

run;

ods rtf close;

