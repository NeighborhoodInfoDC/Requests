/**************************************************************************
 Program:  MH_Q_merge_casey_neighbor.sas
 Library:  Requests
 Project:  
 Author:   E.Guernsey
 Created:  02/02/07, edited 07/24/07
 Version:  
 Environment:  Windows with SAS/Connect
 
 Description:  Merge Casey Neighborhood onto geocoded files.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib( Requests );
%DCData_lib( RealProp );
%DCData_lib( General );
libname housing 'K:\Metro\PTatian\DCData\Libraries\Requests\Map\Marshall Heights 2008';
data housing.cycle2_geocode_casey;
	set housing.cycle2_geocode;
*Identify Casey target neighborhoods;
	%Tr00_to_cnb03()
run;

data housing.cycle3_geocode_casey;
	set housing.cycle3_geocode;
*Identify Casey target neighborhoods;
	%Tr00_to_cnb03()
run;


