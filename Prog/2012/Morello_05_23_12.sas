/**************************************************************************
 Program:  Morello_05_23_12.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/23/12
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Get data on population by race for 2000 and 2010 for
 comparison with 2011 estimates.
 
 Prepared for Carol Morello, Washington Post. 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )

** Start submitting commands to remote server **;

rsubmit;

data A;

  set
    Ncdb.Ncdb_lf_2000_dc
      (keep=trctpop0 nonhisp0 mranhs0n minnhb0n shrnhb0n maxnhb0n
            minnhw0n shrnhw0n maxnhw0n shrhsp0n
       in=in2000)
    Ncdb.Ncdb_2010_dc_blk 
      (keep=trctpop1 nonhisp1 mranhs1n minnhb1n shrnhb1n maxnhb1n
            minnhw1n shrnhw1n maxnhw1n shrhsp1n
       in=in2010);
  
  if in2000 then year = 2000;
  else year = 2010;

run;

proc summary data=A;
  by year;
  var trctpop0 nonhisp0 mranhs0n minnhb0n shrnhb0n maxnhb0n
      minnhw0n shrnhw0n maxnhw0n shrhsp0n
      trctpop1 nonhisp1 mranhs1n minnhb1n shrnhb1n maxnhb1n
      minnhw1n shrnhw1n maxnhw1n shrhsp1n;
  output out=Morello_05_23_12 sum=;
run;

data _null_;
  set Morello_05_23_12;
  file print;
  put / '--------------------';
  put (year trctpop0 nonhisp0 mranhs0n minnhb0n shrnhb0n maxnhb0n
      minnhw0n shrnhw0n maxnhw0n shrhsp0n
      trctpop1 nonhisp1 mranhs1n minnhb1n shrnhb1n maxnhb1n
      minnhw1n shrnhw1n maxnhw1n shrhsp1n) (= /);
run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
