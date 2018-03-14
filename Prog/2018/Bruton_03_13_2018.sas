/**************************************************************************
 Program:  Bruton_03_13_2018.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/14/18
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Request from Scott Bruton, CNHED, for number of
 renters in single family homes by households size. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( IPUMS )

data Bruton_03_13_2018;

  set Ipums.Acs_2011_15_dc (keep=pernum gqtype ownershp condofee numprec unitsstr hhwt);
  
  retain total 1;
  
run;

proc format;
  value numprec
    1 = '1'
    2 = '2'
    3 = '3'
    4-high = '4+';
run;

options nodate nonumber;

%fdate()

ods rtf file="&_dcdata_default_path\Requests\Prog\2018\Bruton_03_13_2018.rtf" style=Styles.Rtf_arial_9pt startpage=no;

proc tabulate data=Bruton_03_13_2018 format=comma12.0 noseps missing;
  where pernum = 1 and gqtype = 0 and ownershp = 2 and condofee = 0;
  class numprec unitsstr;
  var total;
  weight hhwt;
  table 
    /** Rows **/
    all='Total' unitsstr=' ',
    /** Columns **/
    sum=' ' * total='Number of Renter Households' * 
    ( all='Total' numprec='Persons in household' )
    / box='Housing structure type'
  ;
  table 
    /** Rows **/
    all='Total' unitsstr=' ',
    /** Columns **/
    colpctsum=' ' * total='Percentage\~of\~Renter\~Households' * 
    ( all='Total' numprec='Persons in household' )
    / box='Housing structure type'
  ;
  format numprec numprec.;
  title2 " ";
  title3 "Non-Condo Renter Households by Units in Structure and Household Size, District of Columbia, 2011-15";
  footnote1 height=9pt "Source: American Community Survey/IPUMS-USA 5-year data prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;
