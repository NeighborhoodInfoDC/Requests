/**************************************************************************
 Program:  DeLorenzo_09_11_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/11/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Citywide homeownership rate at or below 80% AMI.
 Request from Maribeth DeLorenzo, DHCD, 09/11/07.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( WAWF )

data Ipums_2000;

  set Wawf.Ipums_2000_tables;
  by serial;
  where statefip = 11 and ownershd > 0;
  
  if first.serial;
  
  hhs_2000 = 1;
  
  if ownershd in ( 10, 11, 12, 13 ) then owner_rate_2000 = 100;
  else owner_rate_2000 = 0;
  
  if hud_inc99 in ( 1, 2, 3 ) then do;
    hhs_low_inc_2000 = 1;
    owner_rate_low_inc_2000 = owner_rate_2000;
  end;

run;

proc means data=Ipums_2000 n sum mean std;
  weight hhwt;
  var hhs_: owner_rate_: ;
run;


data Acs_2005;

  set Wawf.ACS_2005_tables;
  by serial;
  where statefip = 11 and ownershd > 0;
  
  if first.serial;
  
  hhs_2005 = 1;
  
  if ownershd in ( 10, 11, 12, 13 ) then owner_rate_2005 = 100;
  else owner_rate_2005 = 0;
  
  if hud_inc in ( 1, 2, 3 ) then do;
    hhs_low_inc_2005 = 1;
    owner_rate_low_inc_2005 = owner_rate_2005;
  end;

run;

proc means data=Acs_2005 n sum mean std;
  weight hhwt;
  var hhs_: owner_rate_: ;
run;

