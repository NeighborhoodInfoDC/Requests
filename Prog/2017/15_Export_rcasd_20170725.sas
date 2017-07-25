/**************************************************************************
 Program:  15_Export_rcasd_20170725.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/30/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Export tract weighting files CSV, with  
 data dictionary. 
 
 Requested by Neal Humphrey for Housing Insights project. 
 
 GitHub issue #15

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )


/** Macro Export - Start Definition **/

%macro Export( data=, out=, desc= );

  %local lib file;
  
  %if %scan( &data, 2, . ) = %then %do;
    %let lib = work;
    %let file = &data;
  %end;
  %else %do;
    %let lib = %scan( &data, 1, . );
    %let file = %scan( &data, 2, . );
  %end;

  %if &out = %then %let out = &file;
  
  %if %length( &desc ) = 0 %then %do;
    proc sql noprint;
      select memlabel into :desc from dictionary.tables
        where upcase(libname)=upcase("&lib") and upcase(memname)=upcase("&file");
      quit;
    run;
  %end;

  filename fexport "&out_folder\&out..csv" lrecl=2000;

  proc export data=&data
      outfile=fexport
      dbms=csv replace;

  run;
  
  filename fexport clear;

  proc contents data=&data out=_cnt_&out (keep=varnum name label label="&desc") noprint;

  proc sort data=_cnt_&out;
    by varnum;
  run;      
  
  %let file_list = &file_list &out;

%mend Export;

/** End Macro Definition **/


/** Macro Dictionary - Start Definition **/

%macro Dictionary( suffix= );

  %local desc;

  ** Start writing to XML workbook **;
    
  ods listing close;

  ods tagsets.excelxp file="&out_folder\Data_dictionary&suffix..xls" style=Normal 
      options( sheet_interval='Proc' orientation='landscape' );

  ** Write data dictionaries for all files **;

  %local i k;

  %let i = 1;
  %let k = %scan( &file_list, &i, %str( ) );

  %do %until ( &k = );
   
    proc sql noprint;
      select memlabel into :desc from dictionary.tables
        where upcase(libname)="WORK" and upcase(memname)=upcase("_cnt_&k");
      quit;
    run;

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
      title1 bold "Data dictionary for file: &k..csv";
      title2 bold "&desc";
      title3 height=10pt "Prepared by NeighborhoodInfo DC on %left(%qsysfunc(date(),worddate.)).";
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


%global file_list out_folder;

** DO NOT CHANGE - This initializes the file_list macro variable **;
%let file_list = ;

** Fill in the folder location where the export files should be saved **;
%let out_folder = &_dcdata_default_path\Requests\Raw\2017\15;

** Export individual data sets **;
%Export( data=Dhcd.Rcasd_2015 )
%Export( data=Dhcd.Rcasd_2016 )
%Export( data=Dhcd.Rcasd_2017 )

** Create data dictionary **;
%Dictionary( suffix=_rcasd_20170725 )

run;
