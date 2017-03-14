/**************************************************************************
 Program:  Gross_rent_2005_2015.sas
 Library:  OCC
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/04/14
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Process gross rent ranges.

 Data from ACS 1-year table B25063/GROSS RENT downloaded from American
 Factfinder. 
 Upper ranges for 2015 were collapsed into $2,000 or more.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )

%let START_YR = 2005;
%let END_YR = 2015;

data A B;

    rcount_input + 1;

    infile datalines missover dlm='09'x;

    input
      Units2005
      Units2006
      Units2007
      Units2008
      Units2009
      Units2010
      Units2011
      Units2012
      Units2013
      Units2014
      Units2015
      Low
      High
     ;
     
   ** Create low and high rent levels adjusted for inflation **;
   
   array a_low{&START_YR:&END_YR} Low&START_YR-Low&END_YR;
   array a_high{&START_YR:&END_YR} High&START_YR-High&END_YR;
   
   do i = &START_YR to &END_YR;
   
     %dollar_convert( Low, a_low{i}, i, &END_YR, series=CUUR0000SA0L2 )
     %dollar_convert( High, a_high{i}, i, &END_YR, series=CUUR0000SA0L2 )
        
   end;
   
   retain Carry&START_YR-Carry&END_YR 0;
   
   array a_units{&START_YR:&END_YR} Units&START_YR-Units&END_YR;
   array a_unitsadj{&START_YR:&END_YR} UnitsAdj&START_YR-UnitsAdj&END_YR;
   array a_carry{&START_YR:&END_YR} Carry&START_YR-Carry&END_YR;
   
   
     rcount_output = rcount_input;
       
     if high = . then do;
     
       if a_low{&END_YR} <= low then do;
       
         do i = &START_YR to &END_YR;
           a_unitsadj{i} = a_units{i} * 0.5;
         end;
           
         output A;
           
         rcount_output = rcount_output - 1;
           
         do i = &START_YR to &END_YR;
           a_unitsadj{i} = a_units{i} * 0.5;
         end;
           
         output B;
           
       end;
       else do;
       
         do i = &START_YR to &END_YR;
           a_unitsadj{i} = a_units{i};
         end;
         
         output A;
         
       end;
     
     end;
     else if a_high{&START_YR} > high then do;
     
       do i = &START_YR to &END_YR;
         a_unitsadj{i} = a_units{i} * ( ( a_high{i} - low ) / ( a_high{i} - a_low{i} ) );
       end;
       
       output A;
       
       if rcount_output > 1 then do;
       
         rcount_output = rcount_output - 1;
         
         do i = &START_YR to &END_YR;
           a_unitsadj{i} = a_units{i} * ( ( low - a_low{i} ) / ( a_high{i} - a_low{i} ) );
         end;
         
         output B;
         
       end;
       
     end;
     else if a_high{&START_YR} <= high then do;
     
       do i = &START_YR to &END_YR;
         a_unitsadj{i} = a_units{i} * ( ( high - a_low{i} ) / ( a_high{i} - a_low{i} ) );
       end;
       
       output A;
       
       rcount_output = rcount_output + 1;
       
       do i = &START_YR to &END_YR;
         a_unitsadj{i} = a_units{i} * ( ( a_high{i} - high ) / ( a_high{i} - a_low{i} ) );
       end;
       
       output B;
       
     end;
   
   
   /**************
     if not missing( a_high{i} ) then do;
     
       a_unitsadj{i} = min( ( ( high - low ) / ( a_high{i} - a_low{i} ) ), 1 ) * a_units{i} + a_carry{i};
       
       a_carry{i} = ( 1 - min( ( ( high - low ) / ( a_high{i} - a_low{i} ) ), 1 ) ) * a_units{i}; 
       
     end;
     else do;
     
       a_unitsadj{i} = a_units{i} + a_carry{i};
       
     end;
   ********************/
      

   
   *drop i Low&START_YR-Low&END_YR High&START_YR-High&END_YR Carry&START_YR-Carry&END_YR;

