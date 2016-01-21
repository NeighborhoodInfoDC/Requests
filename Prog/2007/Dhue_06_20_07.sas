/**************************************************************************
 Program:  Dhue_06_20_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/21/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Tables of subprime lending for P.G. County and
 "Capitol Heights" area.  
 
 Request from Stephanie Dhue, Nightly Business Report 
 [stephanie_dhue@nbr.com].

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Hmda )

%let start_yr = 1997;
%let end_yr = 2005;

/** Macro Compile_data - Compile data sets across multiple years **/

%macro Compile_data( start_yr=, end_yr= );

  %do year = &start_yr %to &end_yr;

    %let shyear = %substr( &year, 3, 2 );
    
    libname hmdatr&shyear "D:\DCData\Libraries\HMDA\Data\HMDATR&shyear._was.zip";
      
  %end;

  *options obs=10;

  ***** TEMPORARY 2005 FILE ADDING SUBPRIME DATA *****;

  proc sort data=hmdatr05.hmdatr05_was out=in_hmdatr05_was;
    by stfid;

  data Hmdatr05_was;

    merge
      in_hmdatr05_was 
        (where=(geoscaleid="1")
         drop=NumSubprimeConvOrigHomePurch numsubprimeconvorigrefin
         in=in1)
        hmda.subprime05tr_was 
          (keep=geo2000 NumSubprimeConvOrigHomePurch numsubprimeconvorigrefin
           rename=(geo2000=stfid)
          );
    by stfid;
    
    if in1;
    
    if missing( NumSubprimeConvOrigHomePurch ) then NumSubprimeConvOrigHomePurch = 0;
    if missing( numsubprimeconvorigrefin ) then numsubprimeconvorigrefin = 0;

  run;

  *options mprint symbolgen mlogic;

  data Subprime_was_tr;

    set 
      
      %do year = &start_yr %to &end_yr;
      
        %let shyear = %substr( &year, 3, 2 );
    
        %if &year = 2005 %then %do;
        
          HMDATR&shyear._was 
            (keep=stfid ucounty year 
                  numconvmrtgorighomepurch numconvmrtgorigrefin
                  NumSubprimeConvOrigHomePurch numsubprimeconvorigrefin
                  NumHighCostConvOrigPurch NumHighCostConvOrigRefin
                  DenHighCostConvOrigPurch DenHighCostConvOrigRefin
             rename=(NumSubprimeConvOrigHomePurch=NumSubprimeConvOrigHomePur)
             where=(ucounty='24033')
             )

        %end;
        %else %do;

          Hmdatr&shyear..HMDATR&shyear._was 
            (keep=geoscaleid stfid ucounty year 
                  numconvmrtgorighomepurch numconvmrtgorigrefin
                  NumSubprimeConvOrigHomePurch numsubprimeconvorigrefin
                  NumHighCostConvOrigPurch NumHighCostConvOrigRefin
                  DenHighCostConvOrigPurch DenHighCostConvOrigRefin
             rename=(NumSubprimeConvOrigHomePurch=NumSubprimeConvOrigHomePur)
             where=(geoscaleid = '1' /** Tract-level obs. **/
               and ucounty='24033'
               )
             )

        %end;
        
      %end;
      ;
            
       NumSubprimePurRef = 
         sum( NumSubprimeConvOrigHomePur, numsubprimeconvorigrefin );
       
       NumConvPurRef = 
         sum( numconvmrtgorighomepurch, numconvmrtgorigrefin );
       
       NumHighCostPurRef = 
         sum( NumHighCostConvOrigPurch, NumHighCostConvOrigRefin );
         
       DenHighCostPurRef = 
         sum( DenHighCostConvOrigPurch, DenHighCostConvOrigRefin );
       
       format ucounty $cnty99f.;
       
       rename stfid=geo2000;

  run;

  options obs=max;

%mend Compile_data;

/** End Macro Definition **/


*******   MAIN PROGRAM   ********;

%Compile_data( start_yr=&start_yr, end_yr=&end_yr )

%let vars = 
      NumSubprimePurRef NumConvPurRef
      numconvmrtgorighomepurch NumSubprimeConvOrigHomePur 
      numconvmrtgorigrefin numsubprimeconvorigrefin
      DenHighCostPurRef NumHighCostPurRef 
      DenHighCostConvOrigPurch NumHighCostConvOrigPurch 
      DenHighCostConvOrigRefin NumHighCostConvOrigRefin;

proc summary data=Subprime_was_tr nway;
  class geo2000 year;
  var &vars;
  output out=Subprime_was_cty sum= ;

%Super_transpose(  
  data=Subprime_was_cty,
  out=Requests.Dhue_06_20_07,
  var=&vars,
  id=year,
  by=geo2000,
  mprint=N
)

%File_info( data=Requests.Dhue_06_20_07 )


run;
