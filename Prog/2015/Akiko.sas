/**************************************************************************
 Program:  Akiko.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/26/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Recent condo sales prices in cluster 14.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( RealProp, local=n )

/*
proc contents data=RealProp.Camacondopt;
run;
*/

data Akiko;

  merge
    RealProp.Sales_res_clean
      (where=(cluster_tr2000 = '14' and ui_proptype = '11' and saledate >= '01jan2013'd)
       in=in1)
    RealProp.camacondopt_2013_08 
      (keep=ssl ayb bathrm bedrm landarea
       in=in2)
    /*
    RealProp.camacommpt_2013_08
      (keep=ssl ayb bathrm bedrm landarea
       in=in3)
    */
    RealProp.camarespt_2014_03
      (keep=ssl ayb bathrm bedrm landarea
       in=in4);
  by ssl;
  
  if in1;
  
  if in2 /*or in3*/ or in4 then In_cama = 1;
  else in_cama = 0;
  
  year = year( saledate );
  
  %dollar_convert( saleprice, rsaleprice, year, 2014 );
  
  rPriceSqFt = rsaleprice / landarea;
  
run;

proc univariate data=Akiko plot nextrobs=5;
  where bathrm = '1' and bedrm = '1' and 1940 <= ayb < 1970;
  var rsaleprice rpricesqft landarea;
run;

proc print data=Akiko;
  where cluster_tr2000 = '14' and ui_proptype = '11' and saledate >= '01jan2013'd;
  id ssl;
  by ssl;
  var saledate rsaleprice in_cama ayb bathrm bedrm landarea rPriceSqFt;
  format rsaleprice comma12.0 rPriceSqFt comma8.0;
run;

**** Parcel_base lookup ****;

data _null_;
  set RealProp.Parcel_base (where=(compbl(ssl) in ( "1301 0954" )));
  file print;
  put / '--------------------';
  put (_all_) (= /);
run;

