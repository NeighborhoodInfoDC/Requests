/**************************************************************************
 Program:  MHCD_geocoding.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Jcomey
 Created:  1/22/2008
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Reading in locations of homebuyers club participants, cycle 2

 Modifications:
Notes: 
Q needs the Casey neighborhoods attached to the file


/*First, convert MHCDO cycle 2 and cycle 3 Excel Files into SAS datasets -- 
calling it Cycle2HBC and Cycle3HBC ;


**************************************************************************/
/*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Schools )
%DCData_lib( RealProp )

%DCData_lib( RealProp );
%DCData_lib( General );

libname housing "K:\Metro\Ptatian\DCData\Libraries\Requests\Prog\2008";
libname raw "K:\Metro\Ptatian\DCData\Libraries\Requests\Raw";

data cycle4;
	set housing.MHCDO_cycle4;

run;

rsubmit;

        proc upload     status = no  

            inlib = Work 

            outlib = Work

            memtype = (data);

			***Insert file name;
            select cycle4;

        run; 
**Commented out because doesn't work -- Dave D working on;
      *%corrections (

            infile = Students, 

            correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt, 

            outfile = students_clean, 

            repl_var = stu_street);

 
*Data statement is the file I'm uploading to the Alpha, and out statement is the final geocoded version
	Plus, you need to fill in the accurate field names for street, zip;

      %DC_geocode(

            data=Work.cycle4, 

            out=Work.cycle4_geocode, 

            staddr=street_address, 

            zip = zip, 

            id = id,

 
/*keep parcel file all the same -- geocoding itself*/
            parcelfile = realprop.parcel_geocode_base_new, 

            unit_match=Y,

            geo_match=Y,

            block_match=Y,

            listunmatched=Y,

            debug=N);

      run;

*select the final geocoded file down from the Alpha;
      proc download status = no  

            inlib=work 

            outlib=housing 

            memtype=(data);

            select  cycle4_geocode;

      run;

  endrsubmit;

 

data housing.cycle4_geocode_casey;
	set housing.cycle4_geocode;
*Identify Casey target neighborhoods;
	%Tr00_to_cnb03()
run;

**********Export geocoded file*******************;

filename fexport "K:\Metro\Ptatian\DCData\Libraries\Requests\Raw\cycle4_geocode_casey.csv" lrecl=2000;

proc export data=housing.cycle4_geocode_casey
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;



