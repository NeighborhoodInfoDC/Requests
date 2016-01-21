/**************************************************************************
 Program:  Download_IPUMS_WAWF.sas
 Library:  WAWF
 Project:  WAWF
 Author:   J. Fenderson
 Created:  06/22/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Download revised Ipums_2000_tables from WAWF Alpha library
 to my WAWF library on my PC.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;


** Define libraries **;
%DCData_lib( NCDB )

rsubmit;

** Download data **;

proc download status=no
  data=NCDB.Twt80_00_dc
  out=NCDB.Twt80_00_dc1 ;
	
run;

endrsubmit;

signoff;

