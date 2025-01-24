/********************************************************************************
					               OECD Climate

Goal: Create Representativeness graphs from file created in R			
Date: May 2024
 
*********************************************************************************/
		 
*--------------------------
* Load & Clean Data
*--------------------------	
	datasetup

	use "$gitpath/data/table_sd.dta", clear
	** Compute difference per country
	foreach country in $countries usc_regular usc_extra usc {
		gen `country'_diff = (`country'_sample_mean - `country'_pop)
		replace `country'_diff = 0 if mi(`country'_diff)
	}
	replace variable = "Master or higher (25-64)" if strpos(variable, "Master")


/********************************************************************************

	Create Graph for each country

********************************************************************************/
global graphs_hi ""
global graphs_mi ""

foreach country in $countries usc_regular usc_extra usc {
	preserve
	*--------------------------
	* Create Labels
	*--------------------------	
	** Education Labels
	if inlist("`country'", "BR", "CN", "IA", "ID", "MX", "TR", "UA", "SA") {
		drop if strpos(variable, "College education (25-64)")
	}
	else {
		drop if strpos(variable, "Master")
	}
	** Vote and Regional Labels
	if strpos("`country'", "AU") {
		loc country_label "Australia"
		replace variable = "Liberal/National Coalition" if strpos(variable, "Candidate 1")
		replace variable = "Labor Party" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "New South Wales and ACT" if strpos(variable, "Region 1")
		replace variable = "Queensland" if strpos(variable, "Region 2")
		replace variable = "South Australia" if strpos(variable, "Region 3")
		replace variable = "Victoria and Tasmania" if strpos(variable, "Region 4")
		replace variable = "West Australia" if strpos(variable, "Region 5")
		
	}
	if strpos("`country'", "BR") {
		loc country_label "Brazil"
		replace variable = "Bolsonaro" if strpos(variable, "Candidate 1")
		replace variable = "Haddad" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central-West" if strpos(variable, "Region 1")
		replace variable = "North" if strpos(variable, "Region 2")
		replace variable = "North-East" if strpos(variable, "Region 3")
		replace variable = "South" if strpos(variable, "Region 4")
		replace variable = "South-East" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "CA") {
		loc country_label "Canada"
		replace variable = "Conservative Party" if strpos(variable, "Candidate 1")
		replace variable = "Liberal Party" if strpos(variable, "Candidate 2")
		replace variable = "New Democratic Party" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central" if strpos(variable, "Region 1")
		replace variable = "East" if strpos(variable, "Region 2")
		replace variable = "North West" if strpos(variable, "Region 3")
		replace variable = "Ontario" if strpos(variable, "Region 4")
		replace variable = "Quebec" if strpos(variable, "Region 5")
		
	}
	if strpos("`country'", "CN") {
		loc country_label "China"
		drop if strpos(variable, "Candidate 1")
		drop if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "East" if strpos(variable, "Region 1")
		replace variable = "North" if strpos(variable, "Region 2")
		replace variable = "Northeast" if strpos(variable, "Region 3")
		replace variable = "South Central" if strpos(variable, "Region 4")
		replace variable = "West" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "DE") {
		loc country_label "Germany"
		replace variable = "CDU/CSU" if strpos(variable, "Candidate 1")
		replace variable = "SPD" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central" if strpos(variable, "Region 1")
		replace variable = "Eastern" if strpos(variable, "Region 2")
		replace variable = "Northern" if strpos(variable, "Region 3")
		replace variable = "Southern" if strpos(variable, "Region 4")
		replace variable = "Western" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "DK") {
		loc country_label "Denmark"
		replace variable = "Socialdemokratiet" if strpos(variable, "Candidate 1")
		replace variable = "Venstre" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Hovedstaden" if strpos(variable, "Region 1")
		replace variable = "Midtjylland" if strpos(variable, "Region 2")
		replace variable = "Nordjylland" if strpos(variable, "Region 3")
		replace variable = "Sjælland" if strpos(variable, "Region 4")
		replace variable = "Syddanmark" if strpos(variable, "Region 5")
		
	}
	if strpos("`country'", "FR") {
		loc country_label "France"
		replace variable = "Macron" if strpos(variable, "Candidate 1")
		replace variable = "Le Pen" if strpos(variable, "Candidate 2")
		replace variable = "Fillon" if strpos(variable, "Candidate 3")
		replace variable = "Mélenchon" if strpos(variable, "Candidate 4")
		replace variable = "Île de France" if strpos(variable, "Region 1")
		replace variable = "Nord-Est" if strpos(variable, "Region 2")
		replace variable = "Nord-Ouest" if strpos(variable, "Region 3")
		replace variable = "Sud-Est" if strpos(variable, "Region 4")
		replace variable = "Sud-Ouest" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "IA") {
		loc country_label "India"
		replace variable = "BJP" if strpos(variable, "Candidate 1")
		replace variable = "INC" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central Zonal Council" if strpos(variable, "Region 1")
		replace variable = "Eastern Zonal Council" if strpos(variable, "Region 2")
		replace variable = "Northern Zonal Council" if strpos(variable, "Region 3")
		replace variable = "Southern Zonal Council" if strpos(variable, "Region 4")
		replace variable = "Western Zonal Council" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "ID") {
		loc country_label "Indonesia"
		replace variable = "PDI-P" if strpos(variable, "Candidate 1")
		replace variable = "Gerindra Party" if strpos(variable, "Candidate 2")
		replace variable = "Golkar" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Eastern Islands" if strpos(variable, "Region 1")
		replace variable = "Eastern Java" if strpos(variable, "Region 2")
		replace variable = "Northern Islands" if strpos(variable, "Region 3")
		replace variable = "Sumatra" if strpos(variable, "Region 4")
		replace variable = "Western Java" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "IT") {
		loc country_label "Italy"
		replace variable = "M5S" if strpos(variable, "Candidate 1")
		replace variable = "PD" if strpos(variable, "Candidate 2")
		replace variable = "Lega" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Centre" if strpos(variable, "Region 1")
		replace variable = "Islands" if strpos(variable, "Region 2")
		replace variable = "North-East" if strpos(variable, "Region 3")
		replace variable = "North-West" if strpos(variable, "Region 4")
		replace variable = "South" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "JP") {
		loc country_label "Japan"
		replace variable = "Liberal Democratic Party" if strpos(variable, "Candidate 1")
		replace variable = "CDP" if strpos(variable, "Candidate 2")
		replace variable = "Innovation" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Chubu" if strpos(variable, "Region 1")
		replace variable = "Kansai" if strpos(variable, "Region 2")
		replace variable = "Kanto" if strpos(variable, "Region 3")
		replace variable = "North" if strpos(variable, "Region 4")
		replace variable = "South" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "MX") {
		loc country_label "Mexico"
		replace variable = "MORENA" if strpos(variable, "Candidate 1")
		replace variable = "PAN" if strpos(variable, "Candidate 2")
		replace variable = "PRI" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central-Eastern" if strpos(variable, "Region 1")
		replace variable = "Central-Western" if strpos(variable, "Region 2")
		replace variable = "North-East" if strpos(variable, "Region 3")
		replace variable = "South" if strpos(variable, "Region 4")
		drop if strpos(variable, "Region 5")
	}
	if strpos("`country'", "PL") {
		loc country_label "Poland"
		replace variable = "Duda" if strpos(variable, "Candidate 1")
		replace variable = "Trzaskowski" if strpos(variable, "Candidate 2")
		replace variable = "Hołownia" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central" if strpos(variable, "Region 1")
		replace variable = "Central-East" if strpos(variable, "Region 2")
		replace variable = "North" if strpos(variable, "Region 3")
		replace variable = "South-East" if strpos(variable, "Region 4")
		replace variable = "South-West" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "SA") {
		loc country_label "South Africa"
		replace variable = "ANC" if strpos(variable, "Candidate 1")
		replace variable = "DA" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Center" if strpos(variable, "Region 1")
		replace variable = "Gauteng" if strpos(variable, "Region 2")
		replace variable = "North-East" if strpos(variable, "Region 3")
		replace variable = "South-East" if strpos(variable, "Region 4")
		replace variable = "West" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "SK") {
		loc country_label "South Korea"
		replace variable = "Jae-In" if strpos(variable, "Candidate 1")
		replace variable = "Joon-pyo" if strpos(variable, "Candidate 2")
		replace variable = "Cheol-soo" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "East" if strpos(variable, "Region 1")
		replace variable = "North" if strpos(variable, "Region 2")
		replace variable = "Seoul" if strpos(variable, "Region 3")
		replace variable = "West" if strpos(variable, "Region 4")
		drop if strpos(variable, "Region 5")
	}
	if strpos("`country'", "SP") {
		loc country_label "Spain"
		replace variable = "PSOE" if strpos(variable, "Candidate 1")
		replace variable = "PP" if strpos(variable, "Candidate 2")
		replace variable = "VOX" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Center" if strpos(variable, "Region 1")
		replace variable = "East" if strpos(variable, "Region 2")
		replace variable = "North" if strpos(variable, "Region 3")
		replace variable = "North-West" if strpos(variable, "Region 4")
		replace variable = "South" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "TR") {
		loc country_label "Turkey"
		replace variable = "AKP" if strpos(variable, "Candidate 1")
		replace variable = "CHP" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central" if strpos(variable, "Region 1")
		replace variable = "East" if strpos(variable, "Region 2")
		replace variable = "Marmara" if strpos(variable, "Region 3")
		replace variable = "West" if strpos(variable, "Region 4")
		drop if strpos(variable, "Region 5")
	}
	if strpos("`country'", "UA") {
		loc country_label "Ukraine"
		replace variable = "Zelenskyy" if strpos(variable, "Candidate 1")
		replace variable = "Poroshenko" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Center" if strpos(variable, "Region 1")
		replace variable = "East" if strpos(variable, "Region 2")
		replace variable = "South" if strpos(variable, "Region 3")
		replace variable = "West" if strpos(variable, "Region 4")
		drop if strpos(variable, "Region 5")
	}
	if strpos("`country'", "UK") {
		loc country_label "United Kingdom"
		replace variable = "Conservative Party" if strpos(variable, "Candidate 1")
		replace variable = "Labour Party" if strpos(variable, "Candidate 2")
		replace variable = "Liberal Democrats" if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Central UK" if strpos(variable, "Region 1")
		replace variable = "London" if strpos(variable, "Region 2")
		replace variable = "Northern England" if strpos(variable, "Region 3")
		replace variable = "Northern UK" if strpos(variable, "Region 4")
		replace variable = "Southern England" if strpos(variable, "Region 5")
	}
	if strpos("`country'", "US") | strpos("`country'", "usc") {
		loc country_label "United States"
		replace variable = "Biden" if strpos(variable, "Candidate 1")
		replace variable = "Trump" if strpos(variable, "Candidate 2")
		drop if strpos(variable, "Candidate 3")
		drop if strpos(variable, "Candidate 4")
		replace variable = "Midwest" if strpos(variable, "Region 1")
		replace variable = "Northeast" if strpos(variable, "Region 2")
		replace variable = "South" if strpos(variable, "Region 3")
		replace variable = "West" if strpos(variable, "Region 4")
		drop if strpos(variable, "Region 5")
	}
	if strpos("`country'", "usc_regular") {
		loc country_label "Regular Incentives"
	}
	if strpos("`country'", "usc_extra") {
		loc country_label "Extra Incentives"
	}
	
	** Only keep variables of country of interest
	keep variable `country'_*
	
	** Create 95% CI
	gen lb = `country'_diff-1.96*`country'_sample_sd/sqrt(`country'_sample_N)
	gen ub = `country'_diff+1.96*`country'_sample_sd/sqrt(`country'_sample_N)
	drop if inlist(var, "Sample size", "Voters: Not reported")

	*--------------------------
	* Create Category Labels and order variables
	*--------------------------	
	** Create new rows for the categories
	global Norig r(N)
	local Norig = _N
	if strpos("`country'", "CN") {
		global new = _N + 7
	}
	else {
		global new = _N + 8
	}
	if inlist("`country'", "MX", "SK", "TR", "UA", "US", "usc_regular", "usc_extra", "usc") {
		loc region_loc 3
	}
	else {
		loc region_loc 4
	}
	
	set obs $new
	gen varid = _n
	
	** Label the categories
	replace variable  = "{bf: Gender}" if varid == (`Norig' + 1)
	replace varid = 1 if varid== (`Norig' +1 )

	replace variable = "{bf: Age}" if varid == (`Norig' + 2)
	replace varid = 2 if varid== (`Norig' +2 )

	replace variable = "{bf: Income}" if varid == (`Norig' + 3)
	replace varid= 6 if varid== (`Norig' +3 )

	replace variable = "{bf: Location}" if varid == (`Norig'+ 4)
	replace varid= 10 if varid== (`Norig' +4 )

	replace variable = "{bf: Education}" if varid == (`Norig'+ 5)
	replace varid= 12+`region_loc' if varid== (`Norig' + 5) // If region_agg

	replace variable = "{bf: Employment}" if varid == (`Norig'+6)
	replace varid= 13+`region_loc' if varid== (`Norig' + 6) // If region_agg
	
	replace variable = "{bf: Ownership}" if varid == (`Norig'+7)
	replace varid= 14+`region_loc' if varid== (`Norig' + 7) // If region _agg

	if strpos("`country'", "CN") == 0 {
		replace variable = "{bf: Vote}" if varid == (`Norig'+8)
		replace varid= 15+`region_loc' if varid== (`Norig' +8 ) // If region _agg
	}
	
	** Sort Variables
	gen priority = 1 if strpos(variable, "{bf")
	
	sort varid priority
	drop varid
	gen varid = _n
	gsort -varid
	replace varid = _n
	
	*--------------------------
	* Create Graphs
	*--------------------------		
	labmask varid, val(variable)

	if inlist("`country'", "AU", "CA", "DE", "DK", "SP") | inlist("`country'", "FR", "IT", "JP", "SK", "PL", "UK", "US") {
		tw (scatter varid `country'_diff, ms(O) mcolor("${p1}%50") mlwidth(1) lcolor("${p1}%50") mlwidth(vthin) ) (rcap lb ub varid, horizontal color("${p1}%50")  ) , ///
  legend(order(3 "`country_label'") row(1) pos(12) size(large) color(black) ) ytitle("") ylabel(1(1)${new}, valuelabel  labsize(4) nogrid notick) ///
	xline(0, lcolor(gs8) lpattern(dash)  lwidth(thin)) ysize(10) xsize(10) ///
	xscale(range(-.2 .2)) xlabel(-.2(.1).2) ///
  name(desc_graph_`country', replace)	
		global graphs_hi "${graphs_hi} desc_graph_`country'"
	}
	
	if inlist("`country'", "BR", "CN", "IA", "ID", "MX", "TR", "UA", "SA") {
		tw (scatter varid `country'_diff, ms(O) mcolor("${p8}%50") mlwidth(1) lcolor("${p8}%50") mlwidth(vthin) ) (rcap lb ub varid, horizontal color("${p8}%50")  ) , ///
  legend(order(3 "`country_label'") row(1) pos(12) size(large) color(black) ) ytitle("") ylabel(1(1)${new}, valuelabel  labsize(4) nogrid notick) ///
	xline(0, lcolor(gs8) lpattern(dash)  lwidth(thin)) ysize(10) xsize(10) ///
		xscale(range(-.3 .3)) xlabel(-.3(.2).3) ///
  name(desc_graph_`country', replace)	
		global graphs_mi "${graphs_mi} desc_graph_`country'"
	}
	
	if inlist("`country'", "usc_regular", "usc_extra", "usc") {
		tw (scatter varid `country'_diff, ms(O) mcolor("${p1}%50") mlwidth(1) lcolor("${p1}%50") mlwidth(vthin) ) (rcap lb ub varid, horizontal color("${p1}%50")  ) , ///
  legend(order(3 "`country_label'") row(1) pos(12) size(large) color(black) ) ytitle("") ylabel(1(1)${new}, valuelabel  labsize(4) nogrid notick) ///
	xline(0, lcolor(gs8) lpattern(dash)  lwidth(thin)) ysize(10) xsize(10) ///
	xscale(range(-.1 .1)) xlabel(-.1(.1).1) ///
  name(desc_graph_`country', replace)	
		global graphs_usc "${graphs_usc} desc_graph_`country'"
	}
	
	restore
}

/********************************************************************************

	Combine Graphs Together & Export Them

********************************************************************************/
graph combine desc_graph_DK desc_graph_UK, ycommon iscale(*.9) cols(4) ysize(25) xsize(63) b1(" ", size(small)  color(black) )
graph export "${gitpath}/figures/FINAL_FIGURES/Figure4a.${ft}", replace 

graph combine desc_graph_ID desc_graph_UA, ycommon iscale(*.9) cols(4) ysize(25) xsize(63) b1("P.P. difference with population", size(small) color(black) )
graph export "${gitpath}/figures/FINAL_FIGURES/Figure4b.${ft}", replace 
