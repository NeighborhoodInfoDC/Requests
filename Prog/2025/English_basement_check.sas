/**************************************************************************
 Program:  English_basement_check.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  10/15/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  94
 
 Description:  Check how SFHs with English basement units are coded
in real property data. 

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( MAR )
%DCData_lib( Realprop )

/*
proc print data=Mar.Address_points_2025_07 (obs=100);
  where active_res_occupancy_count = 2 and active_res_unit_count = 1;
  id address_id;
  var fulladdress active_res_occupancy_count active_res_unit_count has_residential_unit ssl;
run;
*/

proc sql noprint;
  create table English as
  select 
    Parcel.ui_proptype, Parcel.usecode, Mar.address_id, Mar.fulladdress, Mar.has_residential_unit,
    Mar.res_type, Mar.address_type, Mar.status,
    coalesce( Parcel.ssl, Mar.ssl ) as ssl 
  from Mar.Address_points_2025_07 as Mar left join Realprop.Parcel_base as Parcel
  on Parcel.ssl = Mar.ssl
  where active_res_occupancy_count = 2 and active_res_unit_count = 1;
  quit;
  
run;

proc freq data=English;
  tables status res_type address_type has_residential_unit ui_proptype usecode;
run;


title2 "ui_proptype = '10'";

proc print data=English (obs=100);
  where ui_proptype = '10';
  id address_id;
  var ssl fulladdress has_residential_unit ui_proptype usecode;
run;

title2 "ui_proptype = '13'";

proc print data=English (obs=100);
  where ui_proptype = '13';
  id address_id;
  var ssl fulladdress has_residential_unit ui_proptype usecode;
run;

title2 "ui_proptype =: '2'";

proc print data=English (obs=100);
  where ui_proptype =: '2';
  id address_id;
  var ssl fulladdress has_residential_unit ui_proptype usecode;
run;

title2;



proc print data=Realprop.Parcel_units;
  where ssl in ( '0028    0868', '0028    0161', '0875    0043' );
  id ssl;
run;

