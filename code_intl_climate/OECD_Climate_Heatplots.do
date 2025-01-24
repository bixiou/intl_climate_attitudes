/********************************************************************************
					               OECD Climate

Goal: Create heatmaps 					
Date: Feb 2021 
 
*********************************************************************************/
		 
*----------------------------------
*	0) Preface
*----------------------------------

	* Set Environments 
	global graphsetting   "graphregion(fcolor(white) lcolor(white) margin( 1 0 0 1 ) ) plotregion( fcolor(none) lcolor(none) margin(1 2 1 1) ) ysize(8) xsize(18)"
	
	
	global input "$gitpath/xlsx/country_comparison$weight_table_extension/"
	global hi "$gitpath/tables/hi/"
	global mi "$gitpath/tables/mi/"
	global tablefolder "$gitpath/tables/"
	
	global outheat "$gitpath/figures/country_comparison/"
	
	global countrynames "Highincome"	"Australia"	"Canada"	"Denmark"	"France"	"Germany"	"Italy"	"Japan"	"Poland"	"SouthKorea"	"Spain"	"UnitedKingdom"	"UnitedStates" "Middleincome"	"Brazil"	"China"	"India"	"Indonesia"	"Mexico"	"SouthAfrica"	"Turkey"	"Ukraine"				
	
	* Graph settings
	global pal RdWhBu
	global countrylab "1/13 15/24,  valuelabels  labsize(2.2)  labcolor(black)  nogrid   axis(2)  angle (45) glc(black) tlw(vthin) tl(*.5) tlc(black)"
	global xaxis2 "xaxis(2)  xtitle("", axis(2))  xscale( lstyle(black) axis(2))"
	global xaxis1 "xlabel(none  )  xscale(extend lstyle(none)) "
	
	
	do "${code}OECD_Climate_SetUp.do"
*----------------------------------
*	1) Set up program
*----------------------------------
cap program drop heatplotset 

program define heatplotset 
* Order countrynames
order Highincome	Australia	Canada	Denmark	France	Germany	Italy	Japan	Poland	SouthKorea	Spain	UnitedKingdom	UnitedStates	Middleincome	Brazil	China	India	Indonesia	Mexico	SouthAfrica	Turkey	Ukraine

* Reshape 	
	local i = 0 
	foreach K in "${countrynames}" {
		local i = `i' + 1
		gen value`i' = `K'
		
	}

	drop Highincome-Ukraine
	reshape long value , i(policy) j(ccode)

	gen countryname = ""
	local i = 0 
	foreach K in "${countrynames}" {
		local i = `i' + 1
		replace countryname = "`K'" if ccode == `i'
		
	}
	
* Rename countries	
	replace countryname = "South Korea" if countryname == "SouthKorea"
	replace countryname = "South Africa" if countryname == "SouthAfrica"
	replace countryname = "United Kingdom" if countryname == "UnitedKingdom"
	replace countryname = "United States" if countryname == "UnitedStates"
	replace countryname = "Non-OECD" if countryname == "NonOECD"
	replace countryname = "{bf: Middle-income}" if countryname == "Middleincome"
	replace countryname = "{bf: High-income}" if countryname == "Highincome"
	
* Create space between country groupings 
	expand 2 if country == "{bf: Middle-income}", gen(new)
	replace country = "split" if new ==1 

	replace ccode = ccode+1 if ccode >= 14
	replace ccode = 14 if new ==1 
	replace value = . if new == 1 
	drop new 
		labmask ccode, val(country)	

* Replace % to be based out of 100 
	replace value = value*100
	
* Globals for break lines 
	global x1 = 0.5
	global x2 = 14 
	global w1 = 10
	global w2 = 4


end 

* Run the program for color scheme
	datasetup


*--------------------------------------
*	2/ Figure 7: Knowledge Positive Countries ALL questions
*--------------------------------------
clear 
* Open data 
	import excel using "${input}knowledge_full_countries.xlsx", firstrow clear 
	ren A policy 

* Run program 
	heatplotset 
	* Locals for break lines 
	loc x1 = 0.5
	loc x2 = 16 
	loc w1 = 10
	loc w2 = 4

* Rename and order outcomes/policies  
	replace policy = "GHG footprint per capita of different regions" if strpos(policy, "Correctly compares")
	replace policy = subinstr(policy, "CO2", "CO{sub:2}", .) 
	replace policy = subinstr(policy, "warning", "warming", .) 
	
	gen order=. 
	replace order = 1 if strpos(policy, "exists") | strpos(policy, "half")  
	replace	order = 2 if strpos(policy, "footprint") 
	replace order = 3 if strpos(policy, "capita emissions")  | strpos(policy, "Total emissions")
	replace order = 4 if strpos(lower(policy), "greenhouse")
	replace order = 5 if strpos(policy, "unabated")
	
	replace policy = subinstr(policy, " if CC goes unabated", "", .)
	
	gsort ccode order -value
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 
	
* Add header breaks 
	forval i= 2/5 {
	replace suborder = suborder+(`i'-1) if order==`i'
	}
	
	d, sh 
	global Norig r(N)
	local new = _N + 5
    set obs `new'
	
	replace policy = "{it:    }" + policy if _n <= $Norig 
	
	replace ccode = 1 if _n>$Norig 
	replace value = . if _n>$Norig 
	
	replace suborder = 0 if _n== ($Norig +1 )
	replace policy = "{bf: CC is real, human-made, & its dynamics}" if suborder==0 
	
	replace suborder = 3 if _n== ($Norig +2 )
	replace policy = "{bf: GHG emission ranking}" if suborder == 3
	
	replace suborder = 10 if _n== ($Norig +3 )
	replace policy = "{bf: CC gases}" if suborder == 10
	
	replace suborder = 15 if _n== ($Norig +4 )
	replace policy = "{bf: CC impacts if CC goes unabated}" if suborder == 15
	
	
	gen polcode = suborder 
	labmask polcode , val(policy)

	loc yaddline 
	foreach i in 0.48 3.5 9.5 14.5 {
	loc k = `i'+1
	loc yaddline `yaddline' (scatteri `k' $x1 `i' $x1, recast(line)  lwidth($w1) lcolor(white) ls(solid) xlabel(none) ) 
	}
	
	
