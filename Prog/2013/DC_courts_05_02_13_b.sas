/**************************************************************************
 Program:  DC_courts_05_02_13_b.sas
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



ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2013\DC_courts_05_02_13_b.xls" style=Minimal options(sheet_interval='Page' );

ods tagsets.excelxp options( sheet_name="Births" );

data Births (keep=city row y2002-y2010);

  length Row $ 40;
  
  set Requests.Dc_courts_05_02_13_city;
  
  array y{*} y2002-y2010;
  array total{*} births_total_2002-births_total_2010;
  array teen{*} births_teen_2002-births_teen_2010;
  array single{*} births_single_2002-births_single_2010;
  
  Row = "Total births";
  
  do i = 1 to dim( total );
    y{i} = total{i};
  end;
  
  output;
  
  Row = "Teen births";
  
  do i = 1 to dim( teen );
    y{i} = teen{i};
  end;
  
  output;
  
  Row = "Unmarried births";
  
  do i = 1 to dim( single );
    y{i} = single{i};
  end;
  
  output;
  
  label %label_year( 2002, 2010 );
  
run;

proc print data=Births label;
  id Row;
  var y2002-y2010;
run;

** Crimes **;

ods tagsets.excelxp options( sheet_name="Crimes" );

data Crimes (keep=city row y2000-y2011);

  length Row $ 40;
  
  set Requests.Dc_courts_05_02_13_city;
  
  array y{*} y2000-y2011;
  array property{*} crimes_pt1_property_2000-crimes_pt1_property_2011;
  array violent{*} crimes_pt1_violent_2000-crimes_pt1_violent_2011;
  
  Row = "Property crimes";
  
  do i = 1 to dim( property );
    y{i} = property{i};
  end;
  
  output;
  
  Row = "Violent crimes";
  
  do i = 1 to dim( violent );
    y{i} = violent{i};
  end;
  
  output;
  
  label %label_year( 2000, 2011 );

run;

proc print data=Crimes label;
  id Row;
  var y2000-y2011;
run;

** TANF/FS **;

ods tagsets.excelxp options( sheet_name="TANF_FS" );

data Tanf_fs (keep=city row y2000-y2013);

  length Row $ 40;
  
  set Requests.Dc_courts_05_02_13_city;
  
  array y{*} y2000-y2013;
  array tanf{*} tanf_client_2000-tanf_client_2013;
  array fs{*} fs_client_2000-fs_client_2013;
  
  Row = "TANF clients";
  
  do i = 1 to dim( tanf);
    y{i} = tanf{i};
  end;
  
  output;
  
  Row = "SNAP clients";
  
  do i = 1 to dim( fs );
    y{i} = fs{i};
  end;
  
  output;
  
  label %label_year( 2000, 2013 );

run;

proc print data=Tanf_fs label;
  id Row;
  var y2000-y2013;
run;

ods tagsets.excelxp close;

