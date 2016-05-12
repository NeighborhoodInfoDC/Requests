************************************************************************
* Program:  Format_DCFPI_06_15_05.sas
* Library:  NCDB
* Project:  DC Data Warehouse
* Author:   J.Fenderson
* Created:  07/11/05
* Version:  SAS 8.2
* Environment:  Windows
* 
* Description:  This program creates the notlt5f format
*  
* Modifications:
************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( NCDB )


proc format;
  picture notlt5f (round)
    . = '0' (noedit)
    low -< 0 = '<0' (noedit)
    0 = '0' (noedit)
    0 <-< 4.5 = '<5' (noedit)
    4.5 - high = '000000';

run;
