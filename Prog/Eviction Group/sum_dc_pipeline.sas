/**************************************************************************
 Program:  Quick_analysis.sas
 Library:  PresCat
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  03/16/23
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  ???
 
 Description:

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( PresCat )

**** Quick analysis ****;

data working_pipeline_data; 
 set PresCat.dc_pipeline_2022_07;
 u_LRSP_units = input(LRSP_units_new, 8.);
run; 

proc print data=working_pipeline_data; 
 sum u_LRSP_units units_0_to_30;
run;