* Heatplot
	* Create spacing between country groupings 
	loc base 18.75
	loc addline (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 

	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}

	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
	   $xaxis1 /// 
	   yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-143)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=70 r=1)) ///
	   plotregion(margin(b=0 t=0 r = 1 l= 0 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		 $xaxis2 ///
		 xlabel( $countrylab )  ) ///
		   `addline' `yaddline' ) /// 
		 scheme(plotplain)  aspectratio(0.8)
		
		* Save 
		graph export "${gitpath}/figures/FINAL_FIGURES/Figure7.${ft}", replace
		
*--------------------------------------------------------------------------------------------------------------------------
*	3/ Figure 9: Willing Conditions
*--------------------------------------------------------------------------------------------------------------------------
clear
* Open data 
	import excel using "${input}willingness_conditions_all_positive_countries.xlsx", firstrow clear 
	ren A policy 

* Run program 
	heatplotset 

* Rename and order outcomes/policies 
	
	gen 	order = 1 if strpos(policy, "A lot willing to")
	replace order = 2 if strpos(policy, "Condition willing:")
	replace order = 3 if strpos(policy, "Donation") | strpos(policy, "petition")
	replace policy = subinstr(policy, "A lot willing to", "", .) 
	replace policy = subinstr(policy, "Condition willing:", "", .) 
	replace policy = subinstr(policy, "beef", "beef/meat", .) 
	replace policy = subinstr(policy, "The most well off", "The well-off", .) 
	replace policy =  " One's community also changing behaviors" if strpos(policy, "People around you also changing their behavior")
	replace policy =  " Country adopting ambitious climate policies" if strpos(policy, "Ambitious climate policies")
	replace policy = " Willing to sign petition supporting climate action" if strpos(policy, "Willing to sign petition")
	replace policy = " Willing to donate to reforestation cause (hypothetical)" if strpos( policy, "Donation")

	gsort ccode order -value
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 
	
	forval i=1/3 {
	replace suborder = suborder+(`i'-1) if order==`i' 
	}
* Add header breaks 
	d, sh 
	global Norig r(N)
	local new = _N + 3
    set obs `new'
	
	replace policy = "{it:    }" + policy if _n <= $Norig 
	
	replace ccode = 1 if _n>$Norig 
	replace value = . if _n>$Norig 
	
	replace suborder = 0 if _n== ($Norig +1 )
	replace policy = "{bf: Willingness to adopt climate-friendly behaviors}" if suborder==0
	replace suborder = 6 if _n== ($Norig +2 )
	replace policy = "{bf: Factors that would encourage behavior adoption}" if suborder==6
	replace suborder = 11 if _n== ($Norig +3 )
	replace policy =  `"{bf: Real-stakes}"'  if suborder==11
	
	loc yaddline 
	foreach i in 0.48 6.5 11.5 {
	    loc k = `i'+1
	loc yaddline `yaddline' (scatteri `k' $x1 `i' $x1, recast(line)  lwidth($w1) lcolor(white) ls(solid) xlabel(none) ) 

	} 	
	
	gen polcode = suborder 
	labmask polcode , val(policy)
	sort ccode polcode 

* Heatplot
	* Adjust text 
	 loc basetext -11
 
	* Create spacing between country groupings 
	loc base 14.75
	loc addline  (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 

	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1 ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,   angle(horizontal) /// 
		 labgap(-144)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=61 r=1)) ///
	   plotregion(margin(b=0 t=0 r = 1 l= 0 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		 $xaxis2 ///
		 xlabel( $countrylab  ) ) ///
		   `addline' `yaddline' ) /// 
		 scheme(plotplain)  aspectratio(0.8)
		
		* Save 
		graph export "${gitpath}/figures/FINAL_FIGURES/Figure9.${ft}", replace
		
*--------------------------------------------------------------------------------------------------------------------------
*	4/ Figures 10 and A5: National Policies (NEW) REVISED
*--------------------------------------------------------------------------------------------------------------------------
foreach type in positive share  {

loc file national_policies_new_`type'_countries
clear
* Open data 
	import excel using "${input}`file'.xlsx", firstrow clear 
	ren A policyold 
	gen policy = policyold 

* Relabel policies 
	replace policy = subinstr(policy, "LDC", "low-income countries", . )
	replace policy = subinstr(policy, "technos", "technologies", . )
	replace policy = subinstr(policy, "HH", "households", . )
	replace policy = subinstr(policy, "The removal", "Removal", . )
	replace policy = subinstr(policy, "The ban", "Ban", . )
	replace policy = subinstr(policy, "A reduction", "Reduction", . )
	replace policy = subinstr(policy, " (e.g. public transport)", "", . )

	
	replace policy = "Ban on combustion-engine vehicles w. alternatives available" if strpos(policy, "alternatives available")
	replace policy = "Ban on polluting cars in city centers" if strpos(policy, "Ban polluting cars in city centers")
	replace policy = "A high tax on cattle products, doubling beef prices" if policy =="A high tax on cattle products, so that the price of beef doubles"
	replace policy = "Subsidies on organic and local vegetables" if strpos(policy, "fruit")
	
	replace policy = subinstr(policy, "CT: ", "", .)
	replace	policy = "Cash transfers to constrained households"  if strpos(policy,"Cash transfers to constrained households")
	replace policy = "Subsidies to low-carbon tech." if strpos(policy , " Subsidies to low-carbon technologies")

	
	replace policy = subinstr(policy, "combustion engine", "combustion-engine", . )
	
* Run program 
	heatplotset 

* Rename and order outcomes/policies 
    cap drop order 
    gen order =. 
	replace order = 1 if (strpos(policy, "Green infrastructure program") | strpos(policy, "Carbon tax with cash transfers") | policy== "Ban on combustion-engine cars" )
	replace order = 2 if strpos(policy, "Ban on polluting") | strpos(policy, "alternatives ") | strpos(policy, "flying")  
	replace order = 3 if  (strpos(policy, "fossil fuels") | strpos(policy, "clean energy in low") | strpos(policy, "buildings")  | strpos(policy, "low-carbon tech")  ) & strpos(policyold, "CT: ")==0
	replace order = 4 if strpos(policy, "cattle") | strpos(policy, "vegetables")
	replace order = 5 if strpos(policyold, "CT: ") | strpos(policyold, "(CT)") | policy=="Carbon tax with progressive transfers"
	
	gen 	pos = 1 if  strpos(policy, "Green infrastructure program")
	replace pos = 2 if policy== "Ban on combustion-engine cars" 
	replace pos = 3 if  policy =="Carbon tax with cash transfers"
	replace pos = 4 if strpos(policy, "Ban on polluting")
	replace pos = 5 if strpos(policy, "alternatives ") 
	replace pos = 6 if strpos(policy, "flying") 
	replace pos = 7 if strpos(policy, "low-carbon tech")   & strpos(policyold, "CT: ")==0
	replace pos = 8 if strpos(policy, "buildings")
	replace pos = 9 if strpos(policy, "clean energy in low")
	replace pos = 10 if strpos(policy, "fossil fuels") 
	replace pos = 11 if strpos(policy, "vegetables")
	replace pos = 12 if strpos(policy, "intensive cattle")
	replace pos = 13 if strpos(policy, "subsidies for cattle")
	replace pos = 14 if strpos(policy, "tax on cattle")
	replace pos = 15 if strpos(policy, "environmental") & strpos(policyold, "CT: ")
	replace pos = 16 if strpos(policy, "low-carbon") & strpos(policyold, "CT: ")
	replace pos = 17 if strpos(policy, "personal") & strpos(policyold, "CT: ")
	replace pos = 18 if strpos(policy, "poorest") & strpos(policyold, "CT: ")
	replace pos = 19 if strpos(policy, "constrained") & strpos(policyold, "CT")
	replace pos = 20 if strpos(policy, "rebates") & strpos(policyold, "CT: ") 
	replace pos = 21 if strpos(policy, "deficit") & strpos(policyold, "CT: ")
	replace pos = 22 if policy=="Carbon tax with progressive transfers"
	replace pos = 23 if strpos(policy, "Equal") & strpos(policyold, "CT: ")
	replace pos = 24 if strpos(policy, "corporate") & strpos(policyold, "CT: ")
	
	replace policy = "Progressive transfers" if policy =="Carbon tax with progressive transfers"

	*gsort ccode order -value 
	gsort ccode order pos 
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 
	
	forval i= 2/5 {
	replace suborder = suborder+(`i'-1) if order==`i' 
	}
		
* Add header breaks 
	d, sh 
	global Norig r(N)
	local new = _N + 5
    set obs `new'
	
	replace policy = "{it:    }" + policy if _n <= $Norig 
	
	replace ccode = 1 if _n>$Norig 
	replace value = . if _n>$Norig 
	

	replace suborder = 0 if _n== ($Norig +1 )
	replace policy = "{bf: Main Policies Studied}" if suborder==0
	replace suborder = 4 if _n== ($Norig +2 )
	replace policy = "{bf: Transportation Policies}" if suborder==4
	replace suborder = 8 if _n== ($Norig +3 )
	replace policy = "{bf: Energy Policies}" if suborder==8	
	replace suborder = 13 if _n== ($Norig +4 )
	replace policy = "{bf: Food Policies}" if suborder==13
	replace suborder = 18 if _n== ($Norig +5 )
	replace policy = "{bf: Support for Carbon Tax With:}" if suborder==18

	
	gen polcode = suborder 
	labmask polcode , val(policy)
	sort ccode polcode
	assert polcode!=. 
	
	loc yaddline 
	
	foreach i in 0.5 4.5 8.5 13.5 18.5  {
	    loc k = `i'+1
		loc yaddline `yaddline' (scatteri `k' $x1 `i' $x1, recast(line)  lwidth($w1) lcolor(white) ls(solid) xlabel(none) ) 
	}
	
* Heatplot
	* Adjust text 
	 loc basetext -11
 
	* Create spacing between country groupings 
	loc base 29.75
	loc addline (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 

	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) ) ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1 ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-145)     labsize(2.3) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=67 r=2)  ) ///
	   plotregion(margin(b=0 t=0 r = 2 l= 2 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		 $xaxis2  ///
		 xlabel( $countrylab ) ) ///
		   `addline' `yaddline' ) /// 
		 scheme(plotplain)  aspectratio(1) 
		
		* Save 
		if "`type'" == "positive" {
			graph export "${gitpath}/figures/FINAL_FIGURES/Figure10.${ft}", replace
		}
		else {
			graph export "${gitpath}/figures/FINAL_FIGURES/FigureA5.${ft}", replace
		}
}

