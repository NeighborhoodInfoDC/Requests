************************************************************************
* Program:  Thompson_10_20_04.sas
* Library:  Requests
* Project:  DC Data Warehouse
* Author:   P. Tatian
* Created:  10/20/04
* Version:  SAS 8.2
* Environment:  Windows
* 
* Description:  Check changes in tract 60.01 from 1980 - 2000 for
* Terri Thompson.
*
* Modifications:
************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

%Concat_lib( Ncdb2000, D:\Data\NCDB2000\Data )

proc print data=Ncdb2000.twt80_00;
  where geo80 = "11001006001";

run;
