/********************************************************************************
					               OECD Climate

Goal: Create reg plots - heterogeneities on age, gender, or income					
Date: Dec 2021
 
*********************************************************************************/
		 


/********************************************************************************

	Create Program 
	
********************************************************************************/
cap program drop graphcoefplots_het

program define graphcoefplots_het
	args 1 2 3
	
/********************************************************************************

	Load Data and Choose Parameters 

********************************************************************************/
	datasetup
	if "`1'" == "groups" {
		global ctry_fe ""
		global output 	"${gitpath}//figures//all/"
	}
	
	* Create country groupings 
	global eu DE DK FR IT PL SP UK 
	global other BR ID MX SA TR UA 
	
	* Rename 
	ren standard_public_binary standard_public_bin 
	
	* Replace w 0 so that the code runs. policies that are irrelevant for the country 
	foreach var in $set_beefpols {
	    replace `var' = 0 if country == "IA" 
	}
	
	foreach country in IA MX BR ID IA {
	    replace insulation_binary = 0 if country == "`country'"
	}

		* Outcomes Labels
	foreach i in 2  {
	
		* Main indexes
	if strpos("``i''", "index_knowledge") 		loc ``i''t "Knowledge index"
	if strpos("``i''", "index_main_policies") 	loc ``i''t "Support for main climate policies index"
	if strpos("``i''", "index_willing_change") 	loc ``i''t "Willingness to adopt climate-friendly behavior index"
	if strpos("``i''", "index_fairness") 		loc ``i''t "Fairness of main policies index"
	
		* Main 3 pols 
	if strpos("``i''", "standard_binary") 		loc ``i''t "Ban on combustion-engine cars"
	if strpos("``i''", "investments_binary") 	loc ``i''t "Green infrastructure program"
	if strpos("``i''", "tax_transfers_binary")  loc ``i''t "Carbon tax with cash transfers"
		
		* Other pols 
	if strpos("``i''", "tax_fuels_binary") 			loc ``i''t "Tax on fossil fuels"
	if strpos("``i''", "ban_citycenter_binary") 	loc ``i''t "Ban of polluting vehicles in dense areas"
	if strpos("``i''", "subsidies_binary") 			loc ``i''t "Subsidies for low-carbon technologies"
	if strpos("``i''", "tax_flying_binary") 		loc ``i''t "Tax on flying (raising price by 20%)"
	if strpos("``i''", "standard_public_binary")    loc ``i''t  "Ban on combustion-engine cars" "w. alternatives available"  
	if strpos("``i''", "insulation_binary")    loc ``i''t  "Support of mandatory and subsidized" "insulation of buildings"  
	

		* Global Pols 
	if strpos("``i''", "global_tax_binary")    	loc ``i''t  "Global tax on GHG emissions to" "fund global basic income" 
	if strpos("``i''", "tax_1p_binary")    	loc ``i''t "Global tax on millionnaires for" "green transition in low-income countries"
	if strpos("``i''", "assembly_binary")    loc ``i''t  "Global democratic assembly for" "treaties on CC"
	if strpos("``i''", "climate_fund_binary")    loc ``i''t  "Global climate fund to" "finance green energy in low-income countries" 
	
		* Beef Pols 
	if strpos("``i''", "beef_tax_binary")    		loc ``i''t  "A high tax on cattle products, price x2"
	if strpos("``i''", "beef_subsidies_binary")    loc ``i''t  "Subsidies on organic and local vegetables"
	if strpos("``i''", "beef_removal_binary")    	loc ``i''t  "Removal of subsidies for cattle farming"
	if strpos("``i''", "beef_ban_binary")   	    loc ``i''t  "Ban of intensive cattle farming"
	}
	di in red "``2't'"
	
	
	
cap log close 
log using "${output}//OECD_Climate_Coefplots_`3'_`2'$weight_extension.log", replace 

/********************************************************************************

	Graph SET A plot A: Country Heterogeneities 

********************************************************************************/
* Note: includes a dummy for treatment indicator 
	
