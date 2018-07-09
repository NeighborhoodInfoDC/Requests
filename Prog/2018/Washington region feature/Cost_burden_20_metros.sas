/**************************************************************************
 Program:  Cost_burden_20_metros.sas
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

filename fin "&_dcdata_r_path\Requests\Raw\Washington region feature\ACS_16_5YR_B25106\ACS_16_5YR_B25106_with_ann.csv" lrecl=2000;

data Cost_burden_20_metros;

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
  
  if geo_id2 ~= '47900' then do;
    Renter_occ_total_no_was = Renter_occ_total;
    Renter_occ_30p_no_was = Renter_occ_30p;
    Owner_occ_total_no_was = Owner_occ_total;
    Owner_occ_30p_no_was = Owner_occ_30p;
    All_occ_total_no_was = All_occ_total;
    All_occ_30p_no_was = All_occ_30p;
  end;
  
run;


/** Macro Table - Start Definition **/

%macro Table( varpre=, select= );

  ods tagsets.excelxp options( sheet_name="&varpre Top &select" );
  
  title2 " ";
  title3 "Pct %lowcase(&varpre) households with housing cost burden (30%+), &select largest MSAs, 2012-16";
  footnote1 "Source: American Community Survey";

  proc tabulate data=Cost_burden_20_metros format=comma12.1 noseps missing order=data;
    %if &select = 10 %then %do;
      where geo_id2 in ( '35620', '31080', '16980', '19100', '26420', '47900', '33100', '37980', '12060', '14460' );
    %end;
    class Geo_display_label;
    var &varpre._occ_total &varpre._occ_30p &varpre._occ_total_no_was &varpre._occ_30p_no_was;
    table 
      /** Rows **/
      Geo_display_label=' ' all="&select Largest MSAs",
      /** Columns **/
      &varpre._occ_30p=' ' * pctsum<&varpre._occ_total>='With Washington'
      &varpre._occ_30p_no_was=' ' * pctsum<&varpre._occ_total_no_was>='Without Washington'
      / condense rts=65;
  run;
  
  title2;
  footnote1;

%mend Table;

/** End Macro Definition **/

options missing='-';

ods tagsets.excelxp 
  file="&_dcdata_default_path\Requests\Prog\2018\Washington region feature\Cost_burden_20_metros.xls" 
  style=Normal 
  options(sheet_interval='Proc' autofit_height='Yes' embedded_titles='Yes' embed_titles_once='Yes'
    embedded_footnotes='Yes' embed_footers_once='Yes' default_column_width='60' );

ods listing close;

%Table( varpre=Renter, select=10 )
%Table( varpre=Renter, select=20 )
%Table( varpre=Owner, select=10 )
%Table( varpre=Owner, select=20 )
%Table( varpre=All, select=10 )
%Table( varpre=All, select=20 )

ods listing;
ods tagsets.excelxp close;
