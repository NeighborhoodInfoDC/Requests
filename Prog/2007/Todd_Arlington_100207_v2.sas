*************************************************************************
 Program:  Todd_100207.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey/B. Chang
 Created:  10/02/2007
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect

 Description: Pull down NCDB data for Arlington counties

 Modifications:
*************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib( Requests )
libname output 'D:\DCData\Libraries\Requests\Data'; 
rsubmit;


******Download 1970 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;
******Race, Income, Number of 25+, Education levels, HH w/ kids, poverty*************;
******Va FIPS=51, Arlington FIPS=13**********;


*/
I'm not sure what this libname is for?;

libname ncdbpub 'ncdb_public:';

data ncdb_1970_2000_alpha;
set ncdbpub.Ncdb_1970_2000
(keep = geo2000 shr7d shrblk7 shrhsp7  shrwht7 forborn7 trctpop7 avhhin7
        educ87 educ117  educ127 educ157 educ167 educpp7
        ffh7 povrat7 r35pi107 r35pi157 r35pi257 r35pi27 r35pi37 r35pi57
          r35pi77 r35pix7 
where =( geo2000 in ("51013102200", "51013102800", "51013102300","51013102500",
"51013102600", "51013102700",  "51013103200", "51013103300") ) );
			/* creates a file on the alpha - temp */ ;
      
		run;

proc download inlib=work outlib=output;
        select ncdb_1970_2000_alpha;

run;

endrsubmit;

******Download 1980 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;

rsubmit;
libname ncdbpub 'ncdb_public:';

data Ncdb_1980_2000_alpha;
set ncdbpub.Ncdb_1980_2000
(keep = geo2000 shr8d shrami8n shrapi8n  shrnhj8 shrnhw8  shrhsp8 shrnhb8 shrfor8 forborn8
trctpop8 avhhin8 educ118 educ128 educ158 educ158 educ168 educ88 educpp8
ffh8  povrat8 r35pi108 r35pi158 r35pi208 r35pi58 r35pix8 r35pi58 r35pix8
where =( geo2000 in ("51013102200", "51013102800", "51013102300","51013102500",
"51013102600", "51013102700",  "51013103200", "51013103300") ) );
                       /* creates a file on the alpha - temp */          ;
     


proc download inlib=work outlib=output;
        select Ncdb_1980_2000_alpha;

run;

endrsubmit;

******Download 1990 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;

rsubmit;
libname ncdbpub 'ncdb_public:';

data Ncdb_1990_2000_alpha;
set ncdbpub.Ncdb_1990_2000
(keep = geo2000 shrhsp9 shrnha9 shrnhb9 shrnhi9 shrnho9 shrnhw9  shrfor9 forborn9 trctpop9 avhhin9
                        educ119 educ129 educ159 educ169 educ89  educa9 educpp9
                       ffh9 povrat9  r35pi109 r35pi209 shr9d 
                       r35pix9 
where =( geo2000 in ("51013102200", "51013102800", "51013102300","51013102500",
"51013102600", "51013102700",  "51013103200", "51013103300") ) );
 proc download inlib=work outlib=output;
        select Ncdb_1990_2000_alpha;

run;

endrsubmit;

******Download 2000 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;

rsubmit;
libname ncdbpub 'ncdb_public:';

data Ncdb_lf_2000_alpha;
set ncdbpub.Ncdb_lf_2000
(keep = geo2000 
shr0d shrfor0 shrnha0 shrnhb0 shrnhh0 shrnhi0 shrnho0 shrnhr0 shrnhw0 
trctpop0 avhhin0 educ110 educ120 educ150 educ160 educ80  educa0 educpp0 forborn0
 ffh0 povrat0 R20PI0 R29PI0 R39PI0 R49PI0 R50PI0 
where =( geo2000 in ("51013102200", "51013102800", "51013102300","51013102500",
"51013102600", "51013102700",  "51013103200", "51013103300") ) );
                      
 *r35pi100  r35pi200  r35pi350 r35pix0  r35pixa0 ;



