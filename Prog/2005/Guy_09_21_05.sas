/**************************************************************************
 Program:  Guy_09_21_05.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/21/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Data request for NBC report Shoshana Guy for data on
 Deanwood neighborhood. Request received 9/20/05 (follow up).

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Ncdb )

rsubmit;

%let vars = trctpop0 shrhsp0n 
            shrnhw0n shrnhb0n shrnhi0n shrnhr0n shrnhh0n shrnha0n shrnho0n
            fhwkid0 fhnkid0 welfar0d 
            nkidmcf0 nkidmhh0 nkidfhh0
            unempt0n unempt0d povrat0n povrat0d
            educ80 educ110 educ120 educ150 educa0 educ160 educpp0
            hsdrop0n hsdrop0d;

data Ncdb_req;

  set Ncdb.Ncdb_lf_2000_dc
        (keep=geo2000 &vars
         where=(geo2000 in ( "11001007804", "11001007808", "11001009903" ) )
        );

/*
  hsdiploma = sum( educ120, educ150, educa0, educ160 );
  
  children_fam = sum( NKIDMCF0, NKIDMHH0, NKIDFHH0 );
  
  label hsdiploma = 'Persons with a HS diploma, 2000'
    children_fam = 'Own children < 18 yrs. living in families, 2000';
*/

run;

proc summary data=Ncdb_req print sum;
  var &vars /*hsdiploma children_fam*/;
  output 
    out=Guy_09_21_05 (label='Request for Shoshana Guy, 9/20/05')
    sum=;
    
run;

data _null_;

  file print;
  
  set Guy_09_21_05;
  
  put 'Deanwood neighborhood';
  
  put 'Population = ' trctpop0 comma8.0;
  
  pctblk = shrnhb0n / trctpop0;
  put 'Race = ' pctblk percent8.1 ' Black';
  
  femhh = fhwkid0 / welfar0d;
  put 'Female householder no husband with kids = ' femhh percent8.1;
  
  childfhh = NKIDFHH0 / sum( NKIDMCF0, NKIDMHH0, NKIDFHH0 );
  put 'Children living with mother only = ' childfhh percent8.1;
  
  povrat = povrat0n / povrat0d;
  put 'Poverty rate = ' povrat percent8.1;
  
  unemp = unempt0n / unempt0d;
  put 'Unemployment = ' unemp percent8.1;
  
  hsdip = sum( educ120, educ150, educa0, educ160 ) / educpp0;
  put 'High School Diploma = ' hsdip percent8.1;
  
  drop = hsdrop0n / hsdrop0d;
  put 'High School drop outs = ' drop percent8.1;

run;

endrsubmit;

signoff;
