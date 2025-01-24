/********************************************************************************
					               OECD Climate

Goal: Correlation between climate suppport index and other indicators at the country level  					
Date: Mar 2022 
 
*********************************************************************************/

*----------------------------------
*	0) Preface
*----------------------------------
global externalindicators "${gitpath}/data/external indicators"
global outgraph "${gitpath}/figures/external indicators"

cap mkdir "$outgraph"

loc type positive 
global countrynames "Highincome"	"Australia"	"Canada"	"Denmark"	"France"	"Germany"	"Italy"	"Japan"	"Poland"	"SouthKorea"	"Spain"	"UnitedKingdom"	"UnitedStates" "Middleincome"	"Brazil"	"China"	"India"	"Indonesia"	"Mexico"	"SouthAfrica"	"Turkey"	"Ukraine"	
global countrynames2 "HI" "AU" "CA" "DK" "FR" "DE" "IT" "JP" "PL" "SK" "SP" "UK" "US" "MI" "BR" "CN" "IA" "ID" "MX" "SA" "TR" "UA"


global perceptions "index_affected_subjective index_worried index_main_policies"

*----------------------------------
*   2) Country Level Estimates 
*----------------------------------
* Note: based on underlying data 
datasetup 

* Keep control only 
	keep if treatment ==1 

* Countryname 
  decode country_name, gen(countryname)
  ren country3 iso 
	
* Group countries 
	gen hi_income = 0 
	foreach K in $good_data {
	    replace hi_income = 1  if country =="`K'"
	}		
	preserve 
	collapse (mean) $perceptions [w = weight] , by(hi_income)
	gen countryname = "High Income" if hi_income == 1 
	replace countryname = "Middle Income" if hi_income==0 
    gen country = "HI" if hi_income==1
	replace country = "MI" if hi_income == 0 
	gen iso = "Hinc" if hi_income==1
	replace iso = "Minc" if hi_income == 0 
	drop hi_inc
	tempfile meanvals 
	save 	`meanvals'
	restore 
	
* Create means and transpose the data 
	sum $perceptions 
	collapse (mean) $perceptions  [w = weight] , by(country countryname iso)
	
* Save data 
	tempfile surveydata
	save 	`surveydata', replace 
	

*-------------------------------------------------
*   3) External indicators 
*-------------------------------------------------
* Merge with survey data 
	use `surveydata', clear
	
	* Add Vulnerability index from Adrien
	  gen vulnerability = . 
	  replace vulnerability = .306 if country =="AU" 
	  replace vulnerability = .292 if country =="CA" 
	  replace vulnerability = .34 if country =="DK" 
	  replace vulnerability = .29 if country =="FR" 
	  replace vulnerability = .284 if country =="DE" 
	  replace vulnerability = .314 if country =="IT" 
	  replace vulnerability = .361 if country =="JP" 
	  replace vulnerability = .404 if country =="MX" 
	  replace vulnerability = .317 if country =="PL" 
	  replace vulnerability = .366 if country =="SK" 
	  replace vulnerability = .287 if country =="SP" 
	  replace vulnerability = .348 if country =="TR" 
	  replace vulnerability = .287 if country =="UK" 
	  replace vulnerability = .321 if country =="US" 
	  replace vulnerability = .381 if country =="BR" 
	  replace vulnerability = .388 if country =="CN" 
	  replace vulnerability = .503 if country =="IA" 
	  replace vulnerability = .446 if country =="ID" 
	  replace vulnerability = .406 if country =="SA" 
	  replace vulnerability = .368 if country =="UA" 

	
* Classify countries 
	gen hi_income = 0 
	foreach K in $good_data {
		replace hi_income = 1 if country=="`K'"
	}
	
	
* Scatterplot 
loc ylab ylabel( , format(%2.1fc) nogrid )
loc vulnerabilityt "Vulnerability to CC (Notre-Dame index)" 

loc index_main_policiest "Support for main climate policies index"
 

loc index_worriedt ="Worries about the consequences of CC" 
loc index_affected_subjectivet  = "Believes will suffer from climate change" 

* GRAPHS FOR THE PAPER 
global perceptionspaper "index_affected_subjective index_worried index_main_policies"
global indicatorspaper "vulnerability"
foreach yvar in  $perceptionspaper  {
if "`yvar'" == "index_main_policies" loc ylab ylabel( , format(%2.1fc) nogrid )
if "`yvar'" !="index_main_policies" loc ylab ylabel( , format(%4.2fc) nogrid )
foreach var in $indicatorspaper   {

if "`var'" =="vulnerability" loc xlab xsc(r(0.25 0.55)) xlabel( , format(%4.2fc) nogrid )

preserve 	
	reg `yvar' `var' i.hi_income , r
	predict fline 
	loc cons = _b[_cons]
	loc cons : di %4.3fc `cons'
	loc coef = _b[`var']
	loc coef : di %4.3fc `coef'
	loc se = _se[`var']
	loc se: di %4.3fc `se'
	loc inc = _b[1.hi_income]
	loc inc: di  %4.3fc `inc'
	loc r2 = e(r2)
	loc r2: di %4.3fc `r2'
	
		
	sort `yvar' `var'
	tw(scatter `yvar' `var'  if hi_income==1,  ///
	  mlab(iso) mlabpos(1) mlabgap(*1) mlabcolor("${p1}") mlabsize(vsmall) mcolor("${p1}%80") ) ///
	  (scatter `yvar' `var' if hi_income==0,  ///
	  mlab(iso) mlabpos(1) mlabgap(*1) mlabcolor("${p8}") mlabsize(vsmall) mcolor("${p8}%80") )  ///
	(lfit `yvar' `var'   ,  lcolor("${p2}") lw(0.4) ) , ///
	`ylab' `xlab' ///
	ytitle("``yvar't'") ///
	xtitle(" " "``var't'")  ///
   legend(order(1 2 3 ) label(1 "High-income") label(2 "Middle-income") label(3 "Overall linear fitted values")  symx(2) row(1) size(small))  ///
   note( "{bf: Regression Line:} `cons' + `coef' Indicator + `inc' High Inc Dummy, (s.e. = `se', R{sup:2} = `r2' ) ")
   
	if "`var'" == "vulnerability" & "`yvar'" == "index_main_policies" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA2a.${ft}", replace

	}
	else if "`var'" == "vulnerability" & "`yvar'" == "index_worried" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA2b.${ft}", replace

	}
	else if "`var'" == "vulnerability" & "`yvar'" == "index_affected_subjective" {
		graph export "${gitpath}/figures/FINAL_FIGURES/FigureA2c.${ft}", replace
	}
	else {
		graph export "${outgraph}/`var'_`yvar'_update.${ft}", replace 
	}
restore 
}

} 