proc download inlib=work outlib=output;
        select Ncdb_lf_2000_alpha;

run;

endrsubmit;
signoff;

*************Create variables that Todd requested in each work. data set ******************;
data Ncdb_1970_2000_local;
*not sure about where this data file is stored locally;
set output.ncdb_1970_2000_alpha;
educ87p = educ87/educpp7;
educ117p = educ117/educpp7;
educ127p = educ127/educpp7;
educ157p = educ157/educpp7;
educ167p=educ167/educpp7;
label educ87p = 'Proportion of persons 25+ years old who have competed 0-8 years of school, 1970'
	educ87 ='Persons 25+ years old who have competed 0-8 years of school, 1970'
 	educ117p ='Proportion of Persons 25+ years old who have completed 9-12 years of school but no diploma, 1970'
	educ117 = 'Persons 25+ years old who have completed 9-12 years of school but no diploma, 1970 '
	 educ127p = 'Proportion of Persons 25+ years old who have completed h.s. but no college, 1970'
	 educ127 = 'Persons 25+ years old who have completed h.s. but no college, 1970 '
	 educ157p = 'Proportion of Persons 25+ years old who have completed some college but no degree, 1970'
	 educ157 = 'Persons 25+ years old who have completed some college but no degree, 1970 '
	 educ167p = 'Proportion of Persons 25+ years old who have a bachelors or graduate/professional degree, 1970 '
	 educ167 = 'Persons 25+ years old who have a bachelors or graduate/professional degree, 1970'
	 educpp7 = 'Persons 25+ years old, 1970 '
	 shr7d = 'Total population for race/ethnicity, 1970  '
	shrblk7 = 'Prop. Black/Afr. Am. population, 1970 '
	shrhsp7  = 'Prop. Hisp./Latino population, 1970 '
	shrwht7 = 'Prop. White population, 1970 '
	forborn7 = 'Foreign born population, 1970 '
	trctpop7 = 'Total population, 1970 '
	avhhin7 = 'Average HH inc. last year ($), 1970 '
	 ffh7 = 'Prop. of families and subfamilies with own children who are female-headed, 1970   '
 povrat7 = 'Prop. of total persons in families and unrelated individuals below the poverty level last year, 1970' 
r35pi107 ='Renter HHs whose gross rent is 35%+ of last years income, which was $7,000-9,999, 1970' 
r35pi157 ='Renter HHs whose gross rent is 35%+ of last years income., which was $10,000-14,999, 1970' 
r35pi257 ='Renter HHs whose gross rent is 35%+ of last years income., which was $15,000-24,999, 1970' 
r35pi27 ='Renter HHs whose gross rent is 35%+ of last years income, which was less than $2,000, 1970' 
r35pi37 ='Renter HHs whose gross rent is 35%+ of last years income, which was $2,000-2,999, 1970 ' 
r35pi57 ='Renter HHs whose gross rent is 35%+ of last years income, which was $3,000-4,999, 1970 '
 r35pi77 ='Renter HHs whose gross rent is 35%+ of last years income, which was $5,000-6,999, 1970 '
r35pix7 ='Renter HHs whose gross rent is 35%+ of last years income, which was $25,000+, 1970 ';

run;

