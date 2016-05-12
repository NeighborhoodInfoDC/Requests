************************************************************************
* Program:  Tract_Conversion.sas
* Library:  NCDB
* Project:  DC Data Warehouse
* Author:   J.Fenderson
* Created:  07/07/05
* Version:  SAS 8.2
* Environment:  Windows
* 
* Description:  This program converts 1980 tracts to 2000 tracts
*  
* Modifications:
************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( NCDB )


%Transform_geo_data(
    dat_ds_name=Ncdb.tanf_fscount,
    dat_org_geo=geo1980,
    dat_count_vars=fscount tcount,
    wgt_ds_name=Ncdb.twt80_00_dc1,
    wgt_org_geo=geo1980,
    wgt_new_geo=geo2000,
    wgt_wgt_var=weight,
    out_ds_name=Ncdb.dc_tanf_fs_final,
    out_ds_label= DC TANF and Food Stamp Counts,
    keep_nonmatch=Y
  )
