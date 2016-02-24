/**************************************************************************
 Program:  Crispell_2016_02_23.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/23/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Request from Mitchell Crispell
 <mitchellcrispell@gmail.com> for copy of database of rent control
 properties for graduate school research on affordable housing.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( DHCD )
%DCData_lib( RealProp )

data Crispell_2016_02_23;

  merge 
    Dhcd.Parcels_rent_control (where=(Rent_controlled) in=in1)
    RealProp.Parcel_geo (keep=ssl x_coord y_coord);
  by ssl;
  
  if in1;
  
  label
    Rent_controlled = 'Indicates property likely subject to rent stablization'
    Unit_count_pred_flag = 'Indicates whether unit count is estimated'
    Units_full = 'Housing unit count (includes estimates)'
    Units_mar = 'Housing unit count from DC MAR database'
    owneraddress = 'Owner property tax mailing address'
    owneraddress_std = 'Owner property tax mailing address (standardized by %DC_Geocode)';
    
  format Unit_count_pred_flag dyesno.;
  
  keep
    SSL PREMISEADD ADDRESS3 MIX1TXTYPE MIX2TXTYPE owneraddress
    premiseadd_std owneraddress_std Owner_occ_sale
    Ownername_full Ownercat USECODE 
    ui_proptype AYB_Min
    Ward2002 Anc2002 Zip Cluster2000 Geo2000
    Cluster_tr2000 Anc2012 Ward2012 Geo2010 Units_mar Units_full
    Unit_count_pred_flag 
    Rent_controlled
    x_coord y_coord; 

run;

options nodate nonumber;
ods trace on;


ods rtf file="&_dcdata_r_path\Requests\Prog\2016\Crispell_2016_02_23_cb.rtf" style=Styles.Rtf_arial_9pt;
ods exclude EngineHost;

footnote1 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

%File_info( data=Crispell_2016_02_23, printobs=0, stats= )

run;

ods rtf close;

filename fexport "&_dcdata_r_path\Requests\Prog\2016\Crispell_2016_02_23.csv" lrecl=5000;

proc export data=Crispell_2016_02_23
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

run;
