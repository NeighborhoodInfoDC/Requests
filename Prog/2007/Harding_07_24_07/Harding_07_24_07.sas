/**************************************************************************
 Program:  Harding_07_24_07.sas
 Library:  Requests
 Project:  
 Author:   K. Gentsch; M. Gallagher
 Created:  02/02/07, edited 07/24/07
 Version:  
 Environment:  Windows with SAS/Connect
 
 Description:  Request from Quaneza Harding, Marshall Heights Community Development Organization, 
 to geocode client addresses and determine which are in the Casey target neighborhoods.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib( Requests );
%DCData_lib( RealProp );
%DCData_lib( General );

rsubmit;
/*Upload dataset to Alpha*/
proc upload status=no
	data=Requests.Addresses
	out=Work.Addresses;
run;

/*Run geocoding macro*/
%DC_geocode(
    parcelfile=Realprop.PARCEL_GEOCODE_BASE_NEW ,
    data=Work.Addresses,
    out=Work.Addresses_geo,
    staddr=street1,
	zip=Zip_Code
  )
run;

/*Download dataset to PC*/
proc download status=no
	data=Work.Addresses_geo
	out=Addresses_geo;
run;
endrsubmit;

data requests.addresses_sel;
	set addresses_geo;
*Hand-code unmatched ones;
	if street1='4424 Foot Street, NE #3' then geo2000='11001007803';                          
	if street1='5119 Fitch Street, SE, T-2' then geo2000='11001007707';                       
	if street1='606 9th Street, ME' then geo2000='11001008402';
	if street1='3425 Croffut Place, SE #202' then geo2000='11001007708';                      
	if street1='811 Barnaby Street, SE   #204' then geo2000='11001009700';                    
	if street1='328 Ridge Road, SE #12' then geo2000='11001007703';                           
	if street1='3689 Jay Street, NE #202' then geo2000='11001009602';                         
	if street1='3776 Hayes Street, NE #4' then geo2000='11001009602';                         
	if street1='5509 Nannie Helens Burroughs Avene, NE   #304' then geo2000='11001007807';
	if street1='511 51st,  NE' then geo2000='11001007804';
	if street1='4911 Fitch Place, NE' then geo2000='11001007804';                             
	if street1='523 45th Street, SE #4' then geo2000='11001007803';                           
	if street1='1912 Ridgecrest Ct., SE #102' then geo2000='11001007403';                     
	if street1='4962 Eads Place, NE # 31' then geo2000='11001007804';                         
	if street1='2325 15th NW, #308' then geo2000='11001003700';                               
	if street1='3537 Jay Street, NE #302' then geo2000='11001009602';                         
	if street1='405 50th NE #11' then geo2000='11001007804';                                  
	if street1='59 Underwood Street, NW' then geo2000='11001001702';                          
	if street1='3330 Dubois Place, SE #A-13' then geo2000='11001007708';                      
	if street1='1509 28th Place, SE #1' then geo2000='11001007604';                           
	if street1='1719 Lang Place, NE' then geo2000='11001008903';                              
	if street1='4110 Gualt Place, SE' then geo2000='11001007803';                             
	if street1='4506 Quarles Street, NE #3' then geo2000='11001009601';                       
	if street1='2703 Douglass Place, SE' then geo2000='11001007406';                          
	if street1='3535 Jay Street, NE #202' then geo2000='11001009602';                         
	if street1='313 Ancacostia, Road, SE #302' then geo2000='11001007703';
	if street1='2618 Evart Street, NE' then geo2000='11001009101';
	if street1='3766 Hayes Street, #6' then geo2000='11001009602';                            
	if street1='3811 Jay Street, NE #3' then geo2000='11001009602';                           
	if street1='3820 Hayes Street, NE #3' then geo2000='11001009602';                         
	if street1='2 Anacostia Road, SE #12A' then geo2000='11001007703';                        
	if street1='3698 Hayes Street, NE #201' then geo2000='11001009602';                       
	if street1='4514 Quarles Street, NE' then geo2000='11001009601';                          
	if street1='243 Valley Avenue, SE' then geo2000='11001009801';                            
	if street1='1318 First Streetm SW' then geo2000='11001006400';
	if street1='3425 Croffut Place, SE #202' then geo2000='11001007708';    
	if street1='1314 Stevens Road, SE' then geo2000='11001007401';          
	if street1='401 Chaplin Street, SE #405' then geo2000='11001007703';   
	if street1='3510 B Steet, SE #202' then geo2000='11001007708';          
	if street1='4001 Hayes Street, NE #6' then geo2000='11001007803';       
	*if street1='3970 Suitland Road #104' then geo2000='1100100';*Suitland, MD;                          
	*if street1='3331 Blsinr Street, NE' then geo2000='1100100'; *??;                          
	*if street1='6411 Balfour Drive' then geo2000='1100100';*Hyattsville, MD;                               
	*if street1='6006 Plata Street' then geo2000='1100100';*Clinton, MD;                                
	*if street1='710 Dryden Street' then geo2000='1100100'; *Silver Spring, MD;                               
	*if street1='3261 Ridge Road, SE B-2' then geo2000='1100100';*??;                                                    
	*if street1='5140 Ridge Road, SE #304' then geo2000='1100100';*??;                                                   
	*if street1='1917 M Street, SE #3' then geo2000='1100100';*No such SE address;           
	*if street1='24113Russell Avenue #A-2' then geo2000='1100100';*Mount Ranier, MD;       

*Identify Casey target neighborhoods;
	%Tr00_to_cnb03()
run;



