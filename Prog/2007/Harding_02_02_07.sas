/**************************************************************************
 Program:  Harding_02_02_07.sas
 Library:  Requests
 Project:  
 Author:   K. Gentsch
 Created:  02/02/07
 Version:  
 Environment:  Windows with SAS/Connect
 
 Description:  Request from Quaneza Harding, Marshall Heights Community Development Organization, 
 to geocode client addresses and determine which are in the Casey target neighborhoods.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib( Requests );
%DCData_lib( RealProp );
%DCData_lib( General );

rsubmit;
/*Upload dataset to Alpha*/
proc upload status=no
	data=Requests.Addresses
	out=Work.Addresses;
run;

/*Run geocoding macro*/
%DC_geocode(
    data=Work.Addresses,
    out=Work.Addresses_geo,
    staddr=street1,
	zip=Zip_Code
  )
run;

/*Download dataset to PC*/
proc download status=no
	data=Work.Addresses_geo
	out=Addresses_geo;
run;
endrsubmit;

data requests.addresses_sel;
	set addresses_geo;
/*Hand-code unmatched ones*/
	if street1='215 Pebody Street, NE' then geo2000='11001009505';
	if street1='224 14th Place' then geo2000='11001008002';
	if street1='3670 Hayes Street, NE #201' then geo2000='11001009602';
	if street1='3729 Jay Street, NE #5' then geo2000='11001009602';
	if street1='3731 Jay Street, NE #3' then geo2000='11001009602';
	if street1='3739 Jay Street, NE #4' then geo2000='11001009602';
	if street1='3751 Jay Street, NE #1' then geo2000='11001009602';
	if street1='3755 Jay Street, NE #6' then geo2000='11001009602';
	if street1='3801 Jay Street, NE #1' then geo2000='11001009602';
	if street1='3803 Jay street, NE #4' then geo2000='11001009602';
	if street1='3811 Jay Street, NE #2' then geo2000='11001009602';
	if street1='3815 Jay Street, NE #2' then geo2000='11001009602';
	if street1='3817 Jay Street, NE #2' then geo2000='11001009602';
	if street1='3821 Jay Street, NE #8' then geo2000='11001009602';
	if street1='4412 Falls Terr., SE #4' then geo2000='11001009907';
	if street1='4903 Alabama Avenue, SE #4' then geo2000='11001009907';
/*Identify Casey target neighborhoods*/
	%Tr00_to_cnb03()
run;