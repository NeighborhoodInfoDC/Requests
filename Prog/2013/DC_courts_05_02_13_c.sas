/**************************************************************************
 Program:  DC_courts_05_02_13_c.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/22/13
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Export XML data for creating charts.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

/** Macro Year_label - Start Definition **/

%macro Label_year( start, end );

  %local i;

  %do i = &start %to &end;
    y&i = "&i"
  %end;

%mend Label_year;

/** End Macro Definition **/

ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2013\DC_courts_05_02_13_c.xls" 
                    style=Minimal options(sheet_interval='Page' );

** Language **;

ods tagsets.excelxp options( sheet_name="Language" );

data Language (keep=city row y2000 y2007_11);

  length Row $ 40;

  set Requests.Dc_courts_05_02_13_city;
  
  Row = "Speak English not well or not at all";
    
  y2000 = ( pop5to17poorenglish_2000 + pop18to64poorenglish_2000 + pop65andoverpoorenglish_2000 ) /
          ( pop5to17years_2000 + pop18to64years_2000 + pop65andoveryears_2000 );
          
  y2007_11 = ( pop5to17poorenglish_2007_11 + pop18to64poorenglish_2007_11 + pop65andoverpoorenglish_2007_11 ) / 
             ( pop5to17years_2007_11 + pop18to64years_2007_11 + pop65andoveryears_2007_11 );

  output;

  label
    y2000 = '2000'
    y2007_11 = '2007-11';

run;

proc print data=Language label;
  id Row;
  var y2000 y2007_11;
run;

** Educational attainment **;

ods tagsets.excelxp options( sheet_name="Education" );

data Education (keep=city row y2000 y2007_11);

  length Row $ 40;

  set Requests.Dc_courts_05_02_13_city;
  
  Row = "With college";
    
  y2000 = Pop25andOverWCollege_2000 / Pop25andOverYears_2000;
  y2007_11 = Pop25andOverWCollege_2007_11 / Pop25andOverYears_2007_11;
  
  output;
          
  Row = "HS/GED only";
    
  y2000 = ( Pop25andOverWHS_2000 - Pop25andOverWCollege_2000 ) / Pop25andOverYears_2000;
  y2007_11 = ( Pop25andOverWHS_2007_11 - Pop25andOverWCollege_2007_11 ) / Pop25andOverYears_2007_11;

  output;

  Row = "Without HS/GED";
    
  y2000 = Pop25andOverWoutHS_2000 / Pop25andOverYears_2000;
  y2007_11 = Pop25andOverWoutHS_2007_11 / Pop25andOverYears_2007_11;
  
  output;
          
  label
    y2000 = '2000'
    y2007_11 = '2007-11';

run;

proc print data=Education label;
  id Row;
  var y2000 y2007_11;
  sum y2000 y2007_11;
run;

** Dropout **;

ods tagsets.excelxp options( sheet_name="Dropout" );

data Dropout (keep=city row y2000 y2007_11);

  length Row $ 80;

  set Requests.Dc_courts_05_02_13_city;
  
  Row = "High school dropouts";
    
  y2000 = numhighschooldropout_2000 / pop16to19years_2000;

  y2007_11 = numhighschooldropout_2007_11 / pop16to19years_2007_11;

  output;

  label
    y2000 = '2000'
    y2007_11 = '2007-11';

run;

proc print data=Dropout label;
  id Row;
  var y2000 y2007_11;
run;

ods tagsets.excelxp close;

