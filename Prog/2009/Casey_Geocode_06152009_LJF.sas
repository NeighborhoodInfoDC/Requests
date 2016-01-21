/**************************************************************************
 Program:  Casey_Geocode_06152009.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Freiman
 Created:  06/15/2009
 Updated:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Reading in locations to be assigned to 
a Casey neighborhood

 Modifications:
Notes: 

***************/

/*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( MHCDO )
%DCData_lib( RealProp )
%DCData_lib( General )
%DCData_lib( Requests )

rsubmit;

   proc upload     status = no  

            inlib = Requests

            outlib = Work

            memtype = (data);

            select addresses_06_09;
        run; 
       

      %DC_geocode(

            data=work.addresses_06_09, 

            out=work.addresses_06_09_geo,  

            staddr=StreetAddress, 

            zip = Zip, 

            id = personid,

 

            unit_match=Y,

            geo_match=Y,

            block_match=Y,

            listunmatched=Y,

            debug=N);

      run;

  proc freq data=addresses_06_09_geo (where=(StreetAddress NE ''));
  tables StreetAddress_std;
  run;

  proc freq data=addresses_06_09_geo (where=(StreetAddress NE ''));
  tables new_lesley;
  run;


data Requests.addresses_06_09_geo_casey;
	set addresses_06_09_geo;
*Identify Casey target neighborhoods;
	%Tr00_to_cnb03()
run;

      proc download status = no  

            inlib=work 

            outlib=Requests 

            memtype=(data);

            select addresses_06_09_geo_casey; 
      run;

	  endrsubmit; 
**********Export geocoded file*******************;

filename fexport "K:\Metro\Ptatian\DCData\Libraries\Requests\Raw\addresses_06_09_geo_casey.csv" lrecl=2000;

proc export data=Requests.addresses_06_09_geo_casey
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;



