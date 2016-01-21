/**************************************************************************
 Program:  Barden_03_27_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/27/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  List of multifamily properties with unit counts for Kristen
 Barden, MOCRS/Mayor's Office <Kristen.Barden@dc.gov>.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

%let geo = ZIP Ward2002 Anc2002 Psa2004 Geo2000;

%syslput geo=&geo;

** Start submitting commands to remote server **;

rsubmit;

%push_option( compress, quiet=Y )

options compress=no;

data MultiCondo MultiRentCooop;

  merge 
    Realprop.Parcel_base
      (keep=ssl premiseadd in_last_ownerpt ui_proptype ownername
            landarea no_units 
       where=(in_last_ownerpt and ui_proptype in ('11', '12', '13'))
       in=in1)
    Realprop.Parcel_geo
      (keep=ssl &geo);
  by ssl;
  
  if in1;
  
  select ( ui_proptype );
    when ( '11' ) output MultiCondo;
    when ( '12', '13' ) output MultiRentCooop;
  end;
  
  drop in_last_ownerpt;

run;

%DC_geocode(
  geo_match=N,
  data=MultiCondo,
  out=MultiCondoAddr,
  staddr=premiseadd ,
  zip=,
  id=ssl,
  ds_label=,
  listunmatched=Y
)

data MultiCondoAddr;

  set MultiCondoAddr;
  
  length word $ 1000;
  
  if premiseadd_std = "" then do;
  
    i = 1;
    word = scan( premiseadd, i, " " );
  
    do until( word in ( "", "ST", "AV", "RD", "CT", "PL", "PKWY", "TR", "LA", "DR", "CIR", "BLVD" ) );
  
      premiseadd_std = trim( premiseadd_std ) || " " || left( trim( word ) );
      
      i = i + 1;
      word = scan( premiseadd, i, " " );
      
    end;
    
    premiseadd_std = trim( premiseadd_std ) || " " || left( trim( word ) );

    put ssl= premiseadd= premiseadd_std= ;
  
  end;
  
  drop i word; 

run;

proc summary data=MultiCondoAddr nway;
  class premiseadd_std;
  id ui_proptype &geo;
  var landarea;
  output out=MultiCondoBldg (rename=(_freq_=no_units) drop=_type_) sum= ;

** Combine files **;

data MultiBuildings;

  set
    MultiCondoBldg (rename=(premiseadd_std=premiseadd))
    MultiRentCooop;

  number = 1 * compress( scan( premiseadd, 1, " " ), "ABCDEFGHIJKLMNOPQRSTUVWXYZ" );

  length street $ 80;
  
  if scan( premiseadd, 2, " " ) = '-' then do;
    street = scan( premiseadd, 4, " " ) || scan( premiseadd, 5, " " ) || scan( premiseadd, 6, " " ) ||
             scan( premiseadd, 7, " " ) || scan( premiseadd, 8, " " ) || scan( premiseadd, 9, " " );
  end;
  else do;
    street = scan( premiseadd, 2, " " ) || scan( premiseadd, 3, " " ) || scan( premiseadd, 4, " " ) ||
             scan( premiseadd, 5, " " ) || scan( premiseadd, 6, " " ) || scan( premiseadd, 7, " " );
  end;
  
run;

proc sort data=MultiBuildings;
  by street number;

proc download status=no
  inlib=work 
  outlib=work memtype=(data);
  select MultiBuildings;

run;

%pop_option( compress, quiet=Y )

run;

endrsubmit;

** End submitting commands to remote server **;

** Create CSV export file **;

proc format;
  value $UIPRTYP
    '11' = 'Condominium'
    '12' = 'Cooperative'
    '13' = 'Rental';

data XMultiBuildings;

  retain premiseadd ui_proptype no_units LandArea SSL &geo OwnerName;
  
  set MultiBuildings (keep=premiseadd ui_proptype no_units LANDAREA SSL &geo ownername);
  
  ownername = propcase( ownername );
  
  rename
    premiseadd=Address ui_proptype=Type no_units=Units;

  format Zip $5.;

run;

filename fexport "D:\DCData\Libraries\Requests\Prog\2007\Barden_03_27_07.csv" lrecl=2000;

proc export data=XMultiBuildings
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;


signoff;
