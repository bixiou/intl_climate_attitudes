/********************************************************************************
					 OECD Climate - Bar Graphs 

Date: June 2022 
 
*********************************************************************************/



/********************************************************************************

	Variance Graph 

********************************************************************************/

global input "$gitpath/xlsx/country_comparison$weight_table_extension/"
global output "${gitpath}/figures/all/"

global color1 "215 48 39"
global color2  "253 174 97"
global color3 "247 247 247"
global color4 "171 217 233"
global color5 "69 117 180"
global color6  "92 184 92"

global graphsettings_bar  "graphregion(fcolor(white) lcolor(white) margin( 0 0 0 0 ) ) plotregion( fcolor(none) lcolor(none) margin(1 1 1 1) ) ysize(10) xsize(20)"

do "${code}/OECD_Climate_SetUp.do"
*----------------------------------
*	1/ Set up program
*----------------------------------
cap program drop heatplotset 

program define heatplotset 
* Order countrynames
order Highincome	Australia	Canada	Denmark	France	Germany	Italy	Japan	Poland	SouthKorea	Spain	UnitedKingdom	UnitedStates	Middleincome	Brazil	China	India	Indonesia	Mexico	SouthAfrica	Turkey	Ukraine

global countrynames Highincome	Australia	Canada	Denmark	France	Germany	Italy	Japan	Poland	SouthKorea	Spain	UnitedKingdom	UnitedStates	Middleincome	Brazil	China	India	Indonesia	Mexico	SouthAfrica	Turkey	Ukraine


* Reshape 	
	local i = 0 
	foreach K in ${countrynames} {
		local i = `i' + 1
		gen value`i' = `K'
		
	}

	drop Highincome-Ukraine
	reshape long value , i(policy) j(ccode)

	gen countryname = ""
	local i = 0 
	foreach K in ${countrynames} {
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


*--------------------------------------------------------------------------------------------------------------------------
*	2/ CC_problem_should_fight_positive_countries
*--------------------------------------------------------------------------------------------------------------------------

clear
* Open data 
	loc filename CC_problem_should_fight_positive_countries
	import excel using "${input}//`filename'.xlsx", firstrow clear 
	ren A policy 

* Run program 
	heatplotset 
	
* Merge two policies 
	
	lab def ccode 14 "{bf: }", modify 
	lab val ccode ccode
	
	
	graph bar value , over(policy) over(ccode , lab(angle(45)) ) asyvars ///
	bar(1, color("${color6}%60"))	bar(2, color("${color5}%90")) ///
	legend(  $mainlegendops row(1) symx(2) symy(2) ) ///
	blabel(bar, format(%2.0fc) size(2.5) gap(*.2) pos(outside) color(black)) ///
	ytitle("% of Respondents") ylabel( , nogrid)  $graphsettings_bar

	graph export  "${gitpath}/figures/FINAL_FIGURES/Figure1.${ft}", replace 
