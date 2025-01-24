/********************************************************************************
					 OECD Climate - Bar Graphs 

Date: June 2022 
 
*********************************************************************************/
		 
* Country set up directly in Master Dofile		 
	*global choosecountry  
	*global countryname 		 



/********************************************************************************

	Variance Graph 

********************************************************************************/


global output "${gitpath}/figures/all/"
global ft pdf
loc folder All 

foreach file in "LMG_main_policies${weight_table_extension}_C" "LMG_fairness_C" "LMG_willingness_C" {

*-----------------------------------------------
* Decomposition analysis : Main pols 
*-----------------------------------------------
	import delimited using "${gitpath}/tables/`folder'/`file'.csv", clear 
	
* Change to percentage 
	gen percent = x*100
	
* Create appropiate labels 
	gsort -x
   gen vari = ""
   
   replace vari = "Believes own household would lose" 						if v1 == "index_lose_policies_subjective"
   replace vari = "Believes policies would reduce GHG emissions" 				if v1== "index_policies_emissions_plus"
   replace vari = "Believes policies would reduce air pollution" 				if v1 =="index_policies_pollution"
   replace vari = "Believes low-income earners would lose" 					if v1 =="index_lose_policies_poor"
   replace vari = "Believes the policy would have positive econ. effects" 	if v1 =="index_positive_economy"
   replace vari = "Believes net-zero is technically feasible" 				if v1 =="index_net_zero_feasible"
   replace vari = "Worries about the consequences of CC" 					if v1 =="index_worried"
   replace vari = "Believes will suffer from climate change"				if v1 =="index_affected_subjective"
   replace vari = "Country" 												if v1 =="factor(country)"
   replace vari = "Knows CC is real & caused by humans" 					if v1 =="index_knowledge_fundamentals"
   replace vari = "Trusts the government" 									if v1 =="index_trust_govt"

   drop if vari==""
	
	global color5  "92 184 92"
	gen sorting = -percent 
	
	graph bar percent, over(vari,  sort(sorting)) horizontal  ///
	bar(1, color("${color5}%60")) ///
	blabel(bar, format(%3.1fc) size(3) gap(*.2) pos(inside) color(black))   ///
	ytitle(" " "% of response variances") ylabel(,nogrid)
	
	if "`file'" == "LMG_main_policies${weight_table_extension}_C" {
		graph export "${gitpath}/figures/FINAL_FIGURES/Figure14b.${ft}", replace

	}
	else if "`file'" == "LMG_fairness_C" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA18b_left.${ft}", replace

	}
	else if "`file'" == "LMG_willingness_C" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA18b_right.${ft}", replace

	}
	
	graph export  "${gitpath}/figures/all/`file'.${ft}", replace 
} 
