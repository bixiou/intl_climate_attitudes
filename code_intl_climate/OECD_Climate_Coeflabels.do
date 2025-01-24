/********************************************************************************
					               OECD Climate

Goal: Coeflabels 					
Date: March 2021
 
*********************************************************************************/
		 
	
/********************************************************************************

	Create the Program to arrange the labels in the Coefplots 

********************************************************************************/
	loc demo_head female
	if 		"`2'" == "index_main_policies" & "`1'"=="all" & "$choosecountry"==""  & "$index"== "" loc demo_head children
	else if "`2'" == "index_main_policies" & "`1'"!="all" & "$choosecountry"=="" loc demo_head female
	else if ("`2'" == "index_main_policies") & "$index"=="pooled" loc demo_head female

*--------------------------------------------------------
* Treatment
*--------------------------------------------------------

loc coeflabels_T  2.treatment = "Climate Impacts" 3.treatment = "Climate Policies" 4.treatment = "Both Treatments"
loc coefheads_T 2.treatment= `" "{bf: Treatment}" "{it: Compared to Control}" "'

*--------------------------------------------------------
* Set A 
*--------------------------------------------------------

loc coeflabels_A  female = "Woman" ///
				children = "Lives with child(ren)<14" /// 
				age25_34 = "25-34 years old" age35_49 = "35-49 years old" age50plus = "50+ years old" /// 
				2.income_factor = "Between 25th and 50th percentile" 3.income_factor = "Between 50th and 75th percentile" 4.income_factor = "Above 75th percentile" ///
				2.educ_categ = "Has vocational or high-school degree" ///
				30.wtp_variant = "30 USD" 50.wtp_variant = "50 USD" 100.wtp_variant = "100 USD" 300.wtp_variant = "300 USD" 500.wtp_variant = "500 USD" 1000.wtp_variant = "1,000 USD" ///
				3.educ_categ = "Has a college degree" /// 
				econ_veryleft = "Very Left leaning" econ_center = "Center leaning" econ_right = "Right leaning" econ_veryright = "Very Right leaning"  ///
				2.treatment = "Climate Impacts" 3.treatment = "Climate Policies" 4.treatment = "Both Treatments" ///
				index_main_policies = "Index Main Policies" index_willing_change = "Index Willing Change"


loc coefheads_A `demo_head' = "{bf: Demographics}" ///
			 age25_34 = "{bf: Age}" /// 
			 2.income_factor= "{bf: Income}" ///
			 2.employment_agg = "{bf: Employment Status}" ///
			 2.educ_categ  = "{bf: Education}" /// 
			 econ_veryleft = "{bf: Economic Leaning}" /// 
			 30.wtp_variant = "{bf: WTP Variant}" ///
			 index_main_policies = "{bf: Indices}" ///
			 2.treatment= "{bf: Treatment}"
			 

*--------------------------------------------------------
* Set B
*--------------------------------------------------------
loc coeflabels_B 2.agglo_categ = "Small agglomeration"	///
				3.agglo_categ = "Medium agglomeration"	///
				4.agglo_categ = "Large agglomeration" /// 		
				1.binary_gas_expenses = "High gas expenses" ///
				1.binary_heating_expenses = "High heating expenses" ///
				1.polluting_sector = "Works in polluting sector" ///
				1.binary_availability_transport = "Public transport available" ///
				1.car_dependency = "Uses car" ///
				1.beef_binary = "Eats beef/meat weekly or more" /// 
				1.owner = "Owner or landlord" ///
				1.flights_agg_1 = "Flies more than once a year"
				
				
loc coefheads_B 2.agglo_categ = "{bf: Place Charac.}" ///
				1.car_dependency = "{bf: Energy Usage}" ///
				1.owner = "{bf: Personal Charac.}"
				
				
				
*--------------------------------------------------------
* Set C
*--------------------------------------------------------				
* Main policies - Specific 					
					
