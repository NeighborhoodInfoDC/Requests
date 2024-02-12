/**************************************************************************
 Program:  Gross_rent_2005_2022.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  02/12/2024
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Creates adjusted gross rent ranges for 
 DC rental housing units by gross rent trend chart. 

 Data from ACS 1-year table B25063/GROSS RENT downloaded from American
 Factfinder through Census API. 
 
 Modifications: 
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )

%let START_YR = 2005;
%let END_YR = 2022;
%let output_path = &_dcdata_default_path\Requests\Prog\2023;


** Rent range format for summary **;

proc format;
  value rent_range
       0 -<  500 = 'Under $500'
     500 -< 1000 = '$500 to $999'
    1000 -< 1500 = '$1,000 to $1,499'
    1500 -< 2000 = '$1,500 to $1,999'
    2000 -  high = '$2,000 or more';
run;

%include "C:\Projects\UISUG\Uiautos\Get_acs_detailed_table_api.sas";

** Create macros **;

%macro download_data( state=, county= );

  %local i top_code county_name;
  
  %let top_code = 999999999;
  
  %if &state = 11 %then %let county_name = District of Columbia;
  %else %let county_name = %sysfunc( putc( %trim(&state)%trim(&county), $cnty22allf. ) );
  
  %do i = &START_YR %to &END_YR;
  
    %** No ACS 1-year data in 2020 so skip **;
    %if &i = 2020 %then %goto end_loop;

    %Get_acs_detailed_table_api( 
      table=B25063, 
      out=B25063_&i,
      year=&i, 
      sample=acs1, 
      for=county:&county,
      in=state:&state,
      key=&_dcdata_census_api_key,
      get_moe=n
    )
    
    /* %File_info( data=B25063_&i ) */
    
    proc transpose data=B25063_&i out=B25063_&i._tr;
    run;

    /* %File_info( data=B25063_&i._tr, printobs=100 ) */
    
    data Units&i._det;
    
      length temp $ 1000;
    
      set B25063_&i._tr (rename=(col1=units&i));
      
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
    
    %end_loop:
  
  %end;
  
  ** Combine files **;
  
  data Units_all;
  
    merge
      %do i = &START_YR %to &END_YR;
        %** No ACS 1-year data in 2020 so skip **;
        %if &i ~= 2020 %then %do;
          Units&i.
        %end;
      %end;
    ;
    by low high;
    
  run;
  
  /* %File_info( data=Units_all, printobs=100 ) */
  
  ** Calculate adjusted unit counts **;

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
     
     %** If part of requested time series, impute 2020 data **;
     
     %if &START_YR <= 2019 and &END_YR >= 2021 %then %do;
     
       units2020 = ( units2019 + units2021 ) / 2;
       
     %end;
       
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

  run;

  data All;

    set Base Carry_fwd Carry_bck;
    
  run;

  proc summary data=All nway;
    class rcount_output;
    id low high Units&START_YR-Units&END_YR;
    var unitsadj: ;
    output out=Gross_rent_&START_YR._&END_YR. (drop=_type_ _freq_) sum=;
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


  /* %File_info( data=Gross_rent_&START_YR._&END_YR., printobs=50 ) */

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
    title2 "Renter-Occupied Housing Units by Gross Rent (UNADJUSTED)";
    title3 "&county_name";
  run;
      
  ods csvall body="&output_path\Gross_rent_&START_YR._&END_YR._%trim(&state)_%trim(&county).csv";

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
    title2 "Renter-Occupied Housing Units by Gross Rent (constant &END_YR. $)";
    title3 "&county_name";
  run;

  ods csvall close;
  
  title2;
  
  proc datasets library=work memtype=(data) kill;
  quit;

%mend download_data;

%macro rename_all( varA, varB );

  %do i = &START_YR %to &END_YR;
    &varA.&i=&varB.&i 
  %end;
  
%mend rename_all;

%macro label_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i = "&i"
  %end;
  
%mend label_all;


** Generate summary data **;

%download_data( state=11, county=001 )
%download_data( state=24, county=031 )
