/**************************************************************************
 Program:  Population for MSA and inner regions.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng and Rob
 Created:  6/26/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )

data NCDBMaster
      set ncdb.ncdb_master_update;
      metro15 = put( ucounty, $ctym15f. );
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600") then innercounty = 1;
run;


proc summary data = NCDBMaster;
      var trctpop7 trctpop8 trctpop9 trctpop0;
      output out = msa_pop sum=;
run;


proc summary data = NCDBMaster (where=(innercounty=1));
      var trctpop7 trctpop8 trctpop9 trctpop0;
      output out = inner_pop sum=;
run;
