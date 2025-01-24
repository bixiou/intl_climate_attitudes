/********************************************************************************
					 OECD Climate - Master Paper 

Goal: Master Dofile
Date: Jan 2021 
 
*********************************************************************************/
		 
	global choosecountry 
	global countryname
	
************************************************************************
* 0) Preface
************************************************************************

	* Set Environments 
	clear all 
	set more off 
	program drop _all 
	set type double 
	*set matsize 10000
	cap log close 
	
	* /!\ Set this directory global to the repository folder
	global gitpath "EDIT WITH PATH TO THE REPOSITORY"
	
	
	global data "${gitpath}/data/"
	global code	"${gitpath}/code_intl_climate/"
		
	global ft "pdf"
	cap mkdir "${gitpath}/figures/FINAL_FIGURES/"

	
	* Country globals 
	global countries AU BR CA CN DE DK FR IA ID IT JP MX PL SA SK SP TR UA UK US
	global oecd AU CA DE DK FR IT JP MX PL SK SP TR UK US 

	global non_oecd BR CN IA ID SA UA 
	global complete_countries DE DK FR IA ID BR 	
	
	* Required packages
	do "${code}required_packages.do"
	
	
	* Install Theme (optional)
	local source "${code}theme_climate.scheme"
	local personal_dir = c(sysdir_personal)
	cap mkdir "`personal_dir'"
	copy "`source'" "`personal_dir'" , replace
	set scheme theme_climate
	
************************************************************************
* 1) Create Programs
************************************************************************
* datasetup: Data preparation 
	do "${code}OECD_Climate_SetUp.do"
	
* coeflabels: prepare the labels of the different sets 
	do "${code}OECD_Climate_Coeflabels.do"

* graphcoefplots: Coefplots for each country 
	include "${code}OECD_Climate_Coefplots_all.do"

* graphcoefplots_mutli: Coefplots for each country and multiple outcomes (up to 6)
	include "${code}OECD_Climate_Coefplots_all_multi.do"
		
* graphcoefplots_het: Country Heterogeneities (setA)
	include "${code}OECD_Climate_Coefplots_het.do"	
	
* Outcomes 
	global set_otherpols "standard_public_binary transfers_progressive_bin tax_fuels_binary ban_citycenter_binary tax_flying_binary  subsidies_binary insulation_binary"
		
************************************************************************
* 2) Main Paper Figures 
************************************************************************

** Define Weights
	* Usual weights
	global weight_option [w=weight]
	global weight_extension
	global weight_table_extension
	
	** Use those paremeters for unweighted figures
	/*global weight_option
	global weight_extension _no_weight 
	global weight_table_extension _unweighted*/
	
	
*------------------------------------------
* Figure 1: Should fight CC 
*------------------------------------------
	do "${code}OECD_Climate_CC_should_fight.do"

*------------------------------------------
* Figures 4, A25: Representativeness
*------------------------------------------
	do "${code}OECD_graph_desc_stat_het.do"
	
*------------------------------------------
* Figure 5: Real-stakes and support
*------------------------------------------
	include "${code}OECD_Climate_CoefPlots_all_support_willing_indices_multi"
	global gname real_stakes
	global fname Figure5
	graphcoefplots_real_stakes_multi all donation_binary petition
*------------------------------------------
* Heatmaps: Figures 7, 9-10, 12, A4 Panel A, A5, A7, A13-A14-A15
*------------------------------------------	
	do "${code}OECD_Climate_Heatplots.do"

*------------------------------------------
* Figure 8 Panel A: Index Knowledge 
* Set A 
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all.do"
	global fname Figure8a
	graphcoefplots all index_knowledge

*------------------------------------------
* Figure 8 Panel B: Index Knowledge 
* Heterogenous patterns for age 
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_het.do"	
	global fname Figure8b
	graphcoefplots_het groups index_knowledge age

*------------------------------------------
* Figure 11 Panel A: Index Main policies 
* Set AB 
*------------------------------------------
est clear
	include "${code}OECD_Climate_Coefplots_all.do"
	global fname Figure11a
	graphcoefplots all index_main_policies

*-----------------------------------------------------
* Figure 11 Panel B: Index Main policies
* Heterogenous patterns for age, gender, income
*-----------------------------------------------------
est clear 
	include "${code}OECD_Climate_Coefplots_het.do"	
	global fname Figure11b
	graphcoefplots_het groups index_main_policies age_gender_inc 

