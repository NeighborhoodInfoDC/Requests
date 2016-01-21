
**************************************************************************
Program: condo_sale_price_cluster25.sas
Library: requests
Project: NighborhoodInfo DC Technical Assistance: Prepared for Reshma Holla
Author: Lesley Freiman
Created: 07/07/08
Version: SAS 9.1
Environment: Windows with SAS/Connect
Description: Condo yearly median sale price ($2007) by cluster
Modifications:

**************************************************************************/;


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;


*/ Defines libraries /*;
%DCData_lib( Realprop );
%DCData_lib( Requests );
%DCData_lib( General );


rsubmit;

*/creates a file with condo price data on alpha - temp */;
data condo_sale_year_clstr; 
set Realprop.Sales_sum_cltr00 (keep= cluster_tr2000 r_mprice_condo_1995 r_mprice_condo_1996 
r_mprice_condo_1997 r_mprice_condo_1998 r_mprice_condo_1999 r_mprice_condo_2000
r_mprice_condo_2001 r_mprice_condo_2002 r_mprice_condo_2003 r_mprice_condo_2004
r_mprice_condo_2005 r_mprice_condo_2006 r_mprice_condo_2007);
	run;

proc download inlib=work outlib=requests; 
select condo_sale_year_clstr; 
run;

endrsubmit;
*\isolates cluster 25\*;
data requests.condo_sale_year_clstr25;
set requests.condo_sale_year_clstr (where=(cluster_tr2000 in ("25")));
run;
