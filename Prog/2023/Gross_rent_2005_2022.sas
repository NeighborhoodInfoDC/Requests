/**************************************************************************
 Program:  Gross_rent_2005_2022.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  06/20/2018
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Creates adjusted gross rent ranges for 
 DC rental housing units by gross rent trend chart. 

 Data from ACS 1-year table B25063/GROSS RENT downloaded from American
 Factfinder. 
 
 Copy and paste lastest ACS data into DATALINES statement below.
 
 Upper ranges for 2015 and later were collapsed into $2,000 or more.

 Modifications: YS extended data to 2018
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )

%let state = 11;
%let county = 001;
%let START_YR = 2005;
%let END_YR = 2018;
%let output_path = &_dcdata_default_path\Requests\Prog\2023;


** Rent range format for summary **;

proc format;
  value rent_range
       0 -<  500 = 'Under $500'
     500 -<  700 = '$500 to $699'
     700 -<  800 = '$700 to $799'
     800 -< 1000 = '$800 to $999'
    1000 -< 1500 = '$1,000 to $1,499'
    1500 -  high = '$1,500 or more';
run;

%include "C:\Projects\UISUG\Uiautos\Get_acs_detailed_table_api.sas";

** Create macros **;

%macro download_data( );

  %local i top_code;
  
  %let top_code = 999999999;
  
  %do i = &START_YR %to &END_YR;
  
  %PUT _LOCAL_;
  
    %Get_acs_detailed_table_api( 
      table=B25063, 
      out=B25063_&i,
      year=&i, 
      sample=acs1, 
      for=county:&county,
      in=state:&state,
      key=&_dcdata_census_api_key
    )
    
    /* %File_info( data=B25063_&i ) */
    
    proc transpose data=B25063_&i out=B25063_&i._tr;
    run;

    /* %File_info( data=B25063_&i._tr, printobs=100 ) */
    
    data Units&i._det;
    
      length temp $ 1000;
    
      set B25063_&i._tr (rename=(col1=units&i));
      
      if upcase( reverse( _name_ ) ) =: 'E';
      
      temp = left( lowcase( compress( _label_, ':' ) ) );
      
      if temp = 'total' then delete;
      
      temp = left( substr( temp, length( 'total with cash rent ' ) + 1 ) );
        
      if length( temp ) > 1 then do;
      
        if left( temp ) =: 'less than ' then do;
          low = 0;
          high = input( scan( temp, 2, '$' ), comma16. );
        end;
        else do;
        
          temp = compress( temp, 'abcdefghijklmnopqrstuvwxyz$,' ); 
          
          low = min( input( scan( temp, 1 ), 16. ), &top_code );
          
          if low < &top_code then 
            high = input( scan( temp, 2 ), 16. ) + 1;
          else 
            high = .;
          
        end;
        
      end;
      else 
        delete;
        
    run;
      
    /* %File_info( data=Units&i._det, printobs=100 ) */
    
    proc summary data=Units&i._det nway;
      class low high / missing;
      var Units&i;
      output out=Units&i (drop=_freq_ _type_) sum=;
    run;
    
    /* %File_info( data=Units&i, printobs=100 ) */
    
    %if &i = &START_YR %then %do;
    
      ** Set top_code value based on earliest year read **;
    
      proc sql noprint;
        select max(low) into :top_code from Units&i;
      quit;
      
    %end;
  
  %end;
  
  ** Combine files **;
  
  data Units_all;
  
    merge
      %do i = &START_YR %to &END_YR;
        Units&i.
      %end;
    ;
    by low high;
    
  run;
  
  %File_info( data=Units_all, printobs=100 )
  
%mend download_data;

%macro rename_all( varA, varB );

  %do i = &START_YR %to &END_YR;
    &varA.&i=&varB.&i 
  %end;
  
%mend rename_all;

/***
%macro enum_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i 
  %end;
  
%mend enum_all;
***/