data Ncdb_1980_2000_local;
set output.ncdb_1980_2000_alpha;
shrami8np = shrami8n/shr8d;
shrapi8np =shrapi8n/shr8d;
educ118p =educ118/educpp8;
educ128p =educ128/educpp8;
educ158p =educ158/educpp8;
educ168p =educ168/educpp8;
educ88p =educ88/educpp8;
label educ88p = 'Proportion of persons 25+ years old who have competed 0-8 years of school, 1980'
	educ88 ='Persons 25+ years old who have competed 0-8 years of school, 1980'
 	educ118p ='Proportion of Persons 25+ years old who have completed 9-12 years of school but no diploma, 1980'
	educ118 = 'Persons 25+ years old who have completed 9-12 years of school but no diploma, 1980 '
	 educ128p = 'Proportion of Persons 25+ years old who have completed h.s. but no college, 1980'
	 educ128 = 'Persons 25+ years old who have completed h.s. but no college, 1980 '
	 educ158p = 'Proportion of Persons 25+ years old who have completed some college but no degree, 1980'
	 educ158 = 'Persons 25+ years old who have completed some college but no degree, 1980 '
	 educ168p = 'Proportion of Persons 25+ years old who have a bachelors or graduate/professional degree, 1980 '
	 educ168 = 'Persons 25+ years old who have a bachelors or graduate/professional degree, 1980'
	 educpp8 = 'Persons 25+ years old, 1980'
  	 ffh8  = 'Prop. of families and subfamilies with own children who are female-headed, 1980  '
	povrat8 ='Prop. of total persons below the poverty level last year, 1980 '
    r35pi108 ='Renter HHs whose gross rent is 35%+ of last years income which was $5000-9999 1980'
r35pi158 = 'Renter HHs whose gross rent is 35%+ of last years income, which was $10,000-14,999, 1980'
 r35pi208 = 'Renter HHs whose gross rent is 35%+ of last years income, which was $15,000-19,999, 1980' 
r35pi58 = 'Renter HHs whose gross rent is 35%+ of last years income, which was $10,000-14,999, 1980' 
r35pix8 = 'Renter HHs whose gross rent is 35%+ of last years income, which was $15,000-19,999, 1980' 
r35pi58 ='Renter HHs whose gross rent is 35%+ of last years income, which was less than $5,000, 1980 '
r35pix8 ='Renter HHs whose gross rent is 35%+ of last years income, which was $20,000+, 1980'
shrami8np = 'Proportion of Persons that are Am. Indian/AK Native, 1980' 
shrapi8np = 'Proportion of Persons that are Asian, Native HI and other Pac. Isl. , 1980' 
shr8d ='Total population for race/ethnicity, 1980' 
shrami8n ='Total Am. Indian/AK Native population, 1980 '
shrapi8n ='Total Asian, Native HI and other Pac. Isl. population, 1980 '
shrnhj8 = 'Prop. non-Hisp./Latino Am. Indian, Asian, Native HI, other Pac. Isl. and other race population, 1980' 
shrnhw8  ='Prop. non-Hisp./Latino White population, 1980 '
shrhsp8 = 'Prop. Hisp./Latino population, 1980'
shrnhb8 = 'Prop. non-Hisp./Latino Black/Afr. Am. population, 1980' 
shrfor8 = 'Prop. of population who are foreign born, 1980 '
forborn8 = 'Foreign born population, 1980'  
 trctpop8 ='Total population, 1980 '
avhhin8 ='Average HH inc. last year ($), 1980 ';

run;

data Ncdb_1990_2000_local;
set output.Ncdb_1990_2000_alpha;
educ119p = educ119/educpp9;
educ129p = educ129/educpp9;
educ159p =educ159/educpp9;
educ169p =educ169/educpp9;
educ89p =educ89/educpp9;
educa9p =educa9/educpp9;

label 
educ89p = 'Proportion of persons 25+ years old who have competed 0-8 years of school, 1990'
	educ89 ='Persons 25+ years old who have competed 0-8 years of school, 1990'
 	educ119p ='Proportion of Persons 25+ years old who have completed 9-12 years of school but no diploma, 1990'
	educ119 = 'Persons 25+ years old who have completed 9-12 years of school but no diploma, 1990 '
	 educ129p = 'Proportion of Persons 25+ years old who have completed h.s. but no college, 1990'
	 educ129 = 'Persons 25+ years old who have completed h.s. but no college, 1990 '
	 educ159p = 'Proportion of Persons 25+ years old who have completed some college but no degree, 1990'
	 educ159 = 'Persons 25+ years old who have completed some college but no degree, 1990 '
	 educ169p = 'Proportion of Persons 25+ years old who have a bachelors or graduate/professional degree, 1990 '
	 educ169 = 'Persons 25+ years old who have a bachelors or graduate/professional degree, 1990'
	 educpp9 = 'Persons 25+ years old, 1990'
	 educa9 = 'Persons 25+ years old who have an associate degree but no bachelors degree, 1990'  
