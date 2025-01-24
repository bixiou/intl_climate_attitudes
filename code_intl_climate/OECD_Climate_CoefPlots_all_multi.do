/********************************************************************************
					               OECD Climate

Goal: Create reg plots including multiple outcomes 				
Date: Dec 2021
 
*********************************************************************************/
		 

/********************************************************************************

	Create the Program 

********************************************************************************/

cap program drop graphcoefplots_multi

program define graphcoefplots_multi
	* Arguments 
	args 1 2 3 4 5 6 7 8 9 10 11 12 13
	
	*--------------------------
	* Set Environment 
	*--------------------------
	* Run Set-Up Program 
	datasetup
	
	* Run coeflabels 
	include "${code}OECD_Climate_Coeflabels.do"
	
	* Restrict to country 
	if "`1'" == "all" {
		}
	else {
		keep if country=="`1'"
		drop index_* 
		ren c_index_* index_* 
	}
	if "`3'" == "index_knowledge_fund" ren index_knowledge_fundamentals index_knowledge_fund
	
	if "`1'" == "all" global ctry_fe "i.ccode"
	if "`1'" != "all" global ctry_fe ""

	* Outcomes Labels
	if "$gname" == "otherpols" {
	foreach i in 2 3 4 5 6 7 8 9 10 11 12 13  {    
	* Other pols 
	if strpos("``i''", "tax_fuels_binary") 			loc ``i''t "Tax on fossil fuels" 
	if strpos("``i''", "ban_citycenter_binary") 	loc ``i''t "Ban of polluting vehicles in dense areas" 
	if (strpos("``i''", "subsidies_binary") != 0 & strpos("``i''", "beef_subsidies_binary") == 0) loc ``i''t "Subsidies for low-carbon technologies" 
	if strpos("``i''", "tax_flying_binary") 		loc ``i''t "Tax on flying (raising price by 20%)"
	if strpos("``i''", "standard_public_binary")    loc ``i''t  "Ban on combustion-engine cars w. alternatives available"  
	if strpos("``i''", "insulation_binary")    		loc ``i''t  "Support of mandatory and subsidized insulation of buildings"  
	if strpos("``i''", "transfers_progressive_bin")   	loc ``i''t  "Carbon tax w. progressive transfers"
	
	loc title_``i'' " "
	}
	}
	
	else {
	foreach i in 2 3 4 5 6 7 8 9 10 11 12 13  {
	
		* Main indexes
	if strpos("``i''", "index_knowledge") 		loc ``i''t "Knowledge index"
	if strpos("``i''", "index_main_policies") 	loc ``i''t "Support for main climate policies index"
	if strpos("``i''", "index_willing_change") 	loc ``i''t "Willingness to adopt climate-friendly behavior index"
	if strpos("``i''", "index_fairness") 		loc ``i''t "Fairness of main climate policies index"
	
		* Main 3 pols 
	if strpos("``i''", "standard_binary") 		loc ``i''t "Ban on combustion-engine cars"
	if strpos("``i''", "investments_binary") 	loc ``i''t "Green infrastructure program"
	if (strpos("``i''", "tax_transfers_binary")!=0 & "`2'" != "transfer_hh_bin")  loc ``i''t "Carbon tax with cash transfers"
	if (strpos("``i''", "tax_transfers_binary")!=0 & "`2'" == "transfer_hh_bin") loc ``i''t "{it:Support for} a Carbon tax with cash transfers"
		
		* Other pols 
	if strpos("``i''", "tax_fuels_binary") 			loc ``i''t "Tax on fossil fuels"
	if strpos("``i''", "ban_citycenter_binary") 	loc ``i''t "Ban of polluting vehicles in dense areas"
	if (strpos("``i''", "subsidies_binary") != 0 & strpos("``i''", "beef_subsidies_binary") == 0) loc ``i''t "Subsidies for low-carbon technologies"
	if strpos("``i''", "tax_flying_binary") 		loc ``i''t "Tax on flying (raising price by 20%)"
	if strpos("``i''", "standard_public_binary")    loc ``i''t  "Ban on combustion-engine cars" "w. alternatives available"  
	if strpos("``i''", "insulation_binary")    		loc ``i''t  "Support of mandatory and subsidized" "insulation of buildings"  
	

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
	if strpos("``i''", "transfers_progressive_bin")   	loc ``i''t  "Use revenue for progressive transfers"
	
		* Dis Knowledge
	if strpos("``i''", "index_knowledge_footprint") loc ``i''t "Knows emission rankings among activities/regions"
	if strpos("``i''", "index_knowledge_fund") loc ``i''t "Knows CC is real, human-made and its dynamics"
	if strpos("``i''", "index_knowledge_gases") loc ``i''t "Knows which gases cause CC"
	if strpos("``i''", "index_knowledge_impacts") loc ``i''t "Knows impacts of CC"
	
		* Investment Fundings
	if strpos("``i''", "invest_fund_debt")    	loc ``i''t  "Additional public debt"
	if strpos("``i''", "invest_fund_sales_tax")    		loc ``i''t  "Increase in the VAT/sales tax"
	if strpos("``i''", "invest_fund_wealth_tax")    	loc ``i''t  "Increase in taxes on the wealthiest"
	if strpos("``i''", "invest_fund_less_soc")   	loc ``i''t  "Reduction in social spending"
	if strpos("``i''", "invest_fund_less_mil")   loc ``i''t  "Reduction in military spending"
		
		* Main mechanisms
	if strpos("``i''", "index_pos_econ") loc ``i''t "Believes the policy would have positive econ. effects"
	if strpos("``i''", "index_pol_em") loc ``i''t "Believes the policy would reduce GHG emissions"
	if strpos("``i''", "index_lose_self") loc ``i''t "Believes own household would lose"
	if strpos("``i''", "index_lose_poor") loc ``i''t "Believes low-income earners would lose"
	
	
		* Main mechanisms: Tax
	if strpos("``i''", "index_tax_pos") loc ``i''t "Believes the policy would have positive econ. effects"
	if strpos("``i''", "index_tax_em") loc ``i''t "Believes the policy would reduce GHG emissions"
	if strpos("``i''", "index_tax_self") loc ``i''t "Believes own household would lose"
	if strpos("``i''", "index_tax_poor") loc ``i''t "Believes low-income earners would lose"
	
		* Main mechanisms: Invest
	if strpos("``i''", "index_invest_pos") loc ``i''t "Believes the policy would have positive econ. effects"
	if strpos("``i''", "index_invest_em") loc ``i''t "Believes the policy would reduce GHG emissions"
	if strpos("``i''", "index_invest_self") loc ``i''t "Believes own household would lose"
	if strpos("``i''", "index_invest_poor") loc ``i''t "Believes low-income earners would lose"
	
		* Main mechanisms: Standard
	if strpos("``i''", "index_standard_pos") loc ``i''t "Believes policies would have positive econ. effects"
	if strpos("``i''", "index_standard_em") loc ``i''t "Believes policies would reduce GHG emissions"
	if strpos("``i''", "index_standard_self") loc ``i''t "Believes own household would lose"
	if strpos("``i''", "index_standard_poor") loc ``i''t "Believes low-income earners would lose"
	
	
		* Indifference
	if strpos("``i''", "main_pol_indif") loc ``i''t "Indifferent to all main climate policies"
	if strpos("``i''", "standard_indif") loc ``i''t "Indifferent to a ban on combustion-engine cars"
	if strpos("``i''", "investments_indif") loc ``i''t "Indifferent to a green infrastructure program"
	if strpos("``i''", "tax_transfers_indif") loc ``i''t "Indifferent to a carbon tax with cash transfers"

		* Future
	if strpos("``i''", "cc_impacts_extinction_bin") loc ``i''t "Likely that an unbridled CC causes extinction of humankind"
	if strpos("``i''", "index_bad_things_cc") loc ``i''t "Index bad consequences of CC"
	if strpos("``i''", "future_poorer_bin") loc ``i''t "World will be poorer in 100 years"
	if strpos("``i''", "net_zero_not_feasible_bin") loc ``i''t "Net-zero with satisfactory standards of living not technically feasible"
	if strpos("``i''", "index_bad_things_med") loc ``i''t "Index bad consequences of CC above median"
	if strpos("``i''", "index_bad_things_mean") loc ``i''t "Index bad consequences of CC above mean"
	if strpos("``i''", "bad_things_cc_dum_sum") loc ``i''t "CC will have bad consequences"
	if strpos("``i''", "bad_things_cc_dum_mean") loc ``i''t "Bad consequences dummy Mean"

	loc title_``i'' " "
		
	}
	}
		
	loc colnum 2 
	if ("$gname" == "fair_support_willing" |  "$gname" == "invest_funding" | "$gname" == "otherpols"	 ) loc colnum 3
		
	if "$gname" != "otherpols"	 loc commonleg "col(`colnum') span   keygap(0.5)  ring(1)   colgap(1.5) rowgap(1)   size(2.5)   symysize(0.85)   symxsize(0.85) margin(0 0 0 0) linegap(0)"
	if "$gname" == "otherpols"	 loc commonleg "col(3) span   keygap(0.5)  ring(1)   colgap(1.5) rowgap(1)   size(2.5)   symysize(0.85)   symxsize(0.85) margin(0 0 0 0) linegap(0)"

	if 	"$gname" == "taxrevenuespols"	loc commonleg2 "span size(vsmall)"
	else loc commonleg2 "span size(small)"
	
	
	
	if ("$gname" == "set_main_mech") &  ("$gname" != "invest_funding") {
		ren index_positive_economy index_pos_econ
		ren index_policies_emissions_plus index_pol_em
		ren index_lose_policies_subjective index_lose_self
		ren index_lose_policies_poor index_lose_poor
	}
	
	if ("$gname" == "set_main_mech_tax"){
		ren index_tax_transfers_positive index_tax_pos
		ren index_tax_emissions_plus index_tax_em
		ren index_lose_tax_transfers_self index_tax_self
		ren index_lose_tax_transfers_poor index_tax_poor
	}

	if ("$gname" == "set_main_mech_standard"){
		ren index_standard_positive index_standard_pos
		ren index_standard_emissions_plus index_standard_em
		ren index_lose_standard_self index_standard_self
		ren index_lose_standard_poor index_standard_poor
	}
	
	if ("$gname" == "set_main_mech_invest"){
		ren index_investments_positive index_invest_pos
		ren index_investments_emissions_plus index_invest_em
		ren index_lose_investments_self index_invest_self
		ren index_lose_investments_poor index_invest_poor
	}

	*----------------------------
	* Logfile 
	*----------------------------
	cap log close 
	log using "${output}//OECD_Climate_Coefplots_${gname}_`1'$weight_extension.log", replace 	
	
	* Change colors 
	if "$gname"=="beefpols" | "$gname"=="transferpols" | "$gname"=="set_main_mech" | "$gname" == "set_future_bin" | "$gname"=="set_main_mech_tax" | "$gname"=="set_main_mech_standard" | "$gname"=="set_main_mech_invest" {
	    global p4 "165 0 38"
		global p2 "92 184 92"
		global p3 "253 174 97"
	} 
	
	if "$gname" == "set_indif_main" {
		global p1 =  "165 0 38"
		global p2 = "92 184 92"
		global p3 = "0 139 188"
	}
	
	
	if "$gname"=="invest_funding"    {
	    global p4 "165 0 38"
		global p2 "164 206 78"
		global p3 "253 174 97"
		global p5 "0 58 79"
	} 
	
	if "$gname"=="fair_support_willing" | "$gname"=="reducetax" | "$gname"=="otherrevs" {
	    global p2 = "165 0 38"
		global p3 = "164 206 78"
	}
	
	
	if "$gname"=="otherpols"  {
	    global p4 "165 0 38"
		global p2 "164 206 78"
		global p3 "253 174 97"
		global p5 "0 58 79"
		global p7 ="127 72 146"
	} 	

	*----------------------------
	* Graph SET A plot A
	*----------------------------
	
	if "$gname" != "fair_support_willing" {
		loc sym1 "O"
		loc sym2 "D"
		loc sym3 "T"
		loc sym4 "S"
		loc sym5 "X"

		loc toplot 
		loc lgd 
		loc nlabs 
		loc count = 0 
		foreach i in 2 3 4 5 6 7 8 9 10 11 12 13  {
			if "``i''"=="" {
			}
			else {
		loc x = `i'-1
		reg ``i'' $ctry_fe $setA  $weight_option , robust 
		estimates store ``i''A
		loc toplot `toplot' (``i''A, offset(0.0`count') ms(`sym`x'') mlcolor("${p`x'}") mlwidth(vthin) mfcolor("${p`x'}%50") ciopts( lwidth($ciwidth )  color("${p`x'}%50") ) )
		loc count =`count' + 2
		loc nlabs `nlabs' `count'
		loc lgd `lgd'  label(`count' "```i''t'") 
			}
			}
		loc xlab (, format(%4.2fc))
		
		
		
		if ("$gname" != "set_main_mech") {
			loc to_drop _cons econ_pnr gender_other
			loc to_keep age* female *children *income_factor *employment_agg *educ* econ*
		}
		if ("$gname" == "invest_funding") {
			loc to_drop _cons econ_pnr age* gender_other 
			loc to_keep female *children *income_factor *employment_agg *educ* econ*  *treat*
		}
		if	"`1'"!= "all" {
			loc to_drop _cons econ_pnr gender_other 
			loc to_keep age* female *income_factor *children  *educ* econ*
		}
		else {
		loc to_drop _cons econ_pnr age* gender_other 
		loc to_keep  female *children *income_factor *employment_agg *educ* econ* 
		}

		if ("$gname" == "set_indif_main") {
			loc to_drop _cons econ_pnr gender_other 
			loc to_keep female *children *income_factor *employment_agg *educ* econ*  *treat* age*
		}
		
		if ("$gname" == "set_future_bin") {
			loc to_drop _cons econ_pnr gender_other 
			loc to_keep female *children *income_factor *employment_agg *educ* econ* age*
		}
		
		 coefplot ///
		 `toplot', ///	 
		 drop(`to_drop') keep(`to_keep')  $line0 $dotsize   ///
		 $graphsettings1 xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
		 coeflabels(`coeflabels_A' , $coefsize ) 	///
		headings( `coefheads_A' , $headsize ) ///
				legend( order(`nlabs') `lgd'  pos(12) `commonleg' ) ///
				xtitle("Coefficients", $xops ) ///
				 name(gA, replace) 



		
		*------------------------------
		* Graph SET AB plot B 
		*------------------------------
		
		loc toplot 
		loc lgd 
		loc nlabs 
		loc count = 0 
		foreach i in 2 3 4 5 6 7 8 9 10 11 12 13  {
			if "``i''"=="" {
			}
			else {
		loc x = `i'-1
		reg ``i'' $ctry_fe $setA $setB  $weight_option , robust 
		estimates store ``i''AB
		loc toplot `toplot' (``i''AB, offset(0.0`count') ms(`sym`x'')  mlcolor("${p`x'}") mlwidth(vthin) mfcolor("${p`x'}%50") ciopts( lwidth($ciwidth )  color("${p`x'}%50") ) )
		loc count =`count' + 2
		loc nlabs `nlabs' `count'
		loc lgd `lgd'  label(`count' "```i''t'") 
			}
			}
			
		 coefplot ///
		 `toplot', ///	 
	drop(_cons ) keep( *agglo* *binary_availability_transport *binary_gas_expenses *binary_heating_expenses *car_dependency *flights_agg_1 *polluting_sector *owner *beef_binary )  $line0 $dotsize   /// 
		 $graphsettings xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
		coeflabels(`coeflabels_B' , $coefsize ) 	///
		headings(`coefheads_B', $headsize ) ///
				legend(off) ///
				xtitle("Coefficients", $xops ) ///
				 name(gB, replace)  
		
		*-------------------------------
		* Figure 1: Combine A and AB 
		*-------------------------------
		
		
		if ("$gname" == "set_future_bin") {
				grc1leg gA, xcommon title("{bf: `title_`2''}", size(small) color(black)) legendfrom(gA) pos(12) 
				graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
		}
		else {
				grc1leg gA gB, xcommon title("{bf: `title_`2''}", size(small) color(black)) legendfrom(gA) pos(12) 
				graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
		}
	}
	
	
	*---------------------------------------------------------
	* Graph SET AC plot C : Only for support, not knowledge 
	*---------------------------------------------------------
	if "$gname" == "fair_support_willing" {
		
	* Change Set C for specific policies 
	
	foreach i in 2 3 4 5 6 7  8 9 10 11 12 13 {
		if ("$gname" == "transferpols" | "$gname" == "transfersall" | "$gname" == "taxrevenuespols" | "$gname" == "reducetax" | "$gname" == "otherrevs" ) | "$gname"=="taxpols"	{
		global setc_`i' ""
		cap ren index_tax_transfers_positive index_positive 
		cap ren index_lose_tax_transfers_poor index_poor
		cap ren index_lose_tax_transfers_rich index_rich 
		cap ren index_lose_tax_transfers_self index_self 
		cap ren index_tax_transfers_effective index_effective  
		
		cap ren index_tax_emissions_plus index_emissions_plus
		cap ren index_tax_emissions index_emissions
		cap ren index_tax_transfers_pollution index_pollution
		
		cap ren index_fairness_tax_transfers index_fair
		
		global setc_`i' $setCdis_policy 
		}
		else if ("$gname" == "standarpols")	{
		global setc_`i' ""
		cap ren index_standard_positive index_positive 
		cap ren index_lose_standard_poor index_poor
		cap ren index_lose_standard_rich index_rich 
		cap ren index_lose_standard_self index_self 
		cap ren index_standard_effective index_effective 
		
		cap ren index_standard_emissions_plus index_emissions_plus
		cap ren index_standard_emissions index_emissions
		cap ren index_standard_pollution index_pollution
		
		cap ren index_fairness_standard index_fair
		
		global setc_`i' $setCdis_policy 
		}
		else {
			global setc_`i' $setCdis
		}
	}
	
	
	* Disaggregated Panel C: Emissions+
	loc toplot 
	loc lgd 
	loc nlabs 
	loc count = 0 
	foreach i in 2 3 4 5 6 7  8 9 10 11 12 13 {
		if "``i''"=="" {
		}
		else {
	loc x = `i'-1
	reg ``i'' $ctry_fe $setA ${setc_`i'}  $weight_option , robust 
	estimates store ``i''AC
	loc toplot `toplot' (``i''AC, offset(0.0`count') ms(`sym`x'')  mlcolor("${p`x'}%50") mlwidth(vthin) mfcolor("${p`x'}%50") ciopts( lwidth($ciwidth )  color("${p`x'}") ) )
	loc count =`count' + 2
	loc nlabs `nlabs' `count'
	loc lgd `lgd'  label(`count' "```i''t'") 
		}
		}
	
	
	 coefplot ///
	 `toplot' , ///	
	 drop(_cons $setA *ccode *treat* *educ* *inc* *emp* )  $line0 $dotsize    ///
	  xlabel( $labeloptions format(%4.2fc)) ylabel( $labeloptions nogrid ) ///
coeflabels( `coeflabels_Cdis'	 , $coefsize  )  ///
	 headings( `coefheads_Cdis'	 , $headsize ) ///
			title("{bf:`title_`2''}" " " " "    , size(small) color(black)) ///
			legend( order(`nlabs') `lgd' col(`colnum') pos(12) `commonleg' ) ///
			xtitle("Coefficients", $xops ) ///
			$graphsettings4 ///
			name(gC, replace) ///
			`addnote'
			
			grc1leg gC, xcommon title("{bf: `title_`2''}",  size(small) color(black)) legendfrom(gC)  pos(12) ring(0) $cgraphsettings

			graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
				
			
	}
	

	cap log close 
end 


	