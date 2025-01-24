/********************************************************************************
					               OECD Climate

Goal: Create Tax Revenues Graphs			
Date: Apr 2022
 
*********************************************************************************/

	do "${code}OECD_Climate_SetUp.do"
	
	global set_taxrevenues "transfer_hh_bin  transfer_poor transfer_all_bin reduc_personal_bin 	reduc_corporate_bin rebates_firms_bin	investments_bin subsidies_bin 	reduc_deficit_bin" 
	
	global gname taxrevenuespols
	
	loc 1 all 
	loc i = 1 
	foreach var in $set_taxrevenues {
		loc i = `i' +1 
		loc `i' "`var'"
		di "`i': ``i''"
	}
	
	*--------------------------
	* Set Environment 
	*--------------------------
	* Run Set-Up Program 
	datasetup 
	
	* Restrict to country 
	if "`1'" == "all" {
		}
	else {
		keep if country=="`1'"
	}
	
	
	if "`1'" == "all" global ctry_fe "i.ccode"
	if "`1'" != "all" global ctry_fe ""

	* Outcomes Labels
	foreach i in 2 3 4 5 6 7 8 9 10  {
	
		* Main indexes
	if strpos("``i''", "index_knowledge") 		loc ``i''t "Index knowledge"
	if strpos("``i''", "index_main_policies") 	loc ``i''t "Index support for main climate policies"
	if strpos("``i''", "index_willing_change") 	loc ``i''t "Willingness to adopt climate-friendly behavior index"
	if strpos("``i''", "index_fairness") 		loc ``i''t "Fairness of main climate policies index"
	
		* Main 3 pols 
	if strpos("``i''", "standard_binary") 		loc ``i''t "Ban on combustion engine cars"
	if strpos("``i''", "investments_binary") 	loc ``i''t "Green infrastructure program"
	if strpos("``i''", "tax_transfers_binary")  loc ``i''t "Carbon tax with cash transfers"
		
		* Other pols 
	if strpos("``i''", "tax_fuels_binary") 			loc ``i''t "Tax on fossil fuels"
	if strpos("``i''", "ban_citycenter_binary") 	loc ``i''t "Ban of polluting vehicles in dense areas"
	if strpos("``i''", "subsidies_binary") 			loc ``i''t "Subsidies for low-carbon technologies"
	if strpos("``i''", "tax_flying_binary") 		loc ``i''t "Tax on flying (raising price by 20%)"
	if strpos("``i''", "standard_public_binary")    loc ``i''t  "Ban on combustion engine cars" "w. alternatives available"  
	if strpos("``i''", "insulation_binary")    		loc ``i''t  "Support of mandatory and subsidized" "insulation of buildings"  
	

		* Global Pols 
	if strpos("``i''", "global_tax_binary")    	loc ``i''t  "Global tax on GHG emissions to" "fund global basic income" 
	if strpos("``i''", "tax_1p_binary")    		loc ``i''t "Global tax on millionnaires for" "green transition in low-income countries"
	if strpos("``i''", "assembly_binary")    	loc ``i''t  "Global democratic assembly for" "treaties on CC"
	if strpos("``i''", "climate_fund_binary")   loc ``i''t  "Global climate fund to" "finance green energy in low-income countries" 
	
		* Beef Pols 
	if strpos("``i''", "beef_tax_binary")    		loc ``i''t  "A high tax on cattle products, doubling beef prices"
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
	if strpos("``i''", "investments_bin")   	loc ``i''t  "Use revenue to fund environmental infrastructure projects"
	if strpos("``i''", "subsidies_bin")   	    loc ``i''t  "Use revenue to subsidize low-carbon technologies"
	if strpos("``i''", "reduc_deficit_bin")   	loc ``i''t  "Use revenue for a reduction in the public deficit"
	
	
	if strpos("``i''", "transfer_hh_bin")    	loc ``i''t  "Cash transfers to constrained households"
	if strpos("``i''", "transfer_poor")    		loc ``i''t  "Cash transfers to the poorest households"
	if strpos("``i''", "transfer_all_bin")    	loc ``i''t  "Cash transfers to all households"
	if strpos("``i''", "reduc_personal_bin")   	loc ``i''t  "Reduction in personal income taxes"
	if strpos("``i''", "reduc_corporate_bin")   loc ``i''t  "Reduction in corporate income taxes"
	if strpos("``i''", "rebates_firms_bin")   	loc ``i''t  "Tax rebates for the most affected firms"
	if strpos("``i''", "investments_bin")   	loc ``i''t  "Funding environmental infrastructures"
	if strpos("``i''", "subsidies_bin")   	    loc ``i''t  "Subsidies to low-carbon tech."
	if strpos("``i''", "reduc_deficit_bin")   	loc ``i''t  "Reduction in the public deficit"
	
	loc title_``i'' " "
		
	}
		
	loc colnum 2 
	
	loc commonleg "span size(medium)"
	if 	"$gname" == "taxrevenuespols"	loc commonleg2 "span size(2.5)"
	else loc commonleg2 "span size(medium)"

	* Colors
	global c1 "45 55 147" 
	global c2 "116 172 208"
	global c3 "254 224 144"
	global c4 "242 110 64" 
	global c5 "165 0 38"
	
	*----------------------------
	* Logfile 
	*----------------------------
	cap log close 
	log using "${output}//OECD_Climate_Coefplots_${gname}_`1'.log", replace 	
	

	*----------------------------
	* Graph TREATMENT (and set A)
	*----------------------------		

	loc toplot 
	loc lgd 
	loc nlabs 
	loc count = 0 
	foreach i in 2 3 4 5 6 7 8 9 10  {
		if "``i''"=="" {
		}
		else {
	loc x = `i'-1
	reg ``i'' $ctry_fe $setA  [w=weight], robust 
	estimates store ``i''A
		if strpos("``i''", "index")==0 {
		sum ``i'' if e(sample) & treatment == 1 [w=weight]
		loc cmean = r(mean)*100
		loc cmean: di %2.0fc `cmean'
		loc cmeanplot ": `cmean'%"
		di in red "`cmean'"
		}
		else  {
			loc cmeanplot ""
		}
	loc xlab `" xlab(-0.025(0.025)0.10 , format(%4.2fc)) "'
	loc toplot `toplot' (``i''A, offset(0.0`count') if(@ll<0 & @ul>0)  mlcolor("${p`x'}%20") $dotsize mfcolor("${p`x'}%20") ciopts( lwidth($ciwidth)  color("${p`x'}%20") ) )
	loc toplot `toplot' (``i''A, offset(0.0`count') if(@ll>0 | @ul<0)  mlcolor("${p`x'}") $dotsize mfcolor("${p`x'}%50") ciopts( lwidth($ciwidth )  color("${p`x'}%50") ) )
	
	
	loc count =`count' + 4
	loc nlabs `nlabs' `count'
	loc lgd `lgd'  label(`count' "```i''t' `cmeanplot'") 
		}
		} 
	
	coefplot ///
	 `toplot' , ///
	 keep(*treatment) /// 
	 xline(0, lcolor(gs8) lpattern(dash)  lwidth(thin)) /// 
	 $graphsettings4 xlabel( $labeloptions format(%4.1fc)) ylabel( $labeloptions nogrid ) ///
	 coeflabels(2.treatment = "Climate Impacts" 3.treatment = "Climate Policies" 4.treatment = "Both Treatments", $coefsize ) 	///
	headings(2.treatment= `" "{bf: Treatment}" "{it: Compared to Control}" "' /// 
			 , $headsize ) ///
			legend( order(`nlabs') `lgd' col(`colnum') pos(12) `commonleg2' ) ///
			`xlab' /// 
			xtitle("Coefficients", $xops ) ///
			 name(gT, replace) 	
	graph export "${gitpath}/figures/FINAL_FIGURES/FigureA20.${ft}", replace
			
	cap log close
