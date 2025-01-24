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

*--------------------------
* Environments  
*--------------------------	
global set_otherpols "standard_public_binary  transfers_progressive_bin tax_fuels_binary ban_citycenter_binary tax_flying_binary   subsidies_binary insulation_binary"

global pols standard_binary investments_binary tax_transfers_binary fairness_mean_dummy $set_otherpols donation_binary willing_mean_dummy petition

datasetup

global output 	"${gitpath}//figures//all/" 
	* Choose colors 	
		global p2 = "0 139 188"
		global p5 ="127 72 146"
		global p6 =  "165 0 38"
		global p4 = "92 184 92"	
		
	* Choose shape 
	loc sym1 "O"
	loc sym2 "D"
	loc sym3 "T"
	loc sym4 "S"
	loc sym5 "X"

	* Replace w dummies 
	tab treatment, gen(T)
	global setAmeans "T4 T3 T2 T1"
*--------------------------
* Calculate means 
*--------------------------
	foreach var in $pols {	
	preserve 
	matrix M = J(4,5, .)
	loc k = 0 
	foreach factor of varlist $setAmeans {
		loc k =`k'+1 
		loc count = 1
		di in red "`k'"
		
		matrix colnames M = mean_`count' se_`count' cl_`count' cu_`count' n_`count'  
			ci means `var'  [w=weight] if `factor' ==1
			  global x `k'
			  storage 
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
		
		sort varid
		 
		gen outcome = "`var'"
		tempfile d`var'
		save 	`d`var'', replace 
	restore 	
	}
	
				
	* Append the resutls 
     clear  
	 foreach var in $pols {
	 append using `d`var''
	 }
		
		ren varname varnameold 
		gen varname = varnameold 
		replace varname = "Control" 		if varnameold=="T1"
		replace varname = "CC impacts" 		if varnameold=="T2"
		replace varname = "CC policies" 	if varnameold=="T3"
		replace varname = "Both treatments" if varnameold=="T4"
		
*--------------------------
* Label 
*--------------------------
	gen polname = ""
   replace polname = "Ban on combustion-engine cars"  if outcome == "standard_binary"
	replace polname = "Green infrastructure program"   if outcome == "investments_binary"
	replace polname = "Carbon tax with cash transfers" if outcome == "tax_transfers_binary"
	replace polname = "Fairness of main climate policies" if outcome == "fairness_mean_dummy"
	
	replace polname = "Ban on combustion-engine cars w. alternatives available" if outcome == "standard_public_binary"
	replace polname = "Carbon tax with progressive transfers" if outcome =="transfers_progressive_bin"
	replace polname = "Tax on fossil fuels" if outcome == "tax_fuels_binary"
	replace polname = "Ban of polluting vehicles in dense areas" if outcome == "ban_citycenter_binary"
	replace polname = "Tax on flying (raising price by 20%)" if outcome == "tax_flying_binary"
	replace polname = "Subsidies for low-carbon technologies" if outcome == "subsidies_binary"
	replace polname = "Mandatory and subsidized insulation of buildings" if outcome == "insulation_binary"
	replace polname = "Willing to donate to reforestation cause (hypothetical)" if outcome == "donation_binary"
	replace polname = "Willing to adopt climate friendly behavior" if outcome == "willing_mean_dummy"
	replace polname = "Willing to sign petition supporting climate action" if outcome == "petition"
	
	gen outcomeid = . 
	loc k = 0 
	 foreach var in $pols {
	 loc k = `k'+1
	 replace outcomeid = `k' if outcome == "`var'"   
	 }	 
	
	labmask outcomeid, val(polname)
	gen id = outcomeid
	
	gen group = 1 if inrange(outcomeid, 1, 4)
	replace group = 2 if inrange(outcomeid, 5, 11)
	replace group = 3 if inrange(outcomeid, 12, 14)
	
	
		forval i= 2/3 {
		replace outcomeid = outcomeid+(`i'-1) if group==`i'
		}
		labmask outcomeid, val(polname)
		
		d, sh 
		global Norig r(N)
		local new = _N + 3
		set obs `new'	
	
		replace outcomeid = 5 if _n== ($Norig +1 )
		replace polname  = "{bf: Support for Main Climate Policies}" if  outcomeid  == 5 
		replace group = 1 if  outcomeid  == 5 	
	
		replace outcomeid = 13 if _n== ($Norig +2 )
		replace polname  = "{bf: Support for Other Climate Policies}" if  outcomeid  == 13
		replace group = 2 if  outcomeid  == 13 
		
		replace outcomeid = 17 if _n== ($Norig +3 )
		replace polname  = "{bf: Private Behaviors}" if  outcomeid  == 17
		replace group =2 if  outcomeid  == 17	
	
		labmask outcomeid, val(polname)
	     	
		replace outcomeid = -outcomeid 
		
		
		replace outcomeid = 0 if polname  == "{bf: Support for Main Climate Policies}" 
		replace outcomeid = -5 if polname  == "{bf: Support for Other Climate Policies}" 
		replace outcomeid = -13 if polname  == "{bf: Private Behaviors}" 
		
		
*--------------------------
* Plot 
*--------------------------		
		
		foreach stat of varlist mean_ cl_ cu_ {
			replace `stat'= `stat'*100
		}
		
		labmask outcomeid, val(polname)
		
		global line horizontal   msize(1)  
		loc xbase 0.40
		loc toplot 
		forval i = 1/17 {
			loc toplot `toplot'(scatter outcomeid mean_ if  group==`i' & varid==4 ,  ms(`sym4') mlwidth(1)  mcolor("${p5}%50") lcolor("${p5}") mlwidth(vthin)   )  (rcap cl_ cu_ outcomeid if group==`i'  & varid==4 , $line color("${p5}%50")  ) 
			loc toplot `toplot'(scatter outcomeid mean_ if  group==`i' & varid==3 ,  ms(`sym1') mlwidth(1)  mcolor("${p2}%50") lcolor("${p2}") mlwidth(vthin)   ) (rcap cl_ cu_ outcomeid if group==`i'  & varid==3 , $line color("${p2}%50")  ) 
			loc toplot `toplot'(scatter outcomeid mean_ if  group==`i' & varid==2 ,  ms(`sym2') mlwidth(1) mcolor("${p4}%50") lcolor("${p4}") mlwidth(vthin) ) (rcap cl_ cu_ outcomeid if group==`i'  & varid==2 , $line color("${p4}%50")  ) 
			loc toplot `toplot'(scatter outcomeid mean_ if  group==`i' & varid==1 ,  ms(`sym3') mlwidth(1)  mcolor("${p6}%50") lcolor("${p6}") mlwidth(vthin)  ) (rcap cl_ cu_ outcomeid if group==`i'  & varid==1 , $line color("${p6}%50")  ) 
		}
		
		tw `toplot' , ///
		  legend(order(1 "Control" 3 "Climate Impacts" 5 "Climate Policies" 7 "Both Treatments") row(1) pos(12) size(medium) color(black) ) ytitle("") xlabel( , format(%2.0fc))  ylabel(-16(1)0, valuelabel angle(h) labsize(small) nogrid notick ) ///
		  xtitle( " " "% Support", size(medium) color(black)  ) ///
		 name(g, replace)		
		 
	grc1leg  g  , legendfrom(g ) pos(12)  rows(1) ycommon xcommon $graphsettings 
	graph export "${gitpath}/figures/FINAL_FIGURES/FigureA19.${ft}", replace
	
	
	
	
	
	
	
		