*------------------------------------------
* Figure 13: Main mechanisms
* Set AB
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all_multi.do"
	global set_main_mech  "index_pos_econ index_pol_em index_lose_self index_lose_poor"
	global gname set_main_mech
	global fname Figure13
	graphcoefplots_multi all $set_main_mech
	
// 	global set_main_mech_tax  "index_tax_pos index_tax_em index_tax_self index_tax_poor"
// 	global gname set_main_mech_tax
// 	graphcoefplots_multi all $set_main_mech_tax
//	
// 	global set_main_mech_standard  "index_standard_pos index_standard_em index_standard_self index_standard_poor"
// 	global gname set_main_mech_standard
// 	graphcoefplots_multi all $set_main_mech_standard
//	
// 	global set_main_mech_invest  "index_invest_pos index_invest_em index_invest_self index_invest_poor"
// 	global gname set_main_mech_invest
// 	graphcoefplots_multi all $set_main_mech_invest
	
*------------------------------------------
* Figure 14 Panel A, A8 Panel A: Combined Pols  
* Set C
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all.do"
	graphcoefplots all combined_pols 

*------------------------------------------
* Figures 14 Panel B, A18 Panel B: Variance Bar graphs
*------------------------------------------
	include "${code}OECD_Climate_Variance.do"

*------------------------------------------
* Figure 16: Main Policies Treatments 
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all_treat_multi"
	global gname support_main_others
	global fname Figure16
	graphcoefplots_treat_multi all standard_binary investments_binary tax_transfers_binary fairness_mean_dummy $set_otherpols donation_pct willing_mean_dummy petition
	
*------------------------------------------
* Figure 17 panels A and B: Treatment Effects on Reasoning
* Combined pols 
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all_treat_multi"
	global gname all_mech 
	graphcoefplots_treat_multi all all_mech
	

************************************************************************
* 3) Appendix Figures 
************************************************************************
	
*------------------------------------------
* Figure A2: Vulnerability correlation 
*------------------------------------------
	do "${code}OECD_Climate_CorrelationIndicators - Update.do"

*------------------------------------------
* Figure A3: Pre-registered Real-stakes and support
*------------------------------------------
	include  "${code}OECD_Climate_CoefPlots_all_support_willing_indices_multi"
	global gname real_stakes_ref
	global fname FigureA3
	graphcoefplots_real_stakes_multi all donation_binary donation_pct petition	
	
*------------------------------------------
* Figure A4 Panel B: Expectations about the future
* Set AB
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all_multi.do"
	global set_future_bin "cc_impacts_extinction_bin future_poorer_bin net_zero_not_feasible_bin"
	global gname set_future_bin
	global fname FigureA4b
	graphcoefplots_multi all $set_future_bin

*-----------------------------------------------------
* Figure A8 Panel B: Combined pols 
* Heterogenous patterns for car dependency 
*-----------------------------------------------------
est clear 
	include "${code}OECD_Climate_Coefplots_het.do"	
	global fname FigureA8b
	graphcoefplots_het groups combined_pols car_dependency
	
*------------------------------------------
* Meansplots - Figures A9-A10, A16-A17 (all panels), A19
*------------------------------------------
	do "${code}OECD_Climate_Means_1.do"
	do "${code}OECD_Climate_Means_3.do"
	do "${code}OECD_Climate_Means_2.do"

*------------------------------------------
* Figure A11: Indifferent to policies
* Set AB
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all_multi.do"
	global set_indif_main "standard_indif investments_indif tax_transfers_indif"
	global gname set_indif_main
	global fname FigureA11
	graphcoefplots_multi all $set_indif_main

*------------------------------------------
* Figure A12: Other pols 
* Set AB and Set C
*------------------------------------------
	include "${code}OECD_Climate_Coefplots_all_multi.do"
	global gname otherpols
	global fname FigureA12
	graphcoefplots_multi all $set_otherpols
	
*-----------------------------------------------------
* Figure A18 Panel A: Beliefs and fairness, support, willingness 
* Set C
*-----------------------------------------------------	
	include "${code}OECD_Climate_Coefplots_all_multi"
	global gname fair_support_willing
	global fname FigureA18a
	graphcoefplots_multi all index_fairness index_main_policies index_willing_change
	
*------------------------------------------
* Figure A20: Treatment effects
*------------------------------------------
	include "${code}OECD_taxrevenues_graphs.do"
	
*------------------------------------------
* Figure A21: Reverse IV - All Sample
*------------------------------------------
	do "${code}OECD_reverseIV_graph_all.do"
	
*------------------------------------------
* Figure A22 (all panels): Reverse IV - Het
*------------------------------------------
	do "${code}OECD_reverseIV_graph_het.do"
