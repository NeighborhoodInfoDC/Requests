/**************************************************************************
 Program:  Yourish_08_03_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/04/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Compile data on Dupont Circle requested by Karen
 Yourish, Washington Post, 8/3/06.

 Modifications:
**************************************************************************/

/*
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
*/

%include "[dcdata]stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( CTPP )

*rsubmit;

proc format;
  value $stres (notsorted)
    '011' = 'Living in DC'
    other = 'Living outside DC';
  value $stwrk (notsorted)
    '011' = 'Working in DC'
    other = 'Working outside DC';

proc tabulate data=Ctpp.Ctpp_2000_pt3_dc format=comma12.0 missing;
  where sumlev = '040';
  class state3_wrk state3_res / preloadfmt order=data;
  var tab301x1;
  tables 
    /** Rows **/
    all='Total' state3_res=' '
    ,
    /** Columns **/
    tab301x1='Workers Living or Working in DC, 2000' * sum=' ' *
    ( all='Total' state3_wrk=' ' )
    ;
  format state3_wrk $stwrk. state3_res $stres.;
  footnote1 'Source: Census 2000 Transportation Planning Package, pt. 3, tabulated by NeighborhoodInfo DC';

run;

*endrsubmit;

*signoff;

