/**************************************************************************
 Program:  Herring_2008_11_21.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/21/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Census tabulation for Rosie Allen Herring:
Avg. family income, 2000 ($ 2007)


 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )

data A;

  set Ncdb.Ncdb_sum_eor (keep=eor NumFamilies_2000 AggFamilyIncome_2000);
  where eor = '1';
  
  %dollar_convert( AggFamilyIncome_2000, AggFamilyIncome_2000_2007d, 2000, 2007 )
  
  put eor= / AggFamilyIncome_2000= / AggFamilyIncome_2000_2007d= / NumFamilies_2000=;

run;

signoff;
