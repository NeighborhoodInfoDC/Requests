/**************************************************************************
 Program:  PopByRace_2000.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/03/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Population by race for neighborhood clusters.
For Cheryl Pruce.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )

** Start submitting commands to remote server **;

rsubmit;

data PopByRace_2000;

  set Ncdb.NCDB_SUM_CLTR00 
    (keep=cluster_tr2000 PopBlackNonHispBridge_2000 PopAsianPINonHispBridge_2000
          PopWhiteNonHispBridge_2000 PopNativeAmNonHispBridge_2000 
          PopOtherNonHispBridge_2000 PopHisp_2000 PopWithRace_2000);
          
  format _all_ ;

run;

proc download status=no
  data=PopByRace_2000 
  out=Requests.PopByRace_2000 (compress=no);

run;

endrsubmit;

** End submitting commands to remote server **;


%File_info( data=Requests.PopByRace_2000 )

run;

signoff;