*--------------------------------------------------------------------------------------------------------------------------
*	5/ Figure 12: Main Policies REVISED 
*--------------------------------------------------------------------------------------------------------------------------
foreach type in positive {
 
clear 

* Open data 
	import excel using "${input}main_policies_all_win_`type'_3.xlsx",  clear 
	ren A policy 
	ren B green_hi 
	ren C green_3 
	ren D green_mi
	
	ren E tax_hi 
	ren F tax_3 
	ren G tax_mi 
	
	ren H ban_hi 
	ren I ban_3
	ren J ban_mi 
	
	drop if policy ==""
	
	destring *, replace 

* Heatplot Set
	
	* Reshape 
	local i = 0 
	foreach var of varlist green_hi-ban_mi {
		local i = `i' + 1
		gen value`i' = `var'
	}

	drop green_hi-ban_mi
	reshape long value , i(policy) j(gcode)

	gen group = ""
	local i = 0 
	foreach var in green_hi green_3 green_mi tax_hi tax_3 tax_mi ban_hi ban_3 ban_mi  {
		local i = `i' + 1
		replace group = "`var'" if gcode == `i'
		
	}
	
* Rename countries	
	gen groupold= group
	
	foreach var in green tax ban {
	    replace group = "High Income" if groupold =="`var'_hi"
		replace group = "Other Middle Income" if groupold =="`var'_mi"
		replace group = "China, India, Indonesia" if groupold =="`var'_3"
	}
	

* Create space between country groupings 
	expand 3 if groupold == "green_hi", gen(new)
	replace value = . if new == 1 
	replace group = "split" if new ==1 
	
	
	replace gcode = gcode+2 if inlist(gcode, 7,8,9)
	replace gcode = gcode+1 if inlist(gcode, 4,5,6)

	bys policy group: gen dup = _n if new ==1
	replace gcode = 4 if new ==1 & dup ==1
	replace gcode = 8 if new ==1 & dup ==2
	drop dup
	drop new 
	labmask gcode, val(group)	

* Replace % to be based out of 100 
	replace value = value*100


	* Rename and order outcomes/policies 
	gen 	order = 1 if   strpos(policy, "Reduce") | strpos(policy, "electricity") 
	replace order = 2 if strpos(policy, "Encourage") | strpos(policy, "public trans")  
	replace order = 3 if strpos(policy, "economy") | strpos(policy, "Costless") 
	replace order = 5 if strpos(policy, "Would gain") 
	replace order = 6 if strpos(lower(policy), "fair") |  policy == "Support"
	replace policy = "Main climate policies are fair" if strpos(policy, "fair") 
	replace policy = "Support main climate policies" if strpos(policy, "Support") 
	replace policy = subinstr(policy, "CO2", "CO{sub:2}", .)
	replace policy = subinstr(policy, "Your household", "Own household", .)	
	
	drop if strpos(policy, "Large effect")
	
	gen temp1 = _n 
	gsort gcode order temp1 
	gen temp = _n if gcode ==1 
	bys policy : egen suborder = max(temp)
	drop temp* 
	
	replace policy = subinstr(policy, "Would gain: ", "", .)
	replace policy = subinstr(policy, " financially", "", .)
	replace policy = subinstr(policy, "Encourage people to drive less", "Encourage less driving", .)
	
	forval i= 2/6 {
	replace suborder = suborder+(`i'-1) if order==`i' 
	}
	
	drop suborder 
	gen     suborder = 1 if strpos(policy, "air pollution")
	replace suborder = 2 if strpos(policy, "emissions")
	replace suborder = 3 if strpos(policy, "electricity")
	replace suborder = 4 if strpos(policy, "insulation")
	replace suborder = 5 if strpos(policy, "public transport") | strpos(policy, "drive")
	replace suborder = 6 if strpos(policy, "Positive effect on economy")
	replace suborder = 7 if strpos(policy, "Large effect on economy")
	replace suborder = 8 if strpos(policy, "Costless")
	
	replace suborder = 11 if strpos(policy, "rural")
	replace suborder = 12 if strpos(policy, "Low-income")
	replace suborder = 13 if strpos(policy, "middle class")
	replace suborder = 14 if strpos(policy, "High-income")
	
	replace suborder = 16 if strpos(policy, "Own household")
	
	replace suborder = 18 if strpos(policy, "Support")
	replace suborder = 19 if strpos(policy, "are fair")	
	
	replace policy = "Believes own household would gain" if policy =="Own household"
* Add header breaks 
	d, sh 
	global Norig r(N)
	local new = _N + 5
    set obs `new'
	
	replace policy = "{it:    }" + policy if _n <= $Norig 
	
	replace gcode = 1 if _n>$Norig 
	replace value = . if _n>$Norig 
	
	replace suborder = 0 if _n== ($Norig +1 )
	replace policy = "{bf: Effectiveness of Main Climate Policies}" if suborder==0
	replace suborder = 9 if _n== ($Norig +2 )
	replace policy =  "{bf: Distributional Impacts of Main Climate Policies}"  if suborder==9
	replace suborder = 10 if _n== ($Norig +3 )
	replace policy =  "{it: Believes the following groups would gain}" if suborder==10
	replace suborder = 15 if _n== ($Norig +4 )
	replace policy = "{bf: Self-Interest}" if suborder==15
	replace suborder = 17 if _n== ($Norig +5 )
	replace policy = "{bf: Perceived Fairness and Support}" if suborder==17
	
	gen polcode = suborder 
	labmask polcode , val(policy)
	sort gcode polcode
	assert polcode!=.
	* Globals for break lines 
	global x1 = 0.5
	global x2 = 14 
	global w1 = 10
	global w2 = 4
	
	loc yaddline 
	foreach i in 0.45  8.5 9.5 14.5 16.5 {
	    loc k = `i'+1
	loc yaddline `yaddline' (scatteri `k' $x1 `i' $x1, recast(line)  lwidth(20) lcolor(white) ls(solid) xlabel(none) ) 

	}
	
