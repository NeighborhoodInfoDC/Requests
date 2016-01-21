/**************************************************************************
 Program:  PCSB_stu_sch_ward.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J Comey
 Created:  04/15/2009
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: 
 Modifications:
**************************************************************************/
  /*must use dcdata2 signon*/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
** Define libraries **;
%DCData_lib( Schools )

%include 'k:\metro\maturner\SEO Project\prog\students\formats for student data.sas';
%include 'k:\metro\maturner\SEO Project\prog\students\formats for school addresses.sas';
libname SEO 'E:\Schools\Data';
libname RawSeo 'E:\Schools\Raw';

**DOWNLOAD 2008-2009 STUDENT AND SCHOOL FILE FROM THE ALPHA;
rsubmit;
libname seoalph 'DISK$S_USER03:[DCDATA2]';  /*assigns location of DPLACE alpha*/

proc download data= seoalph.stu_sch_08_09_flags  
		out = seo.stu_sch_08_09;
run;
endrsubmit;
signoff;

*this macro pads s variable with leading zeros;
%macro zpad(s);
    * first, recommend aligning the variable values to the right margin to create leading blanks, if they dont exist already;
	&s. = right(&s.);

	* then fill them with zeros;
	if trim(&s.) ~= "" then do;	
		do _i_ = 1 to length(&s.) while (substr(&s.,_i_,1) = " ");
			substr(&s.,_i_,1) = "0";
		end;
	end;
%mend zpad;


data studentruns;
set SEO.Stu_sch_08_09;
  stu_all = 1;
  format dcps pubc stu_all pcsb_pcs boe_pcs 10.;
run;

data studentruns_all;
  set studentruns;

  %zpad (cluster2000); /*for now we are using cluster2000, but will need to use cluster_tr2000*/
  %zpad (sch_cluster2000);
  %zpad (cluster_tr2000); /*for now we are using cluster2000, but will need to use cluster_tr2000*/
  %zpad (sch_cluster_tr2000);

  *if dcg_match_score > 39 then stu_all = 1;
 if gradenum in(-3,-2,-1) then grade_cat = 0;
   else if gradenum in(0,1,2,3,4,5) then grade_cat = 1;
	else if gradenum in(6,7,8) then grade_cat = 2;
     else if gradenum in(9,10,11,12) then grade_cat = 3;
	  else grade_cat = 4;

 if race = "B" then racenum =1;
  else if race = "W" then racenum = 2;
  else if race = "H" then racenum = 3;
  else if race = "A" then racenum = 4;
  else if race = "I" then racenum = 5;
   else racenum = 6;

  if ui_id = "01034800" then delete;

run;

proc contents data=studentruns_all;run;

proc freq data=studentruns_all;
table school_type;
run;

data PCstudents (where=(school_type=2));
  set studentruns_all;run;
*Center City PCSB --Congress Heights and LAMB missing ward;
proc freq data=PCstudents;
table sch_ward2002;
run;

data PCstudents ;
  set PCstudents;
 if UI_ID="02105100" then sch_ward2002="8";
 if UI_ID="03202100" then sch_ward2002="4";

  if UI_ID="02105100" then ward2002="8";
 if UI_ID="03202100" then ward2002="4";
 run;
proc freq data=PCstudents;
table sch_ward2002;
title "New ward runs";
run;


proc freq data=PCstudents;
table ward2002;
title "Frequency of PC students by ward where they live";
run;

*Need to determine the number of public charter students enrolled in each PC's ward;
proc sort data=PCstudents;
by sch_ward2002;
run;

proc means data=PCstudents n ;
	by sch_ward2002;
	var stu_all ;
	title "number of students enrolled in school's ward";
	run;

*Need to determine the number of public charter schools located in each ward;
*Limit dataset to just one PC school each;

data PCstudents_schools;
	set PCstudents;
	run;

proc freq data=PCstudents_schools;
table UI_ID;
run;

proc freq data=PCstudents_schools;
table UI_ID * sch_ward2002;
title "Number of PC schools per ward";
run;
proc sort data=PCstudents_schools nodupkey;
by UI_ID;
run;
proc freq data=PCstudents_schools;
table UI_ID * sch_ward2002;
run;
proc freq data=PCstudents_schools;
table stu_all * sch_ward2002;
title "Number of PC schools per ward";
run;
proc freq data=PCstudents_schools (where=(sch_ward2002= ""));
table master_school_name;
run;

proc freq data=PCstudents_schools (where=(UI_ID= "3202100"));

run;

proc print data=PCstudents_schools (where=(master_school_name= ""));

