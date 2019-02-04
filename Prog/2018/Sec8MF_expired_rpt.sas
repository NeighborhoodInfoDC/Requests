/**************************************************************************
 Program:  Sec8MF_expired_rpt.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/14/2018
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Report showing recently expired Sec. 8 MF projects.
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HUD )
%DCData_lib( PresCat )


/** Macro Create_s8_history - Start Definition **/

%macro Create_s8_history( data= );

  data S8_history;
  
    merge
      S8_history (in=in1)
      &data (in=in2);
    by contract_number;
    
    where not missing( contract_number );
    
    if ( in1 and not in2 and missing( cur_expiration_date ) ) or tracs_status in ( 'T', 'X' ) then do;
      LostS8 = 1;
      cur_expiration_date = min( tracs_overall_expiration_date, extract_date );
    end;
    else if in2 and tracs_status in ( 'A' ) then do;
      LostS8 = 0;
      cur_expiration_date = .;
    end;   
    
    InLastUpdate = in2;
    
    format cur_expiration_date mmddyy10.;
    
  run;
  
  /*
  proc print data=S8_history;
    where LostS8;
    ***where contract_number = 'DC39H001010';
    id extract_date contract_number;
    var InLastUpdate cur_expiration_date tracs_status tracs_overall_expiration_date;
  run;
  */

%mend Create_s8_history;

/** End Macro Definition **/

data S8_history;
  
  length contract_number $ 11;
  
  contract_number = "";
  
run;

** Compile data **;

%Create_s8_history( data=Hud.sec8mf_2005_01_dc )
%Create_s8_history( data=Hud.sec8mf_2005_05_dc )
%Create_s8_history( data=Hud.sec8mf_2005_07_dc )
%Create_s8_history( data=Hud.sec8mf_2006_02_dc )
%Create_s8_history( data=Hud.sec8mf_2006_07_dc )
%Create_s8_history( data=Hud.sec8mf_2006_09_dc )
%Create_s8_history( data=Hud.sec8mf_2007_01_dc )
%Create_s8_history( data=Hud.sec8mf_2007_02_dc )
%Create_s8_history( data=Hud.sec8mf_2007_07_dc )
%Create_s8_history( data=Hud.sec8mf_2007_09_dc )
%Create_s8_history( data=Hud.sec8mf_2007_12_dc )
%Create_s8_history( data=Hud.sec8mf_2013_09_dc )
%Create_s8_history( data=Hud.sec8mf_2014_10_dc )
%Create_s8_history( data=Hud.sec8mf_2014_11_dc )
%Create_s8_history( data=Hud.sec8mf_2015_05_dc )
%Create_s8_history( data=Hud.sec8mf_2015_08_dc )
%Create_s8_history( data=Hud.sec8mf_2015_10_dc )
%Create_s8_history( data=Hud.sec8mf_2015_11_dc )
%Create_s8_history( data=Hud.sec8mf_2015_12_dc )
%Create_s8_history( data=Hud.sec8mf_2016_01_dc )
%Create_s8_history( data=Hud.sec8mf_2016_04_dc )
%Create_s8_history( data=Hud.sec8mf_2016_05_dc )
%Create_s8_history( data=Hud.sec8mf_2016_08_dc )
%Create_s8_history( data=Hud.sec8mf_2016_09_dc )
%Create_s8_history( data=Hud.sec8mf_2016_11_dc )
%Create_s8_history( data=Hud.sec8mf_2016_12_dc )
%Create_s8_history( data=Hud.sec8mf_2017_01_dc )
%Create_s8_history( data=Hud.sec8mf_2017_02_dc )
%Create_s8_history( data=Hud.sec8mf_2017_04_dc )
%Create_s8_history( data=Hud.sec8mf_2017_05_dc )
%Create_s8_history( data=Hud.sec8mf_2017_09_dc )
%Create_s8_history( data=Hud.sec8mf_2017_10_dc )
%Create_s8_history( data=Hud.sec8mf_2017_11_dc )
%Create_s8_history( data=Hud.sec8mf_2017_12_dc )
%Create_s8_history( data=Hud.sec8mf_2018_01_dc )
%Create_s8_history( data=Hud.sec8mf_2018_02_dc )
%Create_s8_history( data=Hud.sec8mf_2018_03_dc )
%Create_s8_history( data=Hud.sec8mf_2018_04_dc )
%Create_s8_history( data=Hud.sec8mf_2018_05_dc )
%Create_s8_history( data=Hud.sec8mf_2018_06_dc )
%Create_s8_history( data=Hud.sec8mf_2018_08_dc )
%Create_s8_history( data=Hud.sec8mf_2018_09_dc )
%Create_s8_history( data=Hud.sec8mf_2018_11_dc )


proc print data=S8_history;
  where LostS8 and 2005 <= year( cur_expiration_date ) <= 2018;
  id extract_date contract_number;
  var property_name_text InLastUpdate cur_expiration_date tracs_status tracs_overall_expiration_date assisted_units_count;
  sum assisted_units_count;
run;

** Match with Catalog **;

proc sql;
  create table Sec8MF_expired_rpt as
  select Nlihc_id.*, Project.Proj_name, Project.Category_code
  from
  (
    select Rpt.*, Subsidy.nlihc_id, Subsidy.program, Subsidy.rent_to_fmr_description from S8_history as Rpt left join PresCat.Subsidy as Subsidy
    on Rpt.contract_number = Subsidy.contract_number
    where Rpt.LostS8 and 2005 <= year( Rpt.cur_expiration_date ) <= 2018 and Subsidy.subsidy_info_source = 'HUD/MFA'
  ) as Nlihc_id
  left join
  PresCat.Project_category_view as Project
  on Nlihc_id.Nlihc_id = Project.Nlihc_id 
  order by cur_expiration_date, nlihc_id;
quit;

options missing=' ';

ods listing close;
ods tagsets.excelxp file="&_dcdata_default_path\Requests\Prog\2018\Sec8MF_expired_rpt.xls" style=Normal options(sheet_interval='None' );
ods tagsets.excelxp options( sheet_name="Sec8MF_expired_rpt" );

proc print data=Sec8MF_expired_rpt;
  by cur_expiration_date;
  id nlihc_id;
  var Proj_name Category_code contract_number InLastUpdate tracs_status tracs_overall_expiration_date Program assisted_units_count rent_to_fmr_description br: owner_company;
  format cur_expiration_date year4.;
  label cur_expiration_date = 'Expired';
run;

ods tagsets.excelxp close;
ods listing;


** 2005 - 2015 losses **;

proc means data=Hud.sec8mf_2005_01_dc n nmiss sum;
  where tracs_status not in ( 'T', 'X' );
  var assisted_units_count;
  title2 'Jan 2005';
run;

proc means data=Hud.sec8mf_2016_01_dc n nmiss sum;
  where tracs_status not in ( 'T', 'X' );
  var assisted_units_count;
  title2 'Jan 2016';
run;

proc print data=S8_history;
  where LostS8 and 2005 <= year( cur_expiration_date ) <= 2015;
  id extract_date contract_number;
  var property_name_text zip_code InLastUpdate cur_expiration_date tracs_status tracs_overall_expiration_date assisted_units_count;
  sum assisted_units_count;
  title2 'Losses 2005 - 2015';
run;

