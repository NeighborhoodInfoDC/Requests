/**************************************************************************
 Program:  HAND_05_13_15.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/13/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Tabulate number of households with severe cost burden
 by jurisdiction from the Housing Security Study for HAND summit on
 affordable housing. 5/13/15.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HsngSec, local=n )
%DCData_lib( IPUMS, local=n );

%File_info( data=HsngSec.Acs_tables, printobs=0 )

***** Formats *****;

proc format;

  /** PUMA to selected counties (combine Arlington & Alexandria) **/

  value $pumctyb (notsorted)
    '1100101' = 'District of Columbia'
    '1100102' = 'District of Columbia'
    '1100103' = 'District of Columbia'
    '1100104' = 'District of Columbia'
    '1100105' = 'District of Columbia'
    '2401001' = 'Montgomery'
    '2401002' = 'Montgomery'
    '2401003' = 'Montgomery'
    '2401004' = 'Montgomery'
    '2401005' = 'Montgomery'
    '2401006' = 'Montgomery'
    '2401007' = 'Montgomery'
    '2401101' = 'Prince George''s'
    '2401102' = 'Prince George''s'
    '2401103' = 'Prince George''s'
    '2401104' = 'Prince George''s'
    '2401105' = 'Prince George''s'
    '2401106' = 'Prince George''s'
    '2401107' = 'Prince George''s'
    '5100100' = 'Arlington'
    '5100200' = 'Alexandria'
    '5100301' = 'Fairfax/Fairfax City/Falls Church'
    '5100302' = 'Fairfax/Fairfax City/Falls Church'
    '5100303' = 'Fairfax/Fairfax City/Falls Church'
    '5100304' = 'Fairfax/Fairfax City/Falls Church'
    '5100305' = 'Fairfax/Fairfax City/Falls Church'
	'5100501' = 'Prince William/Manassas/Manassas Park'
	'5100502' = 'Prince William/Manassas/Manassas Park'
	'5100600' = 'Loudoun/Fauquier/Clarke/Warren'
    other = ' ';
  
  value tenure (notsorted)
    2 = 'Renter'
    1 = 'Owner';

run;

data Hand_05_13_15;

  set HsngSec.Acs_tables;
  
  where pernum=1 and GQ in (1,2) and ownershp in (1, 2) and hud_inc in ( 1, 2, 3 );
  
  if housing_costs = 0 then cost_burden = 0;
  else if missing ( hhincome ) then cost_burden = .u;
  else if hhincome > 0 then cost_burden = ( 100 * 12 * housing_costs ) / hhincome;
  else cost_burden = 100;

  if cost_burden >= 50 then Affprob = 2; **Serious Affordability problem**;
  else if 30 <= cost_burden < 50 then Affprob = 1; **Affordability problem**;
  else if 0 <= cost_burden < 30 then Affprob = 0; **No affordability problem**;

  if Affprob = 1 then Affrate = 1; **Affordability problem**;
  else if Affprob = 0 then Affrate = 0; **No affordability problem**;
  label Affrate = "Affordability problem rate";

  if cost_burden > 50 then Sevaff = 1; **Severe Affordabilty problem**;
  else if 0 <= cost_burden < 50 then Sevaff = 0; **No severe affordability problem**;

  if Sevaff = 1 then Sevrate = 1; **Severe affordability problem**;
  else if Sevaff = 0 then Sevrate = 0; **No severe affordability problem**;
  label Sevrate = "Severe affordability problem rate";

run;

proc format;
  picture hundreds (round)
    low-< 100 = "<100" (noedit)
    100-high = "0,000,9~~" (mult=0.01);

%fdate()



proc tabulate data=Hand_05_13_15 format=hundreds12.0 noseps missing;
  class upuma hud_inc ownershp /order=data preloadfmt;
  var sevaff;
  weight hhwt;
  table 
    /** Rows **/
    all="Washington region" upuma=" ",
    /** Columns **/
    sum=" " * sevaff="Households at or below 80% AMI with severe cost burden, 2009-11" * (all="Total" ownershp="")
  ;
  format upuma $pumctyb. hud_inc hudinc. ownershp tenure.;
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
run;


