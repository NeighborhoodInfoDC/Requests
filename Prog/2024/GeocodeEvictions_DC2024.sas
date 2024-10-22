/**************************************************************************
 Program:  {GeocodeEvictions_DC2024}.sas
 Library:  {Requests}
 Project:  Urban-Greater DC
 Author:   Rodrigo Garcia
 Created:  10/21/24
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  Issue #87
  
 Description: Geocoding Eviction Data from OTA

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
  %DCData_lib( Requests )
  %DCData_lib( MAR )

**{Start program here}**;
**'Proc import' and 'proc print' data import csv file into SAS**;
proc import datafile="\\SAS1\dcdata\Libraries\Requests\Raw\2024\FY24DetailedData(records).csv"
        out=evictions
        dbms=csv
        replace;

     getnames=yes;

run;

proc print data=work.evictions;
run;

**Creates new data set with new street_address and zip_char variables **;
data evictions_addresses
input street_number _DATA_ street _DATA_ type _DATA_ quadrant _DATA_;
  street_address = catx( " ", street_number, street, type, quadrant );


  if not( missing( zip ) ) then zip_char = put( zip, z5.0 );

proc print data=work.evictions_addresses;
run;

**Geocoding Macro**;
%DC_mar_geocode(
data = {evictions_addresses},
staddr = street_address,
zip = zip_char,
out = {GeocodedEvictionsData}
)

**Macro used to finalize and save dataset**;
  %Finalize_data_set( 
    data={GeocodedEvictionsData},
    out={work.evictions},
    outlib=Requests,
    label="DC evictions",
    sortby={Case# variable},
    /** Metadata parameters **/
    revisions=%str(New file.)
  )
