/**************************************************************************
 Program:  Kojo_02_27_06_b.sas
 Library:  Requests
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/27/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Prepare data for use on Kojo Namdi show.
 Neighborhood near All Souls Church (tracts 37 & 28.02).
 
  Part B - Write output to Excel tables:  Kojo_02_27_06.xls.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Requests )

%let path     = D:\DCData\Libraries\Requests\Prog;
%let workbook = Kojo_02_27_06.xls;

/** Macro Write_table - Start Definition **/
/** Writes a block of data to the gap table  **/

%macro Write_table( sheet=, row=, vars=, data=Requests.Kojo_02_27_06 );

  %** Count variables in list **;
  
  %let num_vars = 0;
  %let i = 1;
  %let onev = %scan( &vars, &i );
  
  %do %while( &onev ~= );
  
    %let num_vars = %eval( &num_vars + 1 );
    
    %let i = %eval( &i + 1 );
    %let onev = %scan( &vars, &i );
  
  %end;
  
  ** Open DDE destinations **;
  
  filename xlsfile1 dde "excel|&path\[&workbook]&sheet!r&row.c3:r%eval(&row+&num_vars-1)c3" lrecl=256;
  filename xlsfile2 dde "excel|&path\[&workbook]&sheet!r&row.c4:r%eval(&row+&num_vars-1)c4" lrecl=256;
  filename xlsfile3 dde "excel|&path\[&workbook]&sheet!r&row.c5:r%eval(&row+&num_vars-1)c5" lrecl=256;
  filename xlsfile4 dde "excel|&path\[&workbook]&sheet!r&row.c6:r%eval(&row+&num_vars-1)c6" lrecl=256;

  ** Write data to table **;
  
  data _null_;
  
    set &data (keep=&vars);
    
    select ( _n_ );
      when ( 1 ) file xlsfile1;
      when ( 2 ) file xlsfile2;
      when ( 3 ) file xlsfile3;
      when ( 4 ) file xlsfile4;
      otherwise do;
        %err_put( msg="Invalid number of obs. " _n_= )
      end;
    end;
    
    %do i = 1 %to &num_vars;
    
      %let onev = %scan( &vars, &i );
    
      put &onev;
      
    %end;
    
  run;

  ** Close DDE destinations **;

  filename xlsfile1 clear;
  filename xlsfile2 clear;
  filename xlsfile3 clear;
  filename xlsfile4 clear;

%mend Write_table;

/** End Macro Definition **/

**** Write data to tables ****;

%Write_table( 
  sheet=PovInc, 
  row=9, 
  vars=
    tanf_pers_2000
    tanf_pers_2001
    tanf_pers_2002
    tanf_pers_2003
    tanf_pers_2004
    tanf_pers_2005
)

%Write_table( 
  sheet=PovInc, 
  row=17, 
  vars=
    pct_tanf_pers_2000
    pct_tanf_pers_2001
    pct_tanf_pers_2002
    pct_tanf_pers_2003
    pct_tanf_pers_2004
    pct_tanf_pers_2005
)

%Write_table( 
  sheet=PovInc, 
  row=25, 
  vars=
    fs_pers_2000
    fs_pers_2001
    fs_pers_2002
    fs_pers_2003
    fs_pers_2004
    fs_pers_2005
)

%Write_table( 
  sheet=PovInc, 
  row=33, 
  vars=
    pct_fs_pers_2000
    pct_fs_pers_2001
    pct_fs_pers_2002
    pct_fs_pers_2003
    pct_fs_pers_2004
    pct_fs_pers_2005
)

** Housing, Home Ownership & Mortgages **;

%Write_table( sheet=Housing, row=9, vars=ownrt9 ownrt0 )

%Write_table( 
  sheet=Housing, 
  row=13, 
  vars=
    num_sales_1995
    num_sales_1996
    num_sales_1997
    num_sales_1998
    num_sales_1999
    num_sales_2000
    num_sales_2001
    num_sales_2002
    num_sales_2003
    num_sales_2004  
)

%Write_table( 
  sheet=Housing, 
  row=25, 
  vars=
    num_sales_p100_1995
    num_sales_p100_1996
    num_sales_p100_1997
    num_sales_p100_1998
    num_sales_p100_1999
    num_sales_p100_2000
    num_sales_p100_2001
    num_sales_p100_2002
    num_sales_p100_2003
    num_sales_p100_2004  
)

%Write_table( 
  sheet=Housing, 
  row=37, 
  vars=
    med_saleprice_1995
    med_saleprice_1996
    med_saleprice_1997
    med_saleprice_1998
    med_saleprice_1999
    med_saleprice_2000
    med_saleprice_2001
    med_saleprice_2002
    med_saleprice_2003
    med_saleprice_2004  
)

%Write_table( 
  sheet=Housing, 
  row=49, 
  vars=
    medianmrtginc_1995
    medianmrtginc_1996
    medianmrtginc_1997
    medianmrtginc_1998
    medianmrtginc_1999
    medianmrtginc_2000
    medianmrtginc_2001
    medianmrtginc_2002
    medianmrtginc_2003
)

%Write_table( 
  sheet=Housing, 
  row=60, 
  vars=
    PctBlackLoans_1995
    PctBlackLoans_1996
    PctBlackLoans_1997
    PctBlackLoans_1998
    PctBlackLoans_1999
    PctBlackLoans_2000
    PctBlackLoans_2001
    PctBlackLoans_2002
    PctBlackLoans_2003
)

%Write_table( 
  sheet=Housing, 
  row=71, 
  vars=
    PctInvestLoans_1995
    PctInvestLoans_1996
    PctInvestLoans_1997
    PctInvestLoans_1998
    PctInvestLoans_1999
    PctInvestLoans_2000
    PctInvestLoans_2001
    PctInvestLoans_2002
    PctInvestLoans_2003
)

%Write_table( 
  sheet=Housing, 
  row=82, 
  vars=
    PctSubprime_1995
    PctSubprime_1996
    PctSubprime_1997
    PctSubprime_1998
    PctSubprime_1999
    PctSubprime_2000
    PctSubprime_2001
    PctSubprime_2002
    PctSubprime_2003
)



run;
