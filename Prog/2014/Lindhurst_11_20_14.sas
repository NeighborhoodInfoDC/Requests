/**************************************************************************
 Program:  Lindhurst_11_20_14.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/20/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  I'm trying to put my hands on the number of tax credit
 units in the city. I looked at a HUD data user set and it says
 around 17,900 but that seems high to me. 
 Rebecca Lindhurst, Managing Attorney, Bread for the City Legal
 Clinic, rlindhu@breadforthecity.org

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( PresCat )

data LIHTC;

  merge 
    PresCat.Project (keep=nlihc_id proj_name category)
    PresCat.Subsidy;
  by nlihc_id;

  if portfolio = 'LIHTC' and subsidy_active and category ~=: '6';
  
  lihtc_years = intck( 'year', poa_start, date() );
  
run;

***ods tagsets.excelxp file="L:\Libraries\Requests\Prog\2014\Lindhurst_11_20_14.xls" style=Minimal options(sheet_interval='Proc' );
ods csvall body="L:\Libraries\Requests\Prog\2014\Lindhurst_11_20_14.csv";

proc print data=LIHTC label n;
  id nlihc_id;
  var proj_name poa_start lihtc_years units_assist;
  sum units_assist;
  *format units_assist comma10.0;
  label 
    nlihc_id = 'Catalog ID'
    proj_name = 'Project name'
    poa_start = 'Affordability start' 
    lihtc_years = 'Tax credit years'
    units_assist = 'Assisted units';
run;

***ods tagsets.excelxp close;
ods csvall close;


