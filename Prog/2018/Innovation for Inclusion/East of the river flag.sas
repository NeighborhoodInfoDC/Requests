/**************************************************************************
 Program:  Commuting time to work.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng 
 Created:  9/19/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

%let _years=2012_16;

data EOSflag;
set ACS.Acs_2012_16_dc_sum_tr_tr10;
keep geo2010 geoid EOR_tracts;
EOR_tracts = put( geo2010, $Tr1eor. );
geoid = geo2010;
run;

proc export data=EOSflag
	outfile="&_dcdata_default_path.\Requests\Prog\2018\Innovation for Inclusion\EastofRiver_flag.csv"
	dbms=csv replace;
	run;

