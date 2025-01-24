/********************************************************************************
					               OECD Climate

Goal: Create  Unconditional Mean Graphs 			
Date: Apr 2022 
 
*********************************************************************************/

	
*--------------------------
* Program to store key stats  
*--------------------------	
cap program drop storage 	
	program define storage 
				matrix M[$x ,1] = r(mean)
				matrix M[$x ,2] = r(se)
				matrix M[$x ,3] = r(lb)
				matrix M[$x ,4] = r(ub)
				matrix M[$x ,5] = r(N)
	end


/********************************************************************************

	Create the Program 

********************************************************************************/
cap program drop graphmeans 

program define graphmeans 
	args 1 2 

	*--------------------------
	* Choose Group  
	*--------------------------
	if "`1'"=="hi" global dropgroup $bad_data 
	if "`1'"=="mi" global dropgroup $good_data

	
	 
 
	*--------------------------
	* Set Environment 
	*--------------------------
	* Policies 
	global pols "standard investments tax" 
		
		
    * Choose policy 
	loc perception `2'
	di in red "`perception'"
	if "`2'" == "effect_less_emission" loc lgorder = "1 5"
	else loc lgorder = "1 3 5"
	
	
	*--------------------------
	* Plot parameters 
	*--------------------------	
	* Title name 
	loc positive_negativet = "Believes policies would have positive econ. effects"
	loc effect_less_emissiont = "Believes policies would reduce GHG emissions"
	loc win_lose_selft = "Believes own household would lose"
	loc win_lose_poort = "Believes low-income earners would lose"
	loc less_pollutiont = "Believes policies would reduce air pollution"
	
	
	*--------------------------
	* Set A   
	*--------------------------	
	* Run Set-Up Program 
	datasetup 
	
	* countrycateg 
	foreach K in $dropgroup {
	    drop if country =="`K'"
	}

	
	* Choose colors 				
		global p2 = "0 139 188"
		global p5 = "92 184 92"
		global p4 =  "165 0 38"
		global output 	"${gitpath}//figures//all/" 
	
	* create empty category of a question that was not asked for investments 
	gen investments_effect_less_emission = . 
	ren tax_transfers_effect_less_e* tax_effect_less_emission
	ren tax_transfers_effect_less_p* tax_less_pollution
	ren tax_transfers_* tax_* 
	ren investments_effect_less_pol* investments_less_pollution
	ren *effect_less_pollution* *less_pollution*
	
	* Replace categ vars to dummies 
	tab treatment, gen(T)
	tab income_factor, gen(inc)
	tab educ_categ, gen(edu)
	gen male = female == 0 
	tab children, gen(child)
	 
	global setAmeans "T4 T3 T2 T1 econ_veryright econ_right econ_center econ_left econ_veryleft edu3 edu2 edu1  inc4 inc3 inc2 inc1  age50plus age35_49  age25_34  child2 child1 female male"
	
	foreach pol in $pols {
	preserve 
	ren `pol'_`perception' `pol'`perception'o
	gen  `pol'_`perception' = `pol'`perception'o> 0 
	replace `pol'_`perception' = . if `pol'`perception'o==. 
	loc var `pol'_`perception'
	
	matrix M = J(23 ,5, .)
	loc k = 0 
	foreach factor of varlist $setAmeans {
	    if inlist("`factor'", "T4", "T3", "T2", "T1") {
		loc k =`k'+1 
		di in red "`k'"
		loc count 1
		matrix colnames M = mean_`count' se_`count' cl_`count' cu_`count' n_`count'  
			ci means `var'  [w=weight] if `factor' ==1
			  global x `k'
			  storage 
		}
		
	    else if !inlist("`factor'", "T4", "T3", "T2", "T1") {
		loc k =`k'+1 
		di in red "`k'"
		loc count 1
		matrix colnames M = mean_`count' se_`count' cl_`count' cu_`count' n_`count'  
			ci means `var'  [w=weight] if `factor' ==1 & treatment == 1
			  global x `k'
			  storage 
		}		
	}

	clear
		svmat M, names(col)
		gen varname = ""
		gen varid = . 
		loc k = 0 
		foreach factor in $setAmeans {
		loc k =`k'+1
		replace varname = "`factor'" if _n==`k'
		replace varid = `k'  if _n==`k'
		}
		
		
		reshape long mean_ se_ cl_ cu_ n_ , i(varname varid) j(outcome)
		sort varid
		ren varname varnameold 
		
		
		gen varname = varnameold 
		replace varname = "Control" if varnameold=="T1"
		replace varname = "CC impacts" if varnameold=="T2"
		replace varname = "CC policies" if varnameold=="T3"
		replace varname = "Both treatments" if varnameold=="T4"
		
		replace varname = "Center" if varnameold=="econ_center"
		replace varname = "Very left" if varnameold=="econ_veryleft"
		replace varname = "Left" if varnameold=="econ_left"
		replace varname = "Right" if varnameold=="econ_right"
		replace varname = "Very right" if varnameold=="econ_veryright"
		
		replace varname = "No education" if varnameold=="edu1"
		replace varname = "High School" if varnameold=="edu2"
		replace varname = "College+" if varnameold=="edu3"
		
		replace varname = "Q1" if varnameold=="inc1"
		replace varname = "Q2" if varnameold=="inc2"
		replace varname = "Q3" if varnameold=="inc3"
		replace varname = "Q4" if varnameold=="inc4"
		
		replace varname = "25-34 years old" if varnameold=="age25_34"
		replace varname = "35-49 years old" if varnameold=="age35_49"
		replace varname = "50+ years old" if varnameold=="age50plus"
		
		replace varname = "Does not live with child(ren)<14" if varnameold=="child1"
		replace varname = "Lives with child(ren)<14" if varnameold=="child2"
		
		
		replace varname = "Woman" if varnameold == "female"
		replace varname = "Man" if varnameold == "male"
		
			
		cap drop group
		gen     group = 1 if inrange(varid, 1,4)
		replace group = 2 if inrange(varid, 5,9)
		replace group = 3 if inrange(varid, 10,12)
		replace group = 4 if inrange(varid, 13,16)
		replace group = 5 if inrange(varid, 17,19)
		replace group = 6 if inrange(varid, 20,21)
		replace group = 7 if inrange(varid, 22,23)
		
        gen varidold = varid 
		
		forval i= 2/7 {
		replace varid = varid+(`i'-1) if group==`i'
		}
		labmask varid, val(varname)
		
		d, sh 
		global Norig r(N)
		local new = _N + 7
		set obs `new'
		
		replace varid = 5 if _n== ($Norig +1 )
		replace varname  = "{bf: Treatment}" if varid == 5 
		replace group = 1 if varid == 5 
		
		replace varid= 11 if _n== ($Norig +2 )
		replace varname = "{bf: Econ leaning}" if varid == 11
		replace group = 2 if varid == 11 
		
		replace varid= 15 if _n== ($Norig +3 )
		replace varname = "{bf: Education}" if varid == 15
		replace group = 3 if varid == 15 
		
		replace varid= 20 if _n== ($Norig +4 )
		replace varname = "{bf: Income}" if varid == 20
		replace group = 4 if varid == 20 
		
		replace varid= 24 if _n== ($Norig +5 )
		replace varname = "{bf: Age}" if varid == 24
		replace group = 5 if varid == 24 
		
		replace varid = 27 if varid == 28 
		replace varid = 28 if varid == 29 
		
		replace varid= 29 if _n== ($Norig +7 )
		replace varname = "{bf: Demographics}" if varid == 29
		replace group = 7 if varid==29
		
		labmask varid, val(varname)
		
		ren mean_ mean_`pol'
		ren cl_ cl_`pol'
		ren cu_ cu_`pol'
		tempfile `pol'
		save 	``pol'', replace
		restore 
		}
		
		
	* Append policies together 
	use `standard', clear 
	merge 1:1 varid group using `investments', assert(3) nogen
	merge 1:1 varid group using `tax', assert(3) nogen
	
	* Plot 
		global line horizontal   msize(1)  
		loc xbase 0.40
			
		gsort -varid 
		loc toplot 
		forval i = 1/7 {
			loc toplot `toplot'(scatter varid mean_standard if  group==`i',  ms(O)mcolor("${p4}%50") lcolor("${p4}%50") mlwidth(vthin) ) (rcap cl_standard cu_standard varid if group==`i' , $line color("${p4}%50")  ) 

			loc toplot `toplot'(scatter varid mean_investments if group==`i', ms(D) mcolor("${p5}%50") lcolor("${p5}%50") mlwidth(vthin) ) (rcap cl_investments cu_investments varid if group==`i' , $line color("${p5}%50")  ) 
			
			loc toplot `toplot'(scatter varid mean_tax if  group==`i', ms(T) mcolor("${p2}%50") lcolor("${p2}%50") mlwidth(vthin) ) (rcap cl_tax cu_tax varid if group==`i' , $line color("${p2}%50")  ) 			
			
		}
			
		tw `toplot' , ///
		 legend(row(1) order(`lgorder') label(1 "Ban on combustion-engine cars") label(3 "Green infrastructure program") label(5 "Carbon tax with cash transfers") $comblegendops ) ytitle("") xlabel( , format(%4.2fc))  ylabel(1(1)29, valuelabel labsize(small) nogrid notick ) ///
		   xtitle( " " "Share of Respondents", size(medium) color(black)  ) ///
		 name(setA, replace)	
	
	*--------------------------
	* Set B
	*--------------------------	
	datasetup
	
	* countrycateg 
	foreach K in $dropgroup {
	    drop if country =="`K'"
	}

	
	* create empty category of a question that was not asked for investments 
	gen investments_effect_less_emission = .
	ren tax_transfers_effect_less_e* tax_effect_less_emission
	ren tax_transfers_effect_less_p* tax_less_pollution
	ren tax_transfers_* tax_*
	ren investments_effect_less_p* investments_less_pollution
	ren *effect_less_pollution* *less_pollution*
	
		* Choose colors 				
		global p2 = "0 139 188"
		global p5 = "92 184 92"
		global p4 =  "165 0 38"
		global output 	"${gitpath}//figures//all/" 
	
	* Replace categ vars to dummies 
    tab agglo_categ, gen(agglo)
	tab binary_availability_transport, gen(trans)
	tab car_dependency, gen(car)
	tab binary_gas_expenses, gen(gas)
	tab binary_heating_expenses, gen(heat)
	tab flights_agg_1 , gen(fly)
	tab polluting_sector , gen(polu)
	tab beef_binary , gen(beef)
	tab owner, gen(own)
	
	global setBmeans "own2 own1 beef2 beef1 polu2 polu1 fly2 fly1 heat2 heat1 gas2 gas1 car2 car1 trans2 trans1 agglo4 agglo3 agglo2 agglo1 "
	
	foreach pol in $pols {
	preserve 
	ren `pol'_`perception' `pol'`perception'o
	gen  `pol'_`perception' = `pol'`perception'o> 0 
	replace `pol'_`perception' = . if `pol'`perception'o==. 
	loc var `pol'_`perception'	
	
	matrix M = J(20 ,5, .)
	loc k = 0 
	foreach factor of varlist $setBmeans  {
		loc k =`k'+1 
		di in red "`k'"
		tab `var', m 
		loc count 1
		
		matrix colnames M = mean_`count' se_`count' cl_`count' cu_`count' n_`count'  
			ci means `var'  [w=weight] if `factor' ==1 & treatment ==1 
			  global x `k'
			  storage 
		
	}

		clear
		svmat M, names(col)
		gen varname = ""
		gen varid = . 
		loc k = 0 
		foreach factor in $setBmeans {
		loc k =`k'+1
		replace varname = "`factor'" if _n==`k'
		replace varid = `k'  if _n==`k'
		}
		
		
		reshape long mean_ se_ cl_ cu_ n_ , i(varname varid) j(outcome)
		sort varid
		ren varname varnameold 
		
		
		gen varname = varnameold 
		replace varname = "Owner or landlord" if varnameold=="own2"
		replace varname = "Tenant" if varnameold=="own1"
		
		replace varname = "Eats beef/meat weekly or more" if varnameold=="beef2"
		replace varname = "Eats beef/meat less than once a week" if varnameold=="beef1"
		replace varname = "Works in polluting sector" if varnameold=="polu2"
		replace varname = "Works in non-polluting sector" if varnameold=="polu1"
		replace varname = "Flies more than once a year" if varnameold=="fly2"
		replace varname = "Flies less than once a year" if varnameold=="fly1"
		replace varname = "High heating expenses" if varnameold=="heat2"
		replace varname = "Low heating expenses" if varnameold=="heat1"
		replace varname = "High gas expenses" if varnameold=="gas2"
		replace varname = "Low gas expenses" if varnameold=="gas1"
		replace varname = "Uses car" if varnameold=="car2"
		replace varname = "Does not use car" if varnameold=="car1"
		
		replace varname = "Public transport available" if varnameold=="trans2"
		replace varname = "No public transport available" if varnameold=="trans1"
		replace varname = "Large agglomeration" if varnameold=="agglo4"
		replace varname = "Meidum agglomeration" if varnameold=="agglo3"
		replace varname = "Small agglomeration" if varnameold=="agglo2"
		replace varname = "Rural area" if varnameold=="agglo1"
	
			
		cap drop group
		gen     group = 1 if inrange(varid, 1,2)
		replace group = 2 if inrange(varid, 3,14)
		replace group = 3 if inrange(varid, 15,20)
		
        gen varidold = varid 
		
	forval i= 2/3 {
	replace varid = varid+(`i'-1) if group==`i'
	}
	labmask varid, val(varname)
	
	d, sh 
	global Norig r(N)
	local new = _N + 3
    set obs `new'
	
	replace varid = 3 if _n== ($Norig +1 )
	replace varname  = "{bf: Personal Characteristics}" if varid == 3
	replace group = 1 if varid == 3 
	
	replace varid= 16 if _n== ($Norig +2 )
	replace varname = "{bf: Energy Usage}" if varid == 16
	replace group = 2 if varid == 16
	
	replace varid= 23 if _n== ($Norig +3 )
	replace varname = "{bf: Place Characteristics}" if varid == 23
	replace group = 3 if varid == 23
	
	ren group groupold 
	gen group = groupold 
	
	replace group =3 if inrange(varid, 6,7)
	replace group =4 if inrange(varid, 8,9)
	replace group =5 if inrange(varid, 10,11)
	replace group =6 if inrange(varid, 12,13)
	replace group =7 if inrange(varid, 14,16)
	replace group =9 if inrange(varid, 17,18)
	replace group =8 if inrange(varid, 19,23 )

	
	labmask varid, val(varname)
		ren mean_ mean_`pol'
		ren cl_ cl_`pol'
		ren cu_ cu_`pol'
		tempfile `pol'
		save 	``pol'', replace
		restore 
		}
	
	* Append policies together 
	use `standard', clear 
	merge 1:1 varid group using `investments', assert(3) nogen
	merge 1:1 varid group using `tax', assert(3) nogen	
	
	* Plot 
	global line horizontal   msize(1)  
	loc xbase 0.40
		
    gsort -varid 
	loc toplot 
	forval i = 1/9 {
			loc toplot `toplot'(scatter varid mean_standard if  group==`i',  ms(O)mcolor("${p4}%50") lcolor("${p4}%50") mlwidth(vthin) ) (rcap cl_standard cu_standard varid if group==`i' , $line color("${p4}%50")  ) 

			loc toplot `toplot'(scatter varid mean_investments if group==`i', ms(D) mcolor("${p5}%50") lcolor("${p5}%50") mlwidth(vthin) ) (rcap cl_investments cu_investments varid if group==`i' , $line color("${p5}%50")  ) 
			
			loc toplot `toplot'(scatter varid mean_tax if  group==`i', ms(T) mcolor("${p2}%50") lcolor("${p2}%50") mlwidth(vthin) ) (rcap cl_tax cu_tax varid if group==`i' , $line color("${p2}%50")  ) 			
			
		}
		
	tw `toplot' , ///
	  legend(off) ytitle("") xlabel( , format(%4.2fc))  ylabel(1(1)23, valuelabel labsize(small) nogrid notick ) ///
	   xtitle( " " "Share of Respondents", size(medium) color(black)  ) ///
	  name(setB, replace)		
	
 
   * Combine set A and B and export 
	grc1leg setA setB, xcommon legendfrom(setA) pos(12)  title(" ", $xops )
	graph export "${gitpath}/figures/FINAL_FIGURES/${fname}.${ft}", replace

	cap log close 
end
	
	
	
	
	
**************************
global fname FigureA16a
graphmeans hi less_pollution
global fname FigureA16b
graphmeans hi win_lose_self
global fname FigureA16c
graphmeans hi win_lose_poor

global fname FigureA17a
graphmeans mi less_pollution
global fname FigureA17b
graphmeans mi win_lose_self
global fname FigureA17c
graphmeans mi win_lose_poor
