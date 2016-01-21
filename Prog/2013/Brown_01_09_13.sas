/**************************************************************************
 Program:  Brown_01_09_13.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/09/13
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Request from LaTanya N. Brown, Department of
 Accounting, Finance and Economics, College of Business, Bowie State
 University, 301-860-3661, lnbrown@bowiestate.edu. Cross walk for
 2000 and 2010 blocks/block groups to assessment neighborhoods.

 NOTE: Download latest RealProp.Parcel_base and RealProp.Parcel_geo files
 before running this program.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

** Merge Parcel_base with Parcel_geo to add block/bg IDs **;

data Parcel_base_geo; 

  merge 
    RealProp.Parcel_base
      (where=(in_last_ownerpt)
       keep=ssl in_last_ownerpt nbhd nbhdname landarea
       in=in_base)
    RealProp.Parcel_geo
      (keep=ssl geobg2000 geobg2010 geoblk2000 geoblk2010);
    by ssl;
    
  if in_base;
  
  if nbhdname ~= "";
  
  drop in_last_ownerpt;
  
  format geobg2000 geobg2010 geoblk2000 geoblk2010;
  
run;

proc freq data=Parcel_base_geo;
 tables nbhd * nbhdname /list missing;

run;

/** Macro Aggregate - Start Definition **/

%macro Aggregate( geo );

  %let geo = %lowcase( &geo );

  ** Aggregate by assessment neighborhood and target geo **;

  proc summary data=Parcel_base_geo nway;
    var landarea;
    class &geo. nbhd;
    id nbhdname;
    output out=Crosswalk_&geo._assess_nbhd (rename=(_freq_=Parcels) drop=_type_) sum=;
  run;

  proc sort data=Crosswalk_&geo._assess_nbhd;
    by &geo. descending landarea;
  run;

  filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Prog\2013\Crosswalk_&geo._assess_nbhd.csv" lrecl=200;

  proc export data=Crosswalk_&geo._assess_nbhd
      outfile=fexport
      dbms=csv replace;

  run;

  filename fexport clear;

%mend Aggregate;

/** End Macro Definition **/


%Aggregate( Geobg2000 )
%Aggregate( Geoblk2000 )

%Aggregate( Geobg2010 )
%Aggregate( Geoblk2010 )