* Heatplot
	* Adjust text 
	 loc basetext -4
	 loc basetext2 -2
 
	* Create spacing between country groupings 
	loc base 19.75
	loc addline 
	loc addline `addline' (scatteri `base' 4 0 4 , recast(line)  lwidth(7) lcolor(white) ls(solid) xlabel(none) ) 
	loc addline `addline' (scatteri `base' 8 0 8 , recast(line)  lwidth(7) lcolor(white) ls(solid) xlabel(none) ) 

	lab def gcode 3 " " 6 " " 9 " " , modify
	lab def gcode 1 " " 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " , modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.gcode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1  ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-145)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=64 r=2)) ///
	   plotregion(margin(b=0 t=1 r = 8 l= 1 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode gcode,  ///
		 color(%0) ///
		 $xaxis2 /// 
		 xlabel( 1/12, ///
		   valuelabels  labsize(1.8)  labcolor(black) ///
		   nogrid  ///
		   axis(2)  angle (20) glc(black) tlw(vthin) tl(*.5) tlc(black)  )  ///
		    text(`basetext' 0.5 "{bf: Green Infrastructure}" "{bf: Program}" ///
				 `basetext' 4.4 "{bf: Carbon Tax}" "{bf: w. Cash Transfers}" ///
				 `basetext' 8.0 "{bf: Ban on Combustion-Engine}" "{bf: Cars}" ///
				 `basetext2' 0.5 "High" "Income" ///
				 `basetext2' 1.5 "Indonesia"  "India"  "China" ///
				 `basetext2' 2.8 "Other" "Middle" "Income" ///
				 `basetext2' 4.5 "High" "Income" ///
				 `basetext2' 5.5 "Indonesia"  "India"  "China" ///
				 `basetext2' 6.8 "Other" "Middle" "Income" ///
				 `basetext2' 8.5 "High" "Income" ///
				 `basetext2' 9.5  "Indonesia"  "India"  "China" ///
				 `basetext2' 10.8 "Other" "Middle" "Income" ///
				, size(2.1) color(black) place(e) ) ) ///
		   `addline' `yaddline'	) /// 
		 scheme(plotplain)  aspectratio(0.8)
		
		* Save 
			graph export "${gitpath}/figures/FINAL_FIGURES/Figure12.${ft}", replace

}