%macro label_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i = "&i"
  %end;
  
%mend label_all;


** Generate summary data **;

%download_data()

data 
  Base
    (keep=rcount_output low high Units&START_YR-Units&END_YR UnitsAdj&START_YR-UnitsAdj&END_YR
     Low&START_YR-Low&END_YR High&START_YR-High&END_YR)
  Carry_fwd
    (keep=rcount_output Carry_fwd&START_YR-Carry_fwd&END_YR
     rename=(%rename_all(Carry_fwd, UnitsAdj)))
  Carry_bck
    (keep=rcount_output Carry_bck&START_YR-Carry_bck&END_YR
     rename=(%rename_all(Carry_bck, UnitsAdj)))
  ;

   rcount_input + 1;

   set Units_all;
     
   ** Create low and high rent levels adjusted for inflation **;
   
   array a_low{&START_YR:&END_YR} Low&START_YR-Low&END_YR;
   array a_high{&START_YR:&END_YR} High&START_YR-High&END_YR;
   
   do i = &START_YR to &END_YR;
   
     %dollar_convert( Low, a_low{i}, i, &END_YR, series=CUUR0000SA0L2 )
     %dollar_convert( High, a_high{i}, i, &END_YR, series=CUUR0000SA0L2 )
        
   end;
   
   **retain Carry&START_YR-Carry&END_YR 0;
   
   array a_units{&START_YR:&END_YR} Units&START_YR-Units&END_YR;
   array a_unitsadj{&START_YR:&END_YR} UnitsAdj&START_YR-UnitsAdj&END_YR;
   array a_carry_fwd{&START_YR:&END_YR} Carry_fwd&START_YR-Carry_fwd&END_YR;
   array a_carry_bck{&START_YR:&END_YR} Carry_bck&START_YR-Carry_bck&END_YR;
   array a_rcount{&START_YR:&END_YR} Rcount&START_YR-Rcount&END_YR;
   
   do i = &START_YR to &END_YR;
   
     if high = . then do;
     
       if a_low{i} < low then do;
       
         a_unitsadj{i} = a_units{i} * 0.5;
         a_carry_bck{i} = a_units{i} * 0.5;
           
       end;
       else do;
       
         a_unitsadj{i} = a_units{i};
         
       end;
     
     end;
     else if a_high{i} > high then do;
     
       a_unitsadj{i} = a_units{i} * ( ( high - a_low{i} ) / ( a_high{i} - a_low{i} ) );
       a_carry_fwd{i} = a_units{i} * ( ( a_high{i} - high ) / ( a_high{i} - a_low{i} ) );
         
     end;
     else if a_high{i} <= high then do;
     
       a_unitsadj{i} = a_units{i} * ( ( a_high(i) - low ) / ( a_high{i} - a_low{i} ) );
       a_carry_bck{i} = a_units{i} * ( ( low - a_low{i} ) / ( a_high{i} - a_low{i} ) );

     end;
     
   end;
   
   rcount_output = rcount_input;
   output base;
   
   if rcount_input > 1 then do;
     rcount_output = rcount_input - 1;
     output carry_bck;
   end;
   
   if high ~= . then do;
     rcount_output = rcount_input + 1;
     output carry_fwd;
   end;
   
   *drop i Low&START_YR-Low&END_YR High&START_YR-High&END_YR Carry&START_YR-Carry&END_YR;

