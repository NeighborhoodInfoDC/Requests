/**************************************************************************
 Program:  Commuting time to work.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/26/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )

libname bls "L:\Libraries\Requests\Data\washington region feature\BLS";

%let keeplist = Area_Code Year Area_Type St_Name Area Industry Ownership Annual_Average_Employment;

%let countylist = "District of Columbia","Arlington County, Virginia","Alexandria City, Virginia" ; 



data allyears;
   set bls.County_1990 (keep = &keeplist.) 
		bls.County_1991 (keep = &keeplist.) 
		bls.County_1992 (keep = &keeplist.) 
		bls.County_1993 (keep = &keeplist.)
		bls.County_1994 (keep = &keeplist.)
		bls.County_1995 (keep = &keeplist.)
		bls.County_1996 (keep = &keeplist.)
		bls.County_1997 (keep = &keeplist.)
       	bls.County_1998 (keep = &keeplist.) 
		bls.County_1999 (keep = &keeplist.) 
		bls.County_2000 (keep = &keeplist.) 
		bls.County_2001 (keep = &keeplist.) 
		bls.County_2002 (keep = &keeplist.)
		bls.County_2003 (keep = &keeplist.) 
		bls.County_2004 (keep = &keeplist.) 
		bls.County_2005 (keep = &keeplist.) 
	   	bls.County_2006 (keep = &keeplist.) 
		bls.County_2007 (keep = &keeplist.) 
		bls.County_2008 (keep = &keeplist.) 
		bls.County_2009 (keep = &keeplist.) 
		bls.County_2010 (keep = &keeplist.) 
		bls.County_2011 (keep = &keeplist.)
		bls.County_2012 (keep = &keeplist.) 
		bls.County_2013 (keep = &keeplist.)
	   	bls.County_2014 (keep = &keeplist.) 
		bls.County_2015 (keep = &keeplist.) 
		bls.County_2016 (keep = &keeplist.) 
		bls.County_2017 (keep = &keeplist.);

		if area in (&countylist.);

		if area_type = "County";
		if ownership = "Total Covered";


run;


proc sort data = allyears;
	by area year;
run;
