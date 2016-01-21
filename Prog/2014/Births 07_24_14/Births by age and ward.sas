
%include "L:\SAS\Inc\StdLocal.sas";


** Define libraries **;
%DCData_lib( Vital ) 

%let birthvars =  Births_total_2000 Births_total_2001 Births_total_2002 Births_total_2003 Births_total_2004 Births_total_2005
	 Births_total_2006 Births_total_2007 Births_total_2008 Births_total_2009 Births_total_2010 Births_total_2011
	 Births_0to19_2000 Births_0to19_2001 Births_0to19_2002 Births_0to19_2003 Births_0to19_2004 Births_0to19_2005
	 Births_0to19_2006 Births_0to19_2007 Births_0to19_2008 Births_0to19_2009 Births_0to19_2010 Births_0to19_2011
	 Births_20to24_2000 Births_20to24_2001 Births_20to24_2002 Births_20to24_2003 Births_20to24_2004 Births_20to24_2005
	 Births_20to24_2006 Births_20to24_2007 Births_20to24_2008 Births_20to24_2009 Births_20to24_2010 Births_20to24_2011
	 Births_25to29_2000 Births_25to29_2001 Births_25to29_2002 Births_25to29_2003 Births_25to29_2004 Births_25to29_2005
	 Births_25to29_2006 Births_25to29_2007 Births_25to29_2008 Births_25to29_2009 Births_25to29_2010 Births_25to29_2011
	 Births_30to34_2000 Births_30to34_2001 Births_30to34_2002 Births_30to34_2003 Births_30to34_2004 Births_30to34_2005
	 Births_30to34_2006 Births_30to34_2007 Births_30to34_2008 Births_30to34_2009 Births_30to34_2010 Births_30to34_2011
	 Births_35to39_2000 Births_35to39_2001 Births_35to39_2002 Births_35to39_2003 Births_35to39_2004 Births_35to39_2005
	 Births_35to39_2006 Births_35to39_2007 Births_35to39_2008 Births_35to39_2009 Births_35to39_2010 Births_35to39_2011
	 Births_40plus_2000 Births_40plus_2001 Births_40plus_2002 Births_40plus_2003 Births_40plus_2004 Births_40plus_2005
	 Births_40plus_2006 Births_40plus_2007 Births_40plus_2008 Births_40plus_2009 Births_40plus_2010 Births_40plus_2011
	 Births_unkage_2000 Births_unkage_2001 Births_unkage_2002 Births_unkage_2003 Births_unkage_2004 Births_unkage_2005
	 Births_unkage_2006 Births_unkage_2007 Births_unkage_2008 Births_unkage_2009 Births_unkage_2010 Births_unkage_2011;

data ward;
	set vital.Births_sum_wd12;

%macro transform();
	%let varlist = 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011;
		%let i = 1;
			%do %until (%scan(&varlist,&i,' ')=);
				%let var=%scan(&varlist,&i,' ');
		Births_0to19_&var. = sum(of Births_0to14_&var. Births_15to19_&var.);
		Births_40plus_&var. = sum(of Births_40to44_&var. Births_45plus_&var.);
		Births_unkage_&var. = Births_total_&var. - (sum(of Births_0to19_&var. Births_20to24_&var. Births_25to29_&var.
													Births_30to34_&var. Births_35to39_&var. Births_40plus_&var.));
	%let i=%eval(&i + 1);
			%end;
		%let i = 1;
			%do %until (%scan(&varlist,&i,' ')=);
				%let var=%scan(&varlist,&i,' ');
	%let i=%eval(&i + 1);
			%end;
%mend transform;
%transform;

keep ward2012 &birthvars.;
	
run;

data ward2;
	retain ward2012 &birthvars.;
	set ward;
run;



data clusters;
	set Vital.Births_sum_cltr00;

%macro transform();
	%let varlist = 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011;
		%let i = 1;
			%do %until (%scan(&varlist,&i,' ')=);
				%let var=%scan(&varlist,&i,' ');
		Births_0to19_&var. = sum(of Births_0to14_&var. Births_15to19_&var.);
		Births_40plus_&var. = sum(of Births_40to44_&var. Births_45plus_&var.);
		Births_unkage_&var. = Births_total_&var. - (sum(of Births_0to19_&var. Births_20to24_&var. Births_25to29_&var.
													Births_30to34_&var. Births_35to39_&var. Births_40plus_&var.));
	%let i=%eval(&i + 1);
			%end;
		%let i = 1;
			%do %until (%scan(&varlist,&i,' ')=);
				%let var=%scan(&varlist,&i,' ');
	%let i=%eval(&i + 1);
			%end;
%mend transform;
%transform;

keep cluster_tr2000 &birthvars.;

run;

data clusters2;
	retain cluster_tr2000 &birthvars.;
	set clusters;
run;
