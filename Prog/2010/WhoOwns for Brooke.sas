****GET OWNERS FOR BROOKE **4-1-10***;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

%let data       = sales_master;
%let out        = Foreclosures_history;
%let RegExpFile = Owner type codes & reg expr LH.xls;
%let MaxExp     = 1000;
%let start_dt = '01jan1990'd;
%let end_dt   = '31dec2009'd;

%syslput MaxExp=&MaxExp;
%syslput data=&data;
%syslput out=&out;
%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;

options SORTPGM=SAS MSGLEVEL=I;

** Read in regular expressions **;

filename xlsfile dde "excel|&_dcdata_path\RealProp\Prog\[&RegExpFile]Sheet1!r2c1:r&MaxExp.c2" lrecl=256 notab;

data RegExp (compress=no);

  length OwnerCat $ 3 RegExp $ 1000;
  
  infile xlsfile missover dsd dlm='09'x;

  input OwnerCat RegExp;
  
  OwnerCat = put( 1 * OwnerCat, z3. );
  
  if RegExp = '' then stop;
  
  put OwnerCat= RegExp=;
  
run;

** Upload regular expressions **;

rsubmit ;

proc upload status=no
  data=RegExp 
  out=RegExp (compress=no);

run;

data sf_condo_dc (compress=no)
	 other (compress=no);
	 
  set realprop.sales_master;
  by ssl;

  retain Total 1;
  length OwnerDC 3;

  if address3 ~= '' then do;
  	if indexw( address3, 'DC' ) then OwnerDC=1;
  	else OwnerDC= 0;
  end;
  else OwnerDC = 9;


  if ui_proptype in ('10' '11') and owner_occ_sale=1 then output sf_condo_dc;
  else output other;

  Label Total = 'Total'
  	  OwnerDC = 'DC-based owner';
  	  
run;

data sf_condo_dc_10 (compress=no)
	 sf_condo_dc_un (compress=no);
 set sf_condo_dc;

by ssl;

length OwnerCat $3.;

if ownerDC and owner_occ_sale then Ownercat= '010'; 
label ownerCat='Owner type';

if ownerCat= '010' then output sf_condo_dc_10;
 else output sf_condo_dc_un;


run;

**Match regular expressions against owner data file **;

data other_coded (compress=no);
	set sf_condo_dc_un other;
	by ssl sale_num;
   length OwnerCat1-OwnerCat&MaxExp $ 3;
   retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;

  array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
  array a_re{*}     re1-re&MaxExp;
  
  ** Load & parse regular expressions **;

  if _n_ = 1 then do;

    i = 1;

    do until ( eof );
      set RegExp end=eof;
      a_OwnerCat{i} = OwnerCat;
      a_re{i} = prxparse( regexp );
      if missing( a_re{i} ) then do;
        putlog "Error" regexp=;
        stop;
      end;
      i = i + 1;
    end;

    num_rexp = i - 1;

  end;

  i = 1;
  match = 0;

  do while ( i <= num_rexp and not match );
    if prxmatch( a_re{i}, ownername_full ) then do;
      OwnerCat = a_OwnerCat{i};
      ownername_full = propcase( ownername_full );
      match = 1;
    end;
    i = i + 1;
  end;

  ** Cooperatives are owner-occupied (OwnerCat=20), unless special owner **;
  
  if ui_proptype = '12' and OwnerCat not in ( '040', '050', '060', '070', '080', '090', '100', '120', '130' )
  then do;
    OwnerCat = '020';
  end;
      
  else if OwnerCat = '' then do;
    OwnerCat = '030';
    *OwnerOcc = 0;
  end;

   drop i match num_rexp regexp OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;

run;

** Recombine **;

data Who_owns (compress=no);

  set sf_condo_dc_10 other_coded;
by ssl;
   
  ** Assume OwnerDC=1 for government & quasi-gov. owners **;
  
  if OwnerCat in ( '040', '050', '060', '070' ) then OwnerDC = 1;
  
  ** All owner-occupied condos in OwnerCat = 20 **;
  
  if ui_proptype = '11' and owner_occ_sale then OwnerCat = '020';
  
  ** Separate corporate (110) into for profit & nonprofit by tax status **;
  
  if OwnerCat = '110' then do;
    if mix1txtype = 'TX' then OwnerCat = '115';
    else OwnerCat = '111';
  end;
  
  ** Duplicate OwnerCat variable for tables **;
  
  length OwnerCat_2 $ 3;
  
  OwnerCat_2 = OwnerCat;
  
  label OwnerCat_2 = 'Owner type (duplicate var)';
  

  ** Residential & non-residential land area for tables **;

  if ui_proptype in ( '10', '11', '12', '13' ) then landarea_res = landarea;
  else landarea_non = landarea;

        
run;

** Download final file **;


proc download status=no
  data=Who_owns 
  out=realprop.Who_owns (label="Who owns the neighborhood analysis file, source &data");

run;
endrsubmit;


proc sort data=realprop.parcel_base out=parcel_base;
by ssl;
proc sort data=realprop.who_owns out =who_owns;
by ssl;
data who_owns_last;
set who_owns;
by ssl;
if last.ssl;

run;
data realprop.parcel_base_owns;
merge parcel_base (in=a) who_owns_last (in=b keep=ssl OwnerCat ownername_full rename=(ownername_full=sales_ownername));
by ssl;
if a;

format ownercat $OWNCAT.;
run;

PROC EXPORT DATA= realprop.parcel_base_owns 
            OUTFILE= "D:\DCDATA\Libraries\RealProp\Data\parcel_base_owns.csv" 
            DBMS=CSV REPLACE;
RUN;
