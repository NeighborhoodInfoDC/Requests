/**************************************************************************
 Program:  109_Housingand_present.sas
 Library:  Request
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  3/25/2026
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  109
 
 Description:  https://github.com/NeighborhoodInfoDC/Requests/issues/109
 
 Data for Housing& Faith Housing presentation.

 Modifications:
**************************************************************************/

%include "F:\DCdata\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( Requests )


    %Get_acs_detailed_table_api( 
      key=&_dcdata_census_api_key,
      out=B25140_dc,
      table=B25140, 
      year=2024, 
      sample=acs5, 
      for=county:*, 
      in=%nrstr(state:11)
    )

    %Get_acs_detailed_table_api( 
      key=&_dcdata_census_api_key,
      out=B25140_md,
      table=B25140, 
      year=2024, 
      sample=acs5, 
      for=county:*, 
      in=%nrstr(state:24)
    )

    %Get_acs_detailed_table_api( 
      key=&_dcdata_census_api_key,
      out=B25140_va,
      table=B25140, 
      year=2024, 
      sample=acs5, 
      for=county:*, 
      in=%nrstr(state:51)
    )


** Combine and calculate cost burden variables **;

data B25140;

  set
    B25140_dc
    B25140_md
    B25140_va
  ;
  
  length ucounty $ 5;
  ucounty = cats( state, county );
  
  owner_units = ( B25140_002E - B25140_005E ) + ( B25140_006E - B25140_009E );
  owner_cost_burden = B25140_003E + B25140_007E;
  owner_cost_burden_pct = owner_cost_burden / owner_units;
  
  renter_units = B25140_010E - B25140_013E;
  renter_cost_burden = B25140_011E;
  renter_cost_burden_pct = renter_cost_burden / renter_units;
  
  format ucounty $cnty20f.;
  
run;

%File_info( data=B25140, printobs=0 )


** Export data **;

ods listing close;
ods csvall body="&_dcdata_default_path\Requests\Prog\2026\109_Housingand_present.csv";

title1;
footnote1;

proc print data=B25140;
  where not( missing( put( ucounty, $ctym20f. ) ) );
  id ucounty;
  var owner_: renter_: ;
run;

ods csvall close;
ods listing;

