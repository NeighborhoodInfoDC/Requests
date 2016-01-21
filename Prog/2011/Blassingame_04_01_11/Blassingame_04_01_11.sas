/**************************************************************************
 Program:  Blassingame_04_01_11.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/01/11
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Request from Janice Blassingame (DHCD)
 <janice.blassingame@dc.gov>. List of single-family homes sold in
 2008 and 2009 with sales date, price, address, SSL, and subdivision.
 Sort in ascending order by price. Provide in Excel with separate
 sheets by ward and quarter.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

** Start submitting commands to remote server **;

rsubmit;

data SF_home_sales_08_09;

  merge
    Realprop.Sales_res_clean 
      (where=(2008 <= year(saledate) <= 2009 and ui_proptype='10')
       keep=ssl ward2002 saledate saleprice premiseadd ui_proptype
       in=in1)
    Realprop.Parcel_base
      (keep=ssl nbhdname);
  by ssl;
  
  if in1;
  
  quarter = put( saledate, yyq. );

run;

proc sort data=SF_home_sales_08_09;
  by ward2002 quarter saleprice;
run;

proc download status=no
  data=SF_home_sales_08_09 
  out=Requests.SF_home_sales_08_09;
run;

endrsubmit;

** End submitting commands to remote server **;

%File_info( data=Requests.SF_home_sales_08_09, printobs=10, freqvars=quarter ward2002 nbhdname )


** Summary table **;

%fdate()

options nodate nonumber;

ods rtf file="D:\DCData\Libraries\Requests\Prog\2011\Blassingame_04_01_11.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Requests.SF_home_sales_08_09 format=comma12.0 noseps missing;
  class ward2002 quarter;
  var saleprice;
  table 
    /** Pages **/
    ward2002=' ',
    /** Rows **/
    quarter=' ',
    /** Columns **/
    saleprice='Sale price ($)' * ( 
      min='Minimum' 
      p25='25th percentile'
      median='Median'
      p75='75th percentile'
      max='Maximum' 
    )
  ;
  title2 ' ';
  title3 'Quarterly Sales Prices of Single-Family Homes by Ward, 2008 - 2009';
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;

title2;
footnote1;


** Create workbooks for all eight wards **;

/** Macro Create_workbooks - Start Definition **/

%macro Create_workbooks(  );

  %do ward = 1 %to 8;

    ods tagsets.excelxp file="&_dcdata_path\Requests\Prog\2011\SF_home_sales_08_09_w&ward..xls" 
        style=statistical
        options( sheet_interval='bygroup' suppress_bylines='yes' );

    ods listing close;

    proc print data=Requests.SF_home_sales_08_09 label noobs;
      where ward2002 = "&ward";
      by quarter;
      var saleprice ssl premiseadd nbhdname;
      label
        saleprice = 'Sale price ($)'
        ssl = 'SSL' 
        premiseadd = 'Property address' 
        nbhdname = 'Assessor neighborhood';
      format saleprice comma12.0;
    run;

    ods tagsets.excelxp close;

    ods listing;
    
  %end;

%mend Create_workbooks;

/** End Macro Definition **/


%Create_workbooks()


signoff;
