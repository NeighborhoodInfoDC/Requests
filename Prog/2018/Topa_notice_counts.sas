/**************************************************************************
 Program:  Topa_notice_counts.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  01/16/19
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Count up TOPA notices in different categories.

 Data requested for DC Preservation Network strategy report.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( DHCD )
%DCData_lib( RealProp )
%DCData_lib( MAR )


/** Macro Topa_notices - Start Definition **/

%macro Topa_notices( year );

  ** Join RCASD notice data with real property and MAR info **;
  ** Limit to residential/mixed properties with 5+ residential units **;

  proc sql noprint;
    create table Notices as
    select Rcasd.*, Parcel.ssl, Parcel.ui_proptype 
    from (
      select Rcasd.*, Mar.address_id, Mar.active_res_occupancy_count, Mar.active_res_unit_count, Mar.res_type
      from Dhcd.Rcasd_&year. as Rcasd 
      left join
      Mar.Address_points_2018_06 as Mar
      on Rcasd.Address_id = Mar.address_id
    ) as Rcasd
    left join 
    RealProp.Parcel_base as Parcel
    on Rcasd.ssl = Parcel.ssl
    where Rcasd.res_type in ( 'M', 'R' ) and Rcasd.active_res_occupancy_count >= 5
    order by Rcasd.Notice_type, Rcasd.Address_id, Rcasd.address, Rcasd.Notice_date, Rcasd.Source_file;
  quit;

  ** Filter out last notice of a given type by address (removes duplicate notices across RCASD reports) **;

  proc sort data=Notices;
    by Notice_type Address_id Notice_date Source_file Address;
  run;

  data Notices_res_nodup;

    set Notices;
    by Notice_type Address_id Notice_date;

    if last.Address_id;

    retain Total 1;

    label Total = 'Notice count';

  run;

  /** Uncomment for checking selection process **

  ods listing close;
  ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2018\Topa_notice_counts_&year._temp.xls" style=Normal options(sheet_interval='Bygroup' );

  proc print data=notices;
    by notice_type;
    id Address_id;
    var Notice_date Source_file Nidc_rcasd_id address orig_address active_res_occupancy_count active_res_unit_count ui_proptype;
  run;

  ods tagsets.excelxp close;
  ods listing;

  ***********************************/

  ** Remove multiple addresses for same notice (reduce to single record per notice) **;

  proc sort data=Notices_res_nodup out=Notices_res_nodup_b nodupkey;
    by notice_type Nidc_rcasd_id;
  run; 


  ** Table with notice counts by ward **;

  %fdate()

  options nodate nonumber;
  options missing='-';
  options orientation=landscape;

  ods listing close;
  ods rtf file="&_dcdata_default_path\Requests\Prog\2018\Topa_notice_counts_&year..rtf" style=Styles.Rtf_arial_9pt bodytitle;

  title1 "TOPA notice filings, District of Columbia, &year.";
  title2 "Notices filed at properties with 5+ residential units";

  footnote1 height=9pt "Prepared by Urban-Greater DC (greaterdc.urban.org), &fdate..";

  proc tabulate data=Notices_res_nodup_b  format=comma12.0 noseps missing;
    class Notice_type Ward2012;
    var Total;
    table 
      /** Rows **/
      all='Total' Notice_type=' ',
      /** Columns **/
      Total * sum=' ' * ( all='Total' Ward2012=' ' )
    ;
    format Notice_date mmyyd7.;
  run;

  title1;
  footnote1;

  ods rtf close;
  ods listing;

  ** Output final list of deduplicated notices **;

  ods listing close;
  ods tagsets.excelxp file="&_dcdata_default_path\Requests\Prog\2018\Topa_notice_counts_&year._list.xls" style=Normal options(sheet_interval='Bygroup' );

  title1 "TOPA notice filings, District of Columbia, &year.";
  footnote1 "Prepared by Urban-Greater DC (greaterdc.urban.org), &fdate..";

  proc print data=Notices_res_nodup_b label n;
    by notice_type;
    id orig_address;
    var
      Notice_date Num_units Sale_price Notes
      Source_file Nidc_rcasd_id Anc2012 Geo2010 Psa2012 SSL
      Ward2012 cluster2017 Y X ACTIVE_RES_OCCUPANCY_COUNT Res_type
      ui_proptype;
    label
      Nidc_rcasd_id = 'Urban notice ID'
      Y = 'Latitude'
      X = 'Longitude'
      ACTIVE_RES_OCCUPANCY_COUNT = 'MAR housing unit count'
      Res_type = 'MAR property type';
  run;

  ods tagsets.excelxp close;
  ods listing;

  title1;
  footnote1;

%mend Topa_notices;

/** End Macro Definition **/


%Topa_notices( 2015 )
%Topa_notices( 2016 )
%Topa_notices( 2017 )
%Topa_notices( 2018 )
