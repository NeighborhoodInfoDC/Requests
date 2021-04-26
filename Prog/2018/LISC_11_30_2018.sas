/**************************************************************************
 Program:  LISC_11_30_2018.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  11/30/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Request from LISC for data on rental properties with 4-20 units
			   by ward and neighborhood cluster. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ACS )


%macro rtunits (geo,geosuf);
data rtunits_&geosuf.;
	set acs.acs_2012_16_dc_sum_tr_&geosuf.;

	keep &geo. NumRtOHU5to19u_2012_16 mNumRtOHU5to19u_2012_16;

	/* Combined 5-9 and 10-19 vars */
	NumRtOHU5to19u_2012_16 = sum(of NumRtOHU5to9u_2012_16  NumRtOHU10to19u_2012_16);

	/* Calculate new MOE */
	mNumRtOHU5to19u_2012_16 = %moe_sum( var=mNumRtOHU5to9u_2012_16  mNumRtOHU10to19u_2012_16 );

	label NumRtOHU5to19u_2012_16 = "Renter-occupied housing units in structure: 5 to 19 units, 2012-16"
		  mNumRtOHU5to19u_2012_16 = "Renter-occupied housing units in structure: 5 to 19 units, 2012-16, MOE";

run;

proc export data = rtunits_&geosuf.
	outfile = "&_dcdata_default_path.\Requests\Prog\2018\lisc_units_&geosuf..csv"
	dbms = csv replace;
run;

%mend rtunits;
%rtunits (cluster2017,cl17);
%rtunits (ward2012,wd12);



/* End of Program */
