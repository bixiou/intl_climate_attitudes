/********************************************************************************
					               OECD Climate

Goal: Create Reverse IV graphs for all sample from files created in R			
Date: May 2024
 
*********************************************************************************/

/********************************************************************************

	Set-up

********************************************************************************/

*--------------------------
* Set Colors
*--------------------------

	global p2 = "0 139 188"
	global p5 ="127 72 146"
	global p6 =  "165 0 38"
	global p4 = "92 184 92"	

*--------------------------
* Load & Clean Data
*--------------------------
	use "$gitpath/data/boot_stata_countries_reverseIV_all_control.dta", clear

	* Be carefule here, number outcome depends on position when using the program
	gen outcome_name = outcome

	* Clean treatment
	gen treatment_name = treatment

	drop outcome
	gen outcome = 1
	replace outcome = 2 if outcome_name == "Ban on Combustion-Engine Cars"
	replace outcome = 3 if outcome_name == "Green Infrastructure Program"

/********************************************************************************

	Create Graph

********************************************************************************/	
	
	local gap = 0.06 // define the size of the gap

	replace outcome = outcome+`gap' if treatment == "Climate Impacts"
	replace outcome = outcome-`gap' if treatment == "Both Treatments"

	twoway (scatter outcome coef if treatment=="Climate Impacts", ms(O) mcolor("${p2}%50") mlwidth(1) lcolor("${p2}%50") mlwidth(vthin)) ///
		   (rcap lb ub outcome if treatment=="Climate Impacts", horizontal color("${p2}%50")) ///
		   (scatter outcome coef if treatment=="Climate Policies", ms(D) mcolor("${p4}%50") mlwidth(1) lcolor("${p4}%50") mlwidth(vthin)) ///
		   (rcap lb ub outcome if treatment=="Climate Policies", horizontal color("${p4}%50")) ///
		   (scatter outcome coef if treatment=="Both Treatments", ms(T) mcolor("${p6}%50") mlwidth(1) lcolor("${p6}%50") mlwidth(vthin)) ///
		   (rcap lb ub outcome if treatment=="Both Treatments", horizontal color("${p6}%50")), ///
		   xline(0, lcolor(black) lpattern(dash)  lwidth(thin)) ///
		   $graphsettings4 xlabel( $labeloptions format(%4.2fc)) ylabel(3 "Green infrastructure program" 2 "Ban on combustion-engine cars" 1 "Carbon tax with cash transfers" 4 "{bf: Support for Main Climate Policies}", nogrid ) ///
		   legend(order(1 "Climate Impacts" 3 "Climate Policies" 5 "Both Treatments") pos(12) row(1)) ///
		   ytitle("") xtitle("Coefficients", $xops )
		   
	graph export "${gitpath}/figures/FINAL_FIGURES/FigureA21.${ft}", replace
