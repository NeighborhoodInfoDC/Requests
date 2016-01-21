/**************************************************************************
 Program:  Ways_05_27_08 
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   L. Getsinger
 Created:  5/27/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: This a request from Howard Ways about the number of sales by property
 type classification. 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

** Start submitting commands to remote server **;

rsubmit;

proc download 
  data = realprop.sales_master  
  out  = realprop.sales_master ;
run;
proc download status=no
	inlib=RealProp
	outlib=RealProp memtype=(catalog);
		select formats;
run;


endrsubmit;

data numsales;
	set realprop.sales_master;
	numsales=1;
run;

proc sort data=numsales;
	by UI_PROPTYPE;
	run;
proc summary data=numsales;
	var numsales;
	by UI_PROPTYPE;
	where 17167<=saledate<= 17347 ;
	output out=sumsales sum=numsales;
run;
ODS CSV file = "D:\DCData\Libraries\RealProp\Data\sales Jan_07_June_07.csv" ;
proc print data=sumsales;
run;
ODS CSV close;
run;
