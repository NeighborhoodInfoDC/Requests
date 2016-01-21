/**************************************************************************
 Program:  Lauber_04_05_11.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/05/11
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Request from Daniel Lauber
<dl@planningcommunications.com>, 4/5/11. 
Population by race with Hispanics included for 2010 by standard DC
geographies. Provide data in Excel.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( NCDB )

/** Macro Ncdb_sum_geo - Start Definition **/

%macro Ncdb_sum_geo( geo );

  %let sum_vars = shr1d shrwht1n shrblk1n shrasn1n shrhip1n shrami1n shroth1n shrhsp1n;

  %let geo = %upcase( &geo );

  %if %sysfunc( putc( &geo, $geoval. ) ) ~= %then %do;
    %let geosuf = %sysfunc( putc( &geo, $geosuf. ) );
    %let geodlbl = %sysfunc( putc( &geo, $geodlbl. ) );
    %let geofmt = %sysfunc( putc( &geo, $geoafmt. ) );
  %end;
  %else %do;
    %err_mput( macro=Create_sum_geo, msg=Invalid or missing value of GEO= parameter (GEO=&geo). )
    %goto exit_macro;
  %end;
      
  %put _local_;
  
  %syslput geo=&geo;
  %syslput sum_vars=&sum_vars;
  %syslput geosuf=&geosuf;
  %syslput geodlbl=&geodlbl;
  %syslput geofmt=&geofmt;
  
  ** Start submitting commands to remote server **;

  rsubmit;

  ** Convert data to single obs. per geographic unit & year **;

  proc summary data=Ncdb.Ncdb_2010_dc_blk nway completetypes;
    class &geo / preloadfmt;
    var &sum_vars;
    output 
      out=Ncdb_sum_2010&geosuf 
            (label="NCDB summary, 2010, DC, &geodlbl" 
             sortedby=&geo
             drop=_type_ _freq_) 
      sum=;
    format &geo &geofmt;
  run;
  
  proc download status=no
    data=Ncdb_sum_2010&geosuf 
    out=Ncdb_sum_2010&geosuf;
  run;

  endrsubmit;

  ** End submitting commands to remote server **;
  
  ods listing close;
  
  ods tagsets.excelxp file="&_dcdata_path\Requests\Prog\2011\Lauber_04_05_11\Lauber_04_05_11&geosuf..xls" /*style=statistical*/
        options( sheet_name="&geodlbl" );

  proc print data=Ncdb_sum_2010&geosuf label;
    id &geo;
  run;
  
  ods tagsets.excelxp close;
  
  ods listing;

  %exit_macro:
  
%mend Ncdb_sum_geo;

%Ncdb_sum_geo( anc2002 )
%Ncdb_sum_geo( city )
%Ncdb_sum_geo( cluster_tr2000 )
%Ncdb_sum_geo( psa2004 )
%Ncdb_sum_geo( geo2000 )
%Ncdb_sum_geo( ward2002 )
%Ncdb_sum_geo( zip )

run;

signoff;
