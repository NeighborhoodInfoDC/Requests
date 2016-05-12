/************************************************************************
* Program:  DownloadNCDBfromAlpha.sas
* Library:  TANF
* Project:  DC Data Warehouse
* Authors:  Julie Fenderson
* Created:  6/20/05
* Version:  SAS 8.12
* Environment:  Windows
* Description:  This program downloads variables from the NCDB  
*
* Modifications: 
*
************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

signon;
rsubmit;

*Defines NCDB directory on the Alpha (contains DC Data)*;
libname ncdb 'DISK$S_USER02:[DCDATA.NCDB.DATA]';

options compress=yes;

**Select variables from the NCDB data (top two rows are geography related);
%let fromncdb =
	GEO2000 thy0100 thy0150 thy0200 thy0250 thy0300 thy0350 thy0400 
thy0450 thy0500 thy0600 thy0750 thy01000 thy01250 thy01500 thy02000 
thy0m200;

data NCDB_LF_2000_DC;
	set ncdb.NCDB_LF_2000_DC ( keep=&fromncdb. );
run;

proc download data=NCDB_LF_2000_DC out=TANF.NCDB_LF_2000_DC (label="Extract of NCDB 2000 DC Data");
run;

endrsubmit;
signoff;

data tanf_2005_01_case;
 set tanf.tanf_2005_01_case;
 tcount=1;
 run; 

data fs_2005_01_case;
 set tanf.fs_2005_01_case;
 fscount=1;
 run; 

proc sort data=tanf_2005_01_case;
by geo1980;
run;

proc summary data=tanf_2005_01_case;
var tcount;
by geo1980;
output out=ncdb_tcount_dc sum=tcount;
run;

proc sort data=fs_2005_01_case;
by geo1980;
run;

proc summary data=fs_2005_01_case;
var fscount;
by geo1980;
output out=ncdb_fscount_dc sum=fscount;
run;

proc sort data=ncdb_tcount_dc;
by geo1980;
run;

proc sort data=ncdb_fscount_dc;
by geo1980;
run;
*merging two count datasets together;
data tanf.tanf_fscount (drop=_type_ _freq_);
 merge ncdb_fscount_dc ncdb_tcount_dc;
 by geo1980;
 run;
