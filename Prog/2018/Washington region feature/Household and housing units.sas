/**************************************************************************
 Program:  Household and housing units.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  06/28/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Household and housing unit counts for Washington
region feature.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )
%DCData_lib( ACS )


proc summary data=ncdb.ncdb_master_update;
  by ucounty; 
  var numhhs9 numhhs0 numhhs1 tothsun9 tothsun0 tothsun1;
  output out=Ncdb (drop=_type_ _freq_) sum=;
run;

data ACSallstates;
    set acs.acs_2012_16_va_sum_regcnt_regcnt acs.acs_2012_16_dc_sum_regcnt_regcnt acs.acs_2012_16_md_sum_regcnt_regcnt acs.acs_2012_16_wv_sum_regcnt_regcnt;
      by county;
      keep county numhshlds_2012_16 numhsgunits_2012_16;
      
run;

data Ncdb_acs;

  merge NCDB ACSallstates (rename=(county=ucounty));
  by ucounty;
  
    metro15 = put( ucounty, $ctym15f. );
    if metro15 = "47900";
    
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;
      
  format ucounty $cnty15f.;

run;

options missing=' ';

ods csvall body="&_dcdata_default_path\Requests\Prog\2018\Washington region feature\Household and housing units.csv";

proc print;
  id ucounty;
  var innercounty numhhs9 numhhs0 numhhs1 numhshlds_2012_16 tothsun9 tothsun0 tothsun1 numhsgunits_2012_16;
  sum numhhs9 numhhs0 numhhs1 numhshlds_2012_16 tothsun9 tothsun0 tothsun1 numhsgunits_2012_16;
run;

ods csvall close;

run;