educa9p = 'Proportion of Persons 25+ years old who have an associate degree but no bachelors degree, 1990'
shrhsp9 ='Prop. Hisp./Latino population, 1990 '
shrnha9 = 'Prop. non-Hisp./Latino Asian or Native HI and other Pac. Isl. population, 1990' 
shrnhb9 ='Total Hisp./Latino Black/Afr. Am. population, 1990 '
shrnhi9 ='Prop. non-Hisp./Latino Am. Indian/AK Native population, 1990 '
shrnho9 ='Prop. non-Hisp./Latino other race population, 1990 '
shrnhw9  ='Prop. non-Hisp./Latino White population, 1990 '
shr9d = 'Total population for race/ethnicity, 1990 '
forborn9 ='Foreign born population, 1990 '
shrfor9 ='Prop. of population who are foreign born, 1990  '
 trctpop9 ='Total population, 1990 '
avhhin9 ='Average HH inc. last year ($), 1990 '
ffh9 ='Prop. of families and subfamilies with own children who are female-headed, 1990  '
povrat9 ='Prop. of total persons below the poverty level last year, 1990 '
r35pi109 ='Renter HHs whose gross rent is 35%+ of last years income, which was less than $10,000, 1990 '
r35pi209 ='Renter HHs whose gross rent is 35%+ of last years income, which was $10,000-19,999, 1990 '
r35pix9 ='Renter HHs whose gross rent is 35%+ of last years inc., which was $20,000+, 1990'; 
run;

data Ncdb_lf_2000_local;
set output.Ncdb_lf_2000_alpha;
educ110p = educ110/educpp0;
educ120p = educ120/educpp0;
educ150p = educ150/educpp0;
educ160p = educ160/educpp0;
educ80p = educ80/educpp0;
educa0p = educa0/educpp0;
rentsum =R20PI0 + R29PI0 + R39PI0 + R49PI0 + R50PI0;
R20PI0p = R20PI0/rentsum;
R29PI0p = R29PI0/rentsum;
R39PI0p = R39PI0/rentsum;
R49PI0p = R49PI0/rentsum;
R50PI0p =R50PI0/rentsum;
r_overthirtyp=(R39PI0 + R49PI0 + R50PI0)/rentsum;
label 
educ110p = 'Proportion of Persons 25+ years old who have completed 9-12 years of school but no diploma, 2000'  
educ110 ='Persons 25+ years old who have completed 9-12 years of school but no diploma, 2000'
educ120p ='Proportion of Persons 25+ years old who have completed h.s. but no college, 2000'
educ120 ='Persons 25+ years old who have completed h.s. but no college, 2000'
educ150p ='Proportion of Persons 25+ years old who have completed some college but no degree, 2000 '
educ150='Persons 25+ years old who have completed some college but no degree, 2000'  
educ160p ='Proportion of Persons 25+ years old who have a bachelors or graduate/professional degree, 2000'
educ160 ='Persons 25+ years old who have a bachelors or graduate/professional degree, 2000' 
educ80p ='Proportion of Persons 25+ years old who have competed 0-8 years of school, 2000'
educ80 = 'Persons 25+ years old who have competed 0-8 years of school, 2000'  
educa0p = 'Proportion of Persons 25+ years old who have an associate degree but no bachelors degree, 2000'  
educa0 ='Persons 25+ years old who have competed 0-8 years of school, 2000'
educpp0 = 'Persons 25+ years old, 2000' 

