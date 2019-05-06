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
%DCData_lib( ACS );
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
set acs.Acs_&year._va_sum_tr_tr10 acs.Acs_&year._dc_sum_tr_tr10 acs.Acs_&year._md_sum_tr_tr10 acs.Acs_&year._wv_sum_tr_tr10;
	  keep geo2010 geoid totpop_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. popaloneaiom_&year. 
	       Numdialup_&year. Numbroadbandall_&year. Numcellular_&year. Numcellularonly_&year. Numbroadband_&year. Numbroadbandonly_&year. Numsatellite_&year.
           Numsatelliteonly_&year. Numotheronly_&year. Numaccesswosub_&year. Numnointernet_&year. Numwithinternet_&year. 
           county Jurisdiction hshldinc100000plus_&year. hshldincunder15000_&year. hshldinc15000to34999_&year. hshldinc35000to49999_&year.
           hshldinc50000to74999_&year. hshldinc75000to99999_&year. Numwithinternet_&year. Numhhdefined_&year. numpopbroadbanda_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
           numpopbroadbandiom_&year. NumPopdialupA_&year. NumPopbroadbandA_&year. NumPopnointernetA_&year. NumPopnocomputerA_&year.
           NumPopdialupB_&year. NumPopbroadbandB_&year. NumPopnointernetB_&year. NumPopnocomputerB_&year. 
           NumPopdialupH_&year. NumPopbroadbandH_&year. NumPopnointernetH_&year. NumPopnocomputerH_&year.
           NumPopdialupW_&year. NumPopbroadbandW_&year. NumPopnointernetW_&year. NumPopnocomputerW_&year.
           NumPopdialupIOM_&year. NumPopbroadbandIOM_&year. NumPopnointernetIOM_&year. NumPopnocomputerIOM_&year.;

      county= substr(geo2010, 1,5);
	  ucounty=county;
	  geoid= geo2010;

%ucounty_jurisdiction
	  format Jurisdiction Jurisdiction. ;
run;


data InternetAcccess ;
	  set ACSall;
	  metro15 = put( county, $ctym15f. );

      percent100Kplus= hshldinc100000plus_&year./Numhhdefined_&year.;
	  percentunder15K= hshldincunder15000_&year./Numhhdefined_&year.;
	  percent15to50K= (hshldinc15000to34999_&year.+ hshldinc35000to49999_&year.)/Numhhdefined_&year.;
	  percent50to75K= hshldinc50000to74999_&year./Numhhdefined_&year.;
      percent75Kto100K= hshldinc75000to99999_&year./Numhhdefined_&year.;
	  internetdenom= Numhhdefined_&year.;
	  pctinternetsub= Numwithinternet_&year. /internetdenom;
      pctinternetwosub= Numaccesswosub_&year. /internetdenom;
	  pctnointernet= Numnointernet_&year./internetdenom;

run;

proc export data= InternetAcccess
   outfile="&_dcdata_default_path\Requests\Prog\2019\Internet_access_tract.csv"
   dbms=csv
   replace;
run;

data BroadbandAcccess ;
	  set ACSall;
	      
	  metro15 = put( county, $ctym15f. );
      pctbroadband= Numbroadband_&year./Numhhdefined_&year. ;
	  pctbroadbanda= numpopbroadbanda_&year./(NumPopdialupA_&year. + NumPopbroadbandA_&year. + NumPopnointernetA_&year. + NumPopnocomputerA_&year.);
	  pctbroadbandb= numpopbroadbandb_&year./(NumPopdialupB_&year. + NumPopbroadbandB_&year. + NumPopnointernetB_&year. + NumPopnocomputerB_&year.);
      pctbroadbandh= numpopbroadbandh_&year. /(NumPopdialupH_&year. + NumPopbroadbandH_&year. + NumPopnointernetH_&year. + NumPopnocomputerH_&year.);
      pctbroadbandw= numpopbroadbandw_&year. /(NumPopdialupW_&year. + NumPopbroadbandW_&year. + NumPopnointernetW_&year. + NumPopnocomputerW_&year.);
      pctbroadbandiom= numpopbroadbandiom_&year./(NumPopdialupIOM_&year. + NumPopbroadbandIOM_&year. + NumPopnointernetIOM_&year. + NumPopnocomputerIOM_&year.);
     
      percent100Kplus= hshldinc100000plus_&year./Numhhdefined_&year.;
	  percentunder15K= hshldincunder15000_&year./Numhhdefined_&year.;
	  percent15to50K= (hshldinc15000to34999_&year.+ hshldinc35000to49999_&year.)/Numhhdefined_&year.;
	  percent50to75K= hshldinc50000to74999_&year./Numhhdefined_&year.;
      percent75Kto100K= hshldinc75000to99999_&year./Numhhdefined_&year.;
	  pctinternetsub= Numwithinternet_&year. /Numhhdefined_&year.;
      pctinternetwosub= Numaccesswosub_&year. /Numhhdefined_&year.;
	  pctnointernet= Numnointernet_&year./Numhhdefined_&year.;


