/**************************************************************************
 Program:  101_Faith_based_landowners.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  11/17/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  101
 
 Description:  Export data with faith-based property owners including
 total parcel size, building lot size, "unused" land, and zoning.
 
 Uses 
  - Zoning Boundaries (Zoning Regulations of 2016) downloaded from opendata.dc.gov
    (https://opendata.dc.gov/datasets/fd7c1d709bca4a9295b6fa5ec7d62446_32/explore?location=38.893674%2C-77.014456%2C11.82)
  - Proc Gproject to convert MD state plan to WGS coordinates
    (https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grmapref/n0h81palrr0ucqn11g9r0y3incml.htm)
  - Proc Mapimport to import zoning shapefile
    (https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grmapref/p0qsj9oazola04n10usle21dvk67.htm)
  - Proc Ginside to perform spatial merge of parcel coordinates with zoning polygons
    (https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grmapref/p1frskc294tbapn1wwumr6m4d3ka.htm)

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )
%DCData_lib( MAR )

** Review geo coordinate entries for Proc Gproject **;

proc print data=sashelp.proj4def;
  where upcase( desc ) contains "MARYLAND";
  id name;
  var desc;
run;


proc print data=sashelp.proj4def;
  where upcase( desc ) contains "WGS 84" and upcase( desc ) contains "MERCATOR";
  id name;
  var desc;
run;

** Get Cama data and calculate Bldg_footprint **;

data Bldg_footprint_bldg;

  set Realprop.Cama_building (keep=ssl gba stories);
  
  if gba <= 0 then gba = .;
  if stories <= 0 then stories = .;
  
  if stories > 0 then Bldg_footprint = gba / stories;
  else Bldg_footprint = gba;
  
run;

%File_info( data=Bldg_footprint_bldg, contents=n, printobs=0 )


proc summary data=Bldg_footprint_bldg;
  by ssl;
  var Bldg_footprint;
  output out=Bldg_footprint_ssl sum=;
run;
  
** Get data for parcels owned by faith-baseed entities **;

data Faith_based_landowners_mdsp;

  merge
    Realprop.Parcel_base 
      (keep=ssl premiseadd in_last_ownerpt ui_proptype landarea
       where=(in_last_ownerpt)
       in=in1)
    Realprop.Parcel_geo
      (keep=ssl x_coord y_coord ward2022 cluster2017 anc2023
       rename=(x_coord=x y_coord=y))
    Realprop.Parcel_base_who_owns 
      (keep=ssl ownername_full ownercat
       where=(ownercat='100')
       in=in2)
    Bldg_footprint_ssl
      (keep=ssl Bldg_footprint _freq_
       rename=(_freq_=Num_buildings));
  by ssl;
  
  if in1 and in2;
  
  if landarea <= 0 then landarea = .;
  
  if Bldg_footprint > 0 and landarea >= Bldg_footprint then Unused_land = landarea - Bldg_footprint;
  
  format Landarea Bldg_footprint Unused_land comma12.0;
  
  informat _all_ ;
  
  label
    Num_buildings = "Number of buildings on parcel"
    Bldg_footprint = "Building footprint (sq feet, calculated)"
    Unused_land = "Total amount of unused land (sq feet, calculated)";
    
  drop in_last_ownerpt;

run;

%File_info( data=Faith_based_landowners_mdsp, printobs=5 )


** Reproject MD state plane coordinates to WGS 84 to align with zoning map shapefile **;

proc gproject data=Faith_based_landowners_mdsp out=Faith_based_landowners_wgs84
  from="EPSG:3559" to="EPSG:3857" dupok;
  id x y;
run;

%File_info( data=Faith_based_landowners_wgs84, printobs=5 )


** Import zoning map shapefile **;

proc mapimport out=Zoning_map create_id_ contents
  datafile="&_dcdata_r_path\OCTO\Maps\Zoning_Boundaries_(Zoning_Regulations_of_2016).shp";
run;

%File_info( data=Zoning_map, printobs=5 )


** Join zoning map with parcel coordinates **;

goptions reset=global border;

proc ginside includeborder dropmapvars
  data=Faith_based_landowners_wgs84 
  map=Zoning_map
  out=Faith_based_landowners_full;
  id _id_ zoning zone_descr zoning_web;
run;
 
%File_info( data=Faith_based_landowners_full, printobs=5, freqvars=ui_proptype zoning )

proc univariate data=Faith_based_landowners_full plot nextrobs=20;
  var landarea bldg_footprint unused_land;
  id ssl;
run;

run;


**** Export data ****;

** Reorder fields for export **;

data Faith_based_landowners;

  retain 
    Ownercat SSL ui_proptype zoning zone_descr zoning_web Premiseadd Ownername_full Num_buildings Landarea Bldg_footprint Unused_land
    Ward2022 Anc2023 Cluster2017;

  set Faith_based_landowners_full (drop=x y _ONBORDER_ _ID_);
  
  format Cluster2017 $clus17f.;
  
  label
    premiseadd = 'Property street address'
    zoning = 'Zoning designation'
    zone_descr = 'Zoning description' 
    zoning_web = 'Link to zoning website';
  
run;


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

  ods tagsets.excelxp file="&out_folder\Data dictionary.xls" style=Normal 
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
%let out_folder = &_dcdata_default_path\Requests\Raw\2025\Faith_based_landowners;

** Export individual data sets **;
%Export( data=Faith_based_landowners )

** Create data dictionary **;
%Dictionary()

run;
