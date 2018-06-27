/**************************************************************************
 Program:  Schwartz_2016_08_30.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  08/30/16
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Request from Matthew Schwartz 
 <matthew.s.schwartz@gmail.com> for a story airing on WAMU about who lives
 in million dollar homes in DC. This program uses iPums and RealProp sales
 data to try to answer the question. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( ipums )
%DCData_lib( RealProp )

/* Formats specific to this analysis */
proc format;
	value newrace 1 = 'White'
				  2 = 'Black'
				  3 = 'Hispanic'
				  4 = 'Asian'
				  5 = 'Other';
	value moved 1-4 = '0-9 Years Ago'
				5-7 = '10+ Years Ago';
	value college 0-100 = 'Less than College'
				  100-116 = 'College Grad';
	value tenure 1 = 'Home Owner, Million Dollar Home'
				 2 = 'Home Owner, Under Million$ Home'
				 3 = 'Renter';
	value nativity 1-120 = 'US Born'
				   150-950 = 'Foreign Born';
	value family 1 = 'Unmarried, No Kids'
				 2 = 'Married, No Kids'
				 3 = 'Married with Kids'
				 4 = 'Unmarried Parent'
				 5 = 'Other Family Type';
	value occ 0 = 'N/A'
			  10-499 = 'Management, Business, Science, and Arts Occupations'
			  500-799 = 'Business Operations Specialists'
			  800-999 = 'Financial Specialists'
			  1000-1299 = 'Computer and Mathematical Occupations'
			  1300-1599 = 'Architecture and Engineering Occupations'
			  1600-1999 = 'Life, Physical, and Social Science Occupations'
			  2000-2099 = 'Community and Social Services Occupations'
			  2100-2199 = 'Legal Occupations'
			  2200-2599 = 'Education, Training, and Library Occupations'
			  2600-2999 = 'Arts, Design, Entertainment, Sports, and Media Occupations'
			  3000-3599 = 'Healthcare Practitioners and Technical Occupations'
			  3600-3699 = 'Healthcare Support Occupations'
			  3700-3999 = 'Protective Service Occupations'
			  4000-4199 = 'Food Preparation and Serving Occupations'
			  4200-4299 = 'Building and Grounds Cleaning and Maintenance Occupations'
			  4300-4699 = 'Personal Care and Service Occupations'
			  4700-4999 = 'Sales and Related Occupations'
			  5000-5999 = 'Office and Administrative Support Occupations'
			  6000-6199 = 'Farming, Fishing, and Forestry Occupations'
			  6200-6799 = 'Construction and Extraction Occupations'
			  6800-6999 = 'Extraction Workers'
			  7000-7699 = 'Installation, Maintenance, and Repair Workers'
			  7700-8999 = 'Production Occupations'
			  9000-9799 = 'Transportation and Material Moving Occupations'
			  9800-9999 = 'Military Specific Occupations';
run;


/* Prep iPums data */
data Schwartz_2016_08_30;
	set ipums.Acs_2010_14_dc;

	/* Keep only people living in HHs */
	if gq in (1,2);

	/* Identify householder and spouse/partner if applicable */
	if pernum = 1 then householder = 1;
		else if pernum = 2 and related in (201,1114) then householder = 2;
		else householder = 0;
	
	/* Flag for HH in a million dollar or more home */
	if 1000000 <= valueh < 9999999 then mhome = 1;

	/* Race re-codes */
	if hispan = 0 and race = 1 then newrace = 1; /* White */
		else if hispan = 0 and race = 2 then newrace = 2; /* Black */
		else if hispan = 0 and race in (4,5,6) then newrace = 4; /* Asian */
		else if hispan = 0 and race in (3,7,8,9) then newrace = 5; /* Other */
		else if hispan >= 1 then newrace = 3; /* Hispanic */

	/* Tenure re-codes */
	if ownershp = 1 and mhome = 1 then newownershp = 1;
		else if ownershp = 1 then newownershp = 2;
		else if ownershp = 2 then newownershp = 3;

	/* Family re-codes */
	if marst = 6 and nchild = 0 then newfamily = 1; /* Unmarried no kids */
		else if marst = 1 and nchild = 0 then newfamily = 2; /* Married no kids */
		else if marst = 1 and nchild > 0 then newfamily = 3; /* Married with kids */
		else if marst = 6 and nchild > 0 then newfamily = 4; /* Unmarried parent */
		else if marst in (2,3,4,5) then newfamily = 5;

	if movedin=0 then movedin = .r;
	if educd=999 then educd = .e;

