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

**'Proc import' and 'proc print' data import csv file into SAS**;
proc import datafile="\\SAS1\dcdata\Libraries\Requests\Raw\2024\FY24DetailedData(records).csv"
        out=evictions
        dbms=csv
        replace;

     getnames=yes;
     guessingrows=max;
run;

proc print data=work.evictions (obs=10);
run;

**Creates new data set with new street_address and zip_char variables **;
data evictions_addresses;
	Set work.evictions (rename=(CASE__=Case_num)); 
  street_address = catx( " ", street_number, street, type, quadrant );


  if not( missing( zip ) ) then zip_char = put( zip, z5.0 );
  if UPCASE( disposition )='CANCELLED' then disposition= 'CANCELED';
  
  informat _all_ ;
  format _all_ ;
  format EVICTION_DATE mmddyy10.;
  
  label
    street_address = "Full street address for eviction case"
    Case_num = "Eviction case number"
  ;
  
run;

proc print data=work.evictions_addresses (obs=40);
  id Case_num;
  var street_address street_number street type quadrant zip_char;
run;


**Geocoding Macro**;
%DC_mar_geocode(
data = evictions_addresses,
staddr = street_address,
out = GeocodedEvictionsData,
streetalt_file = &_dcdata_l_path\Requests\Prog\2024\StreetAlt_GeoEvict_2024.txt
)

**Macro used to finalize and save dataset**;
  %Finalize_data_set( 
    data=GeocodedEvictionsData,
    out=Evictions_2024_dc,
    outlib=Requests,
    label="Scheduled and executed evictions, 2024, DC",
    sortby=Case_num eviction_date,
    /** Metadata parameters **/
    printobs=0,
    freqvars=year DISPOSITION ward2022,
    revisions=%str(New file.)
  )

%Dup_check(
  data=evictions_addresses,
  by=Case_num,
  id=street_address eviction_date disposition,
  listdups=Y
)


