     /**************************************************************************
 Program:  DCData\Libraries\Requests\Prog\voter_ward7&8.sas
 Library:  DCData\Libraries\Requests
 Project:  NeighborhoodInfo DC
 Author:   Shelby Kain
 Created:  December 9, 2008
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect

 Description: Number of voters in wards 7 & 8 who voted in the 1996, 2000, or 2004 elections.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( voter )
%DCData_lib( requests );


rsubmit;
data regvoters_wards78;/* creates a file on the alpha - temp */
set voter.voter_2008_07 (keep=e_11_1996_g e_11_2000_g e_11_2004_g ward);
where ward in ('7','8');

proc download inlib=work outlib=requests; /* download to PC */
select regvoters_wards78;

run;
endrsubmit;

filename fexport "D:\DCData\Libraries\Requests\Doc\voter_wards78.csv" lrecl=2000;

proc export data=requests.regvoters_wards78
    outfile=fexport
    dbms=csv replace;

run;

proc freq data=requests.regvoters_wards78;
tables e_11_1996_g*ward / nopercent norow;
tables e_11_2000_g*ward / nopercent norow;
tables e_11_2004_g* ward / nopercent norow;
run;


signoff;
