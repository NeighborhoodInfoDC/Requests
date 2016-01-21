libname health 'D:\DCDATA\Libraries\vital\data';
proc contents data=health.death_2000_geo00; run; 

%macro D_NBC();

%let year= 2000 2001 2002 ; 
%do j = 1 %to 3;

%let Lyear = %scan(&year.,&j., ' ');
%let syear= %substr(&Lyear.,3,2);

proc sort data=health.death_&Lyear._geo00;
by geo2000; 
run; 

proc sort data=health.birth_&Lyear._geo00;
by geo2000; 
run; 

data NBC_death&syear; 

merge health.death_&Lyear._geo00 health.birth_&Lyear._geo00 (keep= geo2000 NBTH&syear.); 
by geo2000;

/*get neighborhoods that NBC wants to highlight*/
NBCtract=substr(geo2000, 8,4);
if NBCtract in ('9700', '9801', '9802','9806') then Nhood_washhighland=1; 
if NBCtract in ('7804', '7808','9903') then Nhood_deanwood=1;
run; 

proc sort data=NBC_death&syear; 
by Nhood_washhighland Nhood_deanwood; 
run; 

proc summary data=NBC_death&syear missing; 
class Nhood_washhighland Nhood_deanwood;
var  d_lt1&syear. NBTH&syear. violteen&syear. d_15to19&syear.; 
output out=sum_NBC_death&syear sum=; 
run;


data calc_nbc_death&syear. (where=(_Type_ in (0,1,2))); 
length nhood $25.;
set sum_NBC_death&syear; 
infmortrate&syear.=(d_lt1&syear./NBTH&syear.)*1000;
pctVteendeaths&syear.=(violteen&syear./d_15to19&syear.)*100;

if _type_=1 and Nhood_deanwood=. then delete; 
if _type_=2 and Nhood_washhighland=. then delete;

if _type_=0 then nhood='1DC';
if _type_=1 then nhood='2Deanwood';
if _type_=2 then nhood='3Washingtonhighlands';
run; 

proc sort data=calc_nbc_death&syear.; 
by nhood;
run; 

%end;
%mend; 

%D_NBC;

data fin_NBC_deaths; 
merge calc_nbc_death00 calc_nbc_death01 calc_nbc_death02; 
by nhood; 

infmort_00_02= (sum(of d_lt100, d_lt101, d_lt102))/3;
totalbirths_00_02=(sum(of NBTH00, NBTH01, NBTH02))/3;

IMR_TYA=(infmort_00_02/totalbirths_00_02)*1000;
run; 


filename nbcds dde "Excel|K:\Metro\PTatian\DCData\Libraries\Requests\Doc\[NBC_Deaths.xls]Sheet1!R9C4:R12C8";
data _null_; 
file nbcds lrecl=65000; 
set fin_NBC_deaths; 
put nhood IMR_TYA infmortrate00 infmortrate01 infmortrate02 pctVteendeaths00 pctVteendeaths01 pctVteendeaths02; 
if _n_ =1 then put; 
run; 