shr0d = 'Total population for race/ethnicity, 2000  '
shrfor0 ='Prop. of population who are foreign born, 2000'
shrnha0 ='Prop. non-Hisp./Latino Asian or Native HI and other Pac. Isl. population, 2000'
shrnhb0 ='Prop. non-Hisp./Latino Black/Afr. Am. population, 2000 '
shrnhh0 ='Prop. non-Hisp./Latino other race population, 2000 '
shrnhi0 ='Prop. non-Hisp./Latino Am. Indian/AK Native population, 2000 '
shrnho0 ='Prop. non-Hisp./Latino other race population, 2000 '
shrnhr0 ='Prop. non-Hisp./Latino Asian population, 2000 '
shrnhw0  ='Prop. non-Hisp./Latino White population, 2000 '
trctpop0 ='Total population, 2000 '
avhhin0 ='Average HH inc. last year ($), 2000 '
ffh0 ='Prop. of families and subfamilies with own children who are female-headed, 2000  '
forborn0 ='Foreign born population, 2000  '
povrat0 ='Prop. of total persons below the poverty level last year, 2000 '
R20PI0 = 'Renter HHs whose gross rent is less than 20% of their inc. last year, 2000' 
R29PI0 = 'Renter HHs whose gross rent is 20-29.9% of their inc. last year, 2000' 
R39PI0 = 'Renter HHs whose gross rent is 30-39.9% of their inc. last year, 2000' 
R49PI0 = 'Renter HHs whose gross rent is 40-49.9% of their inc. last year, 2000' 
R50PI0 = 'Renter HHs whose gross rent is 50%+ of their inc. last year, 2000' 
R20PI0p = 'Proportion of Renter HHs whose gross rent is less than 20% of their income last year, 2000'
R29PI0p = 'Proportion of Renter HHs whose gross rent is 20-29.9% of their income last year, 2000'
R39PI0p = 'Proportion of Renter HHs whose gross rent is 30-39.9% of their income last year, 2000'
R49PI0p = 'Proportion of Renter HHs whose gross rent is 40-49.9% of their income last year, 2000'
R50PI0p = 'Proportion of Renter HHs whose gross rent is 50%+ of their income last year, 2000'
r_overthirtyp ='Proportion of Renter HHs whose gross rent is over 30% of their income last year, 2000'
; 
*r35pi100  ='Renter HHs whose gross rent is 35%+ of last years income, which was less than $10,000, 2000 '
r35pi200 ='Renter HHs whose gross rent is 35%+ of last years income, which was $10,000-19,999, 2000' 
r35pi350 ='Renter HHs whose gross rent is 35%+ of last years income, which was $20,000-34,999, 2000 '
r35pix0  ='Renter HHs whose gross rent is 35%+ of last years income, which was $20,000+, 2000' 
r35pixa0 ='Renter HHs whose gross rent is 35%+ of last years income, which was $35,000+, 2000';

run;
  




************Merge 1970, 1980, 1990 and 2000 work data sets together by geo2000 *******************************;

proc sort data=Ncdb_1970_2000_local;
        by geo2000;
        run;

proc sort data=Ncdb_1980_2000_local;
        by geo2000;
        run;

proc sort data=Ncdb_1990_2000_local;
        by geo2000;
        run;

proc sort data=Ncdb_lf_2000_local;
        by geo2000;
        run;

data output.todd_arlington_100207;
        merge Ncdb_1970_2000_local Ncdb_1980_2000_local Ncdb_1990_2000_local Ncdb_lf_2000_local;
        by geo2000;
        run;

        proc contents data=output.todd_arlington_100207;
run;
**********Export merged variables to excel table table*******************;
*filename fexport "K:\Metro\PTatian\DCData\Libraries\Requests\Raw\Todd_Arlington_100207.csv" lrecl=2000;
*/
proc export data=output.todd_arlington_100207;
   * outfile=fexport
    dbms=csv replace;

*run;
*filename fexport clear;
*run;
ods csv file="D:\DCData\Libraries\Requests\Doc\todd_arlington_100207.csv" ;
    PROC PRINT data=output.todd_arlington_100207 label noobs;
	title1 'Title of Data';
