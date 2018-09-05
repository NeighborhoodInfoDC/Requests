/**************************************************************************
 Program:  Dhcd_2018_09_04.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  09/05/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  List of all the programs that fund affordable housing in DC. 
 Request from DHCD, 9/4/2018.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( PresCat )

%fdate()

options missing='-';

ods csvall body="&_dcdata_default_path\Requests\Prog\2018\Dhcd_2018_09_04.csv";

proc tabulate data=PresCat.Subsidy format=comma12.0 noseps missing;
  class program;
  var units_assist;
  table 
    /** Rows **/
    program=' ',
    /** Columns **/
    n='Projects' sum='Assisted units'*units_assist=' '
  ;
  footnote1 height=9pt "Prepared by Urban-Greater DC (greaterdc.urban.org) &fdate..";
run;

ods csvall close;
