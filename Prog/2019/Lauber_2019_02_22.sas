/**************************************************************************
 Program:  Lauber_2019_02_22.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  02/22/19
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description: Request for ACS data for DC AI from Daniel Lauber at
 Planning/Communications, dl@planningcommunications.com. 

 **B19001, B19001I, B19001D, B19001B, and B19001A files for the 2013-
 2017 ACS 5-year estimates crosswalked to the 2000 census
 tracts.**
  
 Data should be presented with cells as rows and tracts as
  columns, following the format in the [sample Excel
  file](https://urbanorg.box.com/s/oytdqumj7u5uvtzn953ahztmj0zp4aw1)
  that they provided.

 GitHub issue: Requests #40

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ACS )

** Remap ACS data to 2000 tracts **;

%Transform_geo_data(
    dat_ds_name=Acs.Acs_sf_2013_17_dc_tr10,
    dat_org_geo=Geo2010,
    dat_count_vars=
      /** Total **/
      B19001e1 B19001e2 B19001e3 B19001e4 B19001e5 B19001e6 B19001e7 B19001e8 B19001e9 
      B19001e10 B19001e11 B19001e12 B19001e13 B19001e14 B19001e15 B19001e16 B19001e17 
      /** White **/
      B19001Ae1 B19001Ae2 B19001Ae3 B19001Ae4 B19001Ae5 B19001Ae6 B19001Ae7 B19001Ae8 B19001Ae9 
      B19001Ae10 B19001Ae11 B19001Ae12 B19001Ae13 B19001Ae14 B19001Ae15 B19001Ae16 B19001Ae17 
      /** Black **/
      B19001Be1 B19001Be2 B19001Be3 B19001Be4 B19001Be5 B19001Be6 B19001Be7 B19001Be8 B19001Be9 
      B19001Be10 B19001Be11 B19001Be12 B19001Be13 B19001Be14 B19001Be15 B19001Be16 B19001Be17 
      /** Asian **/
      B19001De1 B19001De2 B19001De3 B19001De4 B19001De5 B19001De6 B19001De7 B19001De8 B19001De9 
      B19001De10 B19001De11 B19001De12 B19001De13 B19001De14 B19001De15 B19001De16 B19001De17 
      /** Hispanic **/
      B19001Ie1 B19001Ie2 B19001Ie3 B19001Ie4 B19001Ie5 B19001Ie6 B19001Ie7 B19001Ie8 B19001Ie9 
      B19001Ie10 B19001Ie11 B19001Ie12 B19001Ie13 B19001Ie14 B19001Ie15 B19001Ie16 B19001Ie17 
    ,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_tr10_tr00,
    wgt_org_geo=Geo2010,
    wgt_new_geo=Geo2000,
    wgt_id_vars=,
    wgt_wgt_var=PopWt,
    out_ds_name=Lauber_2019_02_22,
    out_ds_label=,
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=N,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )

%File_info( data=Lauber_2019_02_22 )

run;

** Create spreadsheet tables **;

/** Macro Table - Start Definition **/

%macro Table( varpre=, label= );

  proc tabulate data=Lauber_2019_02_22 format=10.0 noseps missing;
    class Geo2000;
    var &varpre.:;
    table 
      /** Rows **/
        &varpre.e1 &varpre.e2 &varpre.e3 &varpre.e4 &varpre.e5 &varpre.e6 &varpre.e7 &varpre.e8 &varpre.e9 
        &varpre.e10 &varpre.e11 &varpre.e12 &varpre.e13 &varpre.e14 &varpre.e15 &varpre.e16 &varpre.e17 
      ,
      /** Columns **/
      sum=' ' * Geo2000=' '
      / box="&label (&varpre)" rts=40
    ;

  run;

%mend Table;

/** End Macro Definition **/

%fdate()

ods tagsets.excelxp file="&_dcdata_default_path\Requests\Prog\2019\Lauber_2019_02_22.xls" style=Normal 
    options(sheet_interval='None' sheet_name='DC' default_column_width='20,12' embedded_footnotes='yes' );

ods listing close;

%Table( varpre=B19001, label=All HH )
%Table( varpre=B19001A, label=White )
%Table( varpre=B19001B, label=Black )
%Table( varpre=B19001D, label=Asian )

** Only include footnote after last table **;
footnote1 "Prepared by Urban-Greater DC (greaterdc.urban.org), &fdate..";

%Table( varpre=B19001I, label=Hispanic )

ods tagsets.excelxp close;
ods listing;

