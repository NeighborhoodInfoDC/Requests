/**************************************************************************
 Program:  Fosse_11_27_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/27/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Info on 1425 T St NW.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HsngMon )
%DCData_lib( NLIHC )
%DCData_lib( HUD )

data _null_;
  *set HsngMon.S8summary_2007_4;
  *set Nlihc.Preservation_cat;
  set Hud.sec8mf_current_dc;
  where ssl = "0205    0052";
  *where ssl =: "0205";
  file print;
  put / '--------------------';
  put (_all_) (= /);
run;



run;
