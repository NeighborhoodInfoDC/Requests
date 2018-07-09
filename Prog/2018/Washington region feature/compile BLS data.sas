/**************************************************************************
 Program:  compile bls data.sas
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
%dcdata_lib( requests )

libname bls "L:\Libraries\Requests\Data\washington region feature\BLS";

%let keeplist = Area_Code Year Area_Type St_Name Area Industry Ownership Annual_Average_Employment;

%let countylist = "District of Columbia", "Calvert County, Maryland", "Charles County, Maryland", "Frederick County, Maryland", 
                  "Montgomery County, Maryland", "Prince George's County, Maryland", "Arlington County, Virginia", "Clarke County, Virginia",
				  "Culpeper County, Virginia", "Fairfax County, Virginia", "Fauquier County, Virginia", "Loudoun County, Virginia",
				  "Prince William County, Virginia", "Rappahannock County, Virginia", "Spotsylvania County, Virginia", "Stafford County, Virginia",
				  "Warren County, Virginia", "Alexandria City, Virginia", "Fairfax City, Virginia", "Falls Church City, Virginia", 
				  "Fredericksburg City, Virginia", "Manassas City, Virginia", "Manassas Park City, Virginia", "Jefferson County, West Virginia" ; 



data allyears (where=(metro15="47900"));
   set bls.County_1990 (keep = &keeplist. rename=(area_code=ucounty)) 
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

		metro15 = put( ucounty, $ctym15f. );

		if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600","51610") then innercounty = 1;


	   if ownership = "Total Covered";


run;

proc sort data = allyears;
	by year;
run;


proc summary data = allyears;
      class year;
      var Annual_Average_Employment;
      output out = msa_employment sum=;
run;

proc export data=msa_employment
   outfile='L:\Libraries\Requests\Data\washington region feature\BLS_msa_employment.csv'
   dbms=csv
   replace;
run;

proc summary data = allyears (where=(innercounty=1));
      class year;
      var Annual_Average_Employment;
      output out = innercounty_employment sum=;
run;

proc export data=innercounty_employment
   outfile='L:\Libraries\Requests\Data\washington region feature\BLS_innercouty_employment.csv'
   dbms=csv
   replace;
run;