*--------------------------------------
*	6/ Figure A4 Panel A: Future  Positive Countries 
*--------------------------------------
clear 
* Open data 
	import excel using "${input}future_signed_positive_countries.xlsx", firstrow clear 
	ren A policy 

* Run program 
	heatplotset 
	
	gen     pos = 1 if strpos(policy, "extinction")
	replace pos = 2 if strpos(policy, "negatively affect me")
	replace pos = 3 if strpos(policy, "richer")
	replace pos = 4 if strpos(policy, "Ambitious climate policies will affect my own")
	replace pos = 5 if strpos(policy, "Ambitious climate policies have positive")
	replace pos = 6 if strpos(policy, "halt climate change")
	replace pos = 7 if strpos(policy, "technically possible")
	
	replace policy = "It is unlikely or very unlikely that climate change causes extinction of humankind, if nothing is done to limit CC" if policy=="It is unlikely or very unlikely that climate change causes extinction of humankind"

	
* Rename and order outcomes/policies  
	gsort ccode pos
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 
	
	gen polcode = suborder 
	labmask polcode , val(policy)
	
	
* Wrap labels
	splitvallabels polcode , length(47)
	loc ylab `r(relabel)'
	di "`ylab'" 


* Heatplot
	* Adjust text 
	 loc basetext -12.5
 
	* Create spacing between country groupings 
	loc base 7.75
	loc addline (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 
	
	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1 ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-140)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=56 r=1)) ///
	   plotregion(margin(b=0 t=0 r = 1 l= 0 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		 $xaxis2 ///
		 xlabel( $countrylab  ) ) ///
		   `addline' ) /// 
		 scheme(plotplain)  aspectratio(0.7)
		
		* Save 
			graph export "${gitpath}/figures/FINAL_FIGURES/FigureA4a.${ft}", replace
		loc ylab

*----------------------------------
*	7/ Figure A7: Funding 
*----------------------------------
clear 
datasetup
	
* Select vars
	global invest_funding "investments_funding_debt investments_funding_sales_tax investments_funding_wealth_tax investments_funding_less_social investments_funding_less_mil*  investments_bin"
	global invest_funding "invest_fund_debt invest_fund_sales_tax invest_fund_wealth_tax invest_fund_less_soc invest_fund_less_mil investments_bin"
	
* Keep control only 
	keep if treatment ==1 
	
* Group countries 
	gen hi_income = 0 
	foreach K in $good_data {
	    replace hi_income = 1  if country =="`K'"
	}		
	preserve 
	collapse (mean) $invest_funding [w = weight] , by(hi_income)
	gen country = "High Income" if hi_income == 1 
	replace country = "Middle Income" if hi_income==0 
	drop hi_inc
	tempfile meanvals 
	save 	`meanvals'
	restore 
	
* Create means and transpose the data 
	sum $invest_funding
	collapse (mean) $invest_funding [w = weight] , by(country)
	
* Append group means 
	append using `meanvals'
	
