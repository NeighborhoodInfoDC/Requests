/**************************************************************************
 Program:  compile bls data national employment.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  7/5/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description: compile national average annual employment

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )
%dcdata_lib( requests )

libname bls "L:\Libraries\Requests\Data\washington region feature\BLS";

%let keeplist = Area_Code Year Area_Type St_Name Area Industry Ownership Annual_Average_Employment;

data allyears;
   set  bls.County_1990 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_1991 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_1992 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_1993 (keep = &keeplist. rename=(area_code=ucounty))
		bls.County_1994 (keep = &keeplist. rename=(area_code=ucounty))
		bls.County_1995 (keep = &keeplist. rename=(area_code=ucounty))
		bls.County_1996 (keep = &keeplist. rename=(area_code=ucounty))
		bls.County_1997 (keep = &keeplist. rename=(area_code=ucounty))
       	bls.County_1998 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_1999 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2000 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2001 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2002 (keep = &keeplist. rename=(area_code=ucounty))
		bls.County_2003 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2004 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2005 (keep = &keeplist. rename=(area_code=ucounty)) 
	   	bls.County_2006 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2007 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2008 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2009 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2010 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2011 (keep = &keeplist. rename=(area_code=ucounty))
		bls.County_2012 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2013 (keep = &keeplist. rename=(area_code=ucounty))
	   	bls.County_2014 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2015 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2016 (keep = &keeplist. rename=(area_code=ucounty)) 
		bls.County_2017 (keep = &keeplist. rename=(area_code=ucounty));

	   if ownership = "Total Covered";
	   if Area_Type= "Nation";

run;

proc sort data = allyears;
	by year;
run;

proc export data=allyears
   outfile='L:\Libraries\Requests\Data\washington region feature\BLS_national_employment.csv'
   dbms=csv
   replace;
run;

