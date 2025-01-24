/********************************************************************************
					               OECD Climate

Goal: Create reg plots						
Date: 		Dec 2021
 
*********************************************************************************/
		 

/********************************************************************************

	0) Preface

********************************************************************************/
* Set Environments 
	clear 
	set more off 
	program drop _all 
	set type double 
	set matsize 10000
	cap log close 
	
		
	
/********************************************************************************

	Create the Program to Set Up The Data  

********************************************************************************/

cap program drop datasetup 

program define datasetup 
	
	*--------------------------
	* Set Environment 
	*--------------------------
	* Set Graph Settings

		* Final Graph settings 
			global mainlegendops "pos(12) size(medium) color(black)"
			global comblegendops "pos(12) size(small) color(black)"
			global xops " col(black) size(3)"
			global headsize "labsize(3) labcolor(black)"
			global coefsize "labsize(1) labcolor(black)"
			global coefsize2 "labsize(2.5) labcolor(black)"
			global labeloptions = ", labsize(3) labcolor(black) glw(vvthin) glc(black) glp(shortdash) gmax angle(horizontal) tlw(vthin) tl(*.5) tlc(black) "
			global graphsettings   "graphregion(fcolor(white) lcolor(white) margin( 1 1 1 1 ) ) plotregion( fcolor(none) lcolor(none) margin(1 1 1 1) ) ysize(12) xsize(12)"
			global agraphsettings   "graphregion(fcolor(white) lcolor(white) margin( 1 1 1 1 ) ) plotregion( fcolor(none) lcolor(none) margin(1 r=2 1 1) ) ysize(12) xsize(12)"
			global cgraphsettings   "graphregion(fcolor(white) lcolor(white) margin( 1 1 1 1 ) ) plotregion( fcolor(none) lcolor(none) margin(l=1 r=1 b=1 t=3) ) ysize(12) xsize(12)"
			global graphsettings_combined4  "graphregion(fcolor(white) lcolor(white) margin( 1 1 1 1 ) ) plotregion( fcolor(none) lcolor(none) margin(0 0 0 0) ) ysize(10) xsize(63)"
			global graphsettings_combined  "graphregion(fcolor(white) lcolor(white) margin( 0 2 1 1 ) ) plotregion( fcolor(none) lcolor(none) margin(0 1 1 1) ) ysize(10) xsize(20)"
			global graphsettings_combined2  "graphregion(fcolor(white) lcolor(white) margin( 1 2 1 1 ) ) plotregion( fcolor(none) lcolor(none) margin(1 1 1 1) ) ysize(10) xsize(21)"

			global line0 "xline(0, lcolor(black) lpattern(dash)  lwidth(thin))"
			global dotsize "msize(1.5)  mlwidth(vthin)"
			global ciwidth "medthin"
			graph set window fontface "lmroman10-regular" 		

			
			global p1 = "0 139 188"
			global p2 = "253 174 97"
			global p3 ="0 58 79"
			global p4 ="127 72 146"
			global p5 ="164 206 78"
			global p6 ="43 143 67"
			global p7 ="0 115 162"
			global p8 = "165 0 38"
			global p9 ="255 212 0"
			global p10 ="107 189 69"
			
			
	

		if "`1'"=="all" {
		global output 	"${gitpath}//figures//all/"
		}
		else if "`1'"!="all" {
		global output 	"${gitpath}//figures//$choosecountry/"
		cap mkdir "${output}"
		}
		
	* Open data 
	use "${data}all.dta" , clear
  

	global good_data AU CA DE DK SP FR IT JP SK PL UK US 
	global bad_data  BR CN IA ID MX TR UA SA

	
	gen oecd = 0 
	foreach C in $oecd {
		replace oecd = 1 if country == "`C'"
	}
	
		
	* Create country groupings 
	gen 	countrygroup = 1 if country =="US"
	replace countrygroup = 2 if inlist(country, "DE", "DK", "FR", "IT", "PL", "SP" , "UK")
	replace countrygroup = 3 if inlist(country, "SK", "JP")
	replace countrygroup = 4 if inlist(country, "CA", "AU")
	replace countrygroup = 5 if country =="CN"
	replace countrygroup = 6 if country == "IA"
	replace countrygroup = 7 if countrygroup ==. 
	
	lab def grp 1 "United States" 2 "EU-United Kingdom" 3 "Korea-Japan" 4 "Canada-Australia" 5 "China" 6 "India" 7 "Other Middle Income", replace
	lab val countrygroup grp 
	lab var countrygroup "Country Grouping"
	
	encode country , gen(ccode)
	

	*--------------------------
	* Choose sets 
	*--------------------------
	* Set A 
		* Vote 
		tab vote_agg, m 
		gen vote_agg0 = vote_agg == 0 
		gen vote_agg_left = vote_agg < 0 & vote_agg!=-.1
		gen vote_agg_right = vote_agg > 0 
		gen vote_agg_pnr = vote_agg ==-.1 
		
		gen vote_farleft = vote_agg == -2 
		gen vote_left = vote_agg == -1
		gen vote_center = vote_agg == 0 
		gen vote_right = vote_agg == 1 
		gen vote_farright = vote_agg == 2
		gen vote_pnr = vote_agg == -.1  
		
		* Left-right
		gen econ_veryleft = left_right == -2 
		gen econ_left = left_right == -1
		gen econ_center = left_right == 0 
		gen econ_right = left_right == 1 
		gen econ_veryright = left_right == 2
		gen econ_pnr = left_right == -.1  
		
		* Age 
		* Change age for Canada 
		replace age = "18-24" if age == "Below 18" & country =="CA" 
		
		gen age18_24 = age=="18-24"
		gen age25_34 = age=="25-34"
		gen age35_49 = age=="35-49"
		gen age50plus = age=="50-64" | age=="65+"
		
		
		encode age, gen(agecode)
		recode agecode (5=4) /*Note: Combined last two age categories */
		
		* College 
		recode college (2 = 0 "College Degree") (1 = 1 "No college"), gen(college_2)
		drop college
		rename college_2 college
		
		* Education
		drop educ_categ
		gen 	educ_categ = 1 if education <= 2 
		replace educ_categ = 2 if inlist(education, 3,4)
		replace educ_categ = 3 if inlist(education, 5, 6)
		assert educ_categ  ==. if education==. 
		
		* Gender
		gen gender_other = 0
		replace gender_other = 1 if gender == "Other"
		
		* Income (for robustness)
		gen income_Q2 = 0 if income != 2
		replace income_Q2 = 1 if income == 2
		
		gen income_Q3Q4 = 0 if income <= 2
		replace income_Q3Q4 = 1 if income >= 3
		
		gen income_Q4 = 0 if income <= 3
		replace income_Q4 = 1 if income == 4

		global setA ""
		foreach var in "female" "gender_other" "children" "age25_34" "age35_49" "age50plus" "i.income_factor"  "i.educ_categ" "econ_veryleft" "econ_center"  "econ_right" "econ_veryright" "econ_pnr" "i.treatment"    {
			global setA $setA `var'
		}
		
		global setA_het_grouped ""
		foreach var in "female" "gender_other" "children" "age50plus" "income_Q2" "income_Q3Q4"  "i.educ_categ" "econ_veryleft" "econ_center"  "econ_right" "econ_veryright" "econ_pnr" "i.treatment"    {
			global setA_het_grouped $setA_het_grouped `var'
		}
	
		* Set A: WTP variant
		global setA_wtp $setA i.wtp_variant

	
	* Set B 
		gen binary_availability_transport = availability_transport > 0 
		assert availability_transport !=. 
		
		ren gas_expenses_above_median 		binary_gas_expenses
		ren heating_expenses_above_media* 	binary_heating_expenses
			
		* Replace w 0s so that the index gets dropped from the regs rather than the observations
		bys country: egen minheat = min(binary_heating)
		tab country if minheat ==. 
		replace binary_heating = 0 if  minheat ==. 
		drop minheat 

		gen flights_agg_1 = flights_agg > 1 & flights_agg !=. 
	
		gen beef_binary = frequency_beef>=1 
		replace beef_binary = . if frequency_beef ==. 
		
		global setB ""
		foreach var in "i.agglo_categ"  "i.binary_availability_transport" "i.car_dependency"  "i.binary_gas_expenses"   "i.binary_heating_expenses"  "i.flights_agg_1"   "i.polluting_sector" "i.beef_binary"       "i.owner"    {
			global setB $setB `var'
		}
		
		* Set C: simplified 
		ren index_lose_policies_subjecti* index_lose_policies_subjective
		
		global setCdis  ""
		foreach var in "index_trust_govt" "index_problem_inequality" "index_worried"  "index_net_zero_feasible"  "index_affected_subjective" "index_knowledge_footprint" "index_knowledge_fundamentals" "index_knowledge_gases" "index_knowledge_impacts"  "index_positive_economy"          "index_policies_pollution"   "index_policies_emissions_plus"  "index_lose_policies_subjective"  "index_lose_policies_poor"       "index_lose_policies_rich" {
			sum `var'
			global setCdis $setCdis  `var'
		}	
			
		global setCdis_policy ""
		foreach var in "index_trust_govt" "index_problem_inequality"   "index_worried" "index_net_zero_feasible" "index_affected_subjective"   "index_knowledge_footprint" "index_knowledge_fundamentals" "index_knowledge_gases" "index_knowledge_impacts"   "index_positive "     "index_pollution" "index_emissions_plus"   "index_self"  "index_poor"       "index_rich" {
		global setCdis_policy $setCdis_policy  `var'
			}
			
		* Rename Variables for Policy Specific indexes 

		ren index_tax_transfers_positiv* 	index_tax_transfers_positive
		ren index_standard_positive* 		index_standard_positive
		ren index_investments_positive* 	index_investments_positive
		
		ren index_lose_tax_transfers_po* index_lose_tax_transfers_poor
		ren index_lose_tax_transfers_ric* index_lose_tax_transfers_rich 
		
		ren index_lose_tax_transfers_su* index_lose_tax_transfers_self
		ren index_lose_investments_subj* index_lose_investments_self
		ren index_lose_standard_subjecti* index_lose_standard_self 		
		
		ren index_c_tax_transfers_posit* 	index_c_tax_transfers_positive
		ren index_c_standard_posit* 		index_c_standard_positive
		ren index_c_investments_posit* 	index_c_investments_positive
		
		ren index_c_lose_tax_transfers_po* index_c_lose_tax_transfers_poor
		ren index_c_lose_tax_transfers_ric* index_c_lose_tax_transfers_rich 

		ren index_c_lose_tax_transfers__* index_c_lose_tax_transfers_self
		ren index_c_lose_investments_s* index_c_lose_investments_self
		ren index_c_lose_standard_s* index_c_lose_standard_self
		ren index_c_investments_emissio_8* index_c_investments_emiss_plus
		
		* Rename Indexes: country 
		ren index_c_* c_index_*
			
		*-----------------------
		* Outcomes  
		*-----------------------
		* Main Policies
		foreach var in standard investments tax_transfers {
			gen `var'_binary = `var'_support > 0 
			replace `var'_binary = . if `var'_support == . 
			
			gen `var'_indif = `var'_support == 0
			replace `var'_indif = . if `var'_support == .
			
			gen `var'_oppose = `var'_support < 0
			replace `var'_oppose = . if `var'_support == .
		}
		* Add dummies for indifference/support/oppose main policies
		gen main_pol_support = (standard_support > 0 & investments_support > 0 & tax_transfers_support > 0)
		replace main_pol_support = . if standard_support == . | investments_support == . | tax_transfers_support == .
		
		gen main_pol_indif = (standard_support == 0 & investments_support == 0 & tax_transfers_support == 0)
		replace main_pol_indif = . if standard_support == . | investments_support == . | tax_transfers_support == .
		
		gen main_pol_oppose = (standard_support < 0 & investments_support < 0 & tax_transfers_support < 0)
		replace main_pol_oppose = . if standard_support == . | investments_support == . | tax_transfers_support == .
		* Beef outcomes 
		ren beef_subsidies_vegetables_* beef_subsidies_vegetables
		ren beef_subsidies_removal_suppo* beef_removal
		ren beef_tax_support beef_tax
		ren beef_ban_intensive_support beef_ban_intensive
		
		global beefoutcomes "beef_tax beef_subsidies_vegetables  beef_removal beef_ban_intensive"
		
			foreach var in $beefoutcomes {
				sum `var'
				gen 	`var'_binary = `var'> 0 
				replace `var'_binary = . if `var' == . 
				tab `var' `var'_binary 
			} 
		
		ren beef_subsidies_vegetables_binary beef_subsidies_binary
		ren beef_ban_intensive_binary beef_ban_binary
		global beefoutcomes "beef_tax_binary beef_subsidies_binary  beef_removal_binary beef_ban_binary"
		
		* Global Policies 
		global globalpols "global_tax_support global_assembly_support tax_1p_support policy_climate_fund" 
			foreach var in $globalpols {
				gen `var'_binary = `var'  > 0 
				replace `var'_binary = . if `var'  == .
			}
			ren global_assembly_support_binary assembly_binary
			ren global_tax_support_binary global_tax_binary
			ren policy_climate_fund_binary climate_fund_binary 
			ren tax_1p_support_binary tax_1p_binary
		global globalpols "global_tax_binary assembly_binary tax_1p_binary climate_fund_binary" 
		
		
		* Alternatives
		gen 	tax_fuels_binary = policy_tax_fuels > 0 
		replace tax_fuels_binary = . if policy_tax_fuels ==. 
		
		gen 	ban_citycenter_binary = policy_ban_city_centers > 0 
		replace ban_citycenter_binary = . if policy_ban_city_centers==. 
		
		gen 	subsidies_binary = policy_subsidies >0 
		replace subsidies_binary = . if policy_subsidies ==. 
		
		gen 	tax_flying_binary = policy_tax_flying > 0 
		replace tax_flying_binary = . if policy_tax_flying==. 
		
		gen 	standard_public_binary = standard_public_transport_s >0 
		replace standard_public_binary = . if standard_public_transport_s == .
		
		gen insulation_binary = insulation_support >0 
		replace insulation_binary = . if insulation_support==. 
		
		global otherpols "tax_fuels_binary ban_citycenter_binary subsidies_binary tax_flying_binary standard_public_binary insulation_binary"
				foreach var in $otherpols {
				sum `var' 
			}
			
		* Tax w diff sources of revenue	
		foreach var in ///
			transfer_constrained_hh  transfer_poor transfer_all ///
			reduction_personal_tax 	reduction_corporate_tax rebates_affected_firms ///
			investments	subsidies 	reduction_deficit {
				assert tax_`var'>=-2 & tax_`var' <= 2 if tax_`var'!=. 
				gen 	`var'_bin = tax_`var'  > 0 
				replace `var'_bin = . if tax_`var'  == .
			}
			ren transfer_constrained_hh_bin transfer_hh_bin 
			ren reduction_personal_tax_bin reduc_personal_bin 
			ren reduction_corporate_tax_bin reduc_corporate_bin
			ren rebates_affected_firms_bin rebates_firms_bin
			ren reduction_deficit reduc_deficit_bin
			* Only available for DEU or UKR: tax_ecological_protection tax_more_commuter_allowance tax_reduction_eeg_umlage 
			
		* Additional tax variable 