if "`2'" != "combined_pols" {
	* Regression 
		foreach K in $countries {
		di in red "`K'"
		if "`3'" != "car_dependency" {			
			reg `2' $setA_het_grouped  $weight_option  if country =="`K'", robust level(90)
		}
		else {
			reg `2' $setA $setB  $weight_option  if country =="`K'", robust level(90)
		}
		
		estimates store `2'_`K'_A
		}

		
		macro drop toplot 
		loc toplot 
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
			
			local toplot `toplot' (`2'_`K'_A  , if(@ll<0 & @ul>0)  mlwidth(vthin) ciopts( lwidth(vthin) color(gs8%50) ) ms(O)  mlcolor(gs8%50) mlwidth(vthin) mfcolor(gs8%50)  mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor(gs8%50) mlabsize(vsmall) msize(0.5)  ) 
			local toplot `toplot' (`2'_`K'_A  , if(@ll>0 | @ul<0)   mlwidth(vthin) ciopts( lwidth(vthin) color("`i'") ) mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor("`i'") mlabsize(vsmall) mlcolor("`i'") mlwidth(vthin) mfcolor("`i'") msize(1.2) ) 
		}
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
			
			local toplot `toplot' (`2'_`K'_A  , if(@ll<0 & @ul>0)  mlwidth(vthin) ciopts( lwidth(vthin) color(gs8%50) ) ms(O)  mlcolor(gs8%50) mlwidth(vthin) mfcolor(gs8%50)  mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor(gs8%50) mlabsize(vsmall) msize(0.5) ms(T)   ) 
			local toplot `toplot' (`2'_`K'_A  , if(@ll>0 | @ul<0)  mlwidth(vthin) ciopts( lwidth(vthin) color("`i'") ) mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor("`i'") mlabsize(vsmall) mlcolor("`i'") mlwidth(vthin) mfcolor("`i'") msize(1.2) ms(T)  ) 
		}
		

			loc nlabs 2 24 64
			loc lgd label(2 "Not significant, p-val>0.10")  label(24 "Nationally representative" ) label(64 "Online representative" ) row(1) $mainlegendops

		* Block by Block 
		
		if "`3'" == "age_gender_inc" {
			global set1 age50plus
			global set2 income_Q3Q4
			global set3 female 
			loc ngraphs 1 2 3
		loc lgd label(2 "Not significant, p-val>0.10")  label(24 "Nationally representative" ) label(64 "Online representative" ) row(1) size(medium) color(black) pos(12)

		}
		else if "`3'" == "income" {
			global set1  income_Q4
			loc ngraphs 1
		}
		else if "`3'" == "age" {
			global set1  age50plus
			loc ngraphs 1
		}
		else if "`3'" == "gender" {
			global set1 female 
			loc ngraphs 1
		}
		else if "`3'" == "econ" {
			global set1 econ_veryleft econ_center
			global set2 econ_right econ_veryright
			loc ngraphs 1 2
			
			loc nlabs 1 24 64
			loc lgd label(1 "Not significant, p-val>0.10")  label(24 "Nationally representative" ) label(64 "Online representative" ) $mainlegendops
		}
		else if "`3'" == "car_dependency" {
			global set1 1.car_dependency 
			loc ngraphs 1
		}
		
		foreach i in `ngraphs'  {
		loc vari ${set`i'}
			if `i'==1  &  "`3'" == "age_gender_inc" loc tname 50+ years old
			if `i'==2  & "`3'" == "age_gender_inc" loc tname Above median income
			if `i'==3  & "`3'" == "age_gender_inc" loc tname Woman 

			if `i'==1  & "`3'" == "income" loc tname Q4
			
			if `i'==1  & "`3'" == "gender" loc tname Woman 
			
			if `i' <= 2  &  "`3'" == "econ" loc tname ""
			
			if `i'== 1  & "`3'" == "car_dependency" loc tname Uses car 

			if `i'==1  &  "`3'" == "age" loc tname 50+ years old
		* Plot 
		coefplot `toplot'  /// 
		 , drop(_cons econ_pnr ) keep( `vari'  )  xline(0, lcolor(gs8) lpattern(dash)  lwidth(thin))   ///
		 $graphsettings xlabel( $labeloptions format(%4.1fc)) ylabel( $labeloptions nogrid ) ///
			 coeflabels( ///
			 age25_34 = " " age35_49 = " " age50plus = " " ///
			 2.income_factor = " " 3.income_factor = " " 4.income_factor = " "  ///
			 female = " " ///
			 income_Q3Q4 = " " ///
			 econ_veryleft = "Very Left leaning" econ_center = "Center leaning" econ_right = "Right leaning" ///
			 econ_veryright = "Very Right leaning" 1.car_dependency = " " ///
			 ,  labsize(vsmall) notick )   	///
			 legend(order(`nlabs') `lgd'  ) /// 
				xtitle("Coefficients",  $xops ) ///
				title("{bf: `tname'}", $xops  ) /// 
				 name(gA`i', replace) 		
		}
			
		* Save graph
		if "`3'" == "age" | "`3'"=="income" { 
		grc1leg gA1, xcommon title(" ", size(small) color(gs8)) legendfrom(gA1) pos(12)
		graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
		}
		if "`3'" == "age_gender_inc" { 
		grc1leg gA3 gA1 gA2 , xcommon title(" ", size(small) color(gs8)) legendfrom(gA1) pos(12) row(1)
		graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
		}
		if "`3'" == "econ" { 
		grc1leg gA1 gA2, xcommon title(" ", size(small) color(gs8)) legendfrom(gA1) pos(12)
		graph export "${output}//Coefplot_SetA_`3'_`2'$weight_extension.${ft}", replace
		}
		else if "`3'" == "gender" {
		grc1leg gA1 , xcommon title(" ", size(small) color(gs8)) legendfrom(gA1) pos(12)
		graph export "${output}//Coefplot_SetA_`3'_`2'$weight_extension.${ft}", replace
		}
		else if "`3'" == "car_dependency" {
		grc1leg gA1 , xcommon title(" ", size(small) color(gs8)) legendfrom(gA1) pos(12)
		graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
		}
}	
else {
	foreach pol in standard_binary investments_binary tax_transfers_binary {
		foreach K in $countries {
			if "`3'" != "car_dependency" {
				reg `pol' $setA  $weight_option  if country =="`K'", robust level(90)
			}
			else {
				reg `pol' $setA $setB  $weight_option  if country =="`K'", robust level(90)
			}
			estimates store e_`pol'_`K'
		}
	}
	foreach pol in standard_binary investments_binary tax_transfers_binary {

		macro drop toplot 
		loc toplot
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
			
			local toplot `toplot' (e_`pol'_`K'  , if(@ll<0 & @ul>0)  mlwidth(vthin) ciopts( lwidth(vthin) color(gs8%50) ) ms(O)  mlcolor(gs8%50) mlwidth(vthin) mfcolor(gs8%50)  mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor(gs8%50) mlabsize(vsmall) msize(0.5)  ) 
			local toplot `toplot' (e_`pol'_`K'  , if(@ll>0 | @ul<0)   mlwidth(vthin) ciopts( lwidth(vthin) color("`i'") ) mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor("`i'") mlabsize(vsmall) mlcolor("`i'") mlwidth(vthin) mfcolor("`i'") msize(1.2) ) 
		}
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
			
			local toplot `toplot' (e_`pol'_`K'  , if(@ll<0 & @ul>0) mlwidth(vthin) ciopts( lwidth(vthin) color(gs8%50) ) ms(O)  mlcolor(gs8%50) mlwidth(vthin) mfcolor(gs8%50)  mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor(gs8%50) mlabsize(vsmall) msize(0.5) ms(T)  ) 
			local toplot `toplot' (e_`pol'_`K'  , if(@ll>0 | @ul<0)  mlwidth(vthin) ciopts( lwidth(vthin) color("`i'") ) mlab("`k'") mlabpos(1) mlabgap(*1) mlabcolor("`i'") mlabsize(vsmall) mlcolor("`i'") mlwidth(vthin) mfcolor("`i'") msize(1.2) ms(T)  ) 
		}
			
		loc nlabs 2 24 64
		loc lgd label(2 "Not significant, p-val>0.10")  label(24 "Nationally representative" ) label(64 "Online representative" ) 
			
		
		if "`pol'" == "standard_binary" loc tname "Ban on combustion-engine cars"
		if "`pol'" == "investments_binary" loc tname "Green infrastructure program"
		if "`pol'" == "tax_transfers_binary" loc tname "Carbon tax with cash transfers"

		if "`3'" == "gender" loc tokeep "female"
		if "`3'" == "car_dependency" loc tokeep "1.car_dependency"
		if "`3'" == "age" loc tokeep "age*"
		if "`3'" == "income" loc tokeep "*income_factor"
		
		
		coefplot `toplot'  /// 
		 , drop(_cons vote_pnr ) keep( `tokeep'  )  $line0  ///
		 $graphsettings xlabel( $labeloptions format(%4.1fc)) ylabel( $labeloptions nogrid ) ///
			 coeflabels( ///
			 age25_34 = "25-34 years old" age35_49 = "35-49 years old" age50plus = "50+ years old" ///
			 2.income_factor = "Q2" 3.income_factor = "Q3" 4.income_factor = "Q4"  ///
			 female = " " ///
			 vote_farleft = "Vote Far Left" vote_center = "Vote Center" vote_right = "Vote Right" ///
			 vote_farright = "Vote Far Right" 1.car_dependency = " " ///
			 ,  labsize(vsmall) notick )   	///
			 legend(title(" ",  size(small) color(gs8)) order(`nlabs') `lgd' $mainlegendops row(1) ) /// 
				xtitle("Coefficients", $xops ) ///
				title("{bf: `tname'}", $xops ) /// 
				 name(gA_`pol', replace) 		
	}
				
		grc1leg  gA_investments_binary gA_tax_transfers_binary gA_standard_binary , xcommon title(" ", size(small) color(gs8)) legendfrom(gA_standard_binary) col(3)  pos(12)
		if "`3'" != "car_dependency" {
			graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
		}
		else {
			graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace
		}
}
cap log close 
end 
		