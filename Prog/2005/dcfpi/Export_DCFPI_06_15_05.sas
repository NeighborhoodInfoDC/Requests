************************************************************************
* Program:  Export_DCFPI_06_15_05.sas
* Library:  NCDB
* Project:  DC Data Warehouse
* Author:   J.Fenderson
* Created:  07/11/05
* Version:  SAS 8.2
* Environment:  Windows
* 
* Description:  This program exports the final file containing the 
*  				Washington, D.C. tanf, foodstamp, and NCDB data to a
*				csv file.
* Modifications:
************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( NCDB )

proc freq data=NCDB.dc_tanf_fs_inc_final;
	tables tcount fscount;
	format tcount notlt5f. fscount notlt5f.;
	run;

filename fexport "D:\DCData\Libraries\NCDB\Prog\DCFPI_06_15_05.csv" lrecl=256;

proc export data=NCDB.dc_tanf_fs_inc_final
    outfile=fexport
    dbms=csv replace;

run;
