/**************************************************************************
 Program:  Gross_rent_w7_8_2009_2013.sas
 Library:  OCC
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/04/14
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Process gross rent ranges for Wards 7 & 8.
 Adapted from OCC Ch 3 program Gross_rent_2005_2012.sas.
 Data downloaded from ACS 5-year B25063 tables for DC wards.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( OCC )

** Read ACS data for 2009 and 2013 **;

filename fimport "D:\DCData\Libraries\Requests\Raw\2015\ACS_09_5YR_B25063.csv" lrecl=2000;

proc import out=ACS_09_5YR_B25063
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;

run;

filename fimport "D:\DCData\Libraries\Requests\Raw\2015\ACS_13_5YR_B25063.csv" lrecl=2000;

proc import out=ACS_13_5YR_B25063
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;

run;


** Transpose data **;

/** Macro tr_range - Start Definition **/

%macro tr_range( var=, low=, high= );

  Low = &low;
  High = &high;
  Units = &var;

  output;

%mend tr_range;

/** End Macro Definition **/

data ACS_transpose_a;

  set
    ACS_09_5YR_B25063 (drop=hd02_: GEO_id GEO_id2 in=in09 )
    ACS_13_5YR_B25063 (drop=hd02_: GEO_id GEO_id2);
    
  where GEO_display_label in: ( 'Ward 7', 'Ward 8' );
  
  if in09 then Year = 2009;
  else Year = 2013;
  
  %tr_range( var=HD01_VD03, low=0, high=100 )
  %tr_range( var=HD01_VD04, low=100, high=149 )
  %tr_range( var=HD01_VD05, low=150, high=199 )
  %tr_range( var=HD01_VD06, low=200, high=249 )
  %tr_range( var=HD01_VD07, low=250, high=299 )
  %tr_range( var=HD01_VD08, low=300, high=349 )
  %tr_range( var=HD01_VD09, low=350, high=399 )
  %tr_range( var=HD01_VD10, low=400, high=449 )
  %tr_range( var=HD01_VD11, low=450, high=499 )
  %tr_range( var=HD01_VD12, low=500, high=549 )
  %tr_range( var=HD01_VD13, low=550, high=599 )
  %tr_range( var=HD01_VD14, low=600, high=649 )
  %tr_range( var=HD01_VD15, low=650, high=699 )
  %tr_range( var=HD01_VD16, low=700, high=749 )
  %tr_range( var=HD01_VD17, low=750, high=799 )
  %tr_range( var=HD01_VD18, low=800, high=899 )
  %tr_range( var=HD01_VD19, low=900, high=999 )
  %tr_range( var=HD01_VD20, low=1000, high=1249 )
  %tr_range( var=HD01_VD21, low=1250, high=1499 )
  %tr_range( var=HD01_VD22, low=1500, high=1999 )
  %tr_range( var=HD01_VD23, low=2000, high=. )
  
  keep GEO_display_label Year Low High Units;
  
run;

proc summary data=ACS_transpose_a nway missing;
  class low high year;
  var units;
  output out=ACS_transpose_b sum=;
run;

%Super_transpose(  
  data=ACS_transpose_b,
  out=ACS_transpose,
  var=Units,
  id=year,
  by=low high,
  mprint=N
)
    
%File_info( data=ACS_transpose, printobs=100 )
    

%let START_YR = 2009;
%let END_YR = 2013;

data Gross_rent_w7_8_2009_2013;

  set ACS_transpose;
     
   ** Create low and high rent levels adjusted for inflation **;

   %dollar_convert( Low, Low_2009, 2009, &END_YR, series=CUUR0000SA0L2 )
   %dollar_convert( High, High_2009, 2009,&END_YR, series=CUUR0000SA0L2 )
   %dollar_convert( Low, Low_2013, 2013, &END_YR, series=CUUR0000SA0L2 )
   %dollar_convert( High, High_2013, 2013,&END_YR, series=CUUR0000SA0L2 )
   
   retain Carry_&START_YR Carry_&END_YR 0;
   
   if not missing( High_2009 ) then do;
   
     UnitsAdj_2009 = min( ( ( high - low ) / ( High_2009 - Low_2009 ) ), 1 ) * Units_2009 + Carry_2009;
     
     Carry_2009 = ( 1 - min( ( ( high - low ) / ( High_2009 - Low_2009 ) ), 1 ) ) * Units_2009; 
     
   end;
   else do;
   
     UnitsAdj_2009 = Units_2009 + Carry_2009;
     
   end;
    
   if not missing( High_2013 ) then do;
   
     UnitsAdj_2013 = min( ( ( high - low ) / ( High_2013 - Low_2013 ) ), 1 ) * Units_2013 + Carry_2013;
     
     Carry_2013 = ( 1 - min( ( ( high - low ) / ( High_2013 - Low_2013 ) ), 1 ) ) * Units_2013; 
     
   end;
   else do;
   
     UnitsAdj_2013 = Units_2013 + Carry_2013;
     
   end;

   *drop i Low&START_YR-Low&END_YR High&START_YR-High&END_YR Carry&START_YR-Carry&END_YR;

run;

%File_info( data=Gross_rent_w7_8_2009_2013, printobs=50 )


** Create table **;

proc format;
  value rntrang
    0-450 = 'Under $500'
    500-650 = '$500 to $699'
    700-750 = '$700 to $799'
    800-900 = '$800 to $999'
    1000-1250 = '$1,00 to $1,499'
    1500-2000 = '$1,500 or more';
run;
    
ods csvall body="D:\DCData\Libraries\Requests\Prog\2015\Gross_rent_w7_8_2009_2013.csv";

proc tabulate data=Gross_rent_w7_8_2009_2013 format=comma10.0 noseps missing;
  class low;
  var UnitsAdj_2009 UnitsAdj_2013;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( UnitsAdj_2009 UnitsAdj_2013 )
  ;
  format low rntrang.;
  label 
    UnitsAdj_2009 = '2005-09'
    UnitsAdj_2013 = '2009-13';
  title2 'Renter-Occupied Housing Units by Gross Rent (constant 2013 $)';
  title3 'Wards 7 & 8';
run;

ods csvall close;
