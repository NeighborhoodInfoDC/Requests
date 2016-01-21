/**************************************************************************
 Program:  DCHunger_FSPart_07_09_07.sas
 Library:  TANF
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9
 Environment:  Windows with SAS/Connect
 
 Description:  Tabulate FSP participants by ward and cluster in DC, 2006 and 2007

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( TANF );

rsubmit;

data fs_fulpartsum_wd02 fs_fulpartsum_cltr00;
	set TANF.fs_sum_wd02 (in=a keep = ward2002 fs_client_2007 fs_client_2006)
		TANF.fs_sum_cltr00 (in=b keep = cluster_tr2000 fs_client_2007 fs_client_2006
							where=(cluster_tr2000 ne '99'));

	if a then output fs_fulpartsum_wd02;
	else if b then output fs_fulpartsum_cltr00;
run;

proc download status=no
  inlib=work 
  outlib=tanf ;
  select fs_fulpartsum_wd02;
run;

proc download status=no
  inlib=work 
  outlib=tanf ;
  select fs_fulpartsum_cltr00;
run;

endrsubmit;

signoff;

filename fsp dde "Excel|D:\DCData\Libraries\TANF\Data\[FSPart_07_09_07.xls]ward!R5C1:R12C3"; 

data _null_;
	set tanf.fs_fulpartsum_wd02;
	file fsp;
	put ward2002 fs_client_2006 fs_client_2007;
	run;

filename fsp dde "Excel|D:\DCData\Libraries\TANF\Data\[FSPart_07_09_07.xls]cluster!R5C1:R43C3"; 

data _null_;
	set tanf.fs_fulpartsum_cltr00;
	file fsp;
	put cluster_tr2000 fs_client_2006 fs_client_2007;
	run;
