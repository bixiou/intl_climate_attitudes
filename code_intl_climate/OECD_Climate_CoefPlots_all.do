/********************************************************************************
					               OECD Climate

Goal: Create reg plots						
Date: 		Dec 2021
 
*********************************************************************************/
		 

/********************************************************************************

	Create the Program 

********************************************************************************/

cap program drop graphcoefplots 

program define graphcoefplots 
	* Arguments 
	args 1 2 3 
	
	*--------------------------
	* Set Environment 
	*--------------------------
	* Run Set-Up Program 
	datasetup 
	
	* Run coeflabels 
	include "${code}OECD_Climate_Coeflabels.do"
	
	* Directories
		if "`1'"=="all" {
		global output 	"${gitpath}//figures//all/"
		}
		else if "`1'"!="all" {
		global output 	"${gitpath}//figures//$choosecountry/"
		}	
	
	* Restrict to country 
	if "`1'" == "all" {
		}
		
	else {
		keep if country=="`1'"
		drop index_* 
		ren c_index_* index_* 
		ren index_investments_emiss_plus index_investments_emissions_plus
	}
	
	if "`1'" == "all" global ctry_fe "i.ccode"
	if "`1'" != "all" global ctry_fe ""
	
	* Outcomes Labels 
	if strpos("`2'", "knowledge") 				loc `2't "Knowledge index"
	if strpos("`2'", "policies") 				loc `2't "Support for main climate policies index"
	if strpos("`2'", "index_willing_change") 	loc `2't "Willingness to adopt climate-friendly behavior index"
	if strpos("`2'", "index_fairness") 			loc `2't "Fairness of main climate policies index"
	
	if strpos("`2'", "standard_binary") 		loc `2't "Ban on combustion-engine cars"
	if strpos("`2'", "investments_binary") 		loc `2't "Green infrastructure program"
	if strpos("`2'", "tax_transfers_binary") 	loc `2't "Carbon tax with cash transfers"
	

	if strpos("`2'", "tax_fuels_binary") 		loc `2't "Tax on fossil fuels"
	if strpos("`2'", "ban_citycenter_binary") 	loc `2't "Ban of polluting vehicles in city centers"
	if strpos("`2'", "subsidies_binary") 		loc `2't "Subsidies for low-carbon technologies"
	if strpos("`2'", "tax_flying_binary") 		loc `2't "Tax on flying (raising price by 20%)"
	if strpos("`2'", "standard_public_binary") 	loc `2't   "Ban on combustion-engine cars" "where alternatives made available" 
	
	if strpos("`2'", "wtp_binary") loc `2't   "Willing to pay to limit CC" 
	if strpos("`2'", "petition") loc `2't   "Support climate petition" 

	loc title_`2' " "
	
	* Set Colors 
	if strpos("`2'", "knowledge") loc i = 1 
	if strpos("`2'", "policies") loc i = 8
	if strpos("`2'", "standard") loc i = 4
	if strpos("`2'", "investment") loc i = 5
	if strpos("`2'", "tax") loc i = 2
	if strpos("`2'", "index_willing_change") loc i = 3
	if strpos("`2'", "index_fairness") loc i = 3
	
cap log close 
log using "${output}//OECD_Climate_Coefplots_`2'_`1'$weight_extension.log", replace 	
global outname "${output}//OECD_Climate_Coefs_`2'_`1'$weight_extension"
	cap erase "${outname}.txt"
	cap erase "${outname}.xls"
