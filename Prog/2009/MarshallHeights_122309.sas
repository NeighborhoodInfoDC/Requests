/**************************************************************************
 Program:  MHCD_geocoding_122309.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Jcomey
 Created:  1/22/2008
 Updated:  12/23/09
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



rsubmit;
   
data mh_homebuyers_07_09_12_09_adj;
set Requests.MH_Homebuyers_07_09_12_09;
if street1 = "901 46th Street," then street1 = "901 46th Street NE";
else if street1= "3327 U Street, SE" then street1 = "3321 U Street SE";
run;
 
*Data statement is the file I'm uploading to the Alpha, and out statement is the final geocoded version
	Plus, you need to fill in the accurate field names for street, zip;

      %DC_geocode(

            data=MH_Homebuyers_07_09_12_09_adj, 

            out=MHCDO_geocode, 

            staddr=street1, 

            zip = zip_code, 

            id = Last_Name,

 
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

 

data Requests.MHCDO_geocode_casey_122309;
	set MHCDO_geocode;
*Identify Casey target neighborhoods;
	%Tr00_to_cnb03()
run;

**********Export geocoded file*******************;

filename fexport "K:\Metro\Ptatian\DCData\Libraries\Requests\Raw\MHCDO_geocode_casey_122309.csv" lrecl=2000;

proc export data=Requests.MHCDO_geocode_casey_122309
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;



