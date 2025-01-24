/********************************************************************************
					               OECD Climate

Goal: Create Reverse IV graphs by country from files created in R			
Date: May 2024
 
*********************************************************************************/

*--------------------------
* Load & Clean Data
*--------------------------
	datasetup 
	use "$gitpath/data/boot_stata_countries_reverseIV_control.dta", clear

	gen significant = (lb > 0 | ub < 0)
	local outcome_all `" "Ban on Combustion-Engine Cars" "Carbon Tax with Cash Transfers" "Green Infrastructure Program" "'
	local treatment_all `" "Climate Impacts" "Climate Policies" "Both Treatments" "'

/********************************************************************************

	Create Graph for each Policy

********************************************************************************/
foreach policy_condition of local outcome_all {
	loc treat = 0
	
	if "`policy_condition'" == "Ban on Combustion-Engine Cars" loc pol_label = "standard"
	if "`policy_condition'" == "Carbon Tax with Cash Transfers" loc pol_label = "tax_transfers"
	if "`policy_condition'" == "Green Infrastructure Program" loc pol_label = "investments"
	
	*--------------------------
	* Create panel for each Treatment
	*--------------------------
	foreach treatment_condition of local treatment_all {
		loc treat = `treat' + 1
		macro drop toplot 
		loc toplot 
		gen test = .

		loc count = 20
		
		** For High-Income Countries
		foreach K in $good_data {
			loc i "${p1}"
			
			if "`K'" == "DE" loc k  DEU
			if "`K'" == "DK" loc k  DNK
			if "`K'" == "FR" loc k  FRA
			if "`K'" == "IT" loc k  ITA
			if "`K'" == "PL" loc k  POL 
			if "`K'" == "SP" loc k  ESP
			if "`K'" == "UK" loc k  GBR  
			if "`K'" == "CA" loc k  CAN
			if "`K'" == "AU" loc k  AUS
			if "`K'" == "US" loc k  USA 
			if "`K'" == "SK" loc k  KOR   
			if "`K'" == "JP" loc k  JPN
			if "`K'" == "BR" loc k  BRA
			if "`K'" == "ID" loc k  IDN
			if "`K'" == "MX" loc k  MEX
			if "`K'" == "SA" loc k  ZAF  
			if "`K'" == "TR" loc k  TUR 
			if "`K'" == "UA" loc k  UKR
			if "`K'" == "CN" loc k  CHN 
			if "`K'" == "IA" loc k  IND
			
			replace test = `count' if country == "`k'"
			loc count `count' - 1
			
			** Create Graph and change color if significant or not
			local toplot `toplot' (scatter test coef if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 0, mlwidth(vthin) ms(O)  mlcolor(gs8%50) mlwidth(vthin) mfcolor(gs8%50)  mlab(country) mlabpos(1) mlabgap(*1) mlabcolor(gs8%50) mlabsize(vsmall) msize(0.5)  ) (rcap lb ub test if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 0, horizontal color("gs8%50"))
			local toplot `toplot' (scatter test coef if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 1, mlwidth(vthin) ms(O)  mlcolor("`i'") mlwidth(vthin) mfcolor("`i'")  mlab(country) mlabpos(1) mlabgap(*1) mlabcolor("`i'") mlabsize(vsmall) msize(0.5)  ) (rcap lb ub test if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 1, horizontal color("`i'"))
		}
		
		** For Middle-Income Countries
		foreach K in $bad_data {
			loc i "${p8}"
			
			if "`K'" == "DE" loc k  DEU
			if "`K'" == "DK" loc k  DNK
			if "`K'" == "FR" loc k  FRA
			if "`K'" == "IT" loc k  ITA
			if "`K'" == "PL" loc k  POL 
			if "`K'" == "SP" loc k  ESP
			if "`K'" == "UK" loc k  GBR  
			if "`K'" == "CA" loc k  CAN
			if "`K'" == "AU" loc k  AUS
			if "`K'" == "US" loc k  USA 
			if "`K'" == "SK" loc k  KOR   
			if "`K'" == "JP" loc k  JPN
			if "`K'" == "BR" loc k  BRA
			if "`K'" == "ID" loc k  IDN
			if "`K'" == "MX" loc k  MEX
			if "`K'" == "SA" loc k  ZAF  
			if "`K'" == "TR" loc k  TUR 
			if "`K'" == "UA" loc k  UKR
			if "`K'" == "CN" loc k  CHN 
			if "`K'" == "IA" loc k  IND
			
			replace test = `count' if country == "`k'"
			loc count `count' - 1

			** Create Graph and change color if significant or not
			local toplot `toplot' (scatter test coef if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 0, mlwidth(vthin) ms(T)  mlcolor(gs8%50) mlwidth(vthin) mfcolor(gs8%50)  mlab(country) mlabpos(1) mlabgap(*1) mlabcolor(gs8%50) mlabsize(vsmall) msize(0.5)  ) (rcap lb ub test if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 0, horizontal color("gs8%50"))
			local toplot `toplot' (scatter test coef if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 1, mlwidth(vthin) ms(T)  mlcolor("`i'") mlwidth(vthin) mfcolor("`i'")  mlab(country) mlabpos(1) mlabgap(*1) mlabcolor("`i'") mlabsize(vsmall) msize(0.5)  ) (rcap lb ub test if country == "`k'" & outcome == "`policy_condition'" & treatment == "`treatment_condition'" & significant == 1, horizontal color("`i'"))
		}		
		
		** Plot the panel
		twoway `toplot' ,  xline(0, lcolor(black) lpattern(dash)  lwidth(thin))    ///
		   $graphsettings4 xlabel( $labeloptions format(%4.2fc)) ylabel(, nolabel notick) ///
		   legend(order(1 "Not significant, p-val > .05" 3 "Nationally representative" 59 "Online representative") pos(12) row(1)) ///
		   ytitle("") xtitle("Coefficients", $xops ) title("{bf: `treatment_condition'}", $xops ) ///
		   xlabel(-.2(.1).2) ///
		   name(gA`treat', replace)
		   
		drop test
	}
	** Combine Panel together and Export Graph
	grc1leg gA1 gA2 gA3, xcommon title(" ", size(small) color(gs8)) legendfrom(gA1) pos(12) row(1)
	if "`policy_condition'" == "Green Infrastructure Program" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA22a.${ft}", replace
	}
	if "`policy_condition'" == "Ban on Combustion-Engine Cars" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA22b.${ft}", replace
	}
	if "`policy_condition'" == "Carbon Tax with Cash Transfers" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA22c.${ft}", replace
	}

}
