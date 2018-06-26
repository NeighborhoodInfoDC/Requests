/**************************************************************************
 Program:  Commuting time to work.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/26/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( NCDB )

libname bls "L:\Libraries\Requests\Data\washington region feature\BLS";

data allyears;
   set bls.County_1990 bls.County_1991 bls.County_1992 bls.County_1993 bls.County_1994 bls.County_1995 bls.County_1996 bls.County_1997
       bls.County_1998 bls.County_1999 bls.County_2000 bls.County_2001 bls.County_2002 bls.County_2003 bls.County_2004 bls.County_2005 
	   bls.County_2006 bls.County_2007 bls.County_2008 bls.County_2009 bls.County_2010 bls.County_2011 bls.County_2012 bls.County_2013
	   bls.County_2014 bls.County_2015 bls.County_2016 bls.County_2017;

   keep Area_Code Year Area_Type St_Name Area Industry Ownership Annual_Average_Employment;
run;
