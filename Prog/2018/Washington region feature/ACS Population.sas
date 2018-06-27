/**************************************************************************
 Program:  ACS Population.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/26/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  Calculate population for DC MSA and Inner Region from Census population estimates
               https://www.census.gov/data/datasets/2017/demo/popest/counties-total.html

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";


proc import datafile="L:\Libraries\Requests\Data\washington region feature\PEP_2017_PEPANNRES\Population.csv"
 out=work.population
 dbms=csv
 replace;
run;


%let countylist = "District of Columbia", "Calvert County, Maryland", "Charles County, Maryland", "Frederick County, Maryland", 
                  "Montgomery County, Maryland", "Prince George's County, Maryland", "Arlington County, Virginia", "Clarke County, Virginia",
				  "Culpeper County, Virginia", "Fairfax County, Virginia", "Fauquier County, Virginia", "Loudoun County, Virginia",
				  "Prince William County, Virginia", "Rappahannock County, Virginia", "Spotsylvania County, Virginia", "Stafford County, Virginia",
				  "Warren County, Virginia", "Alexandria City, Virginia", "Fairfax City, Virginia", "Falls Church City, Virginia", 
				  "Fredericksburg City, Virginia", "Manassas City, Virginia", "Manassas Park City, Virginia", "Jefferson County, West Virginia" ; 

				  
data pop1017;
   set population;
   ucounty = put(id2,z5.);

   metro15 = put( ucounty, $ctym15f. );
   if ucounty in ("11001","24031","24033","51013","51059","51107","51510","51600") then innercounty = 1;

run;


data pop1017_msa;
	set pop1017;
	if metro15 ^= " ";
run;


proc summary data = pop1017_msa;
      var Pop_2010 Pop_2011 Pop_2012 Pop_2013 Pop_2014 Pop_2015 Pop_2016 Pop_2017;
      output out = msa_pop1017 sum=;
run;

proc export data=msa_pop1017
   outfile='L:\Libraries\Requests\Data\washington region feature\msa_pop1017.csv'
   dbms=csv
   replace;
run;

proc summary data = pop1017_msa (where=(innercounty=1));
      var Pop_2010 Pop_2011 Pop_2012 Pop_2013 Pop_2014 Pop_2015 Pop_2016 Pop_2017;
      output out = innercounty_pop1017 sum=;
run;

proc export data=innercounty_pop1017
   outfile='L:\Libraries\Requests\Data\washington region feature\innercounty_pop1017.csv'
   dbms=csv
   replace;
run;
