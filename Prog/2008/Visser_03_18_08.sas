/**************************************************************************
 Program:  Visser_03_18_08.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/20/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Request from Anita Visser, DHCD, 03/18/08.

 Using the federal standard of a household spending 30% of its income
 on shelter costs as being considered affordable, and the ACS
 microdata distribution of District of Columbia household incomes for
 2006, what percentage of all households in the District could afford
 the following monthly rents? 

 (1)     Monthly rent of $9,500.  To be affordable, a household would
 need to have $31,667 of monthly gross income, or an annual income of
 $380,004.  

 (2)     Monthly rent of $2,790.  To be affordable, a household would
 need to have $9,300 of monthly gross income, or an annual income of
 $111,600.  

 In addition, if it is not too onerous, using the same data, what
 percentage of renter households could afford these rents?

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ipums )

rsubmit;

proc download status=no
  data=Ipums.Acs_2006_dc  
  out=Acs_2006_dc ;

run;

endrsubmit;

/** Macro Table - Start Definition **/

%macro Table( mo_rent );

%let mo_rent_fmt = %sysfunc( putn( &mo_rent, comma8. ) );

%let afford_inc_limit = %sysfunc( round( 12 * ( (&mo_rent) / 0.30 ), 1 ) );

%put afford_inc_limit = &afford_inc_limit;

%let afford_inc_limit_fmt = %sysfunc( putn( &afford_inc_limit, comma12. ) );

proc format;
  value tenure (notsorted)
    2 = 'Renters'
    1 = 'Owners';
  value afford
    low -< &afford_inc_limit = '\line Unaffordable'
    &afford_inc_limit - high = 'Affordable';
    
options missing='0' nodate nonumber;

%fdate()

proc tabulate data=Acs_2006_dc format=comma12.0 noseps missing;
  where pernum = 1 and not missing( hhincome ) and gq in ( 1, 2 ) and ownershp > 0;
  class ownershp / preloadfmt order=data;
  class hhincome;
  var hhwt;
  table 
    /** Rows **/
    hhwt=' ' * ( sum='Households'  colpctsum='\line\i % by affordability' * hhincome=' ' ),
    /** Columns **/
    all='Total' ownershp=' '
    / box='Washington, D.C.' 
  ;
  format ownershp tenure. hhincome afford.;
  title1 " ";
  title2 "Share of households who can afford a monthly rent of $ &mo_rent_fmt";
  title3 "(annual income at or above $ &afford_inc_limit_fmt)";
  footnote1 height=9pt "Source: American Community Survey, 2006";
  footnote2 height=9pt " ";
  footnote3 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote4 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

%mend Table;

/** End Macro Definition **/

ods rtf file="&_dcdata_path\Requests\Prog\2008\Visser_03_18_08.rtf" style=Styles.Rtf_arial_9pt;

%Table( 9500 )

%Table( 2790 )

ods rtf close;

signoff;
