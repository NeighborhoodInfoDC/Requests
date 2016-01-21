/**************************************************************************
 Program:  Cobble_2000old.sas
 Library:  requests
 Project:  NeighborhoodInfo DC
 Author:   Jenn Comey
 Created:  8/23/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Selects number and proportion of seniors from Census long form for Karen Cobble. 
 Modifications:
**************************************************************************/

libname request 'K:\Metro\PTatian\DCData\Libraries\Requests\Prog ';

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ncdb )
%DCData_lib( requests ) /*Megan had this line, not sure of the purpose*/

rsubmit;
data ncdb00_old;/* creates a file on the alpha - temp */
set ncdb.ncdb_lf_2000_dc (keep= geo2000 
 /* seniors */ old0n old0);
 

proc download inlib=work outlib=request; /* download to PC */
select ncdb00_old; 

run;

endrsubmit; 

signoff;


*******************************************************************
WARD-LEVEL ANALYSES
******************************************************************;

/* transforms tracts to wards */
%Transform_geo_data(
    dat_ds_name = request.ncdb00_old,
    dat_org_geo = geo2000, 

/* add in vars here count*/	
    dat_count_vars = old0n,

/* add in vars here proportion*/
	dat_prop_vars = old0 , 


	
	wgt_ds_name = general.wt_tr00_ward02,
	wgt_org_geo=geo2000,
	wgt_new_geo=ward2002,
    wgt_wgt_var = popwt,
	
    out_ds_name = Request.seniors_ward,
    out_ds_label = Seniors by ward);

run;


proc sort data=Request.seniors_ward;
by ward2002;
run;

filename outexc dde "Excel|K:\Metro\PTatian\DCData\Libraries\Requests\Raw [Seniors by ward.xls]"; 

filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\seniors_ward.csv" lrecl=2000;

proc export data=Request.seniors_ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;