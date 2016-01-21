/**************************************************************************
 Program:  Drezen_09_07_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/07/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Request from Richard Drezen, Washington Post, 9/7/06. 
# of people who commute to DC for work every day and # employees
working in DC.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( CTPP )

rsubmit;

proc format;
  value $dcin
    '   ' = 'Missing'
    '011' = 'In D.C.'
    other = 'Outside D.C.';

proc tabulate data=Ctpp.Ctpp_2000_pt3_dc format=comma10. noseps missing;
  where sumlev = '040' and state3_wrk = '011';
  class state3_res;
  var tab301x1;
  table tab301x1*sum=' ' * ( all='Total' state3_res='Resides' );
  format state3_res $dcin.;
  title3 'Persons working in the District of Columbia, 2000';
  footnote1 'Source:  Census 2000 Transportation Planning Package, Part 3 data, tabulated by NeighborhoodInfo DC';

run;

endrsubmit;

signoff;
