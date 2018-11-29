/**************************************************************************
 Program:  DCPN_MF_Sales.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  11/29/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Data on multifamily housing sales for DC Preservation
Network 2018 strategy report. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )

data DCPN_MF_sales;

  set Realprop.Sales_master 
        (keep=ssl sale: ui_proptype ward2012 cluster2017 address: premiseadd usecode
         where=(ui_proptype='13'));

  retain total 1;

run;

proc tabulate data=DCPN_MF_sales format=comma8. noseps missing;
  where '01jan2018'd > saledate >= '01jan2000'd; 
  class saledate usecode ward2012 cluster2017;
  var total;
  table 
    /** Rows **/
    all='Total' usecode=' ',
    /** Columns **/
    total='Number of sales' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' ward2012=' ',
    /** Columns **/
    total='Number of sales' * sum=' ' * saledate=' '
  ;
  table 
    /** Rows **/
    all='Total' cluster2017=' ',
    /** Columns **/
    total='Number of sales' * sum=' ' * saledate=' '
  ;
  format saledate year4.;
run;

