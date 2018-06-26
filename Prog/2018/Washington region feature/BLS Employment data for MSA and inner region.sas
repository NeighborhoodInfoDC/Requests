/* U.S. Department of Labor                                                 */
/* Bureau of Labor Statistics                                               */
/* Quarterly Census of Employment and Wages                                 */
/* April 2015                                                               */
/*                                                                          */
/* QCEW Open Data Access SAS Example                                        */
/*                                                                          */
/* SAS 9.3                                                                  */
/*                                                                          */
/* This file contains 3 SAS Macros that import QCEW data slices.            */
/* Each Macro is called once at the bottom of this file.                    */
/* So, you can run this code to see some results.                           */
/*                                                                          */
/* Submit questions at:                                                     */
/*   http://www.bls.gov/cgi-bin/forms/cew?/cew/home.htm                     */
/*                                                                          */
/*  ----------------------------------------------------------------------- */





/* ------------------------------------------------------------------------ */
/* qcewGetAreaData  : This macro takes 3 parameters: year, qtr, and area.   */
/* These arguments are used to construct the corresponding URL that points  */
/* to the given data file. Use "a" as the qtr value if you want to get      */
/* annual averages.                                                         */
/*                                                                          */
/* For all area codes and titles see:                                       */
/* http://data.bls.gov/cew/doc/titles/area/area_titles.htm                  */
/*                                                                          */
/* ------------------------------------------------------------------------ */
%MACRO qcewGetAreaData(year,qtr,area);
	
	filename ar&area. url 
		"http://data.bls.gov/cew/data/api/&year./%LOWCASE(&qtr.)/area/%UPCASE(&area.).csv";
	data a&area.y&year.q&qtr.;
		infile ar&area.
			   dlm=","
               dsd
			   firstobs=2
               truncover;
		%IF '&qtr.' eq 'a' %THEN %DO;
	    	input area_fips $ 
				own_code $ 
				industry_code $ 
				agglvl_code $ 
				size_code $
				year $
				qtr $
				disclosure_code $ 
				annual_avg_estabs
				annual_avg_emplvl 
				total_annual_wages
				taxable_annual_wages
				annual_contributions
				annual_avg_wkly_wage
				avg_annual_pay
				lq_disclosure_code $
				lq_annual_avg_estabs
				lq_annual_avg_emplvl
				lq_total_annual_wages
				lq_taxable_annual_wages
				lq_annual_contributions
				lq_annual_avg_wkly_wage
				lq_avg_annual_pay
				oty_disclosure_code $
				oty_annual_avg_estabs_chg
				oty_annual_avg_estabs_pct_chg
				oty_annual_avg_emplvl_chg
				oty_annual_avg_emplvl_pct_chg
				oty_total_annual_wages_chg
				oty_total_annual_wages_pct_chg
				oty_taxable_annual_wages_chg
				oty_taxable_annual_wages_pct_chg
				oty_annual_contributions_chg
				oty_annual_contributions_pct_chg
				oty_annual_avg_wkly_wage_chg
				oty_annual_avg_wkly_wage_pct_chg
				oty_avg_annual_pay_chg
				oty_avg_annual_pay_pct_chg;
		%END;
		%ELSE %DO;
			input area_fips $ 
				own_code $ 
				industry_code $ 
				agglvl_code $ 
				size_code $
				year $
				qtr $ 
				disclosure_code $ 
				qtrly_estabs 
				month1_emplvl 
				month2_emplvl
				month3_emplvl 
				total_qtrly_wages
				taxable_qtrly_wages 
				qtrly_contributions
				avg_wkly_wage
				lq_disclosure_code $
				lq_qtrly_estabs
				lq_month1_emplvl
				lq_month2_emplvl
				lq_month3_emplvl
				lq_total_qtrly_wages
				lq_taxable_qtrly_wages
				lq_qtrly_contributions
				lq_avg_wkly_wage
				oty_disclosure_code $
				oty_qtrly_estabs_chg
				oty_qtrly_estabs_pct_chg
				oty_month1_emplvl_chg
				oty_month1_emplvl_pct_chg
				oty_month2_emplvl_chg
				oty_month2_emplvl_pct_chg
				oty_month3_emplvl_chg
				oty_month3_emplvl_pct_chg
				oty_total_qtrly_wages_chg
				oty_total_qtrly_wages_pct_chg
				oty_taxable_qtrly_wages_chg
				oty_taxable_qtrly_wages_pct_chg
				oty_qtrly_contributions_chg
				oty_qtrly_contributions_pct_chg
				oty_avg_wkly_wage_chg
				oty_avg_wkly_wage_pct_chg;
 
		%END;
	run;
%MEND qcewGetAreaData;


%qcewGetAreaData(2015,a,26000);