/*
datalines;
2211	1616	1481	1972	1923	1364	745	1086	1148	1195	1152	2889	1989	1106	0	100
2324	2744	1551	1504	874	1070	1268	1191	1637	1010	709	991	595	1630	100	150
3883	5436	3543	3828	3440	2999	2856	3218	2132	1659	1095	1533	1884	1133	150	200
2563	2672	2725	2286	2169	2107	2810	2236	4649	3324	4641	4733	4031	3797	200	250
2229	2210	1842	2361	3270	1891	2470	2596	2892	3008	2230	2614	1753	2060	250	300
1919	2131	1273	2603	2262	2339	2802	1329	1562	2030	1870	1690	2224	1542	300	350
2249	2579	1818	1071	1913	1413	1968	2007	1150	1713	1828	2226	1434	1965	350	400
2978	1854	2695	1468	1001	1222	1970	1586	1160	1569	1703	2536	1406	1689	400	450
4108	1907	2221	1347	1876	1967	1513	1954	944	1641	2233	1342	669	906	450	500
4119	4214	3283	3981	3149	2232	2033	2951	1267	1329	1179	753	1564	1190	500	550
6017	3812	4317	2922	1683	1988	2827	1765	1657	1493	1646	1368	831	1169	550	600
7504	4892	5957	3808	3035	2583	2196	2732	1796	1203	2536	1695	1649	2349	600	650
7003	5448	5919	5284	3117	3017	3125	2360	2030	2021	1614	2543	1612	1536	650	700
9488	6452	7215	4907	4698	4282	4137	3257	2737	2394	2427	2598	2919	2386	700	750
7856	5495	6397	6582	4167	3222	3321	3766	4133	3121	2195	2393	1625	1853	750	800
11569	11124	11688	12304	13519	11739	11811	11139	9205	9874	7445	7837	4628	4474	800	900
13492	12249	10115	10060	9919	9882	10101	9769	10280	10542	9158	9462	7903	7490	900	1000
18437	21907	20368	22937	21710	18883	22200	22838	23547	22928	23858	23248	21898	22730	1000	1250
11314	12332	13860	14350	16240	21077	22244	20226	19068	16401	18579	20639	18720	19615	1250	1500
11767	11353	14381	16689	16373	22599	26570	27905	28618	28183	34371	30320	34081	32650	1500	2000
7348	10110	12074	16365	17911	22618	25325	26934	34887	41867	41352	42337	45135	50103	2000	.
;
*/

run;

data All;

  set Base Carry_fwd Carry_bck;
  
run;

proc summary data=All nway;
  class rcount_output;
  id low high Units&START_YR-Units&END_YR;
  var unitsadj: ;
  output out=Gross_rent_&START_YR._&END_YR. sum=;
run;

/*** UNCOMMENT TO CHECK ***

%let testyr = 2012;

proc print data=Base;
  id rcount_output;
  var low high low&testyr high&testyr units&testyr unitsadj&testyr;
  sum units&testyr;
run;

proc print data=Carry_fwd;
  id rcount_output;
  var unitsadj&testyr ;
run;

proc print data=Carry_bck;
  id rcount_output;
  var unitsadj&testyr ;
run;

proc print data=All_sum;
  id rcount_output low high;
  var unitsadj&testyr ;
  sum unitsadj&testyr ;
run;

/**********************************/


%File_info( data=Gross_rent_&START_YR._&END_YR., printobs=50 )

proc tabulate data=Gross_rent_&START_YR._&END_YR. format=comma10.0 noseps missing;
  class low;
  var Units&START_YR.-Units&END_YR.;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( Units&START_YR.-Units&END_YR. )
  ;
  format low rent_range.;
  label 
    %label_all( Units )
  ;
  title2 "Renter-Occupied Housing Units by Gross Rent, District of Columbia (UNADJUSTED)";
run;
    
ods csvall body="&output_path\Gross_rent_&START_YR._&END_YR..csv";

proc tabulate data=Gross_rent_&START_YR._&END_YR. format=comma10.0 noseps missing;
  class low;
  var UnitsAdj&START_YR.-UnitsAdj&END_YR.;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( UnitsAdj&START_YR.-UnitsAdj&END_YR. )
  ;
  format low rent_range.;
  label 
    %label_all( UnitsAdj )
  ;
  title2 "Renter-Occupied Housing Units by Gross Rent, District of Columbia (constant &END_YR. $)";
run;

ods csvall close;
