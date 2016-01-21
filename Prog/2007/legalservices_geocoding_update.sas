/**************************************************************************
 Program:  legalservices_geocoding.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Jcomey
 Created:  12/04/2007
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Reading in locations of legal service clinics in DC for DC Bar Foundation

 Modifications:
Notes: 
If there's an apartment unit, it needs to be called "Unit: Number" and it needs before 
the quadrant. It's all in the address field.


/*First, convert DC Bar's Excel File into a SAS dataset -- latest 
is DCBAR_Provider and program list.7.07 -- calling it Legalservices_0108 ;


**************************************************************************/
/*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Schools )
%DCData_lib( RealProp )

libname legal "K:\Metro\Ptatian\DCData\Libraries\Requests\Raw";


data legal;
	set legal.Legalservices_0108;

run;

rsubmit;

        proc upload     status = no  

            inlib = Work 

            outlib = Work

            memtype = (data);

			***Insert file name;
            select legal;

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

            data=Work.legal, 

            out=Work.legal_geocode2, 

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

            outlib=legal 

            memtype=(data);

            select  legal_geocode2;

      run;

  endrsubmit;

 
**Then convert legalgeocode_2 into a dbf for ArcMap;

 
