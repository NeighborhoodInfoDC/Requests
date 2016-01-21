/**************************************************************************
 Program:  Ways_05_29_08 
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   L. Getsinger
 Created:  5/29/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  This is a request from Howard Ways to pull the square footage, 
sale price and number of sales for the six classifications of commercial property  

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
	Year=Year(saledate);
run;

proc sort data=numsales;
	by Year UI_PROPTYPE;
	run;
proc summary data=numsales;
	var numsales landarea saleprice;
	by Year UI_PROPTYPE;
	where '01jan2003'd<=saledate<='30jun2007'd and UI_Proptype in ("20", "21", "22", "23", "24", "29") and landarea >0 and saleprice >0 ;
	output out=sumsales (drop= _freq_ _type_) sum=numsales landarea saleprice;
run;
ODS CSV file = "D:\DCData\Libraries\RealProp\Data\realprop_2.csv" ;
proc print data=sumsales label;
	by year;
	id year;
run;
ODS CSV close;
run;