loc coeflabels_Cdis_policy ///
			index_trust_govt = "Trusts the government" ///
			index_net_zero_feasible  = "Believes net-zero is technically feasible" ///
			index_worried ="Worries about the consequences of CC" ///
			index_knowledge_footprint = "Understands emissions across activities/regions" ///
			index_knowledge_fundamentals ="Knows CC is real & caused by humans" /// 
			index_knowledge_gases= "Knows which gases cause CC" /// 
			index_knowledge_impacts= "Understands impacts of CC" ///	
			index_positive =  "Believes the policy would have positive econ. effects" ///
			index_pollution = "Believes the policy would reduce air pollution" ///
			index_emissions_plus = "Believes the policy would reduce GHG emissions" ///
			index_problem_inequality = "Believes inequality is an important problem" ///
			index_affected_subjective  = "Believes will suffer from climate change" ///
			index_self = "Believes own household would lose" ///
			index_poor = "Believes low-income earners would lose" ///
			index_rich =  "Believes high-income earners would lose" 
			
* w variance decomp	

global indices_policy  "index_trust_govt index_problem_inequality index_worried index_net_zero_feasible index_affected_subjective index_knowledge_footprint index_knowledge_fundamentals index_knowledge_gases index_knowledge_impacts index_positive index_pollution index_emissions_plus index_self index_poor index_rich"	

loc coeflabels_Cdis_var_policy ///
			index_trust_govt = "Trusts the government (`lindex_trust_govt'%)" ///
			index_net_zero_feasible  = "Believes net-zero is technically feasible (`lindex_net_zero_feasible'%)" ///
			index_worried ="Worries about the consequences of CC (`lindex_worried'%)" ///
			index_knowledge_footprint = "Understands emissions across activities/regions (`lindex_knowledge_footprint'%)" ///
			index_knowledge_fundamentals ="Knows CC is real & caused by humans (`lindex_knowledge_fundamentals'%)"  /// 
			index_knowledge_gases= "Knows which gases cause CC (`lindex_knowledge_gases'%)" /// 
			index_knowledge_impacts= "Understands impacts of CC (`lindex_knowledge_impacts'%)"  ///	
			index_positive =  "Believes the policy would have positive econ. effects (`lindex_positive'%)" ///
			index_pollution = "Believes the policy would reduce air pollution (`lindex_pollution'%)" ///
			index_emissions_plus = "Believes the policy would reduce GHG emissions (`lindex_emissions_plus '%)" ///
			index_problem_inequality = "Believes inequality is an important problem (`lindex_problem_inequality'%)" ///
			index_affected_subjective  = "Believes will suffer from climate change (`lindex_affected_subjective'%)"  ///
			index_self = "Believes own household would lose (`lindex_self'%)" ///
			index_poor = "Believes low-income earners would lose (`lindex_poor'%)" ///
			index_rich =  "Believes high-income earners would lose (`lindex_rich'%)"

	
	
			
loc coefheads_Cdis_policy 	index_trust_govt = "{bf: Trust and General Perceptions}" ///
							index_worried = "{bf: Views about Climate Change}" ///
							index_knowledge_footprint =  "{bf: Climate Change Knowledge}" ///
							index_positive  = "{bf: Effects of Each Climate Policy}"  /// 
							index_self = "{bf: Distributional Impacts of Each Climate Policy}" ///

