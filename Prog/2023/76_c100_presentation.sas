/**************************************************************************
 Program:  76_c100_presentation.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  02/09/23
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  76
 
 Description:  Pull demographic data for C100 presentation. 
 Black population change by ward.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )

** Ward data **;

data Ward;

  merge
    Ncdb.Ncdb_sum_wd22 (keep=ward2022 totpop_: popblacknonhispbridge_:)
    Ncdb.Ncdb_sum_2010_wd22 (keep=ward2022 totpop_: popblacknonhispbridge_:)
    Ncdb.Ncdb_sum_2020_wd22 (keep=ward2022 totpop_: popblacknonhispbridge_:);
  by ward2022;
  
  popblacknh_1980_1990 = popblacknonhispbridge_1990 - popblacknonhispbridge_1980;
  popblacknh_1990_2000 = popblacknonhispbridge_2000 - popblacknonhispbridge_1990;
  popblacknh_2000_2010 = popblacknonhispbridge_2010 - popblacknonhispbridge_2000;
  popblacknh_2010_2020 = popblacknonhispbridge_2020 - popblacknonhispbridge_2010;
  
  popblacknh_1980_2020 = popblacknonhispbridge_2020 - popblacknonhispbridge_1980;

run;

proc print data=Ward;
  id ward2022;
  var totpop_: popblacknonhispbridge_: ;
  sum totpop_: popblacknonhispbridge_: ;
  format totpop_: popblacknonhispbridge_: comma10.0;
run;

proc print data=Ward;
  id ward2022;
  var popblacknh_: ;
  sum popblacknh_: ;
  format popblacknh_: comma10.0;
run;

filename fexport "&_dcdata_default_path\Requests\Raw\2023\76_c100_presentation.csv" lrecl=2000;

proc export data=Ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

