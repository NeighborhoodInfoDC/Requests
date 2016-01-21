/**************************************************************************
 Program:  Upload_mh_homebuyers_07_09_12_09.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/23/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload file mh_homebuyers_07_09_12_09 to Alpha for
 geocoding.

 Modifications:
**************************************************************************/

%include dcdatinc( Stdhead.sas );
%include dcdatinc( AlphaSignon.sas );

** Define libraries **;
%DCData_lib( Requests, conf_dat=y )

data mh_homebuyers_07_09_12_09;

  set Requests.mh_homebuyers_07_09_12_09;
  
  length x_Zip_Code $ 5;
  
  x_Zip_Code = put( Zip_Code, z5. );
  
  format _all_;
  informat _all_;
  
  drop Zip_Code;
  rename x_Zip_Code = Zip_Code;
  
run;

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=Work 
  outlib=Requests memtype=(data);
  select mh_homebuyers_07_09_12_09;

run;

%File_info( data=Requests.mh_homebuyers_07_09_12_09, printobs=0, freqvars=Zip_Code )

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
