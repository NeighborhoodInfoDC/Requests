/**************************************************************************
 Program:  WOW_05_15_06.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/15/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Extract nonprofit data for WOW request from C.
 Cormier.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Nprofits )

** Create format for NTEE categories requested by WOW **;

data categories (compress=no);

  length code $ 3;

  input code @@;

datalines;
B02 B25 B28 B29 B30 B40 B41 B42 B43 B50 B60 C02 C20 C30 D20
D30 E62 F40 I01 I02 I03 I05 I20 I21 I23 I30 I31 I40 I44 I50
I51 I60 I70 I71 I72 I73 I80 I83 I99 J J01 J02 J03 J05 J20
J21 J22 J30 J32 J33 J40 J99 P01 P02 P03 P05 P40 P42 P43 P44
Q01 Q02 Q03 Q05 Q11 Q40 Q43 Q99 S40 S41 S43 S46 S47 S50 S80
U40 U41 U99 V26 V37 W01 W02 W03 W05 W11 W12 W30 W40 W80 W90
W99 Y40 Y42 Y99
;

run;

%Data_to_format(
  FmtLib=work,
  FmtName=$select,
  Data=categories,
  Value=code,
  Label=code,
  OtherLabel=" ",
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Desc=,          
  Contents=N
  )

** Get matching organizations from NCCS data **;

data Wow_05_15_06 (compress=no);

  set Nprofits.Nccs_2000
    (keep=ntee_fin name address city state zip5 fips area_local perm_loc p1: p4:);
    
  if not( put( substr( ntee_fin, 1, 3 ), $select. ) = "" ) or
     ntee_fin =: "M";
     
run;

%file_info( data=Wow_05_15_06, freqvars=fips ntee_fin )

/*
proc print data=Wow_05_15_06 (obs=20);

proc freq data=Wow_05_15_06;
  tables fips ntee_fin ;
  
run;

data Wow_05_15_06_exp (compress=no);
  set Wow_05_15_06 (obs=20 drop=fips);
run;
*/

filename fexport "D:\DCData\Libraries\Requests\Raw\WOW_05_15_06.csv" lrecl=5000;

proc export data=Wow_05_15_06
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;



