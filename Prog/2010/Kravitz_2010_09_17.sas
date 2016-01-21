/**************************************************************************
 Program:  Kravitz_2010_09_17.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/20/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Number of rental apartment buildings by year and type,
 2000 - 2010.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

rsubmit;

%let end_yr = 2010;
%let end_qtr = 1;

%************  DO NOT CHANGE BELOW THIS LINE  ************;

%**** Initialize macro variables ****;

%let start_yr = 2001;
%let start_date = "01jan&start_yr"d;

%let end_date = %sysfunc( intnx( QTR, "01jan&end_yr"d, %eval( &end_qtr - 1 ), END ) );
%put end_date = %sysfunc( putn( &end_date, mmddyy10. ) );

%let lib  = RealProp;
%let data = Parcel_base;

*options obs=1000;

** Create count vars **;

data Num_units_raw (compress=no);

  merge 
    &lib..&data 
      (keep=ssl ownerpt_extractdat_first ownerpt_extractdat_last ui_proptype usecode
       where=(ui_proptype in ( '13' ))
       in=in1)
    RealProp.Parcel_geo
      (drop=cjrtractbl x_coord y_coord);
  by ssl;
  
  if in1;
  
  rental_bldg = 1;
  
  rental_bldg_sm = 0;
  rental_bldg_lg = 0;
  
  if usecode in ( '023', '024' ) then rental_bldg_sm = 1;
  else rental_bldg_lg = 1;
  
  ** Output individual obs. for each year **;
  
  do year = &start_yr to &end_yr;
  
    if year( ownerpt_extractdat_first ) <= max( year, 2001 ) <= year( ownerpt_extractdat_last ) 
      then output;
  
  end;

  label
    rental_bldg = 'Rental buildings'
    rental_bldg_sm = 'Rental buildings, < 5 units'
    rental_bldg_lg = 'Rental buildings, 5+ units'
;
  
run;

proc download status=no
  inlib=work 
  outlib=work memtype=(data);
  select Num_units_raw;

run;

endrsubmit;

%File_info( data=Num_units_raw, freqvars=year )

proc format;
  value $usecd (notsorted)
    '023', '024' = 'Buildings With Less Than 5 Units'
    other = 'Buildings With 5 or More Units';
  value yearx
    2010 = '2010-Q1';
run;

%fdate

options nodate nonumber;

ods rtf file="D:\DCData\Libraries\Requests\Prog\2010\Kravitz_2010_09_17.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Num_units_raw format=comma12.0 noseps missing;
  where not( missing( ward2002 ) );
  class usecode / preloadfmt order=data;
  class ward2002 year;
  var rental_bldg;
    table 
    /** Pages **/
    all='All Rental Buildings' usecode=' ',
    /** Rows **/
    all='\b Washington, D.C.' ward2002='\line\i By ward',
    /** Columns **/
    rental_bldg='Number of rental buildings' * sum=' ' * year=' '
    / condense;
  format usecode $usecd. year yearx.;
  title2 ' ';
  title3 'Number of Multifamily Rental Buildings, 2001 - 2010-Q1';
  title4 'Washington, D.C.';
  footnote1 height=9pt "Source: DC Office of Tax and Revenue Real Property Database";
  footnote2 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;

signoff;
