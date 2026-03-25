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
      out=B25106_dc,
      table=B25106, 
      year=2024, 
      sample=acs5, 
      for=county:*, 
      in=%nrstr(state:11)
    )

    %Get_acs_detailed_table_api( 
      key=&_dcdata_census_api_key,
      out=B25106_md,
      table=B25106, 
      year=2024, 
      sample=acs5, 
      for=county:*, 
      in=%nrstr(state:24)
    )

    %Get_acs_detailed_table_api( 
      key=&_dcdata_census_api_key,
      out=B25106_va,
      table=B25106, 
      year=2024, 
      sample=acs5, 
      for=county:*, 
      in=%nrstr(state:51)
    )

data B25106;

  set
    B25106_dc
    B25106_md
    B25106_va
  ;
  
run;

%File_info( data=B25106 )