title2  'NeighborhoodInfo DC,';
title3 'a project of The Urban Institute and Washington DC Local Initiatives Support Corporation (LISC)';
title4 'P: 202-261-5760 / E: info@neighborhoodinfodc.org '; 
var
geo2000 trctpop7 shr7d  shrblk7 shrhsp7  shrwht7 forborn7 avhhin7 povrat7 
 educpp7  educ87 educ117  educ127 educ157 educ167
educ87p educ117p educ127p educ157p educ167p
 ffh7 r35pi107 r35pi157 r35pi257 r35pi27 
r35pi37 r35pi57 r35pi77 r35pix7 

trctpop8 shr8d  shrnhj8 shrnhw8  shrhsp8  shrnhb8 shrfor8 forborn8
avhhin8  povrat8  educpp8
educ88 educ118 educ128  educ158 educ168
educ88p educ118p educ128p educ158p educ168p 
ffh8  r35pi108 r35pi158 r35pi208 r35pi58 
r35pix8 r35pi58 r35pix8

trctpop9 shr9d shrhsp9 shrnha9 shrnhb9 shrnhi9 shrnho9 shrnhw9
shrfor9 forborn9 avhhin9 povrat9 
 educpp9  educ89    educ119 educ129 educ159 educ169  	educa9
educ89p educ119p educ129p educ159p educ169p  educa9p
 ffh9  r35pi109 r35pi209  r35pix9 

trctpop0 shr0d
shrnha0 shrnhb0 shrnhh0 shrnhi0 shrnho0
shrnhr0 shrnhw0  shrfor0 forborn0 avhhin0 povrat0
educpp0    educ80   educ110 educ120 educ150 educ160 
  educa0  educ110p educ120p educ150p educ160p educ80p educa0p
      ffh0  R20PI0 R29PI0 R39PI0 
R49PI0 R50PI0 R20PI0p R29PI0p R39PI0p R49PI0p
R50PI0p  r_overthirtyp; 
run;

ods rtf file="D:\DCData\Libraries\Requests\Doc\todd_arlington_100207.rtf" ;
    PROC PRINT data=output.todd_arlington_100207 label noobs;
	title1 'Title of Data';
title2  'NeighborhoodInfo DC,';
title3 'a project of The Urban Institute and Washington DC Local Initiatives Support Corporation (LISC)';
title4 'P: 202-261-5760 / E: info@neighborhoodinfodc.org '; 
var
geo2000 trctpop7 shr7d  shrblk7 shrhsp7  shrwht7 forborn7 avhhin7 povrat7 
 educpp7  educ87 educ117  educ127 educ157 educ167
educ87p educ117p educ127p educ157p educ167p
 ffh7 r35pi107 r35pi157 r35pi257 r35pi27 
r35pi37 r35pi57 r35pi77 r35pix7 

trctpop8 shr8d  shrnhj8 shrnhw8  shrhsp8  shrnhb8 shrfor8 forborn8
avhhin8  povrat8  educpp8
educ88 educ118 educ128  educ158 educ168
educ88p educ118p educ128p educ158p educ168p 
ffh8  r35pi108 r35pi158 r35pi208 r35pi58 
r35pix8 r35pi58 r35pix8

trctpop9 shr9d shrhsp9 shrnha9 shrnhb9 shrnhi9 shrnho9 shrnhw9
shrfor9 forborn9 avhhin9 povrat9 
 educpp9  educ89    educ119 educ129 educ159 educ169  	educa9
educ89p educ119p educ129p educ159p educ169p  educa9p
 ffh9  r35pi109 r35pi209  r35pix9 

trctpop0 shr0d
shrnha0 shrnhb0 shrnhh0 shrnhi0 shrnho0
shrnhr0 shrnhw0  shrfor0 forborn0 avhhin0 povrat0
educpp0    educ80   educ110 educ120 educ150 educ160 
  educa0  educ110p educ120p educ150p educ160p educ80p educa0p
      ffh0  R20PI0 R29PI0 R39PI0 
R49PI0 R50PI0 R20PI0p R29PI0p R39PI0p R49PI0p
R50PI0p  r_overthirtyp; 
*shrami8np shrapi8np;
run;
