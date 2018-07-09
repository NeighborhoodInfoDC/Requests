/**************************************************************************
 Program:  Cost_burden_inner_2005_2016.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/30/18
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Calculate cost burdens for top 20 metro areas.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )

%global file_list;

%let file_list = ;

/** Macro Read - Start Definition **/

%macro Read( year= );

  %local year2 fname;
  
  %let year2 = %substr( &year, 3, 2 );
  
  %if &year = 2005 or &year = 2006 %then 
    %let fname = ACS_&year2._EST_B25106;
  %else
    %let fname = ACS_&year2._1YR_B25106; 
    
  %let file_list = &file_list &fname;

  filename fin "&_dcdata_r_path\Requests\Raw\Washington region feature\Inner region\&fname\&fname._with_ann.csv" lrecl=2000;

  data &fname;
  
    retain Year &year; 

    infile fin dsd stopover firstobs=3;

    input
      GEO_id : $20.
      GEO_id2 : $8. 
      GEO_display_label : $200.
      HD01_VD01
      HD02_VD01
      HD01_VD02
      HD02_VD02
      HD01_VD03
      HD02_VD03
      HD01_VD04
      HD02_VD04
      HD01_VD05
      HD02_VD05
      HD01_VD06
      HD02_VD06
      HD01_VD07
      HD02_VD07
      HD01_VD08
      HD02_VD08
      HD01_VD09
      HD02_VD09
      HD01_VD10
      HD02_VD10
      HD01_VD11
      HD02_VD11
      HD01_VD12
      HD02_VD12
      HD01_VD13
      HD02_VD13
      HD01_VD14
      HD02_VD14
      HD01_VD15
      HD02_VD15
      HD01_VD16
      HD02_VD16
      HD01_VD17
      HD02_VD17
      HD01_VD18
      HD02_VD18
      HD01_VD19
      HD02_VD19
      HD01_VD20
      HD02_VD20
      HD01_VD21
      HD02_VD21
      HD01_VD22
      HD02_VD22
      HD01_VD23
      HD02_VD23
      HD01_VD24
      HD02_VD24
      HD01_VD25
      HD02_VD25
      HD01_VD26
      HD02_VD26
      HD01_VD27
      HD02_VD27
      HD01_VD28
      HD02_VD28
      HD01_VD29
      HD02_VD29
      HD01_VD30
      HD02_VD30
      HD01_VD31
      HD02_VD31
      HD01_VD32
      HD02_VD32
      HD01_VD33
      HD02_VD33
      HD01_VD34
      HD02_VD34
      HD01_VD35
      HD02_VD35
      HD01_VD36
      HD02_VD36
      HD01_VD37
      HD02_VD37
      HD01_VD38
      HD02_VD38
      HD01_VD39
      HD02_VD39
      HD01_VD40
      HD02_VD40
      HD01_VD41
      HD02_VD41
      HD01_VD42
      HD02_VD42
      HD01_VD43
      HD02_VD43
      HD01_VD44
      HD02_VD44
      HD01_VD45
      HD02_VD45
      HD01_VD46
      HD02_VD46;  

    ** Cost burden **;
    
    Owner_occ_total = HD01_VD02;
    Owner_occ_30p = sum( HD01_VD06, HD01_VD10, HD01_VD14, HD01_VD18, HD01_VD22 );
    
    Renter_occ_total = HD01_VD24;
    Renter_occ_30p = sum( HD01_VD28, HD01_VD32, HD01_VD36, HD01_VD40, HD01_VD44 );

    All_occ_total = Owner_occ_total + Renter_occ_total;
    All_occ_30p = Owner_occ_30p+ Renter_occ_30p;
    
    drop hd01_: hd02_: ;
    
  run;
  
  filename fin clear;
  
  %File_info( data=&fname, printobs=10, printchar=y )

%mend Read;

/** End Macro Definition **/


%Read( year=2005 )
%Read( year=2006 )
%Read( year=2007 )
%Read( year=2008 )
%Read( year=2009 )
%Read( year=2010 )
%Read( year=2011 )
%Read( year=2012 )
%Read( year=2013 )
%Read( year=2014 )
%Read( year=2015 )
%Read( year=2016 )

** Combine all data sets **;

data Cost_burden_inner_2005_2016;

  set &file_list; 
  by year geo_id2;

run;

%File_info( data=Cost_burden_inner_2005_2016, printobs=0, freqvars=year Geo_display_label )


/** Macro Table - Start Definition **/

%macro Table( varpre=, select= );

  ods tagsets.excelxp options( sheet_name="&varpre" );
  
  title2 " ";
  title3 "Pct %lowcase(&varpre) households with housing cost burden (30%+), Inner Region";
  footnote1 "Source: American Community Survey";
  footnote2 "Note: Data are not available for Fairfax city and Falls church city.";

  proc tabulate data=Cost_burden_inner_2005_2016 format=comma12.1 noseps missing order=data;
    class Year Geo_display_label;
    var &varpre._occ_total &varpre._occ_30p;
    table 
      /** Rows **/
      Geo_display_label=' ' all="Inner region",
      /** Columns **/
      &varpre._occ_30p=' ' * pctsum<&varpre._occ_total>=' ' * Year=' '
      / condense rts=65;
  run;
  
  title2;
  footnote1;

%mend Table;

/** End Macro Definition **/

options missing='-';

ods tagsets.excelxp 
  file="&_dcdata_default_path\Requests\Prog\2018\Washington region feature\Cost_burden_inner_2005_2016.xls" 
  style=Normal 
  options(sheet_interval='Proc' autofit_height='Yes' embedded_titles='Yes' embed_titles_once='Yes'
    embedded_footnotes='Yes' embed_footers_once='Yes' default_column_width='40' );

ods listing close;

%Table( varpre=Renter )
%Table( varpre=Owner )
%Table( varpre=All )

ods listing;
ods tagsets.excelxp close;