di in red "Outcome: `2' / Country: `1'"
	
	*----------------------------
	* Graph SET A plot A
	*----------------------------
	if	"`1'" == "all" {
		loc todrop _cons econ_pnr age* gender_other 
		loc tokeep female *income_factor *children  *educ* econ*
	}
	else if "`1'"!= "all" {
		loc todrop _cons econ_pnr gender_other 
		loc tokeep age* female *income_factor *children  *educ* econ*
	}
	
	
	if "`2'" == "index_main_policies"  loc xlab = `" xlab(-0.60(0.2)0.20, format(%4.2fc)) xsc(r(-0.61 0.25)) "' 
	if "`2'" == "index_knowledge"  & "`1'" == "all" loc xlab = `" xlab(-0.50(0.1)0.50, format(%4.2fc)) xsc(r(-0.5 0.5)) "' 
	else loc xlab 
	
	
	if "`2'" == "index_knowledge" {
		
		reg `2' $ctry_fe $setA  $weight_option , robust 
		estimates store `2'A
		loc s2 = e(N) 
		loc s2: di %6.0fc `s2'  
		loc r2 = e(r2)
		loc r2: di %4.2fc `r2'
		

		
	coefplot ///
	 (`2'A,  drop(`todrop') keep( `tokeep') ///
	 $line0 ///
	 $dotsize mlcolor("${p`i'}")  mfcolor("${p`i'}%70") ciopts( lwidth($ciwidth )  color("${p`i'}") )  ) , ///
	 $graphsettings xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
	coeflabels( `coeflabels_A' , $coefsize ) 	///
	headings( `coefheads_A' , $headsize  ) ///
			legend(off) ///
			`xlab' /// 
			xtitle("Coefficients", $xops ) ///
			name(gA, replace) 
	
	loc addnote 
	
	graph combine gA , xcommon
	graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
	}
	
	if  strpos("`2'", "combined_pols") == 0 & strpos("`2'", "index_knowledge") == 0  {
	    
	if strpos("`2'", "wtp_binary") == 0 {
		reg `2' $ctry_fe $setA  $weight_option , robust 
		estimates store `2'A
		loc s2 = e(N) 
		loc s2: di %6.0fc `s2'  
		loc r2 = e(r2)
		loc r2: di %4.2fc `r2'
		outreg2  using "${outname}.xls", dec(3) append ci addtext(Country FE, "$ctry_fe", Spec, "setAT")

	}
	else {
		reg `2' $ctry_fe $setA_wtp $weight_option , robust 
		estimates store `2'A
		loc s2 = e(N) 
		loc s2: di %6.0fc `s2'  
		loc r2 = e(r2)
		loc r2: di %4.2fc `r2'

	}
	
	if "`2'" == "index_main_policies" & "`1'"=="all" loc tokeepA "*children *educ* econ*"
	else if "`2'" == "index_main_policies" & "`1'"!="all" loc tokeepA "*female *children *educ* econ* *age* *income_factor"
	else if "`2'" == "wtp_binary" loc tokeepA "female age* *income_factor *children  *educ* econ* *wtp_variant"
	
	if 		"`2'" == "index_main_policies" & "`1'"=="all" loc demo_head children
	else if "`2'" == "index_main_policies" & "`1'"!="all" loc demo_head female
	else loc demo_head female
	
	di in red "`demo_head'"
	coefplot ///
	 (`2'A,  drop(_cons econ_pnr gender_other ) keep( `tokeepA' )  $line0 ///
	 $dotsize mlcolor("${p`i'}")  mfcolor("${p`i'}%70") ciopts( lwidth($ciwidth )  color("${p`i'}") )  )	 , ///
	 $agraphsettings xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
	 coeflabels(  `coeflabels_A'   , $coefsize ) 	///
	headings( `coefheads_A'  , $headsize ) ///
			legend(off ) ///
			`xlab' /// 
			xtitle("Coefficients", $xops ) ///
			 name(gA, replace) 
	
	
	
	*------------------------------
	* Graph SET AB plot B 
	*------------------------------
	if strpos("`2'", "wtp_binary") == 0 {
		reg `2' $ctry_fe $setA $setB $weight_option  , robust 
		estimates store `2'AB
		loc s2 = e(N) 
		loc s2: di %6.0fc `s2'  
		loc r2 = e(r2)
		loc r2: di %4.2fc `r2'
		outreg2  using "${outname}.xls", dec(3) append drop( $setA ) ci addtext(Country FE, "$ctry_fe", Spec, "setAB")		
	}
	else {
		reg `2' $ctry_fe $setA_wtp $setB $weight_option  , robust 
		estimates store `2'AB
		loc s2 = e(N) 
		loc s2: di %6.0fc `s2'  
		loc r2 = e(r2)
		loc r2: di %4.2fc `r2'

	}
	coefplot ///
	 (`2'AB,  drop(_cons ) keep(*car_dependency *agglo* *binary_availability_transport *binary_gas_expenses *binary_heating_expenses *flights_agg_1 *polluting_sector *owner *beef_binary) $line0  $dotsize mlcolor("${p`i'}") mfcolor("${p`i'}%70") ciopts( lwidth($ciwidth )  color("${p`i'}") )  )	 , ///
	 $graphsettings xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
	 coeflabels( `coeflabels_B' ,$coefsize ) 	///
	headings( `coefheads_B' , $headsize ) ///
			legend(off ) ///
			`xlab' ///
			xtitle("Coefficients", $xops ) ///
			 name(gB, replace) 
		
	*-------------------------------
	* Figure 1: Combine A and AB 
	*-------------------------------
	loc addnote 
	
	graph combine gA gB, xcommon 
	graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
	}
	
	*---------------------------------------------------------
	* Graph SET AC plot C : Only for support, not knowledge 
	*---------------------------------------------------------
	loc addnote
	
	*-----------------------------------------
	* Combine 3 Main Policies into 1 Graph 
	* Set A, Set AB, and Set AC 
	*-----------------------------------------
	
	if "`2'"=="combined_pols"  {	 	
	
		global p2 = "0 139 188"
		global p5 = "92 184 92"
		global p4 =  "165 0 38"
		
	* Graph TREATMENT (and set A)
	reg standard_binary $ctry_fe $setA  $weight_option , robust 
	estimates store support1A
	sum standard_binary  if e(sample) & treatment == 1 $weight_option 
	loc cmean1 = r(mean)*100
	loc cmean1: di %2.0fc `cmean1'
	
	reg investments_binary $ctry_fe $setA  $weight_option , robust 
	estimates store support2A
	sum investments_binary  if e(sample) & treatment == 1 $weight_option 
	loc cmean2 = r(mean)*100
	loc cmean2: di %2.0fc `cmean2'
	
	reg tax_transfers_binary $ctry_fe $setA  $weight_option , robust 
	estimates store support3A	
	sum tax_transfers_binary  if e(sample) & treatment == 1 $weight_option 
	loc cmean3 = r(mean)*100
	loc cmean3: di %2.0fc `cmean3'	
	
	
	if "`2'" == "combined_pols" & "`1'"=="all"  loc xlab = `" xlab(0(0.05)0.15, format(%4.2fc)) xsc(r(0 0.18)) "'

	coefplot ///
		(support1A, offset(0.06) mlcolor("${p4}") $dotsize ms(O)	mfcolor("${p4}%50") ciopts( lwidth($ciwidth )  color("${p4}%50") ) ) ///
		(support2A, offset(0.00) mlcolor("${p5}") $dotsize ms(D) mfcolor("${p5}%50") ciopts( lwidth($ciwidth )  color("${p5}%50") ) ) ///
		(support3A, offset(-0.06) mlcolor("${p2}") $dotsize ms(T) mfcolor("${p2}%50") ciopts( lwidth($ciwidth )  color("${p2}%50") ) )  , ///	 
		 drop(_cons econ_pnr ) ///
	 keep(*treatment ) /// 
	 $graphsettings xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
	 coeflabels(2.treatment = "Climate Impacts" 3.treatment = "Climate Policies" 4.treatment = "Both Treatments" , $coefsize) 	///
	headings(2.treatment= `" "{bf: Treatment}" "{it: Compared to Control}" "' /// 
			 , $headsize ) ///
			legend(row(1) order(2 4 6) label(2 "Ban on combustion-engine cars: `cmean1'%") label(4 "Green infrastructure program: `cmean2'%") label(6 "Carbon tax with cash transfers: `cmean3'%") $comblegendops ) ///
			`xlab' /// 
			xtitle("Coefficients", $xops ) ///
			 name(gTcombined, replace) 	
			 
		grc1leg gTcombined, xcommon legendfrom(gTcombined) pos(12) ring(0)
		//graph export "${output}Coefplot_SetAT_PlotT_`2'_`1'$weight_extension.${ft}", replace
		
	    
	if "`1'"=="all"	loc xlab = `" xlab(-0.20(0.1)0.10, format(%4.2fc)) xsc(r(-0.20 0.12)) "'
	* Graph SET A plot A 
	reg standard_binary $ctry_fe $setA  $weight_option , robust 
	estimates store support1A
	
	reg investments_binary $ctry_fe $setA  $weight_option , robust 
	estimates store support2A
	
	reg tax_transfers_binary $ctry_fe $setA  $weight_option , robust 
	estimates store support3A
	
	
	coefplot ///
		(support1A, offset(0.06) mlcolor("${p4}") $dotsize ms(O) mfcolor("${p4}%50") ciopts( lwidth($ciwidth)  color("${p4}%50") ) ) ///
		(support2A, offset(0.00) mlcolor("${p5}") $dotsize ms(D) mfcolor("${p5}%50") ciopts( lwidth($ciwidth)  color("${p5}%50") ) ) ///
		(support3A, offset(-0.06) mlcolor("${p2}") $dotsize ms(T) mfcolor("${p2}%50") ciopts( lwidth($ciwidth)  color("${p2}%50") ) )  , ///
	 drop(_cons econ_pnr ) ///
	 keep( female  *children *income_factor age* *educ* econ*) ///
	 $line0   ///
	 $agraphsettings xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
	 coeflabels(`coeflabels_A' , $coefsize ) 	///
	headings( `coefheads_A' , $headsize ) ///
			legend(row(1) order(2 4 6) label(2 "Ban on combustion-engine cars") label(4 "Green infrastructure program") label(6 "Carbon tax with cash transfers") $comblegendops ) ///
			`xlab' ///
			xtitle("Coefficients", $xops ) ///
			 name(gAcombined, replace) 
			 
	* Graph SET AB plot B 
	reg standard_binary $ctry_fe $setA $setB $weight_option , robust 
	estimates store support1AB
	
	reg investments_binary $ctry_fe $setA $setB $weight_option , robust 
	estimates store support2AB
	
	reg tax_transfers_binary $ctry_fe $setA $setB $weight_option , robust 
	estimates store support3AB		

	
	coefplot ///
	(support1AB, offset(0.06) mlcolor("${p4}") ms(O) mfcolor("${p4}%50") ciopts( lwidth($ciwidth)  color("${p4}%50") ) ) ///
	(support2AB, offset(0.00) mlcolor("${p5}") ms(D) mfcolor("${p5}%50") ciopts( lwidth($ciwidth)  color("${p5}%50") ) ) ///
	(support3AB, offset(-0.06) mlcolor("${p2}") ms(T) mfcolor("${p2}%50") ciopts( lwidth($ciwidth)  color("${p2}%50") ) )  , ///
	 drop(_cons ) ///
	 keep( *agglo* *binary_availability_transport *binary_gas_expenses *binary_heating_expenses *car_dependency *flights_agg_1 *polluting_sector *owner *beef_binary )  $line0  $dotsize    ///
	 $graphsettings xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
	 coeflabels( `coeflabels_B' , $coefsize ) 	///
	headings(	`coefheads_B' , $headsize ) ///
			legend(off) ///
			`xlab' ///
			xtitle("Coefficients", $xops ) ///
			 name(gBcombined, replace) 
	
	* Figure 1: Combine A and AB 
	loc addnote 
	grc1leg gAcombined gBcombined, xcommon legendfrom(gAcombined) pos(12) 
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA8a.${ft}", replace
			 
	* Graph SET AC plot C : Only for support, not knowledge 
	loc addnote
	global outname "${output}//OECD_Climate_Coefs_SetC_`2'_`1'$weight_extension"
		cap erase "${outname}.txt"
		cap erase "${outname}.xls"	


	* 1.Standard
	preserve 

	ren index_standard_positive index_positive 
	ren index_lose_standard_poor index_poor
	ren index_lose_standard_rich index_rich 
	ren index_lose_standard_self index_self 
	ren index_standard_effective index_effective 
	
	ren index_standard_emissions_plus index_emissions_plus
	ren index_standard_emissions index_emissions
	ren index_standard_pollution index_pollution
	
	ren index_fairness_standard index_fair
	
	reg standard_binary $ctry_fe $setA $setCdis_policy $weight_option  if treatment == 1, robust 
	estimates store support1ACdis
		outreg2  using "${outname}.xls", dec(3) append ci side addtext(Country FE, "$ctry_fe", Spec, "setAC", Outcome, "Standard") 

	
	restore 
	
	* 2. Investments
	preserve 
 	ren index_investments_positive index_positive 
	ren index_lose_investments_poor index_poor
	ren index_lose_investments_rich index_rich 
	ren index_lose_investments_self index_self 
	ren index_investments_effective index_effective 
	
	ren index_investments_emissions_plus  index_emissions_plus
	ren index_investments_pollution index_pollution
	
	ren index_fairness_investments index_fair 

	
	reg investments_binary $ctry_fe $setA $setCdis_policy $weight_option  if treatment == 1, robust 
	estimates store support2ACdis
	outreg2  using "${outname}.xls", dec(3) append ci side addtext(Country FE, "$ctry_fe", Spec, "setAC", Outcome, "Investments" )
	
	restore 
	
		
	* 3. Carbon tax 
	preserve 
	ren index_tax_transfers_positive index_positive 
	ren index_lose_tax_transfers_poor index_poor
	ren index_lose_tax_transfers_rich index_rich 
	ren index_lose_tax_transfers_self index_self 
	ren index_tax_transfers_effective index_effective  
	
	ren index_tax_emissions_plus index_emissions_plus
	ren index_tax_emissions index_emissions
	ren index_tax_transfers_pollution index_pollution
	
	ren index_fairness_tax_transfers index_fair
	
	reg tax_transfers_binary $ctry_fe $setA $setCdis_policy $weight_option  if treatment == 1, robust 
	estimates store support3ACdis
	outreg2  using "${outname}.xls", dec(3) append ci side addtext(Country FE, "$ctry_fe", Spec, "setAC", Outcome, "Tax" )

	restore 
	
	* xlab
	if "`1'" == "all" loc xlab = `" xlab(-0.20(0.1)0.12, format(%4.2fc)) xsc(r(-0.20 0.12)) "'
		
		
	* Merge in Decomposition analysis 
	preserve 
	if "`1'" =="all" loc folder "All"
	if "`1'" !="all" loc folder "${choosecountry}"
	import delimited using "${gitpath}/tables/`folder'/LMG_main_policies_AtC.csv", clear 
		sxpose, clear   force destring 
		
	    foreach var of varlist * {
		  replace `var' = subinstr(`var', " ", "", .)
		  label variable `var' "`=`var'[1]'"
		  ren  `var' `=`var'[1]'
		}
		drop if _n==1 
		destring *, replace 
		cap drop country 
		gen country ="${choosecountry}_var"
		
		ren index_lose_policies_subjective index_self 
		ren index_lose_policies_poor index_poor
		ren index_lose_policies_rich index_rich 
		ren index_policies_pollution index_pollution
		ren index_positive_economy index_positive
		ren index_policies_emissions_plus index_emissions_plus
		
		ren age_control age_variance
		tempfile variance
		save 	`variance'
	restore 
	
	append using `variance'
	foreach var in $indices_policy {
	sum `var' if country=="${choosecountry}_var"
	local l`var' = r(mean)*100
	local l`var' : di %3.1fc `l`var''
	}
	include "${code}OECD_Climate_Coeflabels.do"
	loc labelstoplot_policy `coeflabels_Cdis_var_policy'
	
	* Revert back to not plot the variance % in the y-axis 
	loc  labelstoplot_policy `coeflabels_Cdis_policy' 	

		* Disaggregated C version 	
		coefplot ///
		(support1ACdis, offset(0.06) mlcolor("${p4}") $dotsize ms(O) mfcolor("${p4}%50") ciopts( lwidth($ciwidth)  color("${p4}%50") ) ) ///
		(support2ACdis, offset(0.00) mlcolor("${p5}") $dotsize ms(D) mfcolor("${p5}%50") ciopts( lwidth($ciwidth)  color("${p5}%50") ) ) ///
		(support3ACdis, offset(-0.06) mlcolor("${p2}") $dotsize ms(T) mfcolor("${p2}%50") ciopts( lwidth($ciwidth)  color("${p2}%50") ) )  	, ///
		 drop(_cons ) ///
		 keep( $setCdis_policy  ) order( $setCdis_policy ) $line0	 ///
		  xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ysc(r(0 22)) ///
		 coeflabels( `labelstoplot_policy' 	 ,  $coefsize )  ///
		 headings(	`coefheads_Cdis_policy'		 , $headsize ) ///
				title("{bf: `title_`2''}" " ", size(small) color(black)) ///
				legend(row(1) order(2 4 6) label(2 "Ban on combustion-engine cars") label(4 "Green infrastructure program") label(6 "Carbon tax with cash transfers") $comblegendops ) ///
				`xlab' ///
				xtitle("Coefficients", $xops ) ///
				$cgraphsettings ///
				 name(gC, replace) 
				 
				grc1leg gC, xcommon legendfrom(gC) pos(12) ring(0)
		graph export "${gitpath}/figures/FINAL_FIGURES/Figure14a.${ft}", replace
	}	
	
	
	cap log close 
end 


