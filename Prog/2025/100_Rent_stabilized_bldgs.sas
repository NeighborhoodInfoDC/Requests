/**************************************************************************
 Program:  100_Rent_stabilized_bldgs.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  11/18/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  100
 
 Description:  Create list of rent stabilized MF buildings for tenant
 outreach activities. 

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( DHCD )
%DCData_lib( RealProp )


data Rent_stabilized_bldgs;

  set Dhcd.Parcels_rent_control 
       (keep=ssl premiseadd excluded_: exempt_: rent_controlled 
             ui_proptype ownercat ownername_full units_full unit_count_pred_flag 
             ward2022 cluster2017);

  where rent_controlled and units_full > 1 and ui_proptype ~= '10';

run;

%File_info( data=Rent_stabilized_bldgs, freqvars=ui_proptype )

proc univariate data=Rent_stabilized_bldgs nextrobs=20;
  id ssl;
  var units_full;
run;

