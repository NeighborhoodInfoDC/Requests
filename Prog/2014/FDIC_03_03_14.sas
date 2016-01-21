/**************************************************************************
 Program:  FDIC_03_03_14.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/03/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Data for presentation at FDIC bankers session, 3/5/14.
 
 Data on Maryland counties from 2000 Census and 2008-12 ACS.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ACS )
%DCData_lib( NCDB )

proc format;
  value $cnty
    "24031" = "Montgomery County" 
    "24033" = "Prince George's County" 
    "24009" = "Calvert County" 
    "24017" = "Charles County" 
    "24021" = "Frederick County"
    other = " ";
run;

** NCDB 2000 Data **;

%let year = 2000;
%let y = 0;

data Ncdb_2000_tr;

  set Ncdb.Ncdb_lf_2000_was03 (drop=OCC011F0);
  
  where put( ucounty, $cnty. ) ~= "";
 
  PopEmployedIndAgricMining = sum(IND011&y.,IND021&y.);
  PopEmployedIndTransport = sum(IND048&y.,IND022&y.);
  PopEmployedIndFIRE = sum(IND052&y.,IND053&y.);
  PopEmployedIndProfessional = sum(IND054&y.,IND055&y.,IND056&y.);
  PopEmployedIndEducational = sum(IND061&y.,IND062&y.);
  PopEmployedIndArts = sum(IND071&y.,IND072&y.);
  
  PopEmployedOccConstruction = sum(OCC047&y.,OCC049&y.);
  PopEmployedOccManagement = sum(OCC011&y.,OCC013&y.,OCC015&y.,OCC017&y.,OCC019&y.,
                                       OCC021&y.,OCC023&y.,OCC025&y.,OCC027&y.,OCC029&y.);
  PopEmployedOccProduction = sum(OCC051&y.,OCC053&y.);
  PopEmployedOccSales = sum(OCC041&y.,OCC043&y.);
  PopEmployedOccService = sum(OCC031&y.,OCC033&y.,OCC035&y.,OCC037&y.,OCC039&y.);
  PopEmployedOccFarm = sum( OCC045&y. );
  PopEmployedOccTotal = sum( of OCC0: );
  
  Pop25andOverWoutHS = sum(EDUC8&y.,EDUC11&y.);
  Pop25andOverWHS = SUM(EDUC12&y.,EDUC15&y.,/*EDUC16&y.,*/EDUCA&y.);
  
  rename
    EDUC16&y.=Pop25andOverWCollege
    EDUCPP&y.=Pop25andOverYears;
        
  keep ucounty Pop: EDUC16&y. EDUCPP&y.;

run; 

proc summary data=Ncdb_2000_tr nway;
  class ucounty;
  var Pop: ;
  output out=Ncdb_2000_cnty sum=;
run;

data FDIC_03_03_14;

  set
    Ncdb_2000_cnty
    ACS.ACS_2008_12_sum_md_tr_cnty
      (where=(put( ucounty, $cnty. ) ~= "")
       rename=(
         Pop25andOverYears_2008_12=Pop25andOverYears
         Pop25andOverWoutHS_2008_12=Pop25andOverWoutHS
         Pop25andOverWHS_2008_12=Pop25andOverWHS
         Pop25andOverWCollege_2008_12=Pop25andOverWCollege
         PopEmployedOccConstruct_2008_12=PopEmployedOccConstruction
         PopEmployedOccManagement_2008_12=PopEmployedOccManagement
         PopEmployedOccProduction_2008_12=PopEmployedOccProduction
         PopEmployedOccSales_2008_12=PopEmployedOccSales
         PopEmployedOccService_2008_12=PopEmployedOccService
         PopEmployedOccFarm_2008_12=PopEmployedOccFarm
         PopEmployedOccTotal_2008_12=PopEmployedOccTotal
       )
       in=in2008_12);
  by ucounty;
  
  PopEmployedOccProdFarm = sum( PopEmployedOccProduction, PopEmployedOccFarm );
    
  if in2008_12 then Year = "2008-12";
  else Year = "2000";
  
  format ucounty $cnty.;
  
  keep ucounty Year PopEmployedOcc: Pop25: ;

run;

%File_info( data=FDIC_03_03_14, printobs=0, freqvars=ucounty )

ods tagsets.excelxp file="L:\Libraries\Requests\Prog\2014\FDIC_03_03_14.xls" style=Minimal options(sheet_interval='Page' );

proc tabulate data=FDIC_03_03_14 format=comma10.0 noseps missing;
  class ucounty year;
  var Pop25: PopEmployedOcc:;
  table 
    /** Rows **/
    ucounty=' ' * year=' ',
    /** Columns **/
    sum=' ' * (
      Pop25andOverWoutHS='No HS'
      Pop25andOverWHS='HS/Some college' 
      Pop25andOverWCollege='BA/Advanced'
    )
  ;
  table 
    /** Rows **/
    ucounty=' ' * year=' ',
    /** Columns **/
    sum=' ' * (
      PopEmployedOccManagement='Management/Science/Arts'
      PopEmployedOccSales='Sales/Admin. support'
      PopEmployedOccService='Service'
      PopEmployedOccConstruction='Constr./Maintainence'
      PopEmployedOccProdFarm='Production/Farming'
    )
  ;
run;

ods tagsets.excelxp close;

