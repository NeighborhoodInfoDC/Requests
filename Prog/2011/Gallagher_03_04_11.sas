/**************************************************************************
 Program:  Gallagher_03_04_11.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/04/11
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Request from Mari Gallagher, 3/4/11. Copies of birth
 and death records for 2003-2007 in CSV format. 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Vital )

%let file_list = births_2003 births_2004 births_2005 births_2006 births_2007
                 deaths_2003 deaths_2004 deaths_2005 deaths_2006 deaths_2007;

%syslput file_list=&file_list;

** Start submitting commands to remote server **;

rsubmit;

proc download status=no
  inlib=Vital 
  outlib=Work memtype=(data);
  select &file_list;

proc download status=no
  inlib=Vital 
  outlib=Work memtype=(catalog);
  select formats;

run;

endrsubmit;

** End submitting commands to remote server **;


/** Macro Output_all_files - Start Definition **/

%macro Output_all_files(  );

  %local i v;

  %let i = 1;
  %let v = %scan( &file_list, &i, %str( ) );

  %do %until ( &v = );

    %Output_file( &v )

    %let i = %eval( &i + 1 );
    %let v = %scan( &file_list, &i, %str( ) );

  %end;

%mend Output_all_files;

/** End Macro Definition **/


/** Macro Output_file - Start Definition **/

%macro Output_file( data );

  filename fexport "D:\DCData\Libraries\Requests\Prog\2011\Gallagher_03_04_11\&data..csv" lrecl=3000;

  proc export data=&data
      outfile=fexport
      dbms=csv replace;

  run;

  filename fexport clear;

%mend Output_file;

/** End Macro Definition **/


** Export all files **;

%Output_all_files()

run;

signoff;
