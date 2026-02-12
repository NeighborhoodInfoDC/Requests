/**************************************************************************
 Program:  105_PubHsngAddresses.sas
 Library:  PresCat
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  02/12/26
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  105
 
 Description:  Create list of addresses for public housing
 developments in Preservation Catalog. 

 Request from Brian Rohal, Legal Aid DC.
 
 Based on PresCat\Prog\Dev\481_ProjBasedAddresses.sas

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( PresCat )

** Create merged data **;

proc sql noprint;
  create table PubHsngAddresses as
  select coalesce( Addr.Nlihc_id, Proj.Nlihc_id ) as Nlihc_id, Proj.Proj_name, Addr.Bldg_addre, Addr.Address_id, Addr.Portfolio
    from
    (
      select distinct
        coalesce( Geo.nlihc_id, Sub.nlihc_id ) as Nlihc_id, Geo.bldg_addre, Geo.bldg_address_id as Address_id, Sub.Portfolio 
        from PresCat.Building_geocode as Geo left join PresCat.Subsidy as Sub
      on Geo.nlihc_id = Sub.nlihc_id
      where Sub.Portfolio in ( 'PUBHSNG' ) and Sub.Subsidy_active and not( missing( Geo.bldg_addre ) )
    ) as Addr
    left join
    Prescat.Project_category_view as Proj
  on Addr.Nlihc_id = Proj.Nlihc_id
  order by Addr.nlihc_id, Addr.bldg_addre, Addr.Portfolio;
quit;

%Dup_check(
  data=PubHsngAddresses,
  by=nlihc_id bldg_addre,
  id=portfolio,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)


%File_info( data=PubHsngAddresses, stats=, printobs=40 )

** Create exported data as Excel workbook **;

ods tagsets.excelxp file="&_dcdata_default_path\Requests\Prog\2026\105_PubHsngAddresses.xls" style=Normal options(sheet_interval='bygroup' sheet_label=' ');
ods listing close;

proc print data=PubHsngAddresses label noobs;
  by nlihc_id proj_name;
  var Bldg_addre Address_id;
  label 
    Bldg_addre = "Addresses";
run;

ods tagsets.excelxp close;
ods listing;


** Create exported data as CSV file **;

ods csvall body="&_dcdata_default_path\Requests\Prog\2026\105_PubHsngAddresses.csv";
ods listing close;

title1;
footnote1;

proc print data=PubHsngAddresses label noobs;
  var nlihc_id Proj_name Bldg_addre Address_id;
  label 
    nlihc_id = "PreservationCatalogID"
    proj_name = "ProjectName"
    Bldg_addre = "Addresses";
run;

ods csvall close;
ods listing;