ren tax_transfers_progressive_s* tax_transfers_progressive
		foreach var in transfers_progressive {
				assert tax_`var'>=-2 & tax_`var' <= 2 if tax_`var'!=. 
				gen 	`var'_bin = tax_`var'  > 0 
				replace `var'_bin = . if tax_`var'  == .	
		}
	
	* Burden Share Policies 
		gen 	global_quota_binary = global_quota> 0 & global_quota!=. 
		replace global_quota_binary = . if global_quota==. 
		
		foreach var in population emissions historical damages {
			assert burden_share_`var'>=-2 & burden_share_`var' <= 2 if burden_share_`var'!=. 
			gen 	bs_`var'_binary = burden_share_`var'  > 0 
			replace bs_`var'_binary = . if burden_share_`var'  == .
		}
		
		foreach var in population emissions historical damages {
			assert burden_share_ing_`var'>=-2 & burden_share_ing_`var' <= 2 if burden_share_ing_`var'!=. 
			gen 	bs2_`var'_binary = burden_share_ing_`var'  > 0 
			replace bs2_`var'_binary = . if burden_share_ing_`var'  == .
		}
		
		foreach var in population emissions historical damages {
			sum bs_`var'_binary if inlist(country, "DK", "FR", "US")
			replace bs_`var'_binary = bs2_`var'_binary if inlist(country, "DK" , "FR" , "US")
		}
		
		* WTP
		gen wtp_binary = 1 if wtp == 1
		replace wtp_binary = 0 if wtp == 0
		
		* Donation
		gen donation_binary = 0 if !mi(donation)
		replace donation_binary = 1 if donation_percent > 0
		
		gen donation_pct = donation_percent/100
		
		* Investment funding
		ren investments_funding_debt			invest_fund_debt
		ren investments_funding_sales_tax 		invest_fund_sales_tax
		ren investments_funding_wealth_tax 		invest_fund_wealth_tax 
		ren investments_funding_less_social 	invest_fund_less_soc
	    ren investments_funding_less_* 		invest_fund_less_mil
		
		// Willing and Fairness dummies
		* Willing
		gen willing_limit_heating_temp = willing_limit_heating
		replace willing_limit_heating_temp = 0 if willing_limit_heating_temp == -.1

		gen willing_limit_flying_temp = willing_limit_flying
		replace willing_limit_flying_temp = 0 if willing_limit_flying_temp == -.1

		gen willing_limit_driving_temp = willing_limit_driving
		replace willing_limit_driving_temp = 0 if willing_limit_driving_temp == -.1

		gen willing_limit_beef_temp = willing_limit_beef
		replace willing_limit_beef_temp = 0 if willing_limit_beef_temp == -.1

		gen willing_electric_car_temp = willing_electric_car
		replace willing_electric_car_temp = 0 if willing_electric_car_temp == -.1

		gen willing_mean = (willing_limit_heating_temp + willing_limit_flying_temp + willing_limit_driving_temp + willing_limit_beef_temp + willing_electric_car_temp) / 5
		gen willing_mean_dummy = 0
		replace willing_mean_dummy = 1 if willing_mean >= 1
		replace willing_mean_dummy = . if willing_limit_heating_temp == . & willing_limit_flying_temp == . & willing_limit_driving_temp == . & willing_limit_beef_temp == . & willing_electric_car_temp == .
		
		drop willing_limit_heating_temp willing_limit_flying_temp willing_limit_driving_temp willing_limit_beef_temp willing_electric_car_temp

		* Fairness
		gen standard_fair_temp = standard_fair
		replace standard_fair_temp = 0 if standard_fair_temp == -.1

		gen tax_transfers_fair_temp = tax_transfers_fair
		replace tax_transfers_fair_temp = 0 if tax_transfers_fair == -.1

		gen investments_fair_temp = investments_fair
		replace investments_fair_temp = 0 if investments_fair_temp == -.1

		gen fairness_mean = (standard_fair_temp + tax_transfers_fair_temp + investments_fair_temp) / 3
		gen fairness_mean_dummy = 0
		replace fairness_mean_dummy = 1 if fairness_mean >= 1
		replace fairness_mean_dummy = . if standard_fair_temp == . & tax_transfers_fair_temp == . & investments_fair_temp == .
		
		drop standard_fair_temp tax_transfers_fair_temp investments_fair_temp
		
		* Future
		gen cc_impacts_extinction_bin = cc_impacts_extinction > 0
		replace cc_impacts_extinction_bin = . if cc_impacts_extinction == -.1
		
		gen future_poorer_bin = future_richness < 0
		replace future_poorer_bin = . if future_richness == -.1
		
		gen net_zero_not_feasible_bin = net_zero_feasible < 0
		replace net_zero_not_feasible_bin = . if net_zero_feasible == -.1
		
		sum index_bad_things_cc, d
		local index_bad_things_cc_med: display %5.3f `r(p50)'
		local index_bad_things_cc_mean: display %5.3f `r(mean)'
		gen index_bad_things_med = index_bad_things_cc >= `index_bad_things_cc_med'
		gen index_bad_things_mean = index_bad_things_cc >= `index_bad_things_cc_mean'
		
		gen bad_things_cc_dum_sum = (cc_impacts_more_migration > 0 & cc_impacts_more_wars > 0 & cc_impacts_drop_conso > 0)
		gen bad_things_cc_dum_mean = ((cc_impacts_more_migration  + cc_impacts_more_wars + cc_impacts_drop_conso)/3 > 0)
		
end 


/********************************************************************************

	2) Create color scheme 
	
********************************************************************************/

program colorpalette_RdWhBu
  c_local P #a50026, #d73027, #f46d43, #fdae61, #fee090, #ffffff, #e0f3f8, #abd9e9, #74add1, #4575b4, #313695
end
