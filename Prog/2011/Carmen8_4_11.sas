/**************************************************************************
 Program:  Pull for Evelyn Carmen 8-4-11.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  8-4-11

 Description:  Counts the number of foreclosure sale notices and trustee deeds on
			   single family homes, multi-family homes, and condos, between
			   10/1/10 and 7/31/11.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )

%macro all_wards( );
%do ward = 1 %to 8;

%let filepath = D:\DCData\Requests\Spreadsheets\ ;
%let filename = Carmen 8-4-11.xls ;
%let sheetname = Ward&ward. ;

data foreclosure_set;
	set rod.foreclosures_2011 rod.foreclosures_2010;
	if ui_proptype = '12' then ui_proptype = '14';
	if ui_proptype = '13' then ui_proptype = '14';
run;

/*Filter in instrument and property types of interest, select date range*/
proc sort data = foreclosure_set
		(where = ((ui_instrument = 'F1' or ui_instrument = 'F5') and
		(ui_proptype = '10' or ui_proptype = '11' or ui_proptype = '14') and
		('31jul2011'd >= FilingDate >= '01oct2010'd)));
	by FilingDate;
run;

/*Filter by ward, if necessary*/
proc sort data = foreclosure_set (where = (Ward2002 = "&ward."));
	by FilingDate;
run;

%classify (sf,'10','F1',notice,2,2);     /** Move these inside the loop **/
%classify (sf,'10','F5',deed,2,3);
%classify (condo,'11','F1',notice,3,2);
%classify (condo,'11','F5',deed,3,3);
%classify (multi,'14','F1',notice,4,2);
%classify (multi,'14','F5',deed,4,3);

%end;

%mend all_wards;


%macro classify (prop,code,instr,label,row,col);

data &prop._&label.;
	set foreclosure_set;
run;

proc sort data = &prop._&label.
		(where = (ui_proptype = &code. and ui_instrument = &instr.));
	by FilingDate;
run;

proc summary data=&prop._&label. nway;
	class ui_proptype ui_instrument ssl;
	id x_coord y_coord;
	output out = &prop._&label._summ;
run;

proc freq data = &prop._&label._summ noprint;
	tables ui_proptype / out = &prop._&label._freq;
run;

filename excelout dde "Excel|&filepath.[&filename.]&sheetname.!R&row.C&col.:R&row.C&col."   lrecl=59000;
	data _null_;	  set &prop._&label._freq;  	    file excelout;	
	put count;
run;

filename excelout clear;   /** Clear excelout so that you can reassign on the next loop pass **/

%mend;

%all_wards()           /** Invoke the loop macro **/
