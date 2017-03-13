/**************************************************************************
 Program:  Gross_rent_2005_2012.sas
 Library:  OCC
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/04/14
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Process gross rent ranges.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( OCC )

%let START_YR = 2005;
%let END_YR = 2012;

data Occ_r.Gross_rent_2005_2012;

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
      Low
      High
     ;
     
   ** Create low and high rent levels adjusted for inflation **;
   
   array a_low{&START_YR:&END_YR} Low&START_YR-Low&END_YR;
   array a_high{&START_YR:&END_YR} High&START_YR-High&END_YR;
   
   do i = &START_YR to &END_YR;
   
     %dollar_convert( Low, a_low{i}, i, 2012, series=CUUR0000SA0L2 )
     %dollar_convert( High, a_high{i}, i, 2012, series=CUUR0000SA0L2 )
        
   end;
   
   retain Carry&START_YR-Carry&END_YR 0;
   
   array a_units{&START_YR:&END_YR} Units&START_YR-Units&END_YR;
   array a_unitsadj{&START_YR:&END_YR} UnitsAdj&START_YR-UnitsAdj&END_YR;
   array a_carry{&START_YR:&END_YR} Carry&START_YR-Carry&END_YR;
   
   do i = &START_YR to &END_YR;
   
     if not missing( a_high{i} ) then do;
     
       a_unitsadj{i} = min( ( ( high - low ) / ( a_high{i} - a_low{i} ) ), 1 ) * a_units{i} + a_carry{i};
       
       a_carry{i} = ( 1 - min( ( ( high - low ) / ( a_high{i} - a_low{i} ) ), 1 ) ) * a_units{i}; 
       
     end;
     else do;
     
       a_unitsadj{i} = a_units{i} + a_carry{i};
       
     end;
      
   end;
   
   drop i Low&START_YR-Low&END_YR High&START_YR-High&END_YR Carry&START_YR-Carry&END_YR;

datalines;
2211	1616	1481	1972	1923	1364	745	1086	0	100
2324	2744	1551	1504	874	1070	1268	1191	100	149
3883	5436	3543	3828	3440	2999	2856	3218	150	199
2563	2672	2725	2286	2169	2107	2810	2236	200	249
2229	2210	1842	2361	3270	1891	2470	2596	250	299
1919	2131	1273	2603	2262	2339	2802	1329	300	349
2249	2579	1818	1071	1913	1413	1968	2007	350	399
2978	1854	2695	1468	1001	1222	1970	1586	400	449
4108	1907	2221	1347	1876	1967	1513	1954	450	499
4119	4214	3283	3981	3149	2232	2033	2951	500	549
6017	3812	4317	2922	1683	1988	2827	1765	550	599
7504	4892	5957	3808	3035	2583	2196	2732	600	649
7003	5448	5919	5284	3117	3017	3125	2360	650	699
9488	6452	7215	4907	4698	4282	4137	3257	700	749
7856	5495	6397	6582	4167	3222	3321	3766	750	799
11569	11124	11688	12304	13519	11739	11811	11139	800	899
13492	12249	10115	10060	9919	9882	10101	9769	900	999
18437	21907	20368	22937	21710	18883	22200	22838	1000	1249
11314	12332	13860	14350	16240	21077	22244	20226	1250	1499
11767	11353	14381	16689	16373	22599	26570	27905	1500	1999
7348	10110	12074	16365	17911	22618	25325	26934	2000	.
;


run;

%File_info( data=Occ_r.Gross_rent_2005_2012, printobs=50 )

proc format;
  value rntrang
    0-450 = 'Under $500'
    500-650 = '$500 to $699'
    700-750 = '$700 to $799'
    800-900 = '$800 to $999'
    1000-1250 = '$1,00 to $1,499'
    1500-2000 = '$1,500 or more';
run;
    
ods csvall body="L:\Libraries\OCC\Prog\Ch3\Gross_rent_2005_2012.csv";

proc tabulate data=Occ_r.Gross_rent_2005_2012 format=comma10.0 noseps missing;
  class low;
  var UnitsAdj2005-UnitsAdj2012;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( UnitsAdj2005-UnitsAdj2012 )
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
    UnitsAdj2012 = '2012';
  title2 'Renter-Occupied Housing Units by Gross Rent (constant 2012 $)';
run;

ods csvall close;
