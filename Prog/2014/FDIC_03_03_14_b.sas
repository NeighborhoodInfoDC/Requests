/**************************************************************************
 Program:  FDIC_03_03_14_b.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/03/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Data for presentation at FDIC bankers session, 3/5/14.
 
 Data on Maryland counties from MRIS.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( MRIS )

proc format;
  value $cnty
    "24031" = "Montgomery County" 
    "24033" = "Prince George's County" 
    "24009" = "Calvert County" 
    "24017" = "Charles County" 
    "24021" = "Frederick County"
    other = " ";
run;

%let start_date = '01jul2000'd;
%let end_date = '01jul2013'd;

options mprint symbolgen mlogic;

/** Macro Expand - Start Definition **/

%macro Expand( );


data FDIC_03_03_14_b;

  set Mris.Rbi_cnty_all_data 
       (keep=ucounty numsale: wgtsale:);
       
  where put( ucounty, $cnty. ) ~= "";
  
  %let dt = %sysevalf( &start_date );
  
  %do %until ( &dt > %sysevalf( &end_date ) );

    Date = &dt; 
    
    numsale = numsale%sysfunc( year(&dt) )_%sysfunc( putn(%sysfunc( month(&dt) ),z2.) );
    wgtsale = wgtsale%sysfunc( year(&dt) )_%sysfunc( putn(%sysfunc( month(&dt) ),z2.) );
    
    %dollar_convert( wgtsale, wgtsale_r, %sysfunc(year(&dt)), %sysfunc(year(&end_date)), series=CUUR0000SA0L2 );
    
    output;
    
    %let dt = %sysfunc( intnx( month, &dt, 1, b ) );
    
  %end;

  keep ucounty date numsale wgtsale wgtsale_r;
  
  format ucounty $cnty. date mmddyy10.;

run;

%File_info( data=FDIC_03_03_14_b, printobs=100 )

%mend Expand;

/** End Macro Definition **/

%Expand( )


%File_info( data=FDIC_03_03_14_b, printobs=0, freqvars=ucounty )

ods tagsets.excelxp file="L:\Libraries\Requests\Prog\2014\FDIC_03_03_14_b.xls" style=Minimal options(sheet_interval='Page' );

proc tabulate data=FDIC_03_03_14_b format=comma10.0 noseps missing;
  class ucounty date;
  var numsale;
  var wgtsale_r / weight=numsale;
  table 
    /** Pages **/
    numsale wgtsale_r,
    /** Rows **/
    Date=' ',
    /** Columns **/
    mean=' ' * ucounty=' '
  ;
  format date year4.;
run;

ods tagsets.excelxp close;

