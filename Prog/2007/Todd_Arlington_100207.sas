*************************************************************************
 Program:  Todd_100207.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
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

******Download 1970 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;
******Race, Income, Number of 25+, Education levels, HH w/ kids, poverty*************;
******Va FIPS=51, Arlington FIPS=13**********;

rsubmit;
libname ncdbpub 'ncdb_public:';

data ncdb_1970_2000 (keep=geo2000 shr7d shrblk7 shrblk7n shrhsp7n shrwht7n forborn7 trctpop7 avhhin7
                        educ87 educ117  educ127 educ157 educ167 educpp7
                        ffh7d povrat7
                        )  ;/* creates a file on the alpha - temp */ ;
        set ncdbpub.ncdb_1970_2000    ;

*where geo2000 in ("51131022000", "51131028000", "51131023000", "51131027000", "51131026000", "51131032000", "51131033000",
                "51131025000");
51179010201
proc download inlib=work outlib=output;
        select ncdb_1970_2000  ;

run;

endrsubmit;

******Download 1980 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;

rsubmit;
libname ncdbpub 'ncdb_public:';

data Ncdb_1980_2000 (keep=geo2000 shr8d shrami8n shrapi8n shrblk8n shrhb8 shrhsp8n shrhw8 shrnhb8n shrnhj8n
                        shrnhw8n shroth8n shrwht8n trctpop8 avhhin8
                        educ118 educ128 educ158 educ158 educ168 educ88 educpp8
                        ffh8d povrat8
                        r20pi8 r24pix8 r29pi8 r39pi8 r49pi8 r50pi8 );


where geo2000=   in ("51131022000", "51131028000", "51131023000", "51131027000", "51131026000", "51131032000", "51131033000",
                "51131025000") ;
                       /* creates a file on the alpha - temp */          ;
        set Ncdb.Ncdb_1980_2000    ;


proc download inlib=work outlib=output;
        select Ncdb_1980_2000 ;

run;

endrsubmit;

******Download 1990 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;

rsubmit;
libname ncdbpub 'ncdb_public:';

data Ncdb_1990_2000 (keep=geo2000 shr9d shrami9n shrapi9n shrblk9n shrhb9 shrhsp9n shrhw9 shrnha9n shrnhb9n shrnhi9n shrnho9n
                        shrnhw9n shroth9n shrwht9n forborn9 trctpop9 avhhin9
                        educ119 educ129 educ159 educ169 educ89  educa9 educpp9
                        ffh9d povrat9
                        r20pi9 r24pix9 r29pi9 r39pi9 r49pi9 r50pi9)  ;/* creates a file on the alpha - temp */

where geo2000=   in ("51131022000", "51131028000", "51131023000", "51131027000", "51131026000", "51131032000", "51131033000",
                "51131025000") ;
                      
        set Ncdb.Ncdb_1990_2000   ;


proc download inlib=work outlib=output;
        select Ncdb_1990_2000 ;

run;

endrsubmit;

******Download 2000 Census Data for Arlington Tracts 1022, 1028, 1023, 1027, 1026,1032,1033,1025   ******************;

rsubmit;
libname ncdbpub 'ncdb_public:';

data Ncdb_lf_2000 (keep=geo2000 shr0d shrami0n shrapi0n shrasn0n shrblk0n shrhip0n shrhsp0n shrnha0n shrnhb0n
                shrnhh0n shrnhi0n shrnho0n shrnhr0n shrnhw0n shroth0n shrwht0n forborn0 trctpop0 avhhin0
                educ110 educ120 educ150 educ160 educ80  educa0 educpp0
                ffh0d povrat0
                r20pi0 r24pix0 r29pi0 r39pi0 r49pi0 r50pi0)  ;/* creates a file on the alpha - temp */;

where geo2000=   in ("51131022000", "51131028000", "51131023000", "51131027000", "51131026000", "51131032000", "51131033000",
                "51131025000") ;
                      
        set Ncdb.Ncdb_lf_2000    ;


proc download inlib=work outlib=output;
        select Ncdb_lf_2000 ;

run;

endrsubmit;

*************Create variables that Todd requested in each work. data set ******************;

************Merge 1970, 1980, 1990 and 2000 work data sets together by geo2000 *******************************;

proc sort data=;
        by geo2000;
        run;

proc sort data=;
        by geo2000;
        run;

proc sort data=;
        by geo2000;
        run;

proc sort data=;
        by geo2000;
        run;

data  ;
        merge  ;
        by geo2000;
        run;

        proc contents data=;run;
**********Export merged variables to excel table table*******************;
filename fexport "K:\Metro\PTatian\\\.csv" lrecl=2000;

proc export data=
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
