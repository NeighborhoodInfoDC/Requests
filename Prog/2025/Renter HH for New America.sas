/**************************************************************************
 Program:  Renter HH for New America.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  10/15/2025
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  95

 Description:  Export data for ANCs for GGWash for Local Data for Equitable Communities project

 Modifications: Based on P. Tatian 92_Real_property_data.sas
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS, local=n )

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

%macro Dictionary( );

  %local desc;

  ** Start writing to XML workbook **;
    
  ods listing close;

  ods tagsets.excelxp file="&out_folder\Data dictionary Renters Ngh Cluster.xls" style=Normal 
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
      title3 height=10pt "Prepared by Urban-Greater DC on %left(%qsysfunc(date(),worddate.)).";
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
** The CSV files are large, so the data are saved to the users's local drive rather than SAS1 **;
%let out_folder = &_dcdata_l_path\Requests\Raw\2025;

data acs_2019_23_dc_sum_tr_cl17;

	set acs.acs_2019_23_dc_sum_tr_cl17;

	keep cluster2017 cluster2017_name cluster2017_num
	numrenterhsgunits_2019_23 mnumrenterhsgunits_2019_23
	numrenteroccupiedhu_2019_23 mnumrenteroccupiedhu_2019_23
	rentcstbrdencalc_2019_23 mrentcstbrdencalc_2019_23  
	rentsvrecstbrden_2019_23 mrentsvrecstbrden_2019_23
	rentcstbrden_2019_23 mrentcstbrden_2019_23
	numoccupiedhsgunits_2019_23 mnumoccupiedhsgunits_2019_23;


cluster2017_name=put(Cluster2017, $clus17b.);
cluster2017_num=put(Cluster2017, $clus17g.);
label cluster2017_name='Neighborhood Cluster Name (2017)'
	  cluster2017_num='Neighborhood Cluster Number and Name (2017)';
	run;

** Export individual data sets **;
%Export( data=acs_2019_23_dc_sum_tr_cl17 )



** Create data dictionary **;
%Dictionary()

run;