* General 
loc coeflabels_Cdis  ///			
		index_trust_govt = "Trusts the government" ///
		index_problem_inequality = "Believes inequality is an important problem" ///		
		index_net_zero_feasible  = "Believes net-zero is technically feasible" ///
		index_worried ="Worries about the consequences of CC" ///
		index_knowledge_footprint = "Understands emissions across activities/regions" ///
		index_knowledge_fundamentals = "Knows CC is real & caused by humans" /// 
		index_knowledge_gases= "Knows which gases cause CC" /// 
		index_knowledge_impacts= "Knows impacts of CC" ///	
		index_affected_subjective  = "Believes will suffer from climate change" ///
		index_positive_economy = "Considers policies would have positive econ. effects" ///
		index_policies_pollution= "Considers policies would reduce air pollution" ///
		index_policies_emissions_plus = "Considers policies would reduce GHG emissions" ///
		index_lose_policies_subjective = "Believes own household would lose" ///
		index_lose_policies_poor = "Believes low-income earners would lose" ///
		index_lose_policies_rich =  "Believes high-income earners would lose" ///
			index_positive =  "Considers the policy would have positive econ. effects" ///
			index_pollution = "Considers the policy would reduce air pollution" ///
			index_emissions_plus = "Considers the policy would reduce GHG emissions" ///
			index_problem_inequality = "Believes inequality is an important problem" ///
			index_affected_subjective  = "Believes will suffer from climate change" ///
			index_self =  "Believes own household would lose" ///
			index_poor =  "Believes low-income earners would lose" ///
			index_rich =  "Believes high-income earners would lose" 	
			
		
			
loc coefheads_Cdis ///
			 index_trust_govt = "{bf: Trust and General Perceptions}" ///
			 index_worried = "{bf: Views about Climate Change}" ///
			 index_knowledge_footprint = "{bf: Climate Change Knowledge}" ///
			 index_positive_economy = "{bf: Effects of Main Climate Policies}"  /// 
			 index_lose_policies_subjective = "{bf: Distributional Impacts of Main Climate Policies}" ///
					index_positive  = "{bf: Effects of Main Climate Policy}"  /// 
					index_self = "{bf: Distributional Impacts of Main Climate Policy}"
					
					
					
* General w variance  
global indices "index_trust_govt index_problem_inequality index_worried index_net_zero_feasible index_affected_subjective index_knowledge_footprint index_knowledge_fundamentals index_knowledge_gases index_knowledge_impacts index_positive_economy index_policies_pollution index_policies_emissions_plus index_lose_policies_subjective index_lose_policies_poor index_lose_policies_rich"

loc coeflabels_Cdis_var  ///			
		index_trust_govt = "Trusts the government (`lindex_trust_govt'%)" ///
		index_problem_inequality = "Believes inequality is an important problem (`lindex_problem_inequality'%)" ///		
		index_net_zero_feasible  = "Believes net-zero is technically feasible (`lindex_net_zero_feasible'%)" ///
		index_worried ="Worries about the consequences of CC (`lindex_worried'%)" ///
		index_knowledge_footprint = "Understands emissions across activities/regions (`lindex_knowledge_footprint'%)" ///
		index_knowledge_fundamentals = "Knows CC is real & caused by humans (`lindex_knowledge_fundamentals'%)" /// 
		index_knowledge_gases= "Knows which gases cause CC (`lindex_knowledge_gases'%)" /// 
		index_knowledge_impacts= "Knows impacts of CC (`lindex_knowledge_impacts'%)" ///	
		index_affected_subjective  = "Believes will suffer from climate change (`lindex_affected_subjective'%)" ///
		index_positive_economy = "Considers policies would have positive econ. effects (`lindex_positive_economy'%)" ///
		index_policies_pollution= "Considers policies would reduce air pollution (`lindex_policies_pollution'%)" ///
		index_policies_emissions_plus = "Considers policies would reduce GHG emissions (`lindex_policies_emissions_plus '%)" ///
		index_lose_policies_subjective = "Believes own household would lose (`lindex_lose_policies_subjective'%)" ///
		index_lose_policies_poor = "Believes low-income earners would lose (`lindex_lose_policies_poor'%)" ///
		index_lose_policies_rich =  "Believes high-income earners would lose (`lindex_lose_policies_rich'%)" ///
			index_positive =  "Considers the policy would have positive econ. effects " ///
			index_pollution = "Considers the policy would reduce air pollution" ///
			index_emissions_plus = "Considers the policy would reduce GHG emissions" ///
			index_problem_inequality = "Believes inequality is an important problem" ///
			index_affected_subjective  = "Believes will suffer from climate change" ///
			index_self =  "Believes own household would lose" ///
			index_poor =  "Believes low-income earners would lose" ///
			index_rich =  "Believes high-income earners would lose" 	
	