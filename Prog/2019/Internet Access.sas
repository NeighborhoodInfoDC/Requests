/**************************************************************************
 Program:  Internet Access.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  3/13/19
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib (RegHsg);

%let year= 2013_17;

proc format;
  value Jurisdiction
	0= "Total"
    1= "DC"
	2= "Charles County"
	3= "Frederick County "
	4="Montgomery County"
	5="Prince Georges "
	6="Arlington"
	7="Fairfax, Fairfax city and Falls Church"
	8="Loudoun"
	9="Prince William, Manassas and Manassas Park"
    10="Alexandria"
  	;
run; 

data InternetAcccess ;
	  set acs.Acs_2013_17_va_sum_tr_tr10 acs.Acs_2013_17_dc_sum_tr_tr10 acs.Acs_2013_17_md_sum_tr_tr10 acs.Acs_2013_17_wv_sum_tr_tr10;
	      
	  keep geo2010 geoid totpop_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. popaloneaiom_&year. numpopbroadbandtot
	       Numdialup_&year. Numbroadbandall_&year. Numcellular_&year. Numcellularonly_&year. Numbroadband_&year. Numbroadbandonly_&year. Numsatellite_&year.
           Numsatelliteonly_&year. Numotheronly_&year. Numaccesswosub_&year. Numnointernet_&year. tothhdemom pctinternet percent100Kplus percentunder15K
           percent15to50K percent50to75K percent75Kto100K county metro15 Jurisdiction hshldinc100000plus_2013_17 hshldincunder15000_2013_17 hshldinc15000to34999_2013_17 hshldinc35000to49999_2013_17
           hshldinc50000to74999_2013_17 hshldinc75000to99999_2013_17 pctnointernet;

      county= substr(geo2010, 1,5);
	  ucounty=county;
	  geoid= geo2010;

%ucounty_jurisdiction

	  metro15 = put( county, $ctym15f. );
      tothhdemom= hshldinc100000plus_2013_17+ hshldincunder15000_2013_17+ hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17+
      hshldinc50000to74999_2013_17+ hshldinc75000to99999_2013_17;
      percent100Kplus= hshldinc100000plus_2013_17/tothhdemom;
	  percentunder15K= hshldincunder15000_2013_17/tothhdemom;
	  percent15to50K= (hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17)/tothhdemom;
	  percent50to75K= hshldinc50000to74999_2013_17/tothhdemom;
      percent75Kto100K= hshldinc75000to99999_2013_17/tothhdemom;
	  pctinternet= (tothhdemom - Numnointernet_&year.)/tothhdemom;
	  pctnointernet= Numnointernet_&year./tothhdemom;

	  format Jurisdiction Jurisdiction. ;
run;

proc export data= InternetAcccess
   outfile="&_dcdata_default_path\Requests\Prog\2019\Internet_access_tract.csv"
   dbms=csv
   replace;
run;

data BroadbandAcccess ;
	  set acs.Acs_2013_17_va_sum_tr_tr10 acs.Acs_2013_17_dc_sum_tr_tr10 acs.Acs_2013_17_md_sum_tr_tr10 acs.Acs_2013_17_wv_sum_tr_tr10;
	      
	  keep geo2010 geoid totpop_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. popaloneaiom_&year. numpopbroadbandtot
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_2013_17 hshldincunder15000_2013_17 hshldinc15000to34999_2013_17 hshldinc35000to49999_2013_17
           hshldinc50000to74999_2013_17 hshldinc75000to99999_2013_17 percent100Kplus percentunder15K percent15to50K percent50to75K  percent75Kto100K
           pctbroadband pctbroadbanda pctbroadbandb pctbroadbandh pctbroadbandw pctbroadbandiom  Numnointernet_&year. pctinternet pctnointernetcounty metro15 Jurisdiction ;

      county= substr(geo2010, 1,5);
	  ucounty=county;
	  geoid= geo2010;

%ucounty_jurisdiction

	  metro15 = put( county, $ctym15f. );
      numpopbroadbandtot= numpopbroadbanda_2013_17 + numpopbroadbandiom_2013_17+ numpopbroadbandb_2013_17+ numpopbroadbandh_2013_17+ numpopbroadbandw_2013_17;
      pctbroadband= numpopbroadbandtot/totpop_&year.;
	  pctbroadbanda= numpopbroadbanda_&year./popalonea_&year.;
	  pctbroadbandb= numpopbroadbandb_&year./popaloneb_&year.;
      pctbroadbandh= numpopbroadbandh_&year. /popaloneh_&year.;
      pctbroadbandw= numpopbroadbandw_&year. /popalonew_&year.;
      pctbroadbandiom= numpopbroadbandiom_&year./popaloneaiom_&year.;
      tothhdemom= hshldinc100000plus_2013_17+ hshldincunder15000_2013_17+ hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17+
      hshldinc50000to74999_2013_17+ hshldinc75000to99999_2013_17 ;
      percent100Kplus= hshldinc100000plus_2013_17/tothhdemom;
	  percentunder15K= hshldincunder15000_2013_17/tothhdemom;
	  percent15to50K= (hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17)/tothhdemom;
	  percent50to75K= hshldinc50000to74999_2013_17/tothhdemom;
      percent75Kto100K= hshldinc75000to99999_2013_17/tothhdemom;
	  pctinternet= (tothhdemom - Numnointernet_&year.)/tothhdemom;
	  pctnointernet= Numnointernet_&year./tothhdemom;

	  format Jurisdiction Jurisdiction. ;
run;

proc export data= BroadbandAcccess 
   outfile="&_dcdata_default_path\Requests\Prog\2019\Broadband_access_tract.csv"
   dbms=csv
   replace;
run;

proc sort data= BroadbandAcccess ;
by metro15;run;

proc summary data = BroadbandAcccess;
	var  totpop_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. numpopbroadbandtot
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_2013_17 hshldincunder15000_2013_17 hshldinc15000to34999_2013_17 hshldinc35000to49999_2013_17
           hshldinc50000to74999_2013_17 hshldinc75000to99999_2013_17;
		   by metro15;
	output out = AccessinDMV sum = ;
run;
proc sort data=InternetAcccess;
by Jurisdiction;run;
proc summary data = InternetAcccess (where=(metro15= "47900"));
	var  totpop_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. numpopbroadbandtot
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_2013_17 hshldincunder15000_2013_17 hshldinc15000to34999_2013_17 hshldinc35000to49999_2013_17
           hshldinc50000to74999_2013_17 hshldinc75000to99999_2013_17;
		   by Jurisdiction;
	output out = Accessbycounty sum = ;
run;
data accessbycounty2;
set Accessbycounty;
tothhdemom= hshldinc100000plus_2013_17+ hshldincunder15000_2013_17+ hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17+
           hshldinc50000to74999_2013_17+ hshldinc75000to99999_2013_17 ;
      percent100Kplus= hshldinc100000plus_2013_17/tothhdemom;
	  percentunder15K= hshldincunder15000_2013_17/tothhdemom;
	  percent15to50K= (hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17)/tothhdemom;
	  percent50to75K= hshldinc50000to74999_2013_17/tothhdemom;
      percent75Kto100K= hshldinc75000to99999_2013_17/tothhdemom;
	  broadbandaccess= numpopbroadbandtot/totpop_&year.;

run;


proc sort data=InternetAcccess;
by geo2010;run;

proc summary data = InternetAcccess (where=(metro15= "47900"));
	var  totpop_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. numpopbroadbandtot
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_2013_17 hshldincunder15000_2013_17 hshldinc15000to34999_2013_17 hshldinc35000to49999_2013_17
           hshldinc50000to74999_2013_17 hshldinc75000to99999_2013_17;
		   by geo2010;
	output out = Accessbytract sum = ;
run;

data Accessbytract2;
set Accessbytract;
tothhdemom= hshldinc100000plus_2013_17+ hshldincunder15000_2013_17+ hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17+
           hshldinc50000to74999_2013_17+ hshldinc75000to99999_2013_17 ;
      percent100Kplus= hshldinc100000plus_2013_17/tothhdemom;
	  percentunder15K= hshldincunder15000_2013_17/tothhdemom;
	  percent15to50K= (hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17)/tothhdemom;
	  percent50to75K= hshldinc50000to74999_2013_17/tothhdemom;
      percent75Kto100K= hshldinc75000to99999_2013_17/tothhdemom;
	  broadbandaccess= numpopbroadbandtot/totpop_&year.;

run;

proc export data=Accessbytract2
   outfile='&_dcdata_default_path\Requests\Prog\2019\Internet_access_tract.csv'
   dbms=csv
   replace;
run;
