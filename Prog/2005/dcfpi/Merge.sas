/************************************************************************
* Program:  Merge.sas
* Library:  NCDB
* Project:  DC Data Warehouse
* Authors:  Julie Fenderson
* Created:  6/20/05
* Version:  SAS 8.12
* Environment:  Windows
* Description:  This program merges the tanf & foodstamp data with the 
*				Washington, D.C. NCDB data. 
*Modifications: 07/11/05  moved code that exports to csv file to a
*				separate program -- JF
************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( NCDB )

proc sort data=Ncdb.dc_tanf_fs_final;
by geo2000;
run;

proc sort data=Ncdb.ncdb_lf_2000_dc;
by geo2000;
run;
*merging TANF/FS & Income Eligibility datasets;
data NCDB.dc_tanf_fs_inc_final;
 merge Ncdb.dc_tanf_fs_final Ncdb.ncdb_lf_2000_dc;
 by geo2000;
 format tcount notlt5f. fscount notlt5f.;
 label fscount="Number of Households Receiving Food Stamps";
 label tcount="Number of Households Receiving TANF";
run;


