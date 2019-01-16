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

proc freq data=Dhcd.Rcasd_2018;
  tables notice_type;
run;

proc sql noprint;
  create table Notices as
  select Rcasd.*, Parcel.ssl, Parcel.ui_proptype 
  from (
    select Rcasd.*, Mar.address_id, Mar.active_res_occupancy_count, Mar.active_res_unit_count, Mar.res_type
    from Dhcd.Rcasd_2018 as Rcasd 
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

proc sort data=Notices;
  by Notice_type Address_id Notice_date Source_file Address;
run;

data Notices_res_nodup;

  set Notices;
  by Notice_type Address_id Notice_date;

  if first.Notice_date;

run;

** START HERE: SELECT MOST RECENT VERSION OF NOTICE FROM ABOVE **;

ods listing close;
ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Prog\2018\Topa_notice_counts.xls" style=Normal options(sheet_interval='Bygroup' );

proc print data=notices;
  by notice_type;
  id Address_id;
  var Notice_date Source_file Nidc_rcasd_id address orig_address active_res_occupancy_count active_res_unit_count ui_proptype;
run;

ods tagsets.excelxp close;
ods listing;



/*
proc sort data=Notices out=Notices_res_nodup nodupkey;
  where res_type in ( 'M', 'R' ) and active_res_occupancy_count >= 5;
  by nidc_rcasd_id;
run;
*/
