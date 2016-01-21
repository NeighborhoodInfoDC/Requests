/**************************************************************************
 Program:  Request_07_10_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/10/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:

 Modifications:
**************************************************************************/

***%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( IPums )

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
  
  format hud_inc hud_inc.;

run;

data HudInc_2005 (compress=no);

  set Ipums.Acs_2005_dc (keep=year serial numprec hhwt hhincome);
  by serial;
  
  if first.serial;

  %Hud_inc_2005()
  
  format hud_inc hud_inc.;

run;

data HudInc (compress=no);

  set HudInc_1999 HudInc_2005;
  
  households = 1;
  
  if hud_inc < 6;
  
run;

proc tabulate data=HudInc format=comma12.0 noseps missing;
  class year hud_inc;
  var households;
  weight hhwt;
  table 
    /** Rows **/
    all='Total' hud_inc='By HUD Income Category'
    ,
    /** Columns **/
    households='Number of Households'*year=' '*sum=' '
    households='% Households'*year=' '*colpctsum=' '*f=comma12.1
    ;
run;

