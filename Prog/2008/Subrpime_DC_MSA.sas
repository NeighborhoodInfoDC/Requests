**************************************************************************
Program: Subprime_DC_MSA.sas
Library: requests
Project: NighborhoodInfo DC Technical Assistance: Prepared for Emily Salomon
Author: Lesley Freiman
Created: 8/15/2008
Version: SAS 9.1
Environment: Windows with SAS/Connect
Description: percent subprime loans by tract in DC MSA (2004, 2005)
Modifications:

**************************************************************************/;


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

*/ Defines libraries /*;
%DCData_lib( Requests );
%DCData_lib( General );

rsubmit;

libname subprime "DISK$USER05:[DPLACE.HMDA]";

data hmda_geoscale;
set subprime.DPLEX_HMDA_SUMMARY_04 (keep= MSAPMA99 geoscaleid stfid NumSubprimeConvOrigHomePurch 
				NumSubprimeConvOrigRefin NumConvMrtgOrigHomePurch
				NumConvMrtgOrigRefin); 

run;

data hmda_DCMet_vars;
set hmda_geoscale;
where MSAPMA99 = '8840' and geoscaleid = '1';

subp_ln = (NumSubprimeConvOrigHomePurch + NumSubprimeConvOrigRefin);
	label subp_ln = "# Subprime Conventional Loans";
	
	total_ln = (NumConvMrtgOrigHomePurch + NumConvMrtgOrigRefin);
	label total_ln ="# Total Conventional Loans";

	p_subp = (subp_ln / total_ln) if total_ln!=0;
	else p_subp = 1;
	label p_subp ="% of Total Loans that are Suprime";
	run;

	rsubmit;
proc download inlib=work outlib=requests;
select hmda_CDMet_vars;
run;

endrsubmit;
