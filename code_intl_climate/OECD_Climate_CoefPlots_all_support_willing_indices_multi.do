/********************************************************************************
					               OECD Climate

Goal: Create reg plots						
Date: Dec 2021
 
*********************************************************************************/
		 

/********************************************************************************

	Create the Program 

********************************************************************************/

cap program drop graphcoefplots_real_stakes_multi

program define graphcoefplots_real_stakes_multi
	* Arguments 
	args 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 
	
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
	}
	ren index_knowledge_fundamentals index_knowledge_fund
	ren index_tax_transfers_positive index_tax_positive
	ren index_tax_transfers_pollution index_tax_pollution
	ren index_lose_tax_transfers_self index_lose_tax_self
	ren index_lose_tax_transfers_poor index_lose_tax_poor
	ren index_lose_tax_transfers_rich index_lose_tax_rich
	ren index_standard_emissions_plus index_standard_em_plus
	
	ren index_investments_positive index_invest_positive
	cap ren index_investments_emissions_plus index_invest_em_plus
	cap ren index_investments_emiss_plus index_invest_em_plus
	ren index_investments_pollution index_invest_pollution
	ren index_lose_investments_self index_lose_invest_self
	ren index_lose_investments_poor index_lose_invest_poor
	ren index_lose_investments_rich index_lose_invest_rich
	
	if "`1'" == "all" global ctry_fe "i.ccode"
	if "`1'" != "all" global ctry_fe ""

	* Outcomes Labels
	foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 {
		
		if "$gname" == "taxrevenuespols" {
			* Tax revenues 
		if strpos("``i''", "transfer_hh_bin")    	loc ``i''t  "Cash transfers to constrained households"
		if strpos("``i''", "transfer_poor")    		loc ``i''t  "Cash transfers to the poorest households"
		if strpos("``i''", "transfer_all_bin")    	loc ``i''t  "Equal cash transfers to all households"
		if strpos("``i''", "reduc_personal_bin")   	loc ``i''t  "A reduction in personal income taxes"
		if strpos("``i''", "reduc_corporate_bin")   loc ``i''t  "A reduction in corporate income taxes"
		if strpos("``i''", "rebates_firms_bin")   	loc ``i''t  "Tax rebates for the most affected firms"
		if (strpos("``i''", "investments_bin") != 0 & strpos("``i''", "investments_binary") == 0)  	loc ``i''t  "Fund environmental infrastructure projects"
		if (strpos("``i''", "subsidies_bin") != 0 & strpos("``i''", "subsidies_binary") == 0)   	    loc ``i''t  "Subsidize low-carbon technologies"
		if strpos("``i''", "reduc_deficit_bin")   	loc ``i''t  "A reduction in the public deficit"
		}
	
	else {
		* Main indexes
	if strpos("``i''", "index_knowledge") 		loc ``i''t "Knowledge index"
	if strpos("``i''", "index_main_policies") 	loc ``i''t "Support for main climate policies index"
	if strpos("``i''", "index_willing_change") 	loc ``i''t "Willingness to adopt climate-friendly behavior index"
	if strpos("``i''", "index_fairness") 		loc ``i''t "Fairness of main climate policies index"
	
		* Main 3 pols 
	if strpos("``i''", "standard_binary") 		loc ``i''t "Ban on combustion-engine cars"
	if strpos("``i''", "investments_binary") 	loc ``i''t "Green infrastructure program"
	if strpos("``i''", "tax_transfers_binary")  loc ``i''t "Carbon tax with cash transfers"
		
		* Other pols 
	if strpos("``i''", "tax_fuels_binary") 			loc ``i''t "Tax on fossil fuels"
	if strpos("``i''", "ban_citycenter_binary") 	loc ``i''t "Ban of polluting vehicles in dense areas"
	if strpos("``i''", "subsidies_binary") 			loc ``i''t "Subsidies for low-carbon technologies"
	if strpos("``i''", "tax_flying_binary") 		loc ``i''t "Tax on flying (raising price by 20%)"
	if strpos("``i''", "standard_public_binary")    loc ``i''t  "Ban on combustion-engine cars w. alternatives available"  
	if strpos("``i''", "insulation_binary")    		loc ``i''t  "Mandatory and subsidized insulation of buildings"  
	

		* Global Pols 
	if strpos("``i''", "global_tax_binary")    	loc ``i''t  "Global tax on GHG emissions to" "fund global basic income" 
	if strpos("``i''", "tax_1p_binary")    		loc ``i''t "Global tax on millionnaires for" "green transition in low-income countries"
	if strpos("``i''", "assembly_binary")    	loc ``i''t  "Global democratic assembly for" "treaties on CC"
	if strpos("``i''", "climate_fund_binary")   loc ``i''t  "Global climate fund to" "finance green energy in low-income countries" 
	
		* Beef Pols 
	if strpos("``i''", "beef_tax_binary")    		loc ``i''t  "A high tax on cattle products, price x2"
	if strpos("``i''", "beef_subsidies_binary")    	loc ``i''t  "Subsidies on organic and local vegetables"
	if strpos("``i''", "beef_removal_binary")    	loc ``i''t  "Removal of subsidies for cattle farming"
	if strpos("``i''", "beef_ban_binary")   	    loc ``i''t  "Ban of intensive cattle farming"
	
		* Tax revenues 
	if strpos("``i''", "transfer_hh_bin")    	loc ``i''t  "Use revenue for cash transfers to constrained households"
	if strpos("``i''", "transfer_poor")    		loc ``i''t  "Use revenue for cash transfers to the poorest households"
	if strpos("``i''", "transfer_all_bin")    	loc ``i''t  "Use revenue for equal cash transfers to all households"
	if strpos("``i''", "reduc_personal_bin")   	loc ``i''t  "Use revenue for a reduction in personal income taxes"
	if strpos("``i''", "reduc_corporate_bin")   loc ``i''t  "Use revenue for a reduction in corporate income taxes"
	if strpos("``i''", "rebates_firms_bin")   	loc ``i''t  "Use revenue for tax rebates for the most affected firms"
	if (strpos("``i''", "investments_bin") != 0 & strpos("``i''", "investments_binary") == 0)  	loc ``i''t  "Use revenue to fund environmental infrastructure projects"
	if (strpos("``i''", "subsidies_bin") != 0 & strpos("``i''", "subsidies_binary") == 0)   	    loc ``i''t  "Use revenue to subsidize low-carbon technologies"
	if strpos("``i''", "reduc_deficit_bin")   	loc ``i''t  "Use revenue for a reduction in the public deficit"
	if strpos("``i''", "transfers_progressive_bin")   	loc ``i''t  "Carbon tax with progressive transfers"
	
		* Dis Knowledge
	if strpos("``i''", "index_knowledge_footprint") loc ``i''t "Understands emissions across activities/regions"
	if strpos("``i''", "index_knowledge_fund") loc ``i''t "Knows CC is real & caused by humans"
	if strpos("``i''", "index_knowledge_gases") loc ``i''t "Knows which gases cause CC"
	if strpos("``i''", "index_knowledge_impacts") loc ``i''t "Understands impacts of CC"
	
		* Investment Fundings
	if strpos("``i''", "invest_fund_debt")    	loc ``i''t  "Additional public debt"
	if strpos("``i''", "invest_fund_sales_tax")    		loc ``i''t  "Increase in the VAT/sales tax"
	if strpos("``i''", "invest_fund_wealth_tax")    	loc ``i''t  "Increase in taxes on the wealthiest"
	if strpos("``i''", "invest_fund_less_soc")   	loc ``i''t  "Reduction in social spending"
	if strpos("``i''", "invest_fund_less_mil")   loc ``i''t  "Reduction in military spending"
		
		* Mechanisms
	if strpos("``i''", "index_trust_govt") loc ``i''t "Trusts the government"
	if strpos("``i''", "index_problem_inequality") loc ``i''t "Believes inequality is an important problem"
	if strpos("``i''", "index_worried") loc ``i''t "Worries about the consequences of CC"
	if strpos("``i''", "index_net_zero_feasible") loc ``i''t "Believes net-zero is technically feasible"
	if strpos("``i''", "index_affected_subjective") loc ``i''t "Believes will suffer from climate change"


		* Mechanisms Indiv Pol.
	if strpos("``i''", "index_tax_positive") loc ``i''t "Believes the policy would have positive econ. effects"
	if strpos("``i''", "index_tax_emissions_plus") loc ``i''t "Believes the policy would reduce pollution"
	if strpos("``i''", "index_tax_pollution") loc ``i''t "Believes the policy would reduce emissions"
	if strpos("``i''", "index_lose_tax_self") loc ``i''t "Believes own household would lose"
	if strpos("``i''", "index_lose_tax_poor") loc ``i''t "Believes low-income earners would lose"
	if strpos("``i''", "index_lose_tax_rich") loc ``i''t "Believes high-income earners would lose"
	
	if strpos("``i''", "index_standard_positive") loc ``i''t "Believes the policy would have positive econ. effects"
	if strpos("``i''", "index_standard_em_plus") loc ``i''t "Believes the policy would reduce pollution"
	if strpos("``i''", "index_standard_pollution") loc ``i''t "Believes the policy would reduce emissions"
	if strpos("``i''", "index_lose_standard_self") loc ``i''t "Believes own household would lose"
	if strpos("``i''", "index_lose_standard_poor") loc ``i''t "Believes low-income earners would lose"
	if strpos("``i''", "index_lose_standard_rich") loc ``i''t "Believes high-income earners would lose"
	
	if strpos("``i''", "index_invest_positive") loc ``i''t "Believes the policy would have positive econ. effects"
	if strpos("``i''", "index_invest_em_plus") loc ``i''t "Believes the policy would reduce pollution"
	if strpos("``i''", "index_invest_pollution") loc ``i''t "Believes the policy would reduce emissions"
	if strpos("``i''", "index_lose_invest_self") loc ``i''t "Believes own household would lose"
	if strpos("``i''", "index_lose_invest_poor") loc ``i''t "Believes low-income earners would lose"
	if strpos("``i''", "index_lose_invest_rich") loc ``i''t "Believes high-income earners would lose"
	
		* Real stakes
	if strpos("``i''", "petition") loc ``i''t "Willing to sign petition supporting climate action"
	if strpos("``i''", "donation_binary") loc ``i''t "Willing to donate to reforestation cause (hypothetical)"
	if strpos("``i''", "wtp_binary") loc ``i''t "Willing to pay to fight global warming"
	if strpos("``i''", "donation_pct") loc ``i''t "Share of the prize willing to donate to reforestation cause"


	if strpos("``i''", "willing_mean_dummy") loc ``i''t "Willing to adopt climate-friendly behavior"
	if strpos("``i''", "fairness_mean_dummy") loc ``i''t "Fairness of main climate policies"

	}
	
	loc title_``i'' " "
		
	}
		
	loc colnum 3 
	
	loc commonleg "span size(medium)"
	if 	"$gname" == "taxrevenuespols"	loc commonleg2 "span size(2.5)"
	else loc commonleg2 "span size(medium)"
	

	*----------------------------
	* Logfile 
	*----------------------------
	cap log close 
	log using "${output}//OECD_Climate_Coefplots_${gname}_`1'$weight_extension.log", replace 
	
	global outname "${output}//OECD_Climate_Coefs_${gname}_`1'$weight_extension"
	cap erase "${outname}.txt"
	cap erase "${outname}.xls"	
	
	* Change colors 
	global p2 = "0 139 188"
	global p4 = "164 206 78"
	global p6 =  "165 0 38"
	global p4 = "92 184 92"
	
	global p2 = "0 139 188"
	global p5 ="127 72 146"
	global p6 =  "165 0 38"
	global p4 = "92 184 92"	
		
	* Shape 
	loc sym1 "O"
	loc sym2 "D"
	loc sym3 "T"
	loc sym4 "S"
	loc sym5 "X"

	
	*----------------------------
	* Graph TREATMENT (and set A)
	*----------------------------		

	
		loc toplot 
		loc count = 0 
		foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 {
			if "``i''"=="" {
			}
			else {
		loc x = `i'-1
		if "``i''" == "wtp_binary"{
			reg ``i'' $ctry_fe $setA  index_main_policies index_willing_change i.wtp_variant  $weight_option , robust 
		}
		else {
			reg ``i'' $ctry_fe $setA index_main_policies index_willing_change  $weight_option , robust 
		}
		estimates store ``i''A
		outreg2  using "${outname}.xls", dec(3) append    ci addtext(Country FE, "$ctry_fe", Variable, "``i''")		


		loc xlab `" xlab( , format(%4.2fc)) "'
		loc toplot `toplot' (``i''A, keep(index_main_policies) rename(index_main_policies = "```i''t'") offset(0.06) mlcolor("${p2}") $dotsize ms(`sym1') mfcolor("${p2}%50") ciopts( lwidth($ciwidth )  color("${p2}%50") ) )
		loc toplot `toplot' (``i''A, keep(index_willing_change) rename(index_willing_change = "```i''t'") offset(-0.06) mlcolor("${p6}") $dotsize ms(`sym3') mfcolor("${p6}%50") ciopts( lwidth($ciwidth )  color("${p6}%50") ) )

			}
			}
		loc wrap 30 
		loc wrap 55
		
		loc xscale xscale(range(-0.05)) xlab(-0.05(0.05)0.20)
		loc wrap 60 
		
		coefplot ///
		 `toplot'	 , ///
		 `line' ///
		 keep(index_*) /// 
		 $line0 /// 
		 $graphsettings4 xlabel( $labeloptions format(%4.1fc)) ylabel( $labeloptions nogrid ) `xscale' ///
		 coeflabels(index_main_policies = "Support for main climate policies index" index_willing_change = "Willingness to change behaviors index", wrap(`wrap') $coefsize ) 	///
		headings(	"Cash transfers to constrained households" = "{bf: Use carbon tax revenue for: }"   /// 
					"Additional public debt" = "{bf: Finance green investment program through: }"   /// 
					"Trusts the government" = "{bf: Trust and General Perceptions}" ///
					 "Worries about the consequences of CC" = "{bf: Views about Climate Change}" ///
					 "Understands emissions across activities/regions" =  "{bf: Climate Change Knowledge}" ///
					"Believes the policy would have positive econ. effects"  = "{bf: Effectiveness of the Climate Policy}"  /// 
					 "Believes own household would lose" = "{bf: Distributional Impacts of the Climate Policy}" ///
					 "Ban on combustion-engine cars" = "{bf: Support for Main Climate Policies}" ///
					 "Fairness of main climate policies index" = "{bf: Indices}" ///
					 "Ban on combustion-engine cars w. alternatives available" = "{bf: Support for Other Climate Policies}" ///
				 , $headsize ) ///
				legend( order(2 "Support for main climate policies index" 4 "Willingness to change behaviors index") col(`colnum') pos(12) `commonleg2' ) ///
				`xlab' /// 
				xtitle("Coefficients", $xops ) ///
				 name(gT, replace) 	
				 graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace

	cap log close 
end 
