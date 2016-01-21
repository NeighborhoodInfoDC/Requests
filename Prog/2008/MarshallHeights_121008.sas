/**************************************************************************
 Program:  MHCD_geocoding_070808.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Jcomey
 Created:  1/22/2008
 Updated:  12/11/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Reading in locations of Marshall Heights participants to be assigned to 
a Casey neighborhood

 Modifications:
Notes: 



/*First, convert Marshall Heights file into SAS dataset -- 
calling it MH_homebuyers ;


**************************************************************************/
/*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );
%DCData_lib( Requests );


data MHCDO;
	set Requests.MHCDO_12_10_2008;

run;

rsubmit;

        proc upload     status = no  

            inlib = Work 

            outlib = Work

            memtype = (data);

			***Insert file name;
            select MHCDO;

        run; 
 
*Data statement is the file I'm uploading to the Alpha, and out statement is the final geocoded version
	Plus, you need to fill in the accurate field names for street, zip;

      %DC_geocode(

            data=Work.MHCDO, 

            out=Work.MHCDO_geocode, 

            staddr=street_address, 

            zip = zip, 

            id = id,

 
/*keep parcel file all the same -- geocoding itself*/
/*           parcelfile = realprop.parcel_geocode_base_new, [We used to include this code, no longer]*/

            unit_match=Y,

            geo_match=Y,

            block_match=Y,

            listunmatched=Y,

            debug=N);

      run;

*select the final geocoded file down from the Alpha;
      proc download status = no  

            inlib=work 

            outlib=work 

            memtype=(data);

            select  MHCDO_geocode;

      run;

  endrsubmit;

 

data Requests.MHCDO_geocode_casey_121008;
	set MHCDO_geocode;
*Identify Casey target neighborhoods;
	%Tr00_to_cnb03()
run;

**********Export geocoded file*******************;

filename fexport "K:\Metro\Ptatian\DCData\Libraries\Requests\Raw\MHCDO_geocode_casey_121008.csv" lrecl=2000;

proc export data=Requests.MHCDO_geocode_casey_121008
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;



