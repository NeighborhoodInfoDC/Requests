/**************************************************************************
 Program:  Small_landlord_TOPA.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  10/14/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue: 94
 
 Description:  Summarize number of 2-4 and 5+ TOPA notices of sale by year.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( DHCD )

proc format;
  value $notice_type
    '209','224', '225', '227' = "2-4 rental unit offer of sale"
    '210', '228', '229', '230' = "5+ rental unit offer of sale"
    other = " ";
run;

data Notices;

  set 
    DHCD.Rcasd_2015
    DHCD.Rcasd_2016
    DHCD.Rcasd_2017
    DHCD.Rcasd_2018
    DHCD.Rcasd_2019
    DHCD.Rcasd_2020
    DHCD.Rcasd_2021;
  
  where put( notice_type, $notice_type. ) ~= "";
  
  keep nidc_rcasd_id addr_num notice_type notice_date num_units;

run;

ods rtf file="&_dcdata_default_path\Requests\Prog\2025\Small_landlord_TOPA.rtf" style=Styles.Rtf_arial_9pt bodytitle;

title2 ' ';
title3 'TOPA Offer of Sale Notices by Type and Year';

proc tabulate data=Notices format=comma12.0 noseps missing;
  class Notice_type Notice_date;
  var Num_units;
  table 
    /** Rows **/
    all='Total' notice_type=' ',
    /** Columns **/
    n='Number of notices by year' * notice_date=' '
  ;
  table 
    /** Rows **/
    all='Total' notice_type=' ',
    /** Columns **/
    colpctn='Percentage of notices by year' * notice_date=' ' * f=comma12.1
  ;
  format notice_type $notice_type. notice_date year4.;
run;

ods rtf close;