run;

proc export data= BroadbandAcccess 
   outfile="&_dcdata_default_path\Requests\Prog\2019\Broadband_access_tract.csv"
   dbms=csv
   replace;
run;


proc sort data= BroadbandAcccess ;
by metro15;run;

proc summary data = BroadbandAcccess;
	var    Numhhdefined_&year. medfamincm_&year. NumPopdialupA_&year. NumPopbroadbandA_&year. NumPopnointernetA_&year. NumPopnocomputerA_&year.
	       NumPopdialupB_&year. NumPopbroadbandB_&year. NumPopnointernetB_&year. NumPopnocomputerB_&year. NumPopdialupH_&year. NumPopbroadbandH_&year. NumPopnointernetH_&year. NumPopnocomputerH_&year.
           NumPopdialupW_&year. NumPopbroadbandW_&year. NumPopnointernetW_&year. NumPopnocomputerW_&year. NumPopdialupIOM_&year. NumPopbroadbandIOM_&year. NumPopnointernetIOM_&year. NumPopnocomputerIOM_&year. Numbroadband_&year.
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_&year. hshldincunder15000_&year. hshldinc15000to34999_&year. hshldinc35000to49999_&year.
           hshldinc50000to74999_&year. hshldinc75000to99999_&year.;
		   by metro15;
	output out = AccessinDMV sum = ;
run;
proc sort data= BroadbandAcccess;
by Jurisdiction;run;
proc summary data = BroadbandAcccess (where=(metro15= "47900"));
	var    Numhhdefined_&year. medfamincm_&year. Numbroadband_&year.
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_&year. hshldincunder15000_&year. hshldinc15000to34999_&year. hshldinc35000to49999_&year.
           hshldinc50000to74999_&year. hshldinc75000to99999_&year.;
		   by Jurisdiction;
	output out = Accessbycounty sum = ;
run;
data accessbycounty2;
set Accessbycounty;
      percent100Kplus= hshldinc100000plus_&year./Numhhdefined_&year.;
	  percentunder15K= hshldincunder15000_&year./Numhhdefined_&year.;
	  percent15to50K= (hshldinc15000to34999_&year.+ hshldinc35000to49999_&year.)/Numhhdefined_&year.;
	  percent50to75K= hshldinc50000to74999_&year./Numhhdefined_&year.;
      percent75Kto100K= hshldinc75000to99999_&year./Numhhdefined_&year.;
	  pctbroadband= Numbroadband_&year./Numhhdefined_&year. ;

run;


proc sort data=BroadbandAcccess;
by geo2010;run;

proc summary data = BroadbandAcccess (where=(metro15= "47900"));
	var  Numbroadband_&year. medfamincm_&year. popalonew_&year. popaloneb_&year. popaloneh_&year. popalonea_&year. 
	       numpopbroadbanda_&year. numpopbroadbandiom_&year. numpopbroadbandb_&year. numpopbroadbandh_&year. numpopbroadbandw_&year.
	       hshldinc100000plus_&year. hshldincunder15000_&year. hshldinc15000to34999_&year. hshldinc35000to49999_&year.
           hshldinc50000to74999_&year. hshldinc75000to99999_&year. Numhhdefined_&year. Numwithinternet_&year. Numaccesswosub_&year. Numnointernet_&year. ;
		   by geo2010;
	output out = Accessbytract_DMV sum = ;
run;

data Accessbytract2_DMV;
set Accessbytract_DMV;

      percent100Kplus= hshldinc100000plus_&year./Numhhdefined_&year.;
	  percentunder15K= hshldincunder15000_&year./Numhhdefined_&year.;
	  percent15to50K= (hshldinc15000to34999_&year.+ hshldinc35000to49999_&year.)/Numhhdefined_&year.;
	  percent50to75K= hshldinc50000to74999_&year./Numhhdefined_&year.;
      percent75Kto100K= hshldinc75000to99999_&year./Numhhdefined_&year.;
	  broadbandaccess= Numbroadband_&year./Numhhdefined_&year.;
	  pctinternetsub= Numwithinternet_&year. /Numhhdefined_&year.;
      pctinternetwosub= Numaccesswosub_&year. /Numhhdefined_&year.;
	  pctnointernet= Numnointernet_&year./Numhhdefined_&year.;

run;

proc export data= Accessbytract2_DMV
   outfile="&_dcdata_default_path\Requests\Prog\2019\Internetbroadband_access_DMVtract.csv"
   dbms=csv
   replace;
run;