run;


/* Table 1: Frequency of all HHs by tenure type */
proc freq data = Schwartz_2016_08_30 (where=( householder=1));
	tables newownershp;
	format newownershp tenure.;
	weight hhwt;
run;


/* Table 2: Frequency of household and householder characteristics */
proc freq data = Schwartz_2016_08_30 (where=( householder=1));
	tables movedin newrace educd bpl newfamily;
	format movedin moved. newrace newrace. educd college. bpl nativity. newfamily family. ;
	weight hhwt;
run;

proc freq data = Schwartz_2016_08_30 (where=(mhome=1 and householder=1));
	tables movedin newrace educd bpl newfamily ;
	format movedin moved. newrace newrace. educd college. bpl nativity. newfamily family. ;
	weight hhwt;
run;

proc freq data = Schwartz_2016_08_30 (where=(ownershp=1));
	tables movedin newrace educd bpl newfamily ;
	format movedin moved. newrace newrace. educd college. bpl nativity. newfamily family. ;
	weight hhwt;
run;

proc freq data = Schwartz_2016_08_30 (where=(ownershp=2));
	tables movedin newrace educd bpl newfamily ;
	format movedin moved. newrace newrace. educd college. bpl nativity. newfamily family. ;
	weight hhwt;
run;


/* Table 2: Median Indicators */
proc means data = Schwartz_2016_08_30 (where=(householder=1)) n median mean ;
	var hhincome age;
	weight hhwt;
	output out = all_medians median=;
run;

proc means data = Schwartz_2016_08_30 (where=(mhome=1 and householder=1)) n median mean ;
	var hhincome age;
	weight hhwt;
	output out = m_medians median=;
run;

proc means data = Schwartz_2016_08_30 (where=(ownershp=1)) n median mean ;
	var hhincome age;
	weight hhwt;
	output out = m_medians median=;
run;

proc means data = Schwartz_2016_08_30 (where=(ownershp=2)) n median mean ;
	var hhincome age;
	weight hhwt;
	output out = m_medians median=;
run;


/* Table 3: Occupation frequency of householder and spouse/partner */
proc freq data = Schwartz_2016_08_30 (where=( householder in (1,2)));
	tables occ;
	format occ occ.;
	weight perwt;
run;

proc freq data = Schwartz_2016_08_30 (where=(mhome=1 and householder in (1,2)));
	tables occ;
	format occ occ.;
	weight perwt;
run;

proc freq data = Schwartz_2016_08_30 (where=(ownershp=1 and householder in (1,2)));
	tables occ;
	format occ occ.;
	weight perwt;
run;

proc freq data = Schwartz_2016_08_30 (where=(ownershp=2 and householder in (1,2)));
	tables occ;
	format occ occ.;
	weight perwt;
run;


/* Table 4: RealProp Sales by Year */
data Schwartz_2016_08_30_sales;
	set realprop.sales_res_clean;
	if '01jan2015'd <= saledate < '01jan2016'd then year = 2015;
		else if '01jan2014'd <= saledate < '01jan2015'd then year = 2014;
		else if '01jan2013'd <= saledate < '01jan2014'd then year = 2013;
		else if '01jan2012'd <= saledate < '01jan2013'd then year = 2012;
		else if '01jan2011'd <= saledate < '01jan2012'd then year = 2011;
		else if '01jan2010'd <= saledate < '01jan2011'd then year = 2010;
	if ui_proptype in (10,11);
	if saleprice >= 1000000 then over1m = 1;
		else if saleprice < 1000000 then over1m = 0;
run;

proc freq data = Schwartz_2016_08_30_sales;
	tables over1m*year;
run;


/* End of Program */
