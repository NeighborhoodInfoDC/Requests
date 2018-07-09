/**************************************************************************
 Program:  Tenure by Household income.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  6/28/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description: Downloaded 2000 (HCT011) and 2005-2016 1 year estimates from factfinder
			  for B25118 for all counties in the US. 

**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";
%dcdata_lib( requests )
%dcdata_lib( acs )

options symbolgen;

libname raw "L:\Libraries\Requests\Raw\2018\tenure by income"; 

%let year=05 06 07 08 09 10 11 12 13 14 15 16;

%macro all_years; 

%do i = 1 %to 12;  
%let yr=%scan(&year.,&i.," "); 

	data WORK.acs_&yr.   ;
	     %let _EFIERR_ = 0; /* set the ERROR detection macro variable */

		infile "L:\Libraries\Requests\Raw\2018\tenure by income\ACS_&yr._1YR_B25118_with_ann.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=3 ;
	
	     informat GEO_id $14. ;
	     informat GEO_id2 $5. ;
	     informat GEO_display_label $50. ;
	     informat HD01_VD01 best32. ;
	     informat HD02_VD01 best32. ;
	     informat HD01_VD02 best32. ;
	     informat HD02_VD02 best32. ;
	     informat HD01_VD03 best32. ;
	     informat HD02_VD03 best32. ;
	     informat HD01_VD04 best32. ;
	     informat HD02_VD04 best32. ;
	     informat HD01_VD05 best32. ;
	     informat HD02_VD05 best32. ;
	     informat HD01_VD06 best32. ;
	     informat HD02_VD06 best32. ;
	     informat HD01_VD07 best32. ;
	     informat HD02_VD07 best32. ;
	     informat HD01_VD08 best32. ;
	     informat HD02_VD08 best32. ;
	     informat HD01_VD09 best32. ;
	     informat HD02_VD09 best32. ;
	     informat HD01_VD10 best32. ;
	     informat HD02_VD10 best32. ;
	     informat HD01_VD11 best32. ;
	     informat HD02_VD11 best32. ;
	     informat HD01_VD12 best32. ;
	     informat HD02_VD12 best32. ;
	     informat HD01_VD13 best32. ;
	     informat HD02_VD13 best32. ;
	     informat HD01_VD14 best32. ;
	     informat HD02_VD14 best32. ;
	     informat HD01_VD15 best32. ;
	     informat HD02_VD15 best32. ;
	     informat HD01_VD16 best32. ;
	     informat HD02_VD16 best32. ;
	     informat HD01_VD17 best32. ;
	     informat HD02_VD17 best32. ;
	     informat HD01_VD18 best32. ;
	     informat HD02_VD18 best32. ;
	     informat HD01_VD19 best32. ;
	     informat HD02_VD19 best32. ;
	     informat HD01_VD20 best32. ;
	     informat HD02_VD20 best32. ;
	     informat HD01_VD21 best32. ;
	     informat HD02_VD21 best32. ;
	     informat HD01_VD22 best32. ;
	     informat HD02_VD22 best32. ;
	     informat HD01_VD23 best32. ;
	     informat HD02_VD23 best32. ;
	     informat HD01_VD24 best32. ;
	     informat HD02_VD24 best32. ;
	     informat HD01_VD25 best32. ;
	     informat HD02_VD25 best32. ;
	     
	  input
	              GEO_id $
	              GEO_id2 $
	              GEO_display_label $
	              HD01_VD01
	              HD02_VD01
	              HD01_VD02
	              HD02_VD02
	              HD01_VD03
	              HD02_VD03
	              HD01_VD04
	              HD02_VD04
	              HD01_VD05
	              HD02_VD05
	              HD01_VD06
	              HD02_VD06
	              HD01_VD07
	              HD02_VD07
	              HD01_VD08
	              HD02_VD08
	              HD01_VD09
	              HD02_VD09
	              HD01_VD10
	              HD02_VD10
	              HD01_VD11
	              HD02_VD11
	              HD01_VD12
	              HD02_VD12
	              HD01_VD13
	              HD02_VD13
	              HD01_VD14
	              HD02_VD14
	              HD01_VD15
	              HD02_VD15
	              HD01_VD16
	              HD02_VD16
	              HD01_VD17
	              HD02_VD17
	              HD01_VD18
	              HD02_VD18
	              HD01_VD19
	              HD02_VD19
	              HD01_VD20
	              HD02_VD20
	              HD01_VD21
	              HD02_VD21
	              HD01_VD22
	              HD02_VD22
	              HD01_VD23
	              HD02_VD23
	              HD01_VD24
	              HD02_VD24
	              HD01_VD25
	              HD02_VD25
	  ;
	  if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */


	  run;


