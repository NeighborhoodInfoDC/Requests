/**************************************************************************
 Program:  Unrelated_adults_ACS.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  09/16/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Identify the number of unrelated person households in the region using most recent ACS data.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( IPUMS )

*Pull down Household level 2006 ACS data in this order
/*HH series number of merge on later*/
/*Total number of persons in HH */
/*Number of related persons in HH */
/*Number of unrelated persons in HH */
/*State FIP ID */
/*Household weight*/ ;

rsubmit;

data ACS_2006_fam ;/* creates a file on the alpha - temp */
set Ipums.Acs_2006_fam_pmsa99 (keep= serial persons_hh related_pers	unrelated_pers statefip	hhwt) 
	 ;
proc download inlib=work outlib=Ipums; /* download to PC */
select ACS_2006_fam ;  

run;

endrsubmit; 

*Pull down individual level 2006 ACS data in this order
/*HH series number of merge on later*/
Age of individual;
rsubmit;


data ACS_2006_indiv ;/* creates a file on the alpha - temp */
set Ipums.Acs_2006_pmsa99 (keep= serial age)
	;
proc download inlib=work outlib=Ipums; /* download to PC */
select ACS_2006_indiv ; 

run;

endrsubmit; 

data Ipums.ACS_2006_indiv;
	set Ipums.ACS_2006_indiv;
	
	if age <35 then youngflg =1;
	else youngflg = 0;
	Label youngflg = "Younger than 35 years old";
	
	run;
 proc sort data = Ipums.ACS_2006_indiv;
 	by serial;run;
proc summary data=Ipums.ACS_2006_indiv;
	var youngflg;
	by serial;
	output out=ACS_2006_indiv_young sum=;
	run;

proc print data=ACS_2006_indiv_young;
	title "Sum of household with young flag";run;

	proc freq data=ACS_2006_indiv_young;
	table youngflg;
	run;
data Ipums.ACS_2006_indiv_noyoung (where=(youngflg=0));
	set ACS_2006_indiv_young;

run;

proc freq data=Ipums.ACS_2006_indiv_noyoung ;
	table youngflg;run;


*Merge noyoung indivudal data to HH level data;
proc sort data=Ipums.ACS_2006_fam ;
by serial;run;

data Ipums.ACS_HH_noyoung;
	merge Ipums.ACS_2006_indiv_noyoung (in=in1) Ipums.ACS_2006_fam ;
	by serial;
	if in1=1;
	run;
proc sort data =Ipums.ACS_HH_noyoung;
by persons_hh;run;

*There are 453 instances where there are 2 people in a HH, and 1 reports being unrelated and another
reports being related;

proc print data=Ipums.ACS_HH_noyoung;
	where persons_HH=2 and related_pers=1 and unrelated_pers=1;
	run; 

proc print data=Ipums.ACS_HH_noyoung;
	where unrelated_pers=0;
	run; 
data Ipums.ACS_HH_noyoung_norelated (where=(unrelated_pers=0));
	set Ipums.ACS_HH_noyoung;
	run;
data Ipums.ACS_HH_noyoung_norelated (where=(persons_HH>1));
	set Ipums.ACS_HH_noyoung;
	run;

	signoff;




