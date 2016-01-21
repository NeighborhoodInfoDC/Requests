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
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( REALPROP )
/*FY10 - Oct09-Sep10; FY11 Oct10-Sep11; FY12 Oct11-Sep12; FY13 Oct12-Sep13; */ 

rsubmit;
proc download data=rod.foreclosures_2013 out=rod.foreclosures_2013;
run;
proc download data=rod.foreclosures_2012 out=rod.foreclosures_2012;
run;
proc download data=rod.foreclosures_2011 out=rod.foreclosures_2011;
run;
proc download data=rod.foreclosures_2010 out=rod.foreclosures_2010;
run;
proc download data=rod.foreclosures_2009 out=rod.foreclosures_2009;
run;
endrsubmit; 
%macro all_wards( );

	%let filepath = D:\DCDATA\Libraries\ROD\Prog\ ;
		%let filename = Carmen 2-6-13.xls ;

		data foreclosure_set1;
			set /*rod.foreclosures_2013*/ rod.foreclosures_2012 rod.foreclosures_2011 rod.foreclosures_2010 rod.foreclosures_2009;
			if ui_proptype = '12' then ui_proptype = '14';
			if ui_proptype = '13' then ui_proptype = '14';
		run;

		/*Filter in instrument and property types of interest, select date range*/
		proc sort data = foreclosure_set1
				(where = (ui_instrument in('F1' 'F5' 'D1' 'M1') and
				(ui_proptype = '10' or ui_proptype = '11' or ui_proptype = '14') and
				('31dec2012'd >= FilingDate >= '01oct2009'd)));
			by FilingDate;
		run;

		proc sort data = foreclosure_set1 out=foreclosure_set;
			by FilingDate;
		run;

		%classify (sf,'10','D1',default);  
		%classify (sf,'10','M1',mediate);  
		%classify (sf,'10','F1',notice);     
		%classify (sf,'10','F5',deed);
		%classify (condo,'11','D1',default);
		%classify (condo,'11','M1',mediate);
		%classify (condo,'11','F1',notice);
		%classify (condo,'11','F5',deed);
		%classify (multi,'14','D1',default);
		%classify (multi,'14','M1',mediate);
		%classify (multi,'14','F1',notice);
		%classify (multi,'14','F5',deed);

		data recombo;
		set sf_default_summ sf_mediate_summ sf_notice_summ sf_deed_summ condo_default_summ condo_mediate_summ condo_notice_summ 
		condo_deed_summ multi_default_summ multi_mediate_summ multi_notice_summ multi_deed_summ;
		count=1;

		new_inst=.;
		if ui_instrument='D1' then new_inst=1;
		if ui_instrument='M1' then new_inst=2;
		if ui_instrument='F1' then new_inst=3;
		if ui_instrument='F5' then new_inst=4;

		format new_inst inst. ui_proptype $prop.;
		run;

	ods tagsets.excelxp file="&filepath.&filename."  style=styles.minimal_mystyle options(sheet_interval='page' );
				ods tagsets.excelxp options( sheet_name="DC");

				proc tabulate data=recombo format=comma10.;

				     class ui_proptype Fiscal_yr new_inst;
				      var count;
				       table ui_proptype="Property Type"*Fiscal_yr="Fiscal Year",
				          new_inst="Type of Notice"*count=" "*sum=" " 
				             / rts=25 printmiss MISSTEXT='0';
				 
				run;
	
%do ward = 1 %to 8;

			%let sheetname = Ward&ward. ;

		/*Filter by ward, if necessary*/
		proc sort data = foreclosure_set1 (where = (Ward2012 = "&ward.")) out=foreclosure_set;
			by FilingDate;
		run;

		%classify (sf,'10','D1',default);  
		%classify (sf,'10','M1',mediate);  
		%classify (sf,'10','F1',notice);     
		%classify (sf,'10','F5',deed);
		%classify (condo,'11','D1',default);
		%classify (condo,'11','M1',mediate);
		%classify (condo,'11','F1',notice);
		%classify (condo,'11','F5',deed);
		%classify (multi,'14','D1',default);
		%classify (multi,'14','M1',mediate);
		%classify (multi,'14','F1',notice);
		%classify (multi,'14','F5',deed);


		data recombo_&ward.;
		set sf_default_summ sf_mediate_summ sf_notice_summ sf_deed_summ condo_default_summ condo_mediate_summ condo_notice_summ 
		condo_deed_summ multi_default_summ multi_mediate_summ multi_notice_summ multi_deed_summ;
		count=1;

		new_inst=.;
		if ui_instrument='D1' then new_inst=1;
		if ui_instrument='M1' then new_inst=2;
		if ui_instrument='F1' then new_inst=3;
		if ui_instrument='F5' then new_inst=4;

		format new_inst inst. ui_proptype $prop.;
		run;

ods tagsets.excelxp options( sheet_name="Ward&ward.");

				proc tabulate data=recombo_&ward. format=comma10.;

				     class ui_proptype Fiscal_yr new_inst;
				      var count;
				       table ui_proptype="Property Type"*Fiscal_yr="Fiscal Year",
				          new_inst="Type of Notice"*count=" "*sum=" " 
				             / rts=25 printmiss MISSTEXT='0';
				 
				run;
%end;	

 ods tagsets.excelxp close;
%mend all_wards;


%macro classify (prop,code,instr,label);

data &prop._&label.;
	set foreclosure_set;

	FilingQtr=intnx( "qtr", FilingDate, 0, 'end' );

	format filingqtr mmddyy10.;

	length Fiscal_yr $4.;
	if FilingQtr in ('31dec2009'd '31mar2010'd '30jun2010'd '30sep2010'd) then Fiscal_yr="FY10";
    if FilingQtr in ('31dec2010'd '31mar2011'd '30jun2011'd '30sep2011'd) then Fiscal_yr="FY11";
	if FilingQtr in ('31dec2011'd '31mar2012'd '30jun2012'd '30sep2012'd) then Fiscal_yr="FY12";
	if FilingQtr in ('31dec2012'd '31mar2013'd '30jun2013'd '30sep2013'd) then Fiscal_yr="FY13";
run;

proc sort data = &prop._&label.
		(where = (ui_proptype = &code. and ui_instrument = &instr.));
	by Fiscal_yr;
run;

proc summary data=&prop._&label. nway;
	class Fiscal_yr ui_proptype ui_instrument ssl;
	id x_coord y_coord;
	output out = &prop._&label._summ;
run;
%mend; 

%all_wards()           /** Invoke the loop macro **/



proc format ;
	value inst

	1="Notice of Default"
	2="Mediation Certificate"
	3="Notice of Foreclosure Sale"
	4="Trustees' Deed Sale"

	;

	value $prop

	10='Single-Family Home'
	11='Condominium Unit'
	14='Multi-Family Bldg.';

	run;