* Rename vars and countries 
	sxpose, clear   force destring firstnames  
	ren _var21 Middleincome
	ren _var22 Highincome
	
	order Highincome $good_data Middleincome $bad_data 
	
	ren (Highincome	AU	CA	DE	DK	SP	FR	IT	JP	SK	PL	UK	US	Middleincome	MX	TR	BR	CN	IA	ID	SA	UA) (Highincome	Australia	Canada	Germany	Denmark	Spain	France	Italy	Japan	SouthKorea	Poland	UnitedKingdom	UnitedStates	Middleincome	Mexico	Turkey	Brazil	China	India	Indonesia	SouthAfrica	Ukraine)
	
	order Highincome	Australia	Canada	Denmark	France	Germany	Italy	Japan	Poland	SouthKorea	Spain	UnitedKingdom	UnitedStates	Middleincome	Brazil	China	India	Indonesia	Mexico	SouthAfrica	Turkey	Ukraine
	
* Name the vars 
	gen     funding = "Additional public debt" if _n == 1 
	replace funding = "Increase in sales taxes" if _n == 2 
	replace funding = "Increase in taxes on the wealthiest" if _n == 3 
	replace funding = "Reduction in social spending" if _n == 4 
	replace funding = "Reduction in military spending" if _n == 5 
	replace funding = "Carbon tax* (increasing gasoline prices by 0.40cts/gallon)" if _n== 6
	ren funding policy 


* Run Heaplot set program 
	heatplotset
	
* Rename and order outcomes/policies 
	gsort ccode -value
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 

	gen polcode = suborder 
	labmask polcode , val(policy)
	sort ccode polcode 
	
	
* Heatplot
	* Adjust text 
	 loc basetext -14
 
	* Create spacing between country groupings 
	loc base 6.75
	loc addline (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 

	
	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1 ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-145)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=61 r=1)) ///
	   plotregion(margin(b=0 t=0 r = 1 l= 0 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		$xaxis2 ///
		 xlabel( $countrylab  ) ///
		   ) ///
		   `addline' ) /// 
		 scheme(plotplain)  aspectratio(0.6)
	
* Save 
			graph export "${gitpath}/figures/FINAL_FIGURES/FigureA7.${ft}", replace


*--------------------------------------------------------------------------------------------------------------------------
*	8.1/ Figure A13: Standard Win Positive 
*--------------------------------------------------------------------------------------------------------------------------

foreach sign in positive {
clear
* Open data 
	import excel using "${input}standard_all_win_`sign'_countries.xlsx", firstrow clear 
	ren A policy 


* Run program 
	heatplotset 

* Rename and order outcomes/policies 
	gen 	order = 1 if   strpos(policy, "Reduce") | strpos(policy, "electricity") 
	replace order = 2 if strpos(policy, "Encourage") | strpos(policy, "public trans")  
	replace order = 3 if strpos(policy, "economy") | strpos(policy, "Costless") 
	replace order = 5 if strpos(policy, "Would gain") 
	replace order = 6 if strpos(lower(policy), "fair") |  policy == "Support"
	replace policy = "Main climate policy is fair" if strpos(policy, "fair") 
	replace policy = "Support main climate policy" if strpos(policy, "Support") 
	replace policy = subinstr(policy, "CO2", "CO{sub:2}", .)
	replace policy = subinstr(policy, "Your household", "Own household", .)	
	
	gsort ccode order -value
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 
	
	replace policy = subinstr(policy, "Would gain: ", "", .)
	replace policy = subinstr(policy, " financially", "", .)
	
	forval i= 2/6 {
	replace suborder = suborder+(`i'-1) if order==`i' 
	}
	
	drop suborder 
	gen     suborder = 1 if strpos(policy, "air pollution")
	replace suborder = 2 if strpos(policy, "emissions")
	replace suborder = 3 if strpos(policy, "electricity")
	replace suborder = 4 if strpos(policy, "insulation")
	replace suborder = 5 if strpos(policy, "public transport") | strpos(policy, "drive")
	replace suborder = 6 if strpos(policy, "Positive effect on economy")
	replace suborder = 7 if strpos(policy, "Large effect on economy")
	replace suborder = 8 if strpos(policy, "Costless")
	
	replace suborder = 11 if strpos(policy, "rural")
	replace suborder = 12 if strpos(policy, "Low-income")
	replace suborder = 13 if strpos(policy, "middle class")
	replace suborder = 14 if strpos(policy, "High-income")
	
	replace suborder = 16 if strpos(policy, "Own household")	
	
	replace suborder = 18 if strpos(policy, "Support")
	replace suborder = 19 if strpos(policy, "is fair")	
	
* Add header breaks 
	d, sh 
	global Norig r(N)
	local new = _N + 5
    set obs `new'
	
	replace policy = "{it:    }" + policy if _n <= $Norig 
	
	replace ccode = 1 if _n>$Norig 
	replace value = . if _n>$Norig 
	
	replace suborder = 0 if _n== ($Norig +1 )
	replace policy = "{bf: Effectiveness of the Climate Policy}" if suborder==0
	replace suborder = 9 if _n== ($Norig +2 )
	replace policy = "{bf: Distributional Impacts of the Climate Policy}" if suborder==9
	replace suborder = 10 if _n== ($Norig +3 )
	replace policy = "{it: Believes the following groups would gain}" if suborder==10
	replace suborder = 15 if _n== ($Norig +4 )
	replace policy = "{bf: Self-Interest}" if suborder==15
	replace suborder = 17 if _n== ($Norig +5 )
	replace policy = "{bf: Perceived Fairness and Support}" if suborder==17
	
	gen polcode = suborder 
	labmask polcode , val(policy)
	sort ccode polcode
	assert polcode!=. 
	
	loc yaddline 
	foreach i in 0.5 6.5 7 7.5 12.5 14.5 {
	loc k = `i'+1
	loc yaddline `yaddline' (scatteri `k' $x1 `i' $x1, recast(line)  lwidth($w1) lcolor(white) ls(solid) xlabel(none) ) 
	}
	