datalines;
2211	1616	1481	1972	1923	1364	745	1086	1148	1195	1152	0	100
2324	2744	1551	1504	874	1070	1268	1191	1637	1010	709	100	150
3883	5436	3543	3828	3440	2999	2856	3218	2132	1659	1095	150	200
2563	2672	2725	2286	2169	2107	2810	2236	4649	3324	4641	200	250
2229	2210	1842	2361	3270	1891	2470	2596	2892	3008	2230	250	300
1919	2131	1273	2603	2262	2339	2802	1329	1562	2030	1870	300	350
2249	2579	1818	1071	1913	1413	1968	2007	1150	1713	1828	350	400
2978	1854	2695	1468	1001	1222	1970	1586	1160	1569	1703	400	450
4108	1907	2221	1347	1876	1967	1513	1954	944	1641	2233	450	500
4119	4214	3283	3981	3149	2232	2033	2951	1267	1329	1179	500	550
6017	3812	4317	2922	1683	1988	2827	1765	1657	1493	1646	550	600
7504	4892	5957	3808	3035	2583	2196	2732	1796	1203	2536	600	650
7003	5448	5919	5284	3117	3017	3125	2360	2030	2021	1614	650	700
9488	6452	7215	4907	4698	4282	4137	3257	2737	2394	2427	700	750
7856	5495	6397	6582	4167	3222	3321	3766	4133	3121	2195	750	800
11569	11124	11688	12304	13519	11739	11811	11139	9205	9874	7445	800	900
13492	12249	10115	10060	9919	9882	10101	9769	10280	10542	9158	900	1000
18437	21907	20368	22937	21710	18883	22200	22838	23547	22928	23858	1000	1250
11314	12332	13860	14350	16240	21077	22244	20226	19068	16401	18579	1250	1500
11767	11353	14381	16689	16373	22599	26570	27905	28618	28183	34371	1500	2000
7348	10110	12074	16365	17911	22618	25325	26934	34887	41867	41352	2000	.
;

run;

%let testyr = 2012;

proc print data=A;
  id rcount_output;
  var low high units&testyr;
  sum units&testyr;
run;

proc print data=A;
  id rcount_output;
  var low&testyr high&testyr unitsadj&testyr ;
run;

proc print data=B;
  id rcount_output;
  var unitsadj&testyr ;
run;

data C;

  set A B (drop=low high);
  
run;

proc summary data=C nway;
  class rcount_output;
  id low high;
  var unitsadj: ;
  output out=C_sum sum=;
run;

proc print data=C_sum;
  id rcount_output low high;
  var unitsadj&testyr ;
  sum unitsadj&testyr ;
run;


ENDSAS;

%File_info( data=Gross_rent_&START_YR._&END_YR., printobs=50 )

proc format;
  value rntrang
    0-450 = 'Under $500'
    500-650 = '$500 to $699'
    700-750 = '$700 to $799'
    800-900 = '$800 to $999'
    1000-1250 = '$1,00 to $1,499'
    1500-2000 = '$1,500 or more';
run;

proc tabulate data=Gross_rent_&START_YR._&END_YR. format=comma10.0 noseps missing;
  class low;
  var Units&START_YR.-Units&END_YR.;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( Units&START_YR.-Units&END_YR. )
  ;
  format low rntrang.;
  label 
    Units2005 = '2005'
    Units2006 = '2006'
    Units2007 = '2007'
    Units2008 = '2008'
    Units2009 = '2009'
    Units2010 = '2010'
    Units2011 = '2011'
    Units2012 = '2012'
    Units2013 = '2013'
    Units2014 = '2014'
    Units2015 = '2015';
  title2 "Renter-Occupied Housing Units by Gross Rent (UNADJUSTED)";
run;
    
ods csvall body="&_dcdata_default_path\Requests\Prog\2017\Gross_rent_&START_YR._&END_YR..csv";

proc tabulate data=Gross_rent_&START_YR._&END_YR. format=comma10.0 noseps missing;
  class low;
  var UnitsAdj&START_YR.-UnitsAdj&END_YR.;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( UnitsAdj&START_YR.-UnitsAdj&END_YR. )
  ;
  format low rntrang.;
  label 
    UnitsAdj2005 = '2005'
    UnitsAdj2006 = '2006'
    UnitsAdj2007 = '2007'
    UnitsAdj2008 = '2008'
    UnitsAdj2009 = '2009'
    UnitsAdj2010 = '2010'
    UnitsAdj2011 = '2011'
    UnitsAdj2012 = '2012'
    UnitsAdj2013 = '2013'
    UnitsAdj2014 = '2014'
    UnitsAdj2015 = '2015';
  title2 "Renter-Occupied Housing Units by Gross Rent (constant &END_YR. $)";
run;

ods csvall close;
