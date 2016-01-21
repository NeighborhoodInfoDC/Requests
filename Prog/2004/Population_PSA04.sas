************************************************************************
* Program:  Population_PSA04.sas
* Library:  Requests
* Project:  DC Data Warehouse
* Author:   P. Tatian
* Created:  09/09/04
* Version:  SAS 8.12
* Environment:  Windows
* 
* Description:  Request from Jack McKay, 8/16/04.
* Produce population, household, and housing unit counts
* from Census 2000 SF1 for 2004 PSAs.  
* Output to CSV file for reading in Excel.
*
* Modifications:
************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( General )
%DCData_lib( Census )

proc sql;
  create table Requests.Population_PSA04 
    (label='Census 2000 SF1 pop., HHs, and housing units for 2004 PSAs') 
    as 
  select PSA2004, PolDist2004, 
    sum( pop100 ) as Population_2000 label='Total population, 2000',
    sum( P15i1 ) as Households_2000 label='Total households, 2000',
    sum( h1i1 ) as Housing_units_2000 label='Total housing units, 2000'
    from 
    ( select * from 
        General.Block00_PSA04 as Blk 
          left join
        Census.Cen2000_sf1_dc_blks as Cen
        on Blk.GeoBlk2000 = Cen.GeoBlk2000 )
  group by PSA2004, PolDist2004 
  order by PSA2004, PolDist2004
;

proc print data=Requests.Population_PSA04 label;
  sum Population_2000 Households_2000 Housing_units_2000;

run;

** Output to CSV file **;

filename fexport "D:\DCData\Libraries\Requests\Data\Population_PSA04.csv" lrecl=256;

proc export data=Requests.Population_PSA04
    outfile=fexport
    dbms=csv replace;

run;

