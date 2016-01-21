/**************************************************************************
 Program:  Geocode_06152009_clean1.sas
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

            select cleaned_06_09;
        run; 
       

      %DC_geocode(

            data=work.cleaned_06_09, 

            out=work.cleaned_06_09_geo,  

            staddr=Street1, 

            zip = Zip, 

 

            unit_match=Y,

            geo_match=Y,

            block_match=Y,

            listunmatched=Y,

            debug=N);

      run;



      proc download status = no  

            inlib=work 

            outlib=Requests 

            memtype=(data);

            select cleaned_06_09_geo; 
      run;

	  endrsubmit; 
**********Export geocoded file*******************;

filename fexport "D:\DCData\Libraries\Requests\Raw\cleaned_06_09_geo.csv" lrecl=2000;

proc export data=Requests.cleaned_06_09_geo
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;





