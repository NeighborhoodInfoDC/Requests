/**************************************************************************
 Program:  PresCat_lost_review.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/13/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Review lost properties/subsidies in Preservation
Catalog, 2015-2018.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( PresCat )


** Actual end data recorded **;

proc print data=PresCat.Subsidy;
  where 2015 <= year( poa_end_actual );
  id nlihc_id;
  var program poa_end poa_end_actual subsidy_info_source_date units_assist update_dtm;
run;

** No update in past year **;

proc print data=PresCat.Subsidy;
  where subsidy_info_source in ( 'HUD/MFA' ) and subsidy_info_source_date < '28Nov2018'd 
    and ( 2014 <= year( poa_end ) <= 2018 );
  id nlihc_id;
  var program poa_end poa_end_actual subsidy_info_source_date units_assist update_dtm;
run;

** Correct flag for active subsidies **;

data Subsidy;

  set PresCat.Subsidy;
  
  if poa_end_actual > 0 or ( subsidy_info_source in ( 'HUD/MFA' ) and subsidy_info_source_date < '28Nov2018'd )
  then Subsidy_active = 0;
  
  if not Subsidy_active then do;
    if 1950 <= year( poa_end_actual ) <= 2018 then LostDate = poa_end_actual;
    else if 1950 <= year( poa_end ) <= 2018 then LostDate = poa_end;
  end;
  
  format LostDate mmddyy10.;
  
run;

proc sql noprint;
  create table PresCat_lost_review as
  select *
  from
  (
    select Project.nlihc_id, Project.Category_code, Project.proj_addre, Project.proj_name, Project.proj_units_tot,
      Project.ward2012, Project.update_dtm as Proj_update_dtm, LostSubsidy.*
    from PresCat.Project_category_view as Project
    left join
    (
      select Subsidy.nlihc_id, max( Subsidy_active ) as Any_subsidy_active, max( LostDate ) as LostYear format=year4. 
      from Subsidy
      group by nlihc_id
    ) as LostSubsidy
    on Project.nlihc_id = LostSubsidy.nlihc_id
  ) as Project
  right join
  Subsidy as Subsidy
  on Project.nlihc_id = Subsidy.nlihc_id
  where category_code = '6' or Any_subsidy_active = 0
  order by LostYear, nlihc_id, subsidy_id;
quit;


options missing=' ';

ods listing close;
ods tagsets.excelxp file="&_dcdata_default_path\Requests\Prog\2018\PresCat_lost_review.xls" style=Normal options(sheet_interval='None' );
ods tagsets.excelxp options( sheet_name="PresCat_lost_review" );

proc print data=PresCat_lost_review;
  by LostYear;
  id nlihc_id subsidy_id;
run;

ods tagsets.excelxp close;
ods listing;

