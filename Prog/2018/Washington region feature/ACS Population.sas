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
   if Geography in (&countylist.);

run;


data pop1017;
	set pop1017;
    if area in ("District of Columbia","Montgomery County, Maryland","Prince George's County, Maryland","Arlington County, Virginia","Alexandria City, Virginia","Fairfax City, Virginia","Loudoun County, Virginia", "Fairfax County, Virginia") then innercounty = 1;
run;

proc summary data = pop1017;
      var Pop_2010 Pop_2011 Pop_2012 Pop_2013 Pop_2014 Pop_2015 Pop_2016 Pop_2017;
      output out = msa_pop1017 sum=;
run;

proc export data=msa_pop1017
   outfile='L:\Libraries\Requests\Data\washington region feature\msa_pop1017.csv'
   dbms=csv
   replace;
run;

proc summary data = allyears (where=(innercounty=1));
      var Pop_2010 Pop_2011 Pop_2012 Pop_2013 Pop_2014 Pop_2015 Pop_2016 Pop_2017;
      output out = innercounty_pop1017 sum=;
run;

proc export data=innercounty_pop1017
   outfile='L:\Libraries\Requests\Data\washington region feature\innercounty_pop1017.csv'
   dbms=csv
   replace;
run;
