/**************************************************************************
 Program:  David Bardin Request.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  06/08/15
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create race comparisons dating back to 1970 for Ward 3, ANC 3F and Cluster 12. Obtained NCDB 2010 from C. Hayes
 Modifications:
**************************************************************************/ 
%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;

%DCData_lib( NCDB )
proc contents data=ncdb.ncdb_master_update22615;
run;

data dc_only;
set ncdb.ncdb_master_update22615;
where statecd="11";
run;
 %Transform_geo_data(
      dat_ds_name=dc_only,
      dat_org_geo=geo2010,
      dat_count_vars=PFLG26 PFLG1 TRCTPOP7 NONHISP7 SHRBLK7N SHRWHT7N SHR7D FORBORN7 NONHISP8 SHRBLK8N SHRWHT8N SHR8D FORBORN8 NONHISP9 SHRBLK9N SHRWHT9N  SHR9D FORBORN9 NONHISP0 SHRBLK0N SHRWHT0N  SHR0D FORBORN0 NONHISP1 SHRBLK1N SHRWHT1N  SHR1D FORBORN1A, 
      wgt_ds_name=General.wt_tr10_ward12,
      wgt_org_geo=geo2010,
      wgt_new_geo=ward2012,
      wgt_wgt_var=popwt,
      out_ds_name=dcrace_sum_tr10_ward12,
      mprint=n
    )

 %Transform_geo_data(
      dat_ds_name=dc_only,
      dat_org_geo=geo2010,
      dat_count_vars=PFLG26 PFLG1 TRCTPOP7 NONHISP7 SHRBLK7N SHRWHT7N SHR7D FORBORN7 NONHISP8 SHRBLK8N SHRWHT8N SHR8D FORBORN8 NONHISP9 SHRBLK9N SHRWHT9N  SHR9D FORBORN9 NONHISP0 SHRBLK0N SHRWHT0N  SHR0D FORBORN0 NONHISP1 SHRBLK1N SHRWHT1N  SHR1D FORBORN1A, 
      wgt_ds_name=General.wt_tr10_cltr00,
      wgt_org_geo=geo2010,
      wgt_new_geo=cluster_tr2000,
      wgt_wgt_var=popwt,
      out_ds_name=dcrace_sum_tr10_cltr00,
      mprint=n
    )

	 %Transform_geo_data(
      dat_ds_name=dc_only,
      dat_org_geo=geo2010,
      dat_count_vars=PFLG26 PFLG1 TRCTPOP7 NONHISP7 SHRBLK7N SHRWHT7N SHR7D FORBORN7 NONHISP8 SHRBLK8N SHRWHT8N SHR8D FORBORN8 NONHISP9 SHRBLK9N SHRWHT9N  SHR9D FORBORN9 NONHISP0 SHRBLK0N SHRWHT0N  SHR0D FORBORN0 NONHISP1 SHRBLK1N SHRWHT1N  SHR1D FORBORN1A, 
      wgt_ds_name=General.wt_tr10_city,
      wgt_org_geo=geo2010,
      wgt_new_geo=city,
      wgt_wgt_var=popwt,
      out_ds_name=dcrace_sum_tr10_city,
      mprint=n
    )

	%Transform_geo_data(
      dat_ds_name=dc_only,
      dat_org_geo=geo2010,
      dat_count_vars=PFLG26 PFLG1 TRCTPOP7 NONHISP7 SHRBLK7N SHRWHT7N SHR7D FORBORN7 NONHISP8 SHRBLK8N SHRWHT8N SHR8D FORBORN8 NONHISP9 SHRBLK9N SHRWHT9N  SHR9D FORBORN9 NONHISP0 SHRBLK0N SHRWHT0N  SHR0D FORBORN0 NONHISP1 SHRBLK1N SHRWHT1N  SHR1D FORBORN1A, 
      wgt_ds_name=General.wt_tr10_anc12,
      wgt_org_geo=geo2010,
      wgt_new_geo=Anc2012,
      wgt_wgt_var=popwt,
      out_ds_name=dcrace_sum_tr10_anc12,
      mprint=n
    )

data dc_race;
set dcrace_sum_tr10_city dcrace_sum_tr10_ward12  dcrace_sum_tr10_cltr00 dcrace_sum_tr10_anc12;
 

PCTFOR7=FORBORN7/TRCTPOP7*100;
PCTNHSP7=NONHISP7/SHR7D*100;
PCTWHT7=SHRWHT7N/SHR7D*100;
PCTBLK7=SHRBLK7N/SHR7D*100;

PCTFOR8=FORBORN8/SHR8D*100;
PCTNHSP8=NONHISP8/SHR8D*100;
PCTWHT8=SHRWHT8N/SHR8D*100;
PCTBLK8=SHRBLK8N/SHR8D*100;

PCTFOR9=FORBORN9/SHR9D*100;
PCTNHSP9=NONHISP9/SHR9D*100;
PCTWHT9=SHRWHT9N/SHR9D*100;
PCTBLK9=SHRBLK9N/SHR9D*100;

PCTFOR0=FORBORN0/SHR0D*100;
PCTNHSP0=NONHISP0/SHR0D*100;
PCTWHT0=SHRWHT0N/SHR0D*100;
PCTBLK0=SHRBLK0N/SHR0D*100;

PCTFOR1=FORBORN1A/SHR1D*100;
PCTNHSP1=NONHISP1/SHR1D*100;
PCTWHT1=SHRWHT1N/SHR1D*100;
PCTBLK1=SHRBLK1N/SHR1D*100;

run;

proc print data= dc_race;
var 

city ward2012 cluster_tr2000 anc2012  
PCTBLK7
PCTBLK8
PCTBLK9
PCTBLK0
PCTBLK1

PCTFOR7
PCTFOR8
PCTFOR9
PCTFOR0
PCTFOR1


PCTNHSP7
PCTNHSP8
PCTNHSP9
PCTNHSP0
PCTNHSP1


PCTWHT7
PCTWHT8
PCTWHT9
PCTWHT0
PCTWHT1;
run;

