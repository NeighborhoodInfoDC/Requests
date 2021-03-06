/**************************************************************************
 Program:  DCFPI_pipeline.sas
 Library:  PresCat
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/11/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Match DCFPI pipeline spreadsheet with Preservation
Catalog.

Nonprofit=NP/ Forprofit=FP/ Partnership=NP/FP


 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( PresCat )
%DCData_lib( MAR )

filename fimport "L:\Libraries\PresCat\Raw\Extract of DCFPI Pipeline Spreadsheet 1.11.18.csv" lrecl=2000;

data DCFPI_pipeline;

  infile fimport dsd stopover firstobs=8;

  input
    ID
    ProjectName : $80.
    Address : $160.
    Developer : $80.
    DeveloperType : $8.
    NewRowAdded
    InfoVerified
    WhoEdited : $16.
    AppFiscalYear : $8.
    SelectionFiscalYear : $8.
    ApplicationType : $16.
    TOPA
    PADD
    Tenure : $40.
    ProjectType : $40.
    PctAMIUnits30
    PctAMIUnits50
    PctAMIUnits60
    PctAMIUnits80
    PctAMIUnits81
    PSHUnits
    AffordableUnits
    TotalUnits
    LRSPUnits
    AffordableUnits01Bdrm
    AffordableUnits2pBdrm
    TotalDevelopmentCost
    HPTFLoanGrantAmount
    TCE
    HOPWA
    CIP
    NSP
    CDBG
    HOME
    DBH
    TotalLoanGrantAmount
    LIHTCAllocation
    LIHTCType : $8.
    LoanStatus : $16.
    xClosingDate : $16.
    ClosingFiscalYear : $8.
  ;
  
  if missing( ID ) then delete;
  
  OtherPublic = sum( TCE, HOPWA, CIP, NSP, CDBG, HOME, DBH, 0 );
  
  ** Manual address fixes **;
  
  length address_geo $ 160;
  
  select ( ID );
    when ( 97 )
      address_geo = '1852 Providence St NE';
    when ( 98 )
      address_geo = '1864 Central Place NE';
    when ( 102 )
      address_geo = '1913 Gallaudet St NE';
    when ( 167 )
      address_geo = '115 16th St NE';
    when ( 102 )
      address_geo = '1913 Gallaudet St NE';
    when ( 192 )
      address_geo = '2850 Douglass Pl SE';
    otherwise
      address_geo = address;
  end;
  
  if ClosingFiscalYear in ( '#VALUE!', '1905' ) then ClosingFiscalYear = '';
  
  if length( xClosingDate ) = 4 then do;
    ClosingDate = mdy( 12, 31, input( xClosingDate, 4. ) );
    ClosingFiscalYear = left( input( xClosingDate, 4. ) + 1 );
  end;
  else 
    ClosingDate = input( xClosingDate, mmddyy10. );
  
  format ClosingDate mmddyy10.;
  
  drop xClosingDate;

run;


%File_info( 
  data=DCFPI_pipeline, 
  freqvars=DeveloperType AppFiscalYear SelectionFiscalYear ApplicationType 
           Tenure ProjectType LIHTCType LoanStatus ClosingFiscalYear 
)


%DC_mar_geocode(
  geo_match=Y,
  data=DCFPI_pipeline,
  out=DCFPI_pipeline_geo,
  staddr=address_geo,
  zip=,
  id=ID,
  ds_label=,
  listunmatched=Y
)

proc sql noprint;
  create table Pipeline_nlihc_id as
  select coalesce( Catalog.bldg_address_id, Pipeline.address_id ) as address_id, Pipeline.*, Catalog.*,
    case 
    when not( missing( Catalog.nlihc_id ) ) or Pipeline.ProjectType not in ( 'New Construction', '' ) then 1
    else 0
    end as IsPreservation
  from (
    select coalesce( Building.Nlihc_id, Project.Nlihc_id ) as Nlihc_id, Building.bldg_address_id, 
      Project.proj_name as Catalog_name, Project.category_code as Catalog_category,
      Project.status as Catalog_status, Project.subsidized as Catalog_subsidized,
      Project.proj_units_tot as Catalog_units_total, Project.Proj_units_assist_min as Catalog_units_assist_min, 
      Project.Proj_units_assist_max as Catalog_units_assist_max
    from PresCat.Building_geocode as Building 
    left join
    PresCat.Project_category_view as Project
    on Building.Nlihc_id = Project.Nlihc_id 
    where Building.nlihc_id ~= 'NL000202'  /** Duplicate match for Mayfair Mansions **/
  ) as Catalog
  right join 
  DCFPI_pipeline_geo as Pipeline
  on Catalog.bldg_address_id = Pipeline.address_id
  order by id, nlihc_id;
quit;

** Multiple matches **;

%Dup_check(
  data=Pipeline_nlihc_id,
  by=id Projectname,
  id=nlihc_id catalog_name,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)

options missing=' ';

ods listing close;
ods tagsets.excelxp file="&_dcdata_default_path\Requests\Prog\2018\DCFPI_pipeline_catalog.xls" style=Normal options(sheet_interval='None' );
ods tagsets.excelxp options( sheet_name="DCFPI_pipeline_catalog" );

proc print data=Pipeline_nlihc_id;
  id id;
  var 
    ProjectName Address Ward2012 Developer DeveloperType NewRowAdded
    InfoVerified WhoEdited AppFiscalYear SelectionFiscalYear
    ApplicationType TOPA PADD Tenure ProjectType pctAMIUnits30
    pctAMIUnits50 pctAMIUnits60 pctAMIUnits80 pctAMIUnits81 PSHUnits
    AffordableUnits TotalUnits LRSPUnits AffordableUnits01Bdrm
    AffordableUnits2pBdrm TotalDevelopmentCost
    HPTFLoanGrantAmount TCE HOPWA CIP NSP CDBG HOME DBH
    TotalLoanGrantAmount LIHTCAllocation LIHTCType LoanStatus
    ClosingDate ClosingFiscalYear 
    nlihc_id Catalog_: IsPreservation;
run;

ods tagsets.excelxp close;
ods listing;


** Summary of preserved units & investments **;

%fdate()

options missing='0';
options nodate nonumber;

ods rtf file="&_dcdata_default_path\Requests\Prog\2018\DCFPI_pipeline.rtf" style=Styles.Rtf_arial_9pt;

footnote1 height=9pt "Data compiled by DC Fiscal Policy Institute from DC government and other sources, tabulated by Urban-Greater DC (greaterdc.urban.org), &fdate..";
footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

proc tabulate data=Pipeline_nlihc_id format=comma12.0 noseps missing;
  where IsPreservation and ClosingFiscalYear in ( '2015', '2016', '2017', '2018' );
  var AffordableUnits HPTFLoanGrantAmount OtherPublic LIHTCAllocation;
  class ClosingFiscalYear;
  class Ward2012 / preloadfmt;
  table 
    /** Pages **/
    AffordableUnits='Affordable housing units (at or below 80% AMI)' 
    HPTFLoanGrantAmount='HPTF loan/grant amount ($)' 
    OtherPublic='Other public investment amount ($)' 
    LIHTCAllocation='LIHTC allocation ($)',
    /** Rows **/
    all='Total' Ward2012=' ',
    /** Columns **/
    sum=' ' * ClosingFiscalYear='By Actual or Projected Fiscal Year Closing'
    / condense printmiss;
run;

ods rtf close;
