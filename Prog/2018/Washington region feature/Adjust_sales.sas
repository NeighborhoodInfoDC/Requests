/**************************************************************************
 Program:  Adjust Sales.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  6/28/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description: Adjust HFPC's Corelogic Market Trends and Zillow Rent index for inflation.


**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";
%dcdata_lib( requests )

libname raw "L:\Libraries\Requests\Raw\2018";

PROC IMPORT OUT= WORK.county_sales_wide 
            DATAFILE= "L:\Libraries\Requests\Raw\2018\county-sales-wide.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

%macro inflate;
data county_sales_wide1 (keep=r: fips_Code name);
	set county_SALES_WIDE;


%let year=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018; 

%do y= 1 %to 19;

	%let yr=%scan(&year.,&y.," "); 

	array oldlist_&yr {*} med&yr.01 med&yr.02 med&yr.03 med&yr.04 med&yr.05 med&yr.06 med&yr.07 med&yr.08 med&yr.09 med&yr.10 med&yr.11 med&yr.12;
	array newlist_&yr {*} rmed&yr.01 rmed&yr.02 rmed&yr.03 rmed&yr.04 rmed&yr.05 rmed&yr.06 rmed&yr.07 rmed&yr.08 rmed&yr.09 rmed&yr.10 rmed&yr.11 rmed&yr.12;

		do m=1 to dim( oldlist_&yr );

	 %dollar_convert(oldlist_&yr.{m},newlist_&yr.{m},&yr.,2018,series=CUUR0000SA0L2);

	 	end; 
%end;

run; 

%mend inflate;

%inflate; 

proc transpose data= county_sales_wide1 out= county_sales;
id name;

run; 

data county_sales_adjusted;
	set county_sales;

if _name_ ne "fips_code" then do; ;

month=substr(_name_,5,6);

end;

run;


proc export data=county_sales_adjusted
   outfile="&_dcdata_default_path\Requests\Prog\2018\washington region feature\county_sales_adjusted.csv"
   dbms=csv
   replace;
run;

**Zillow rent index;

PROC IMPORT OUT= WORK.county_rent_wide 
            DATAFILE= "L:\Libraries\Requests\Raw\2018\rent-wide.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


%macro inflate_rent;
data county_rent_wide1 (keep=r: regionname);
	set county_rent_wide;


%let year=2010 2011 2012 2013 2014 2015 2016 2017 2018; 

%do y= 1 %to 9;

	%let yr=%scan(&year.,&y.," "); 

	array oldlist_&yr {*} zri&yr._01 zri&yr._02 zri&yr._03 zri&yr._04 zri&yr._05 zri&yr._06 zri&yr._07 zri&yr._08 zri&yr._09 zri&yr._10 zri&yr._11 zri&yr._12;
	array newlist_&yr {*} Rzri&yr._01 Rzri&yr._02 Rzri&yr._03 Rzri&yr._04 Rzri&yr._05 Rzri&yr._06 Rzri&yr._07 Rzri&yr._08 Rzri&yr._09 Rzri&yr._10 Rzri&yr._11 Rzri&yr._12;

		do m=1 to dim( oldlist_&yr );

	 %dollar_convert(oldlist_&yr.{m},newlist_&yr.{m},&yr.,2018,series=CUUR0000SA0L2);

	 	end; 
%end;

run; 

%mend inflate_rent;

%inflate_rent; 

proc transpose data= county_rent_wide1 out= county_rent;
id regionname;

run; 

data county_rent_adjusted;
	set county_rent;



month=substr(_name_,5);


run;


proc export data=county_rent_adjusted
   outfile="&_dcdata_default_path\Requests\Prog\2018\washington region feature\county_rent_adjusted.csv"
   dbms=csv
   replace;
run;
