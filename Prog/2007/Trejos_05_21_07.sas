/**************************************************************************
 Program:  Trejos_05_21_07.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/21/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  The number of Latinos who have bought homes by ward,
 especially wards 7 and 8, which are east of the Anacostia River.
 Request from Nancy E Trejos [trejosn@washpost.com].



 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( HMDA )

** Start submitting commands to remote server **;

rsubmit;

proc print data=Hmda.Hmda_sum_city label;
  id city;
  var 
    nummrtgorigwithrace_2000 
    nummrtgorigblack_2000 
    nummrtgorigwhite_2000 
    nummrtgorighisp_2000 
    nummrtgorigasianpi_2000 

    nummrtgorigwithrace_2005 
    nummrtgorigblack_2005 
    nummrtgorigwhite_2005 
    nummrtgorighisp_2005 
    nummrtgorigasianpi_2005 
  ;
  format 
    nummrtgorig: comma12.;
  
run;

proc print data=Hmda.Hmda_sum_wd02 label;
  id ward2002;
  var
    nummrtgorigwithrace_2000 
    nummrtgorigblack_2000 
    nummrtgorigwhite_2000 
    nummrtgorighisp_2000 
    nummrtgorigasianpi_2000 

    nummrtgorigwithrace_2005 
    nummrtgorigblack_2005 
    nummrtgorigwhite_2005 
    nummrtgorighisp_2005 
    nummrtgorigasianpi_2005 
  ;
  format 
    nummrtgorig: comma12.;
  footnote1 'Home Mortgage Disclosure Act data tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org)';

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
