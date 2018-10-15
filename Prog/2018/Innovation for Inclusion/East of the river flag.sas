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
keep geo2010 EOR_tracts;
if not( missing( put( geo2010, $Tr10_eor. ) ) ) then EOR_tracts = 1;
else EOR_tracts = 0;

run;


proc export data=ACS_&geosuf
	outfile="&_dcdata_default_path.\Requests\Prog\2018\EastofRiver_flag.csv"
	dbms=csv replace;
	run;

