/**************************************************************************
 Program:  IBP Voter Precinct Demographic Data.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  7/13/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Export some ACS data in VoterPre geography for IBP blog post. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

data acsVP;
	set acs.acs_2012_16_dc_sum_tr_vp12;

	keep voterpre2012 totpop_2012_16 mtotpop_2012_16 numhshlds_2012_16 mnumhshlds_2012_16

	/* Race vars */
	popwhitenonhispbridge_2012_16 mpopwhitenonhispbridge_2012_16
	pophisp_2012_16 mpophisp_2012_16
	popblacknonhispbridge_2012_16	mpopblacknonhispbridge_2012_16
	popasianpinonhispbridge_2012_16 mpopasianpinonhispbridge_2012_16

	/* Income */
	agghshldincome_2012_16 magghshldincome_2012_16
	hshldincunder15000_2012_16 mhshldincunder15000_2012_16
	hshldinc15000to34999_2012_16 mhshldinc15000to34999_2012_16
	hshldinc35000to49999_2012_16 mhshldinc35000to49999_2012_16
	hshldinc50000to74999_2012_16 mhshldinc50000to74999_2012_16
	hshldinc75000to99999_2012_16 mhshldinc75000to99999_2012_16
	hshldinc100000to124999_2012_16 mhshldinc100000to124999_2012_16
	hshldinc125000to149999_2012_16 mhshldinc125000to149999_2012_16
	hshldinc150000to199999_2012_16 mhshldinc150000to199999_2012_16
	hshldinc200000plus_2012_16 mhshldinc200000plus_2012_16

	/* Labor force */
	popincivlaborforce_2012_16 mpopincivlaborforce_2012_16
	popcivilianemployed_2012_16 mpopcivilianemployed_2012_16
	popunemployed_2012_16 mpopunemployed_2012_16

	;

run;

proc contents data = acsvp out= acsVPmeta; run;


proc export data = acsVP
	outfile = "&_dcdata_default_path.\Requests\Prog\2018\ACS_voterPre.csv"
	dbms = csv replace;
run;

proc export data = acsVPmeta
	outfile = "&_dcdata_default_path.\Requests\Prog\2018\ACS_voterPre_meta.csv"
	dbms = csv replace;
run;
