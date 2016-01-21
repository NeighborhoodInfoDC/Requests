/**************************************************************************
 Program:  DC_courts_05_02_13_d.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/22/13
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Export XML data for creating ward maps.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2013\DC_courts_05_02_13_d.xls" 
                    style=Minimal options(sheet_interval='Page' );

ods tagsets.excelxp options( sheet_name="Wards" );
ods csvall body="D:\DCData\Libraries\Requests\Prog\2013\DC_courts_05_02_13_d.csv";

data Wards;

  set Requests.DC_courts_05_02_13_wd12;

  PctSinBirth02 = 100 * births_single_2002 / births_w_mstat_2002;
  PctSinBirth10 = 100 * births_single_2010 / births_w_mstat_2010;
  PctTeenBirth10 = 100 * births_teen_2010 / births_w_age_2010;
  
  UnempRate0711 = 100 * PopUnemployed_2007_11 / popincivlaborforce_2007_11;
  
  PctWOHS0711 = 100 * Pop25andOverWoutHS_2007_11 / Pop25andOverYears_2007_11;
  PctDropOut0711 = 100 * numhighschooldropout_2007_11 / pop16to19years_2007_11;
  
  PovRate0711 = 100 * PopPoorPersons_2007_11 / PersonsPovertyDefined_2007_11; 
  
  rename PopUnemployed_2007_11=PopUnemp0711 crimes_pt1_violent_2011=vcrime11
    crimes_pt1_property_2011=pcrime11;
  
run;

title;
proc print data=Wards;
  id Ward2012;
  var births_total_2002 births_total_2010 PctSinBirth02 PctSinBirth10 PctTeenBirth10 
      fs_client_2013 PovRate0711 PopUnemp0711 UnempRate0711 PctWOHS0711 PctDropOut0711
      vcrime11 pcrime11;
run;

ods tagsets.excelxp close;
ods csvall close;


