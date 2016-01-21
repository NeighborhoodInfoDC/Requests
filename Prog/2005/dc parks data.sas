/**************************************************************************
 Program:  dc parks data.sas
 Library:  requests
 Project:  NeighborhoodInfo DC
 Author:   Megan Gallagher
 Created:  6/20/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 Description:  Selects variables from Census 2000 Long Form for cluster-
				level analyses for DC Parks Master Plan Data Request
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2; /* location of signon */

/* Note: K:\Metro\PTatian\DCData\Procedures\addingdata.html */
** Define libraries **;
%DCData_lib( ncdb )
%DCData_lib( requests )

rsubmit;
data dcparksdata;/* creates a file on the alpha - temp */
set ncdb.ncdb_lf_2000_dc (keep= geo2000 
 /* race-ethnicity */ MINWHT0N MINBLK0N MINAMI0N MINAPI0N MINOTH0N mrapop0n shrhsp0n
 /* age */ fem40 men40 fem90  men90 fem140 men140 fem190 men190 fem240 men240 fem290 fem340 fem440 men290 men340 men440 fem540 fem640 men540 men640 fem740 fem750 men740 men750
 /* median age */ 
 /* income groups */ thy0100 thy0150 thy0200 thy0250 thy0300 thy0350 thy0400 thy0450 thy0500 thy0600 thy0750 thy01000 thy01250 thy01500 thy02000 thy0m200
 /* Median Household Income */ MDHHY0 
 /* Average Household Income (need two variables) */ AVHHIN0N WELFAR0D
 /* Average Household Size (need two variables) */ prsocu0 occhu0  
 /* Total households WELFAR0D (listed above) */ );

proc download inlib=work outlib=requests; /* download to PC */
select dcparksdata; /* could be multiple files */

run;
endrsubmit; 

signoff;

/******************************************
Variables I need 
Person-level: 
	Race
		White, non-Hispanic -- shrnhw0n
		Black, non-Hispanic -- shrnhb0n
		Asian, non-Hispanic -- shrnha0n
		Hispanic 			-- shrhsp0n
		Other, non-Hispanic -- shrnho0n + nshrnhi0n + shrnhh0n
	Age
		0-4		-- fem40  + men40
		5-9		-- fem90  + men90
		10-14	-- fem140 + men140
		15-19	-- fem190 + men190
		20-24	-- fem240 + men240
		25-44	-- fem290 + fem340 + fem440 + men290 + men340 + men440
		45-64	-- fem540 + fem640 + men540 + men640
		65+		-- fem740 + fem750 + men740 + men750
		Median age
Household-level:
	Household Income
		Number of Households
			<$20K 	-- thy0100 + thy0150 + thy0200 
			$20-30K	-- thy0250 + thy0300
			$30-40K -- thy0350 + thy0400
			$40-50K -- thy0450 + thy0500
			$50-75K -- thy0600 + thy0750
			$75K+	-- thy01000 + thy01250 + thy01500 + thy02000 + thy0m200
		Median Household Income -- MDHHY0 
		Average Household Income (need two variables)
			Aggregate household income -- AVHHIN0N
			Number of households -- WELFAR0D instead of numhhs0 
	Average Household Size (need two variables)
		Total number of persons in occupied housing units -- prsocu0
		Total occupied housing units -- occhu0  
	Total households -- WELFAR0D instead of numhhs0
***********************************************/	


