/**************************************************************************
 Program:  DeLorenzo_10_15_08.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/15/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Citywide homeownership rate at or below 80% AMI.
 Updated to include 2006 data.
 Request from Maribeth DeLorenzo, DHCD, 10/15/08.

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
  
  if hud_inc in ( 1, 2, 3 ) then do;
    hhs_low_inc_2000 = 1;
    owner_rate_low_inc_2000 = owner_rate_2000;
  end;

run;

proc means data=Ipums_2000 n sum mean std;
  weight hhwt;
  var hhs_: owner_rate_: ;
run;


*****  2005  *****;

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


*****  2006  *****;

data Acs_2006;

  set Wawf.ACS_2005_06_TABLES;
  by serial;
  where year = 6 and statefip = 11 and ownershd > 0;
  
  if first.serial;
  
  hhs_2006 = 1;
  
  if ownershd in ( 10, 11, 12, 13 ) then owner_rate_2006 = 100;
  else owner_rate_2006 = 0;
  
  if hud_inc in ( 1, 2, 3 ) then do;
    hhs_low_inc_2006 = 1;
    owner_rate_low_inc_2006 = owner_rate_2006;
  end;

run;

proc means data=Acs_2006 n sum mean std;
  weight hhwt_org;
  var hhs_: owner_rate_: ;
run;


