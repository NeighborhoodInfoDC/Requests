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

data ACSall;
set acs.Acs_2013_17_va_sum_tr_tr10 acs.Acs_2013_17_dc_sum_tr_tr10 acs.Acs_2013_17_md_sum_tr_tr10 acs.Acs_2013_17_wv_sum_tr_tr10;
	  keep geo2010 geoid totpop_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. popaloneaiom_&year. 
	       Numdialup_&year. Numbroadbandall_&year. Numcellular_&year. Numcellularonly_&year. Numbroadband_&year. Numbroadbandonly_&year. Numsatellite_&year.
           Numsatelliteonly_&year. Numotheronly_&year. Numaccesswosub_&year. Numnointernet_&year. tothhdemom pctinternet percent100Kplus percentunder15K
           percent15to50K percent50to75K percent75Kto100K county metro15 Jurisdiction hshldinc100000plus_2013_17 hshldincunder15000_2013_17 hshldinc15000to34999_2013_17 hshldinc35000to49999_2013_17
           hshldinc50000to74999_2013_17 hshldinc75000to99999_2013_17 pctinternet pctnointernet Numwithinternet_2013_17;

      county= substr(geo2010, 1,5);
	  ucounty=county;
	  geoid= geo2010;

%ucounty_jurisdiction
	  format Jurisdiction Jurisdiction. ;
run;


data InternetAcccess ;
	  set ACSall;
	  metro15 = put( county, $ctym15f. );
      hshldinc50000to74999_2013_17+ hshldinc75000to99999_2013_17;
      percent100Kplus= hshldinc100000plus_2013_17/Numhhdefined_2013_17;
	  percentunder15K= hshldincunder15000_2013_17/Numhhdefined_2013_17;
	  percent15to50K= (hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17)/Numhhdefined_2013_17;
	  percent50to75K= hshldinc50000to74999_2013_17/Numhhdefined_2013_17;
      percent75Kto100K= hshldinc75000to99999_2013_17/Numhhdefined_2013_17;
	  internetdenom= Numdialup_&year. + Numbroadbandall_&year. + Numcellular_&year. + Numcellularonly_&year. + Numbroadband_&year. + Numbroadbandonly_&year. + Numsatellite_&year.+ 
                     Numsatelliteonly_&year. + Numotheronly_&year. + Numaccesswosub_&year. + Numnointernet_&year.;
	  pctinternet= (internetdenom- Numnointernet_&year.)/internetdenom;
	  pctnointernet= 1- pctinternet;

run;

proc export data= InternetAcccess
   outfile="&_dcdata_default_path\Requests\Prog\2019\Internet_access_tract.csv"
   dbms=csv
   replace;
run;

data BroadbandAcccess ;
	  set ACSall;
	      
	  metro15 = put( county, $ctym15f. );
      pctbroadband= Numbroadband_2013_17/Numhhdefined_2013_17 ;
	  pctbroadbanda= numpopbroadbanda_&year./(NumPopdialupA_2013_17 + NumPopbroadbandA_2013_17 + NumPopnointernetA_2013_17 + NumPopnocomputerA_2013_17);
	  pctbroadbandb= numpopbroadbandb_&year./(NumPopdialupB_2013_17 + NumPopbroadbandB_2013_17 + NumPopnointernetB_2013_17 + NumPopnocomputerB_2013_17);
      pctbroadbandh= numpopbroadbandh_&year. /(NumPopdialupH_2013_17 + NumPopbroadbandH_2013_17 + NumPopnointernetH_2013_17 + NumPopnocomputerH_2013_17);
      pctbroadbandw= numpopbroadbandw_&year. /(NumPopdialupW_2013_17 + NumPopbroadbandW_2013_17 + NumPopnointernetW_2013_17 + NumPopnocomputerW_2013_17);
      pctbroadbandiom= numpopbroadbandiom_&year./(NumPopdialupIOM_2013_17 + NumPopbroadbandIOM_2013_17 + NumPopnointernetIOM_2013_17 + NumPopnocomputerIOM_2013_17);
      tothhdemom= hshldinc100000plus_2013_17+ hshldincunder15000_2013_17+ hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17+
      hshldinc50000to74999_2013_17+ hshldinc75000to99999_2013_17 ;
      percent100Kplus= hshldinc100000plus_2013_17/tothhdemom;
	  percentunder15K= hshldincunder15000_2013_17/tothhdemom;
	  percent15to50K= (hshldinc15000to34999_2013_17+ hshldinc35000to49999_2013_17)/tothhdemom;
	  percent50to75K= hshldinc50000to74999_2013_17/tothhdemom;
      percent75Kto100K= hshldinc75000to99999_2013_17/tothhdemom;
      internetdenom= Numdialup_&year. + Numbroadbandall_&year. + Numcellular_&year. + Numcellularonly_&year. + Numbroadband_&year. + Numbroadbandonly_&year. + Numsatellite_&year.+ 
           Numsatelliteonly_&year. + Numotheronly_&year. + Numaccesswosub_&year. + Numnointernet_&year.;
	  pctinternet= (internetdenom- Numnointernet_&year.)/internetdenom;
	  pctnointernet= 1- pctinternet;

run;

proc export data= BroadbandAcccess 
   outfile="&_dcdata_default_path\Requests\Prog\2019\Broadband_access_tract.csv"
   dbms=csv
   replace;
run;

proc sort data= BroadbandAcccess ;
by metro15;run;

proc summary data = BroadbandAcccess;
	var    tothhdemom Numhhdefined_2013_17 medfamincm_&year. NumPopdialupA_2013_17 NumPopbroadbandA_2013_17 NumPopnointernetA_2013_17 NumPopnocomputerA_2013_17
	      NumPopdialupB_2013_17 NumPopbroadbandB_2013_17NumPopnointernetB_2013_17 NumPopnocomputerB_2013_17 NumPopdialupH_2013_17 + NumPopbroadbandH_2013_17 + NumPopnointernetH_2013_17 + NumPopnocomputerH_2013_17
           NumPopdialupW_2013_17 + NumPopbroadbandW_2013_17 + NumPopnointernetW_2013_17 + NumPopnocomputerW_2013_17 NumPopdialupIOM_2013_17 + NumPopbroadbandIOM_2013_17 + NumPopnointernetIOM_2013_17 + NumPopnocomputerIOM_2013_17 numpopbroadbandtot
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_2013_17 hshldincunder15000_2013_17 hshldinc15000to34999_2013_17 hshldinc35000to49999_2013_17
           hshldinc50000to74999_2013_17 hshldinc75000to99999_2013_17;
		   by metro15;
	output out = AccessinDMV sum = ;
run;
proc sort data=InternetAcccess;
by Jurisdiction;run;
proc summary data = InternetAcccess (where=(metro15= "47900"));
	var  Numhhdefined_2013_17 medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. numpopbroadbandtot
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