data washregion_acs_&yr. (where=(metro15="47900"));
	set acs_&yr. (rename=(GEO_id2=ucounty));


 metro15 = put( ucounty, $ctym15f. );
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;

	  label 

	  HD01_VD01="Total Occupied Housing Units"
		HD02_VD01="Margin of Error: Total Occupied Housing Units"
		HD01_VD02="Owner occupied units"
		HD02_VD02="Margin of Error: Owner occupied units"
		HD01_VD03="Owner occupied: - Less than $5,000"
		HD02_VD03="Margin of Error: Owner occupied: - Less than $5,000"
		HD01_VD04="Owner occupied: - $5,000 to $9,999"
		HD02_VD04="Margin of Error: Owner occupied: - $5,000 to $9,999"
		HD01_VD05="Owner occupied: - $10,000 to $14,999"
		HD02_VD05="Margin of Error: Owner occupied: - $10,000 to $14,999"
		HD01_VD06="Owner occupied: - $15,000 to $19,999"
		HD02_VD06="Margin of Error: Owner occupied: - $15,000 to $19,999"
		HD01_VD07="Owner occupied: - $20,000 to $24,999"
		HD02_VD07="Margin of Error: Owner occupied: - $20,000 to $24,999"
		HD01_VD08="Owner occupied: - $25,000 to $34,999"
		HD02_VD08="Margin of Error: Owner occupied: - $25,000 to $34,999"
		HD01_VD09="Owner occupied: - $35,000 to $49,999"
		HD02_VD09="Margin of Error: Owner occupied: - $35,000 to $49,999"
		HD01_VD10="Owner occupied: - $50,000 to $74,999"
		HD02_VD10="Margin of Error: Owner occupied: - $50,000 to $74,999"
		HD01_VD11="Owner occupied: - $75,000 to $99,999"
		HD02_VD11="Margin of Error: Owner occupied: - $75,000 to $99,999"
		HD01_VD12="Owner occupied: - $100,000 to $149,999"
		HD02_VD12="Margin of Error: Owner occupied: - $100,000 to $149,999"
		HD01_VD13="Owner occupied: - $150,000 or more"
		HD02_VD13="Margin of Error: Owner occupied: - $150,000 or more"
		HD01_VD14="Renter occupied units"
		HD02_VD14="Margin of Error: Renter occupied units"
		HD01_VD15="Renter occupied: - Less than $5,000"
		HD02_VD15="Margin of Error: Renter occupied: - Less than $5,000"
		HD01_VD16="Renter occupied: - $5,000 to $9,999"
		HD02_VD16="Margin of Error: Renter occupied: - $5,000 to $9,999"
		HD01_VD17="Renter occupied: - $10,000 to $14,999"
		HD02_VD17="Margin of Error: Renter occupied: - $10,000 to $14,999"
		HD01_VD18="Renter occupied: - $15,000 to $19,999"
		HD02_VD18="Margin of Error: Renter occupied: - $15,000 to $19,999"
		HD01_VD19="Renter occupied: - $20,000 to $24,999"
		HD02_VD19="Margin of Error: Renter occupied: - $20,000 to $24,999"
		HD01_VD20="Renter occupied: - $25,000 to $34,999"
		HD02_VD20="Margin of Error: Renter occupied: - $25,000 to $34,999"
		HD01_VD21="Renter occupied: - $35,000 to $49,999"
		HD02_VD21="Margin of Error: Renter occupied: - $35,000 to $49,999"
		HD01_VD22="Renter occupied: - $50,000 to $74,999"
		HD02_VD22="Margin of Error: Renter occupied: - $50,000 to $74,999"
		HD01_VD23="Renter occupied: - $75,000 to $99,999"
		HD02_VD23="Margin of Error: Renter occupied: - $75,000 to $99,999"
		HD01_VD24="Renter occupied: - $100,000 to $149,999"
		HD02_VD24="Margin of Error: Renter occupied: - $100,000 to $149,999"
		HD01_VD25="Renter occupied: - $150,000 or more"
		HD02_VD25="Margin of Error: Renter occupied: - $150,000 or more"
		;

	  run;

	  
	proc summary data=washregion_acs_&yr. (where=(innercounty=1));

	var HD01: ;
	output out=inner_acs_&yr. sum=;

	run;

	proc transpose data=inner_acs_&yr. out=long_acs_&yr.;
	
	run;

	data long_acs_&yr.a (drop= _name_ rename=(newname=_name_));
		set long_acs_&yr. (rename=(COL1=acs_20&yr.));

		if _name_ in("_TYPE_" "_FREQ_") then delete;

		length newname $4.;

		newname=substr(_name_,6,4);
		
	run;
	%end; 


	%mend all_years;

	%all_years;

