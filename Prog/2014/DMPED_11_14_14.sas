/**************************************************************************
 Program:  DMPED_11_14_14.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/14/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Request from DC DMPED, 11/14/14.

 Modifications:
  11/17/14 PAT Added table showing counts of projects and units by subisdy.
               Removed 2 projects with Project Rental Assistance Contract 
               (PRAC).
               Renamed output file to DMPED_11_17_14.xls.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( PresCat )

** Read in census tracts for Promise Zone **;

data Tracts;

  length geo2010 $ 11;

  input tract;
  
  geo2010 = '11001' || put( tract * 100, z6. );
  
  if put( geo2010, $geo10v. ) = '' then put 'Invalid tract: ' tract= geo2010=;

datalines;
64.00
68.04
71.00
72.00
73.04
74.01
74.03
74.04
74.06
74.07
74.08
74.09
75.02
75.03
75.04
76.01
76.03
76.04
76.05
77.03
77.07
77.08
77.09
78.03
78.04
78.06
78.07
78.08
78.09
79.01
79.03
87.01
87.02
88.02
88.03
88.04
89.03
89.04
90.00
91.02
96.01
96.02
96.03
96.04
97.00
98.01
98.02
98.03
98.04
98.07
98.10
98.11
99.01
99.02
99.03
99.04
99.05
99.06
99.07
104.00
109.00
111.00
;

run;

%Data_to_format(
  FmtLib=work,
  FmtName=$tracts,
  Desc=,
  Data=Tracts,
  Value=geo2010,
  Label=geo2010,
  OtherLabel="",
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

** Subsidy list for projects **;

/*
%Super_transpose(  
  data=PresCat.Subsidy,
  out=Subsidy_tr,
  var=Portfolio,
  id=,
  by=nlihc_id,
  mprint=N
)
*/


data Subsidy;

  merge 
    PresCat.Subsidy
    PresCat.Project (keep=nlihc_id geo2010);
  by nlihc_id;
  
  if put( geo2010, $tracts. ) ~= "";
  if portfolio ~= "Project Rental Assistance Contract (PRAC)";
  
  if Subsidy_active and 2014 <= year( POA_end ) <= 2024 then Units_expire_2024 = Units_Assist;
  else Units_expire_2024 = 0;
  
run;

/*
proc print data=Subsidy;
  where nlihc_id = 'NL000029';
  id nlihc_id;
run;
*/

proc summary data=Subsidy;
  by nlihc_id;
  var Units_expire_2024;
  output out=Subsidy_sum sum=;
run;

data Project_subsidy;

  merge 
    PresCat.Project 
      (where=(put( geo2010, $tracts. ) ~= "" and status = 'A' and Subsidized)
       in=in1)
    Subsidy_sum (drop=_freq_ _type_);
  by nlihc_id;

  if in1;
  
  Units_expire_2024 = min( Proj_Units_Assist_Max, Units_expire_2024 );
  
run;

** Create project list from Preservation Catalog **;

ods tagsets.excelxp file="L:\Libraries\Requests\Prog\2014\DMPED_11_17_14.xls" style=Minimal options(sheet_interval='Proc' );
ods listing close;

ods tagsets.excelxp options( sheet_name="Projects" );

proc print data=Project_subsidy noobs;
  where Units_expire_2024 > 0;
  id nlihc_id;
  var Proj_Name Proj_Addre Proj_Zip Proj_Units_: Units_expire_2024 Subsidy_end_: Ward2012 Geo2010 Cluster_tr2000: Proj_x Proj_y Proj_lat Proj_lon Subsidy:; 
run;

ods tagsets.excelxp options( sheet_name="Subsidies" );

proc tabulate data=Subsidy format=comma12.0 noseps missing;
  where Units_expire_2024 > 0;
  class portfolio /order=freq;
  var Units_expire_2024;
  table 
    /** Rows **/
    portfolio=' ',
    /** Columns **/
    Units_expire_2024='Expiring by 2024' * ( n='Projects' sum='Units' ) 
    / rts=60 box='Subsidy'
  ;
run;

ods tagsets.excelxp close;
ods listing;


