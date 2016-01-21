/**************************************************************************
 Program:  Yourish_08_03_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/04/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Compile data on Dupont Circle requested by Karen
 Yourish, Washington Post, 8/3/06.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )
%DCData_lib( HMDA )
%DCData_lib( RealProp )

rsubmit;

libname dplace "DISK$USER05:[DPLACE]";

%let ncdb_var_list =
  trctpop9 trctpop0 child9n child0n adult9n adult0n old9n old0n
  shrnhb9n shrnhw9n shrnha9n shrnhi9n shrnho9n shrhsp9n 
  shrnhb0n shrnhw0n shrnha0n shrnhi0n shrnho0n shrhsp0n 
  unempt9d unempt9n
  unempt0d unempt0n
  occ19 occ29 occ39 occ49 occ59 occ69 occ79 occ89 occ99
  occ10 occ20 occ30 occ40 occ50 occ60 occ70 occ80 occ90
  occhu9 occhu0
  car9 car0
  avgrent9 avgrent0
  educ:
  fmc9n ffh9n ffh9d famsub9 nonfam9 
  fmc0n ffh0n ffh0d famsub0 nonfam0

  ;

** Sales **;

data Sales;

  merge RealProp.Test_master (keep=ssl saleprice saledate ui_proptype)
   RealProp.Parcel_geo (keep=ssl geo2000);
  by ssl;

  year = year( saledate );

  if 1995 <= year <= 2005 and 
    ui_proptype in ( '10', '11' ) and 
    geo2000 in ( "11001004202", "11001005301", "11001005302", "11001005402",
                     "11001005401", "11001005500" );

run;

proc summary data=Sales nway;
  var saleprice;
  class year;
  output out=Sales_dup median=;
  label saleprice = "Median sales price s.f. homes & condos ($)";

%Super_transpose( data=Sales_dup, out=Sales_tr, var=saleprice, id=year )

/*
proc contents data=Sales_tr;

proc print data=Sales_tr;
*/

run;

** HMDA **;

data Hmda_03_04;

  set  
    Dplace.DPLEX_HMDA_SUMMARY_03 (keep=year MedianMrtgInc1_4m nummrtgorighomepurch1_4m stfid
      rename=(year=xyear MedianMrtgInc1_4m=MedianMrtgInc nummrtgorighomepurch1_4m=nummrtgorighomepurch
              stfid=geo2000))
    Dplace.DPLEX_HMDA_SUMMARY_04 (keep=year MedianMrtgInc1_4m nummrtgorighomepurch1_4m stfid
      rename=(year=xyear MedianMrtgInc1_4m=MedianMrtgInc nummrtgorighomepurch1_4m=nummrtgorighomepurch
              stfid=geo2000));

  where geo2000 ~= "";

  year = 1 * xyear;

  drop xyear;

run;

data Hmda;

  set 
    Hmda.Hmda_sum_1995_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    Hmda.Hmda_sum_1996_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    Hmda.Hmda_sum_1997_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    Hmda.Hmda_sum_1998_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    Hmda.Hmda_sum_1999_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    Hmda.Hmda_sum_2000_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    Hmda.Hmda_sum_2001_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    Hmda.Hmda_sum_2002_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)
    /*Hmda.Hmda_sum_2003_was (keep=year medianmrtginc nummrtgorighomepurch geo2000)*/
    Hmda_03_04;

  where geo2000 in ( "11001004202", "11001005301", "11001005302", "11001005402",
                     "11001005401", "11001005500" );

run;

proc summary data=Hmda nway;
  var medianmrtginc /weight=nummrtgorighomepurch;
  class year;
  output out=Hmda_dup mean=;
run;

%Super_transpose( data=Hmda_dup, out=Hmda_tr, var=medianmrtginc, id=year )

/*
proc contents data=Hmda_tr;

proc print data=Hmda_tr;
*/

run;

** NCDB **;

data Tractlevel;

  merge 
    Ncdb.Ncdb_1990_2000_dc
    Ncdb.Ncdb_lf_2000_dc;
  by geo2000;
  
  where geo2000 in ( "11001004202", "11001005301", "11001005302", "11001005402",
                     "11001005401", "11001005500" );

  avgrent9 = aggrent9 / ( sum( of grnt: ) - grntncr9 );
  avgrent0 = aggrent0 / ( sum( of grnt: ) - grntncr0 );

  label
   avgrent9 = "Avg. gross rent of renter-occ. housing units paying cash rent, 1990"
   avgrent0 = "Avg. gross rent of renter-occ. housing units paying cash rent, 2000";


  keep geo2000 &ncdb_var_list;

run;

proc summary data=Tractlevel;
  var &ncdb_var_list;
  output out=Dupont sum=;

** All together now **;  

data Export (keep=Description Value);

  set Sales_tr;
  set HMDA_tr;
  set Dupont;
  
  length Description $ 255;
  
  array v{*} saleprice: medianmrtginc: &ncdb_var_list;
  
  do i = 1 to dim( v );
  
    Description = vlabel( v{i} );
    Value = v{i};
    
    output;
    
  end;
  
run;

proc print data=Export noobs;

run;

proc download status=no
  data=Export 
  out=Export;

run;

endrsubmit;

filename fexport "D:\DCData\Libraries\Requests\Raw\Yourish_08_03_06.csv" lrecl=1000;

proc export data=Export
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

signoff;