data WORK.sf3_2000   ;
	     %let _EFIERR_ = 0; /* set the ERROR detection macro variable */

		infile "L:\Libraries\Requests\Raw\2018\tenure by income\DEC_00_SF3_HCT011_with_ann.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=3 ;
	
	     informat GEO_id $14. ;
	     informat GEO_id2 $5. ;
	     informat GEO_display_label $50. ;
	     informat VD01 best32. ;
	     informat VD02 best32. ;
	     informat VD03 best32. ;
	     informat VD04 best32. ;
	     informat VD05 best32. ;
	     informat VD06 best32. ;
	     informat VD07 best32. ;
	     informat VD08 best32. ;
	     informat VD09 best32. ;
	     informat VD10 best32. ;
	     informat VD11 best32. ;
	     informat VD12 best32. ;
	     informat VD13 best32. ;
	     informat VD14 best32. ;
	     informat VD15 best32. ;
	     informat VD16 best32. ;
	     informat VD17 best32. ;
	     informat VD18 best32. ;
	     informat VD19 best32. ;
	     informat VD20 best32. ;
	     informat VD21 best32. ;
	     informat VD22 best32. ;
	     informat VD23 best32. ;
	     informat VD24 best32. ;
	     informat VD25 best32. ;

	     
	  input
	              GEO_id $
	              GEO_id2 $
	              GEO_display_label $
	              VD01
	              VD02
	              VD03
	              VD04
	              VD05
	              VD06
	              VD07
	              VD08
	              VD09
	              VD10
	              VD11
	              VD12
	              VD13
	              VD14
	              VD15
	              VD16
	              VD17
	              VD18
	              VD19
	              VD20
	              VD21
	              VD22
	              VD23
	              VD24
	              VD25
	  ;
	  if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */


	  run;


data washregion_sf3_2000 (where=(metro15="47900"));
	set sf3_2000 (rename=(GEO_id2=ucounty));


 metro15 = put( ucounty, $ctym15f. );
      if ucounty in ("11001","24031","24033","51013","51059","51107","51510") then innercounty = 1; *excluding Fairfax city and Falls Church city since they are not in the ACS;

	  label 

	  VD01="Total Occupied Housing Units"
		VD02="Owner occupied units"
		VD03="Owner occupied: - Less than $5,000"
		VD04="Owner occupied: - $5,000 to $9,999"
		VD05="Owner occupied: - $10,000 to $14,999"
		VD06="Owner occupied: - $15,000 to $19,999"
		VD07="Owner occupied: - $20,000 to $24,999"
		VD08="Owner occupied: - $25,000 to $34,999"
		VD09="Owner occupied: - $35,000 to $49,999"
		VD10="Owner occupied: - $50,000 to $74,999"
		VD11="Owner occupied: - $75,000 to $99,999"
		VD12="Owner occupied: - $100,000 to $149,999"
		VD13="Owner occupied: - $150,000 or more"
		VD14="Renter occupied units"
		VD15="Renter occupied: - Less than $5,000"
		VD16="Renter occupied: - $5,000 to $9,999"
		VD17="Renter occupied: - $10,000 to $14,999"
		VD18="Renter occupied: - $15,000 to $19,999"
		VD19="Renter occupied: - $20,000 to $24,999"
		VD20="Renter occupied: - $25,000 to $34,999"
		VD21="Renter occupied: - $35,000 to $49,999"
		VD22="Renter occupied: - $50,000 to $74,999"
		VD23="Renter occupied: - $75,000 to $99,999"
		VD24="Renter occupied: - $100,000 to $149,999"
		VD25="Renter occupied: - $150,000 or more"

		;

	  run;

	  
	proc summary data=washregion_sf3_2000  (where=(innercounty=1));

	var VD: ;
	output out=inner_sf3_2000 sum=;

	run;

	proc transpose data=inner_sf3_2000 out=long_sf3_2000;
	
	run;

	data long_sf3_2000a;
		set long_sf3_2000 (rename=(COL1=sf3_1999));

		if _name_ in("_TYPE_" "_FREQ_") then delete;
	run;

	data all_years;
	merge long_sf3_2000a long_acs_05a long_acs_06a long_acs_07a long_acs_07a long_acs_08a long_acs_09a long_acs_10a long_acs_11a long_acs_12a long_acs_13a 
		  long_acs_14a long_acs_15a long_acs_16a;
	
	by _name_;

	if _name_ in("VD01" "VD02" "VD14") then delete;
	run;

   proc export data=all_years 
   outfile="&_dcdata_default_path\Requests\Prog\2018\Washington region feature\tenure_by_hhinc.csv"
   dbms=csv
   replace;
	run;
