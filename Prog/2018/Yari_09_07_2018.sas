/**************************************************************************
 Program:  Yari_09_07_2018.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  9/17/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Request from Yari to geocode a list of addresses to Ward.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Mar )

/* Import raw addresses */
%let rawpath = &_dcdata_default_path.\Requests\Prog\2018\;
%let filename = addresses_yari.csv;

filename fimport "&rawpath.&filename." lrecl=2000;
data raw_address;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

	informat ID $7.;
	informat address $50.;
	informat unit $20.;
	informat zip $5.;

	input  
	ID $
	address $
	unit $
	zip $ ;

	if id = "na_2406" then address = "4545 MacArthur blvd nw";
	if id = "na_2450" then address = "4800 c st se";
	if id = "na_2493" then address = "4455 Connecticut Ave NW";
	if id = "na_2511" then address = "2710 knox st se";
	if id = "na_2515" then address = "560 n st sw";
	if id = "na_2535" then address = "306 oklahoma ave ne";
	if id = "na_2541" then address = "5543 chillum pl ne";
	if id = "na_2545" then address = "2819 12th st ne";
	if id = "na_2546" then address = "3911 garrison st nw";

run;


%DC_mar_geocode(
  debug=n,
  listunmatched=N,
  data = raw_address,
  staddr = Address,
  zip = zip,
  out = geocoded
);


data finalgeo;
	set geocoded;
	if Ward2012 = " " then do;
		if zip = "20001" then Ward2012 = "6";
		if zip = "20005" then Ward2012 = "2";
		if zip = "20006" then Ward2012 = "2";
		if zip = "20011" then Ward2012 = "5";
		if zip = "20016" then Ward2012 = "3";
		if zip = "20017" then Ward2012 = "5";
		if zip = "20019" then Ward2012 = "7";
		if zip = "20024" then Ward2012 = "6";
		if zip = "20032" then Ward2012 = "8";
		geocoded = 0;
	end; 

	if id = "na_2491"  then geocoded = 0;
	if geocoded ^= 0 then geocoded = 1;

	keep id address unit zip ward2012 geocoded;

run;

proc export data = finalgeo
	outfile = "&_dcdata_default_path.\Requests\Prog\2018\yari_geocoded.csv"
	dbms = csv replace;
run;


/* End of Program */
