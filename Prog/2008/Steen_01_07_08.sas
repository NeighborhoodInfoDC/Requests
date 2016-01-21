/**************************************************************************
 Program:  Steen_01_07_08.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/07/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create ACS 2006 tabulations to show "supply and
 demand" for housing at different affordability levels.
 Requested by Leslie Steen, Office of the DMPED, 1/7/08.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ACS )

** Start submitting commands to remote server **;

proc format;
  value inc
    -100000 -< 21228 = '< $21,228'
    21228 <- 42457 = '$21,228 - 42,457'
    42457 <- 56609 = '$42,457 - 56,609'
    56609 <- 70762 = '$56,609 - 70,762'
    70762 <- 84914 = '$70,762 - 84,914'
    84914 <- 114523 = '$84,914 - 114,523'
    114523 <- high = '> $114,523';
  value rent
    0 -< 531 = '< $531'
    531 <- 1061 = '$531 - 1,061'
    1061 <- 1415 = '$1,061 - $1,415'
    1415 <- 1769 = '$1,415 - 1,769'
    1769 <- 2123 = '$1,769 - 2,123'
    2123 <- 3538 = '$2,123 - 3,538'
    3538 <- high = '> $3,538';
  value price
    low -< 74627 = '< $74,627'
    74627 <- 149253 = '$74,627 - 149,253'
    149253 <- 199005 = '$149,253 - 199,005'
    199005 <- 248756 = '$199,005 - 248,756'
    248756 <- 298507 = '$248,756 - 298,507'
    298507 <- 497511 = '$298,507 - 497,511'
    497511 <- high = '> $497,511';
  value $val
    '01', '02', '03', '04', '05', '06', '07', '08', '09', '10' = '< $70,000'
    '11', '12', '13', '14', '15' = '$70,000 - 149,999'
    '16', '17' = '$150,000 - 199,999'
    '18' = '$200,000 - 249,999'
    '19' = '$250,000 - 299,999'
    '20', '21' = '$300,000 - 499,999'
    '22', '23', '24' = '$500,000 or more';
  value $vacs
    ' ' = 'Occupied'
    other = 'Vacant';

** Select only occupied and vacant housing units (not group quarters) in DC **;

data Acs_pums_2006_was;

  set Acs.Acs_pums_2006_was;
  
  where Statecd = '11' and type = '1' and ( sporder = 1 or vacs in ( '1', '2', '3', '4' ) );
  
  if vacs in ( '1', '2' ) then rent = rntp;
  else rent = grntp;
  
  keep type sporder vacs hincp rent wgtp ten val;
  
run;

ods rtf file="&_dcdata_path\Requests\Prog\2008\Steen_01_07_08.rtf" style=Styles.Rtf_arial_9pt;

options missing='0' nodate nonumber;

%fdate()

proc tabulate data=Acs_pums_2006_was format=comma12.0 noseps missing;
  where type = '1' and sporder = 1;
  class hincp / preloadfmt;
  var wgtp;
  table 
    /** Rows **/
    all='Total' hincp='\i By income',
    /** Columns **/
    sum=' ' * wgtp='Households,\~2006'
    / printmiss;
  format hincp inc.;
  title2 ' ';
  title3 'Households by annual income';
  footnote1;
  footnote3 height=9pt "\b0 Source: American Community Survey, 2006, tabulated by NeighborhoodInfo DC (&fdate).";
  footnote4 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

 
run;

proc tabulate data=Acs_pums_2006_was format=comma12.0 noseps missing;
  where type = '1' and ( ( sporder = 1 and ten = '3' ) or vacs in ( '1', '2' ) );
  class rent vacs / preloadfmt;
  var wgtp;
  table 
    /** Rows **/
    all='Total' rent='\i By monthly rent',
    /** Columns **/
    sum=' ' * wgtp='Renter-occupied and vacant for rent housing units, 2006' * ( all='Total' vacs=' ' )
    / printmiss;
  format rent rent. vacs $vacs.;
  title2 ' ';
  title3 'Housing units by monthly rent';
  footnote1 height=9pt "\b0 Note: Only includes units renting for cash. Rent for vacant units does not include utility costs unless included in basic rent.";
  footnote2 height=9pt " ";
  footnote3 height=9pt "\b0 Source: American Community Survey, 2006, tabulated by NeighborhoodInfo DC (&fdate).";
  footnote4 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
 
run;


proc tabulate data=Acs_pums_2006_was format=comma12.0 noseps missing;
  where type = '1' and ( ( sporder = 1 and ten in ( '1', '2' ) ) or vacs in ( '3', '4' ) );
  class val vacs / preloadfmt;
  var wgtp;
  table 
    /** Rows **/
    all='Total' val='\i By property value',
    /** Columns **/
    sum=' ' * wgtp='Owner-occupied and vacant for sale housing units, 2006' * ( all='Total' vacs=' ' )
    / printmiss;
  format val $val. vacs $vacs.;
  title2 ' ';
  title3 'Housing units by property value';
  footnote1;
  footnote3 height=9pt "\b0 Source: American Community Survey, 2006, tabulated by NeighborhoodInfo DC (&fdate).";
  footnote4 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
 
run;

ods rtf close;

run;