* Heatplot
	* Adjust text 
	 loc basetext -11
 
	* Create spacing between country groupings 
	loc base 18.75
	loc addline (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 

	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1 ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-145)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=55 r=2)) ///
	   plotregion(margin(b=0 t=0 r = 4 l= 0 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		 $xaxis2 ///
		 xlabel( $countrylab  ) ) ///
		   `addline' `yaddline' ) /// 
		 scheme(plotplain)  aspectratio(0.8)
		
		* Save 
			graph export "${gitpath}/figures/FINAL_FIGURES/FigureA13.${ft}", replace

		
*--------------------------------------------------------------------------------------------------------------------------
*	8.2/ Figure A14: Tax Transfers Win Positive 
*-------------------------------------------------------------------------------------------------------------------------- 
clear
* Open data 
	import excel using "${input}tax_transfers_all_win_`sign'_countries.xlsx", firstrow clear 
	ren A policy 
	
* Run program 
	heatplotset 

* Rename and order outcomes/policies 
	gen 	order = 1 if   strpos(policy, "Reduce") | strpos(policy, "electricity") 
	replace order = 2 if strpos(policy, "Encourage") | strpos(policy, "public trans")  
	replace order = 3 if strpos(policy, "economy") | strpos(policy, "Costless") 
	replace order = 5 if strpos(policy, "Would gain") 
	replace order = 6 if strpos(lower(policy), "fair") |  policy == "Support"
	replace policy = "Main climate policy is fair" if strpos(policy, "fair") 
	replace policy = "Support main climate policy" if strpos(policy, "Support") 
	replace policy = subinstr(policy, "CO2", "CO{sub:2}", .)
	replace policy = subinstr(policy, "Your household", "Own household", .)	
	gsort ccode order -value
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 
	
	replace policy = subinstr(policy, "Would gain: ", "", .)
	replace policy = subinstr(policy, " financially", "", .)

	forval i= 2/6 {
	replace suborder = suborder+(`i'-1) if order==`i' 
	}
	
	drop suborder 
	gen     suborder = 1 if strpos(policy, "air pollution")
	replace suborder = 2 if strpos(policy, "emissions")
	replace suborder = 3 if strpos(policy, "electricity")
	replace suborder = 4 if strpos(policy, "insulation")
	replace suborder = 5 if strpos(policy, "public transport") | strpos(policy, "drive")
	replace suborder = 6 if strpos(policy, "Positive effect on economy")
	replace suborder = 7 if strpos(policy, "Large effect on economy")
	replace suborder = 8 if strpos(policy, "Costless")
	
	replace suborder = 11 if strpos(policy, "rural")
	replace suborder = 12 if strpos(policy, "Low-income")
	replace suborder = 13 if strpos(policy, "middle class")
	replace suborder = 14 if strpos(policy, "High-income")
	
	replace suborder = 16 if strpos(policy, "Own household")
	
	replace suborder = 18 if strpos(policy, "Support")
	replace suborder = 19 if strpos(policy, "is fair")

* Add header breaks 
	d, sh 
	global Norig r(N)
	local new = _N + 5
    set obs `new'
	
	replace policy = "{it:    }" + policy if _n <= $Norig 
	
	replace ccode = 1 if _n>$Norig 
	replace value = . if _n>$Norig 
	
	replace suborder = 0 if _n== ($Norig +1 )
	replace policy = "{bf: Effectiveness of the Climate Policy}" if suborder==0
	replace suborder = 9 if _n== ($Norig +2 )
	replace policy = "{bf: Distributional Impacts of the Climate Policy}" if suborder==9
	replace suborder = 10 if _n== ($Norig +3 )
	replace policy = "{it: Believes the following groups would gain}" if suborder==10	
	replace suborder = 15 if _n== ($Norig +4 )
	replace policy = "{bf: Self-Interest}" if suborder==15
	replace suborder = 17 if _n== ($Norig +5 )
	replace policy = "{bf: Perceived Fairness and Support}" if suborder==17
	
	gen polcode = suborder 
	labmask polcode , val(policy)
	sort ccode polcode
	assert polcode!=. 
	
	loc yaddline 
	foreach i in 0.5 8.5 9 9.5 14.5 16.5 {
	    loc k = `i'+1
		loc yaddline `yaddline' (scatteri `k' $x1 `i' $x1, recast(line)  lwidth($w1) lcolor(white) ls(solid) xlabel(none) ) 
	}
	
