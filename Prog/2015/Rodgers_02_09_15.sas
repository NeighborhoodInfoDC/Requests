/**************************************************************************
 Program:  Rodgers_02_09_15.sas
 Library:  PresCat
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/09/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Export of projects and geocoded buildings for Art
Rodgers, OP, 2/9/15.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( PresCat )

%global file_list;

%let file_list = ;

/** Macro Export - Start Definition **/

%macro Export( k );

  filename fexport "D:\DCData\Libraries\Requests\Raw\Rodgers_&k..csv" lrecl=2000;

  proc export data=PresCat.&k
      outfile=fexport
      dbms=csv replace;

  run;

  filename fexport clear;

  proc contents data=PresCat.&k out=_cnt_&k (keep=varnum name label) noprint;

  proc sort data=_cnt_&k;
    by varnum;
  run;      
  
  %let file_list = &file_list &k;

%mend Export;

/** End Macro Definition **/

/** Macro Dictionary - Start Definition **/

%macro Dictionary(  );

  ** Start writing to XML workbook **;
    
  ods listing close;

  ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2015\Rodgers_02_09_15.xls" style=/*Minimal*/Normal 
      options( sheet_interval='Proc' orientation='landscape' );

  ** Write data dictionaries for all files **;

  %local i k;

  %let i = 1;
  %let k = %scan( &file_list, &i, %str( ) );

  %do %until ( &k = );
   
    ods tagsets.excelxp 
        options( sheet_name="&k" 
                 embedded_titles='yes' embedded_footnotes='yes' 
                 embed_titles_once='yes' embed_footers_once='yes' );

    proc print data=_cnt_&k label;
      id varnum;
      var name label;
      label 
        varnum = 'Col #'
        name = 'Name'
        label = 'Description';
      title1 bold "Preservation Catalog data dictionary - File: Rodgers_&k..csv";
      title2 height=10pt "Prepared by NeighborhoodInfo DC (revised%sysfunc(date(),worddate.)).";
      /***title3 height=10pt "Notes: i = Insufficient data; s = Suppressed proprietary or confidential data.";***/
      footnote1;
    run;

    %let i = %eval( &i + 1 );
    %let k = %scan( &file_list, &i, %str( ) );

  %end;

  ** Close workbook **;

  ods tagsets.excelxp close;
  ods listing;

  run;
  
%mend Dictionary;

/** End Macro Definition **/



%Export( Project )
%Export( Subsidy )
%Export( Building_geocode )

%Dictionary()
