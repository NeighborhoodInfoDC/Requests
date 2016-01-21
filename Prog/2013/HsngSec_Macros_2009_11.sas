
/**************************************************************************
 Program:  HsngSec_macros_2009_11.sas
 Library:  HsngSec
 Project:  NeighborhoodInfo DC
 Author:   G. MacDonald
 Created:  04/24/2013
 Version:  SAS 9.2
 Environment:  Windows
 
 Description:  Create tables from 2009-11 3-year ACS IPUMS data for 
 Housing Security 2013 report out to funders.

 Modifications: 07/25/13 LH Separated Macros to output tables from program.
**************************************************************************/


***** Macros *****;

** Count table macro **;

** Count table for person**;

%macro Count_table( where=, row_var=, row_fmt=, title=, weight=perwt, universe=Persons, out=);

  %fdate()

  proc tabulate data=Acs_tables_senior format=comma10.0 noseps missing out=&out.;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma /order=data preloadfmt;
    var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "&universe" * sum=' ' * ( upuma=' ' )
      / condense
    ;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "% &universe" * colpctsum=' ' * f=comma10.1 * ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Count_table;

** Count table for households**;

%macro Count_table2( where=, row_var=, row_fmt=, title=, weight=perwt, universe=Persons, out= );

  %fdate()

  proc tabulate data=Acs_tables_senior format=comma10.0 noseps missing  out=&out.;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma sex /order=data preloadfmt;
    var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "&universe" * sum=' ' * ( upuma=' ' )
      / condense
    ;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "% &universe" * colpctsum=' ' * f=comma10.1 * ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. sex sex. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Count_table2;

%macro Count_table3( where=, row_var=, row_fmt=, title=, weight=perwt, universe=Persons, out= );

  %fdate()

  proc tabulate data=Acs_tables_senior format=comma10.0 noseps missing out=&out.;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma sex /order=data preloadfmt;
    var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "&universe" * sum=' ' * ( upuma=' ' )
      / condense
    ;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "% &universe" * colpctsum=' ' * f=comma10.1 * ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. sex sex. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Count_table3;

%macro Count_table4( where=, row_var=, row_fmt=, title=, weight=hhwt, universe=Persons, out=);

  %fdate()

  proc tabulate data=Acs_tables_senior format=comma10.0 noseps missing out=&out.;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma hud_inc /order=data preloadfmt;
    var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total' hud_inc=' '
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "&universe" * sum=' ' * ( upuma=' ' )
      / condense
    ;
    table 
      /** Pages (do not change) **/
      all='Total' hud_inc=' '
  	,
      /** Rows **/
      all='Total' &row_var
      ,
      /** Columns (do not change) **/
      total = "% &universe" * colpctsum=' ' * f=comma10.1 * ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. hud_inc hudinc. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Count_table4;

%macro Count_table_med( where=, row_var=, row_fmt=, title=, weight=perwt, universe=Persons, out= );

  %fdate()

  proc tabulate data=Acs_tables_senior format=comma10.0 noseps missing out=&out.;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma /order=data preloadfmt;
    var rentgrs;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Median Gross Rent' &row_var
      ,
      /** Columns (do not change) **/
      median="&universe" * rentgrs = " " * ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Count_table_med;

%macro Count_table_med2( where=, row_var=, row_fmt=, title=, weight=perwt, universe=Persons, out= );

  %fdate()

  proc tabulate data=Acs_tables_senior format=comma10.0 noseps missing out=&out.;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma /order=data preloadfmt;
    var valueh;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Median Home Value' &row_var
      ,
      /** Columns (do not change) **/
      median="&universe" * valueh = " " * ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Count_table_med2;