* Heatplot
	* Adjust text 
	 loc basetext -11
 
	* Create spacing between country groupings 
	loc base 18.75
	loc addline (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 

	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1 ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-145)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=55 r=2)) ///
	   plotregion(margin(b=0 t=0 r = 4 l= 0 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		 $xaxis2  ///
		 xlabel( $countrylab ) ) ///
		   `addline' `yaddline' ) /// 
		 scheme(plotplain)  aspectratio(0.8)
		
		* Save 
			graph export "${gitpath}/figures/FINAL_FIGURES/FigureA14.${ft}", replace

*--------------------------------------------------------------------------------------------------------------------------
*	8.3/ Figure A15: Investments Win Positive 
*--------------------------------------------------------------------------------------------------------------------------
clear
* Open data 
	import excel using "${input}investments_all_win_`sign'_countries.xlsx", firstrow clear 
	ren A policy 


* Run program 
	heatplotset 
	


* Rename and order outcomes/policies 
	gen 	order = 1 if   strpos(policy, "Reduce") | strpos(policy, "electricity") 
	replace order = 2 if strpos(policy, "Encourage") | strpos(policy, "public trans")  
	replace order = 3 if strpos(policy, "economy") | strpos(policy, "Costless") 
	replace order = 5 if strpos(policy, "Would gain") 
	replace order = 6 if strpos(lower(policy), "fair") |  policy == "Support"
	replace policy = "Main climate policy is fair" if strpos(policy, "fair") 
	replace policy = "Support main climate policy" if strpos(policy, "Support") 
	replace policy = subinstr(policy, "CO2", "CO{sub:2}", .)
	replace policy = subinstr(policy, "Your household", "Own household", .)	
	
	gsort ccode order -value
	gen temp = _n if ccode ==1 
	bys policy : egen suborder = max(temp)
	drop temp 
	
	replace policy = subinstr(policy, "Would gain: ", "", .)
	replace policy = subinstr(policy, " financially", "", .)
	
	forval i= 2/6 {
	replace suborder = suborder+(`i'-1) if order==`i' 
	}
	
	
	drop suborder 
	gen     suborder = 1 if strpos(policy, "air pollution")
	replace suborder = 2 if strpos(policy, "emissions")
	replace suborder = 3 if strpos(policy, "electricity")
	replace suborder = 4 if strpos(policy, "insulation")
	replace suborder = 5 if strpos(policy, "public transport") | strpos(policy, "drive")
	replace suborder = 6 if strpos(policy, "Positive effect on economy")
	replace suborder = 7 if strpos(policy, "Large effect on economy")
	replace suborder = 8 if strpos(policy, "Costless")
	
	replace suborder = 11 if strpos(policy, "rural")
	replace suborder = 12 if strpos(policy, "Low-income")
	replace suborder = 13 if strpos(policy, "middle class")
	replace suborder = 14 if strpos(policy, "High-income")
	
	replace suborder = 16 if strpos(policy, "Own household")
	
	replace suborder = 18 if strpos(policy, "Support")
	replace suborder = 19 if strpos(policy, "is fair")	
		
	
* Add header breaks 
	d, sh 
	global Norig r(N)
	local new = _N + 5
    set obs `new'
	
	replace policy = "{it:    }" + policy if _n <= $Norig 
	
	replace ccode = 1 if _n>$Norig 
	replace value = . if _n>$Norig 
	
	replace suborder = 0 if _n== ($Norig +1 )
	replace policy = "{bf: Effectiveness of the Climate Policy}" if suborder==0
	replace suborder = 9 if _n== ($Norig +2 )
	replace policy = "{bf: Distributional Impacts of the Climate Policy}" if suborder==9
	replace suborder = 10 if _n== ($Norig +3 )
	replace policy = "{it: Believes the following groups would gain}" if suborder==10
	replace suborder = 15 if _n== ($Norig +4 )
	replace policy = "{bf: Self-Interest}" if suborder==15
	replace suborder = 17 if _n== ($Norig +5 )
	replace policy = "{bf: Perceived Fairness and Support}" if suborder==17
	
	gen polcode = suborder 
	labmask polcode , val(policy)
	sort ccode polcode
	assert polcode!=.
	loc yaddline 
	foreach i in 0.5 7.5 8 8.5 13.5 15.5 {
	    loc k = `i'+1
		loc yaddline `yaddline' (scatteri `k' $x1 `i' $x1, recast(line)  lwidth($w1) lcolor(white) ls(solid) xlabel(none) ) 
	}
	
* Heatplot
	* Adjust text 
	 loc basetext -11
 
	* Create spacing between country groupings 
	loc base 18.75
	loc addline (scatteri `base' $x2 0 $x2 , recast(line)  lwidth($w2) lcolor(white) ls(solid) xlabel(none) ) 

	lab def ccode 14 " " 24 " ", modify
	
	* Color cuts 
	loc cuts 
	forval c = 0(1)100 {
		loc cuts `cuts' `c'
	}
	
	* Plot 
	heatplot value i.polcode i.ccode , ///
	 values(format(%2.0fc) mlabcolor(black) mlabsize(vsmall)) ///
	   ytitle("")    ///            
	   xtitle("") /// 
	   missing(fcolor(gs8%40) lcolor(white) lw(0.05) )  ///
	   cuts( `cuts') ///
	   legend(off) ///
		$xaxis1 ///
	 yscale(    noline      alt      reverse     ) ///  
	   ylabel( `ylab' ,     angle(horizontal) /// 
		 labgap(-145)     labsize(2.2) ///
		 noticks     labcolor(black)      nogrid     ) ///   
	   graphregion(margin(l=55 r=2)) ///
	   plotregion(margin(b=0 t=0 r = 4 l= 0 )) ///    
	   p(   lcolor(white)   lwidth(0.1)  lalign(center)   ) ///
		colors(${pal}) ///
		 addplot(      ///
		 (scatter polcode ccode,  ///
		 color(%0) ///
		 $xaxis2 ///
		 xlabel( $countrylab ) ) ///
		   `addline' `yaddline' ) /// 
		 scheme(plotplain)  aspectratio(0.8)
		
		* Save 
			graph export "${gitpath}/figures/FINAL_FIGURES/FigureA15.${ft}", replace
		loc ylab 
		
}
