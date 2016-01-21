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
If there's an apartment unit, it needs to be called "Unit: Number" and it needs before 
the quadrant. It's all in the address field.


/*First, convert MHCDO cycle 2 and cycle 3 Excel Files into SAS datasets -- 
calling it Cycle2HBC and Cycle3HBC ;


**************************************************************************/
/*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Schools )
%DCData_lib( RealProp )

libname housing "K:\Metro\Ptatian\DCData\Libraries\Requests\Map\Marshall Heights 2008";


data cycle2;
	set housing.Cycle2HBC;

run;

rsubmit;

        proc upload     status = no  

            inlib = Work 

            outlib = Work

            memtype = (data);

			***Insert file name;
            select cycle2;

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

            data=Work.cycle2, 

            out=Work.cycle2_geocode, 

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

            select  cycle2_geocode;

      run;

  endrsubmit;

 
**Then convert cycle2_geocode into a dbf for ArcMap;