%macro Count_table_tworows( where=, row_var=, row_var2=, row_fmt=, row_fmt2=, title=, weight=perwt, universe=Persons, out= );

  %fdate()

  proc tabulate data=Acs_tables_senior format=comma10.0 noseps missing out=&out.;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
	class &row_var2;
    class upuma /order=data preloadfmt;
    var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var. * &row_var2.
      ,
      /** Columns (do not change) **/
      total = "&universe" * sum=' ' * ( upuma=' ' )
      / condense
    ;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
      all='Total' &row_var. * &row_var2.
      ,
      /** Columns (do not change) **/
      total = "% &universe" * colpctsum=' ' * f=comma10.1 * ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. &row_var &row_fmt &row_var2 &row_fmt2;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Count_table_tworows;


** Rate table macro **;

**Rate table for persons**;

%macro Rate_table( where=, rate_var=, row_var=, row_fmt=, title=, desc=, weight=perwt, universe=Persons );

  %fdate()

  proc tabulate data=Acs_tables_senior format=percent10.1 noseps missing;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma sex /order=data preloadfmt;
    var &rate_var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total' sex=' '
  	,
      /** Rows **/
	  all='Total' *total='' *sum='' *f=comma10.0
      (all="% &desc" &row_var) *&rate_var='' *mean=''
    ,
      /** Columns (do not change) **/
      ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. sex sex. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Rate_table;

**Rate table for households**;

%macro Rate_table2( where=, rate_var=, row_var=, row_fmt=, title=, desc=, weight=perwt, universe=Persons );

  %fdate()

  proc tabulate data=Acs_tables_senior format=percent10.1 noseps missing;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma /order=data preloadfmt;
    var &rate_var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total'
  	,
      /** Rows **/
	  all='Total' *total='' *sum='' *f=comma10.0
      (all="% &desc" &row_var) *&rate_var='' *mean=''
    ,
      /** Columns (do not change) **/
     ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Rate_table2;

**Rate table for UPUMA**;

%macro Rate_table3( where=, rate_var=, row_var=, row_fmt=, title=, desc=, weight=perwt, universe=Persons );

  %fdate()

  proc tabulate data=Acs_tables_senior format=percent10.1 noseps missing;
    %if "&where. "~= "" %then %do;
      where &where;
    %end;
    class &row_var;
    class upuma sex /order=data preloadfmt;
    var &rate_var total;
    weight &weight;
    table 
      /** Pages (do not change) **/
      all='Total' sex=' '
  	,
      /** Rows **/
	  all='Total' *total='' *sum='' *f=comma10.0
      (all="% &desc" &row_var) *&rate_var='' *mean=''
    ,
      /** Columns (do not change) **/
      ( upuma=' ' )
      / condense
    ;
    format upuma $pumctyb. sex sex. &row_var &row_fmt;
    title2 &title;
    title3 "Universe: &universe";
    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

  run;

  title2;
  footnote1;

%mend Rate_table3;

%macro Income_table( where=, row_var=, row_fmt=, title=, weight=hhwt, universe=Households );

 

  %fdate()

 

  proc tabulate data=Acs_tables_senior_inc format=comma10.1 noseps missing;

    %if &where~= %then %do;

      where &where;

    %end;

    class &row_var;

    class upuma /order=data preloadfmt;

    var total inc: ;

    weight &weight;

    table 

      /** Rows **/

      total='Households' * sum=' '

      mean="Average Income ($)" * ( all='Total' &row_var ) * ( inctot incwage incbus00 incss incwelfr incinvst incretir incsupp incother ),

      /** Columns (do not change) **/

      ( upuma=' ' )

      / condense 

    ;

    table 

      /** Rows **/

      total='Households' * sum=' '

      pctsum<inctot>="Pct. Income" * ( all='Total' &row_var ) * ( inctot incwage incbus00 incss incwelfr incinvst incretir incsupp incother ),

      /** Columns (do not change) **/

      ( upuma=' ' )

      / condense 

    ;

    format upuma $pumctyb. sex sex. &row_var &row_fmt;

    title2 &title;

    title3 "Universe: &universe";

    footnote1 "Source: ACS IPUMS data, 2009-11 (&fdate)";

 

  run;

 

  title2;

  footnote1;

 

%mend Income_table;
