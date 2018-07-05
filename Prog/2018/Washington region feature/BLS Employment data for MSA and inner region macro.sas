/* U.S. Department of Labor                                                 */
/* Bureau of Labor Statistics                                               */
/* Quarterly Census of Employment and Wages                                 */
/* April 2015                                                               */
/*                                                                          */
/* QCEW Open Data Access SAS Example                                        */
/*                                                                          */
/* SAS 9.3                                                                  */
/*                                                                          */
/* This file contains 3 SAS Macros that import QCEW data slices.            */
/* Each Macro is called once at the bottom of this file.                    */
/* So, you can run this code to see some results.                           */
/*                                                                          */
/* Submit questions at:                                                     */
/*   http://www.bls.gov/cgi-bin/forms/cew?/cew/home.htm                     */
/*                                                                          */
/*  ----------------------------------------------------------------------- */





/* ------------------------------------------------------------------------ */
/* qcewGetAreaData  : This macro takes 3 parameters: year, qtr, and area.   */
/* These arguments are used to construct the corresponding URL that points  */
/* to the given data file. Use "a" as the qtr value if you want to get      */
/* annual averages.                                                         */
/*                                                                          */
/* For all area codes and titles see:                                       */
/* http://data.bls.gov/cew/doc/titles/area/area_titles.htm                  */
/*                                                                          */
/* ------------------------------------------------------------------------ */
%MACRO qcewGetAreaData(year,qtr,area);
	
	filename ar&area. url 
		"http://data.bls.gov/cew/data/api/&year./%LOWCASE(&qtr.)/area/%UPCASE(&area.).csv";
	data a&area.y&year.q&qtr.;
		infile ar&area.
			   dlm=","
               dsd
			   firstobs=2
               truncover;
		%IF "&qtr." eq "a" %THEN %DO;
	    	input area_fips $ 
				own_code $ 
				industry_code $ 
				agglvl_code $ 
				size_code $
				year $
				qtr $
				disclosure_code $ 
				annual_avg_estabs
				annual_avg_emplvl 

		%END;
		%ELSE %DO;
			input area_fips $ 
				own_code $ 
 
		%END;
	run;

data a&area.y&year.q&qtr._x;
	set a&area.y&year.q&qtr.;
	if agglvl_code = "70";
run;

%MEND qcewGetAreaData;

%qcewGetAreaData(2012,a,11001);
%qcewGetAreaData(2013,a,11001);
%qcewGetAreaData(2014,a,11001);
%qcewGetAreaData(2015,a,11001);
%qcewGetAreaData(2016,a,11001);
%qcewGetAreaData(2017,a,11001);


data dc_empl;
	set A11001y2013qa_x A11001y2014qa_x A11001y2015qa_x A11001y2016qa_x A11001y2017qa_x;
run;

