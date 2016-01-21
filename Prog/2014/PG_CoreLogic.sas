/**************************************************************************
 Program:  PG_CoreLogic.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/14/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Get CoreLogic data for Prince George's, region
comparisons.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( CoreLog )

%let indicators = active_loan_count loan_count troubled_pct equity_pct reo_pct foreclosures_pct delinq_pct reo_sale_count short_sale_count compl_fcls;

data PG_CoreLogic;

  set
    CoreLog.Mkttrends_cbsa (where=(cbsa_name='Washington-Arlington-Alexandria DC-VA-MD-WV Metropolitan Division'))
    CoreLog.Mkttrends_county (where=(county_name='Prince Georges'));

  length Name $ 20;

  if cbsa_name = "" then Name = "PG";
  else Name = "Metro";
  
  *length Year $ 4;
  
  *Year = left( put( yyyymm, 6. ) );
  Year = int( yyyymm / 100 );
  
  Date = mdy( yyyymm - ( 100 * int( yyyymm / 100 ) ), 1, int( yyyymm / 100 ) );
  
  format Date yymmd7.;
  
  reo_pct = reo / loan_count;
  foreclosures_pct = foreclosures / loan_count;
  delinq_pct = delinq_90pl_only / loan_count;
  
  troubled_pct = reo_pct + foreclosures_pct + delinq_pct;

  keep Name Year yyyymm &indicators;

  *keep Name Year yyyymm active_loan_count pct_nonown_refi reo seriousdelinq short_sale_count total_sale_count foreclosures equity_pct delinq_90pl_only;

run;

*proc print;

proc sort data=PG_CoreLogic;
  by yyyymm;

%Super_transpose(  
  data=PG_CoreLogic,
  out=PG_CoreLogic_tr,
  var=&indicators,
  id=Name,
  by=Year yyyymm,
  mprint=N
)

proc summary data=PG_CoreLogic;
  where 2006 <= year <= 2013 and Name = "PG";
  by year;
  var reo_sale_count short_sale_count compl_fcls;
  output out=PG_CoreLogic_year sum= ;
run;

/** Macro Export - Start Definition **/

%macro Export( vars= );

  ods tagsets.excelxp file="D:\DCData\Libraries\Requests\Raw\PG_CoreLogic.xls" style=Minimal options(sheet_interval='Proc' );
  ods listing close;

  %local i v;

  %let i = 1;
  %let v = %scan( &vars, &i, %str( ) );

  %do %until ( &v = );
  
    ods tagsets.excelxp options( sheet_name="&v" );

    proc print data=PG_CoreLogic_tr label;
      id Year;
      var &v._pg &v._metro;
      label
        &v._pg = "Prince George's" 
        &v._metro = "Washington metro";
    run;

    %let i = %eval( &i + 1 );
    %let v = %scan( &vars, &i, %str( ) );

  %end;
  
  ** Yearly data **;
  
  ods tagsets.excelxp options( sheet_name="Yearly" );

  proc print data=PG_CoreLogic_year label;
    id year;
    var compl_fcls reo_sale_count short_sale_count;
    label reo_sale_count = "REO sales"
    short_sale_count = "Short sales" 
    compl_fcls = "Foreclosure completions";
  run;
  
  ods tagsets.excelxp close;
  ods listing;

%mend Export;

/** End Macro Definition **/

%Export( vars=&indicators )

