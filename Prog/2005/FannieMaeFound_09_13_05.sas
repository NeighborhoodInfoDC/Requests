/**************************************************************************
 Program:  FannieMaeFound_09_13_05.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/13/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Median sales prices for city and clusters in 2003 &
 2004.
 
 Request from Olive at Fannie Mae Foundation, 9/13/05.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp )
%DCData_lib( General )

*options obs=1000;

proc tabulate data=Realprop.Sales_res_clean_dc format=comma14.0 noseps missing;
  where ui_proptype in ( '1', '2' ) and saledate_yr in ( 2003, 2004 ) 
        and ward2002 ~= '';
  class ward2002 saledate_yr;
  var saleprice;
  table 
    all='Washington, D.C.' ward2002=' ',
    median=' ' * saleprice='Median Sales Price' * saledate_yr=' '
    n='Number of Sales' * saledate_yr=' ';
  format ward2002 $ward02a.;
  title2 ' ';
  title3 'Median Sales Price and Number of Sales of Single-Family Homes and Condominiums by Ward and Year';
  title4 ' ';
  title5 'Washington, D.C.';
  
run;

signoff;
