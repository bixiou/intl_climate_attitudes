##### A.C Country Appendices #####
inv <- read.xlsx("../xlsx/country_comparison/investments_all_win_positive_countries.xlsx", colNames = F)
tax <- read.xlsx("../xlsx/country_comparison/tax_transfers_all_win_positive_countries.xlsx", colNames = F)
ban <- read.xlsx("../xlsx/country_comparison/standard_all_win_positive_countries.xlsx", colNames = F)

country_appendix <- function(country = "all") {
  print(country)
  update_constant(d(country), Country = country)
  
  # tryCatch({
  #   (CC_anthropogenic <- barres(vars = "CC_anthropogenic", rev = F, rev_color = T, export_xls = export_xls, df = e, miss=F, labels="Part of CC anthropogenic"))
  #   save_plotly(CC_anthropogenic, width= 660, height=140, folder = paste0("../../oecd_latex/figures/appendix/", country, "/"))
  #   (CC_dynamic <- barres(vars = "CC_dynamic", export_xls = export_xls, df = e, rev=F, miss=F, labels="Cutting GHG emissions by half <br> sufficient to stop rise in temperatures"))
  #   save_plotly(CC_dynamic, width= 650, height=140, folder = paste0("../../oecd_latex/figures/appendix/", country, "/"))
  #   (CC_impacts3 <- barres(vars = rev(c("CC_impacts_droughts", "CC_impacts_sea_rise", "CC_impacts_volcanos")), export_xls = export_xls, df = e, miss=F, rev_color=T, sort = F, labels=rev(c("<b>If nothing is done to limit CC:</b><br>Severe droughts and heatwaves", "Sea-level rise", "More frequent volcanic eruptions"))))
  #   save_plotly(CC_impacts3, width= 800, height=250, folder = paste0("../../oecd_latex/figures/appendix/", country, "/"))
  #   (footprint2 <- barres(vars = rev(c("know_footprint_elec", "know_footprint_food", "know_footprint_transport", "know_footprint_region", "know_footprint_pc")), export_xls = export_xls, df = e, miss=F, sort = F, rev_color=T, showLegend = F, labels=rev(c("<b>Correct ranking of emissions/footprints:</b><br>Electricity (Coal > Gas > Nuclear)", "Food (Beef/Meat > Chicken > Pasta/Rice)", "Transport (Plane > Car > Train/Bus)", "Country total (China > US > EU > India)", "Per capita GHG footprint<br>(US > EU > China > India)"))))
  #   save_plotly(footprint2, width= 800, height=300, folder = paste0("../../oecd_latex/figures/appendix/", country, "/"))
  # }, error = function(cond) { print('paste0("knowledge")')})
  # 
  # variables_national_policies <- rev(c(variables_policies_main[4],variables_policy[4], variables_policy[5], variables_policy[3], variables_policies_main[3], variables_policies_main[2], "insulation_mandatory_support_no_priming", variables_beef[2], variables_policy[1], variables_tax[c(7,4,8,2,1,6,9,3,5)], variables_policy[2], variables_policies_main[1], variables_beef[c(4,1,3)]))
  # labels_national_policies <- rev(c(paste("<b>Support for Infrastructure & Technologies:</b><br>", labels_main_policies[4]), labels_policy_short[c(4,5)], paste("<b>Support for Car-targeted policies:</b><br>", labels_policy_short[3]), labels_main_policies[3], labels_main_policies[2], paste("<b>Support for Other household-related policies:</b><br>", "Mandatory and subsidized insulation of buildings"), labels_beef[2],  
  #                                   labels_policy_short[1],  paste("<b>Surpport for Carbon Taxes:</b><br>", labels_policy_short[2]), labels_main_policies[1], paste("<b>Surpport for Carbon Tax With:</b><br>", labels_tax[7]), labels_tax[c(4,8,2,1,6,9,3,5)], paste("<b>Support for Cattle-Related Policies:</b><br>", labels_beef[4]), labels_beef[c(1,3)]))
  # tryCatch({(national_policies <- barres(color = c("e36f68", "fec691", "f7f7f7", "c4e4f0", "7c9ecb"),vars = variables_national_policies[variables_national_policies %in% names(e)],export_xls = export_xls, df = e, rev = F, rev_color = T, miss=F, sort = F, labels=labels_national_policies[variables_national_policies %in% names(e)]))
  #   save_plotly(national_policies, width= 1050, height=1000, folder = paste0("../../oecd_latex/figures/appendix/", country, "/")) }, error = function(cond) { print('paste0("national_policies")')})
  # 
  # tryCatch({labels_willingness_country <- c("Limit flying", "Limit driving", "Have a fuel-efficient or eletric vehicle", "Limit beef/meat consumption", "Limit heating or cooling your home", "Country adopting ambitious climate policies", "Having enough financial support", "One's community also changing behaviors", "The well-off also changing their behavior")
  # (willingness_conditions_all <- barres(color = c("e36f68", "fec691", "f7f7f7", "c4e4f0", "7c9ecb"), vars = rev(variables_willingness_all[c(1:9)]), export_xls = export_xls, df = e, rev = F, rev_color = T, miss=F, sort = F, labels=rev(c(paste("<b>Willingness to adopt climate-friendly behaviors:</b><br>", labels_willingness_country[1]), labels_willingness_country[2:5], paste("<b>Factors that would encourage behavior adoption:</b><br>", labels_willingness_country[6]), labels_willingness_country[7:9]))))
  # save_plotly(willingness_conditions_all, width= 990, height=560, folder = paste0("../../oecd_latex/figures/appendix/", country, "/")) }, error = function(cond) { print('paste0("willingness_conditions_all")')})
  
  tryCatch({if (!(country %in% c("All", "alla"))) {
    temp <- rbind(c("", "Green infrastructure program", "", "Carbon tax with cash transfers", "", "Ban on combustion-engine cars", ""), c("", rep(c(countries_names[country], ifelse(high_income[country], "High-income", "Middle-income")), 3)),
                  c(t(inv[2, c(1, which(heatmap_countries == country), ifelse(high_income[country], 2, 15))]), rep("", 4)),
                  c("Increase the use of public transport/Encourage people to drive less", t(inv[3, c(which(heatmap_countries == country), ifelse(high_income[country], 2, 15))]), t(tax[2, c(which(heatmap_countries == country), ifelse(high_income[country], 2, 15))]), rep("", 2)),
                  c(tax[3, 1], "", "", t(tax[3, c(which(heatmap_countries == country), ifelse(high_income[country], 2, 15))]), "", ""),
                  c("Reduce GHG emissions/Reduce CO2 emissions from cars", "", "", t(tax[4, c(which(heatmap_countries == country), ifelse(high_income[country], 2, 15))]), t(ban[2, c(which(heatmap_countries == country), ifelse(high_income[country], 2, 15))])),
                  cbind(inv[c(4,6:14),c(1,which(heatmap_countries == country), ifelse(high_income[country], 2, 15))], tax[c(5,7:15),c(which(heatmap_countries == country), ifelse(high_income[country], 2, 15))], ban[c(3,5:13),c(which(heatmap_countries == country), ifelse(high_income[country], 2, 15))]))
    write.xlsx(temp, paste0("../tables/", country, "/main_policies_all_win_positive.xlsx"), overwrite = T, col.names = F)
  }}, error = function(cond) { print('paste0("main_policies_all_win_positive")')})
  
  # tex <- readLines("../appendix/country_appendix_template.tex")
  # tex <- gsub("[country]", country, tex, fixed = T)
  # tex <- gsub("[Country]", countries_names[country], tex, fixed = T)
  # cat(paste(tex, collapse="\n"), file = paste0("../appendix/country_appendix_", country, ".tex"))
  # tex <- gsub("../", "", tex, fixed = T)
  # cat(paste(tex, collapse="\n"), file = paste0("../../oecd_latex/appendix/country_appendix_", country, ".tex"))
}
for (c in c(countries, "All", "alla")) country_appendix(c) 

variance_main_policies_C <- variance_main_policies_AC <- variance_main_policies_Cmain <- list()
for (c in countries) {
  update_constant(d(c), c)
  variance_main_policies_Cmain[[country]] <- calc.relimp(lm(as.formula(paste("index_main_policies", " ~ ", paste(c(setC, if (nrow(e) > 7000) "country" else c()), collapse = ' + '))), data = e, weights = e$weight), type = c("lmg"), rela = F, rank= F)
  (lmg_main_policies_Cmain_US <- barres(data = unname(t(as.matrix(variance_main_policies_Cmain[[country]]@lmg))), labels = gsub("\\&", "&", unname(regressors_names[names(variance_main_policies_Cmain[[country]]@lmg)]), fixed = T), legend = "% of response variances", rev = F))
  save_plotly_new_filename(lmg_main_policies_Cmain_US, width= 900, height=700)
  write.csv(variance_main_policies_Cmain[[country]]@lmg, paste0("../tables/", c, "/LMG_main_policies_Cmain.csv"))
}


# appendix_graphs
labels_main_policies_app <- labels_main_policies
labels_main_policies_app[3] <- "Ban on combustion-engine vehicles\nw. alternatives available"
labels_policy_short_app <- labels_policy_short
labels_policy_short_app[4] <- "Subsidies to low-carbon technologies"
labels_policy_short_app[3] <- "Ban on polluting cars in city centers"
labels_policy_short_app[5] <- "Funding clean energy in low-income countries"
labels_beef_app <- labels_beef
labels_beef[1] <- "A high tax on cattle products, doubling beef prices"
labels_beef[4] <- "Ban of intensive cattle farming"
labels_beef[2] <- "Subsidies on organic and local vegetables"
labels_beef[3] <- "Removal of subsidies for cattle farming"
labels_tax_app <- labels_tax
labels_tax_app[1] <- "Cash transfers to constrained households"
labels_tax_app[4] <- "Reduction in personal income taxes"
labels_tax_app[5] <- "Reduction in corporate income taxes"
labels_tax_app[7] <- "Funding environmental infrastructures"
labels_tax_app[8] <- "Subsidies to low-carbon tech."
labels_tax_app[9] <- "Reduction in the public deficit"

variables_nat_policies <- c(variables_policies_main[c(4,2,1)], variables_policy[3], variables_policies_main[3],
                            variables_policy[c(1,4)], "insulation_mandatory_support_no_priming", variables_policy[c(5,2)],
                            variables_beef[c(2,4,3,1)],variables_tax[c(7,8,4,2,1,6,9)], "tax_transfers_progressive_support",
                            variables_tax[c(3,5)])

labels_nat_policies <- c(paste("<b>Main Policies Studied:</b><br>", labels_main_policies[2]),
                         labels_main_policies[c(1,3)], paste("<b>Transportation Policies:</b><br>",labels_policy_short_app[3]),
                         labels_main_policies_app[3], labels_policy_short_app[1],
                         paste("<b>Energy Policies:</b><br>", labels_policy_short_app[4]),
                         "Mandatory and subsidized insulation of buildings", labels_policy_short_app[c(5,2)],
                         paste("<b>Food Policies:</b><br>", labels_beef_app[2]), labels_beef_app[c(4,3,1)],
                         paste("<b>Support for Carbon Tax With:</b><br>", labels_tax_app[7]),
                         labels_tax_app[c(8,4,2,1,6,9)], "Progressive transfers", labels_tax_app[c(3,5)])

variables_willing_app <- variables_willingness_all[c(3,1,4,2,5,9,7,8,6)]
labels_willingness_country <- c("Limit flying", "Limit driving", "Have a fuel-efficient or eletric vehicle", "Limit beef/meat consumption", "Limit heating or cooling your home", "Country adopting ambitious climate policies", "Having enough financial support", "One's community also changing behaviors", "The well-off also changing their behavior")
labels_willing_app <- c(paste("<b>Willingness to adopt climate-friendly behaviors:</b><br>",
                              labels_willingness_country[3]), labels_willingness_country[c(1,4,2,5)],
                        paste("<b>Factors that would encourage behavior adoption:</b><br>", labels_willingness_country[9]),
                        labels_willingness_country[c(7,8,6)])

country_list <- countries
for (i in seq_along(country_list)){
  update_constant(d(country_list[i]), control_group = T)
  
  if (country_list[i] %in% c("FR", "DK", "US")){
    variables_nat_policies_used <- variables_nat_policies[-22]
    labels_nat_policies_used <- labels_nat_policies[-22]
  } else if (country_list[i] %in% c("BR", "ID", "MX")) {
    variables_nat_policies_used <- variables_nat_policies[-8]
    labels_nat_policies_used <- labels_nat_policies[-8]
  } else if (country_list[i] == "IA") {
    variables_nat_policies_used <- variables_nat_policies[c(-8,-14:-11)]
    labels_nat_policies_used <- labels_nat_policies[c(-8,-14:-11)]
  } else {
    variables_nat_policies_used <- variables_nat_policies
    labels_nat_policies_used <- labels_nat_policies
  }
  (national_policies <- barres(color = c("e36f68", "fec691", "f7f7f7", "c4e4f0", "7c9ecb"),
                               vars = rev(variables_nat_policies_used),
                               export_xls = export_xls, df = e, rev = F, rev_color = T, miss=F, sort = F,
                               labels=rev(labels_nat_policies_used)))
  save_plotly(national_policies, folder = paste0("../../oecd_latex/figures/appendix/", country_list[i], "/"), width= 1050, height=1000) 
  
  (willingness_conditions_all <- barres(color = c("e36f68", "fec691", "f7f7f7", "c4e4f0", "7c9ecb"),
                                        vars = rev(variables_willing_app),
                                        export_xls = export_xls, df = e, rev = F, rev_color = T, miss=F, sort = F,
                                        labels=rev(labels_willing_app)))
  save_plotly(willingness_conditions_all, folder = paste0("../../oecd_latex/figures/appendix/", country_list[i], "/"), width= 990, height=560) 
}

# summary_statistics_clean
for (country in countries){
  print(country)
  if(country %in% rich_countries) country_group <- T else country_group <- F 
  summary_stats_table(country, folder = paste0("../../oecd_latex/tables/", country, "/"), hi = country_group)
}

# vote_econ_table
econ_vote_table <- function(country, folder = "../tables/sample_composition/", filename = NULL, return_table = FALSE){
  
  table_econ_vote <- data.frame()
  
  dataset <- d(country)
  
  vote <- unique(dataset$vote_voters)
  vote <- c(sort(vote[!is.na(vote) & vote != "PNR"]), "PNR")
  econ_veryleft <- c()
  econ_left <- c()
  econ_center <- c()
  econ_right <- c()
  econ_veryright <- c()
  econ_pnr <- c()
  
  # Get Sample statistics
  for (i in seq_along(vote)){
    econ_veryleft[i] <- as.numeric(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Very left"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Very left"], weight = F)) == vote[i])[1])))])
    econ_left[i] <- as.numeric(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Left"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Left"], weight = F)) == vote[i])[1])))])
    econ_center[i] <- as.numeric(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Center"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Center"], weight = F)) == vote[i])[1])))])
    econ_right[i] <- as.numeric(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Right"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Right"], weight = F)) == vote[i])[1])))])
    econ_veryright[i] <- as.numeric(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Very right"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "Very right"], weight = F)) == vote[i])[1])))])
    econ_pnr[i] <- as.numeric(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "PNR"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_voters[dataset$econ_leaning == "PNR"], weight = F)) == vote[i])[1])))])
  }
  
  econ_veryleft[length(vote)+1] <-  as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Very left"], weight = F))["counts.n"]) - as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Very left"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Very left"], weight = F)) == "Yes")[1])))])
  econ_left[length(vote)+1] <-  as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Left"], weight = F))["counts.n"]) - as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Left"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Left"], weight = F)) == "Yes")[1])))])
  econ_center[length(vote)+1] <-  as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Center"], weight = F))["counts.n"]) - as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Center"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Center"], weight = F)) == "Yes")[1])))])
  econ_right[length(vote)+1] <-  as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Right"], weight = F))["counts.n"]) - as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Right"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Right"], weight = F)) == "Yes")[1])))])
  econ_veryright[length(vote)+1] <- as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Very right"], weight = F))["counts.n"]) - as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Very right"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "Very right"], weight = F)) == "Yes")[1])))])
  econ_pnr[length(vote)+1] <-  as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "PNR"], weight = F))["counts.n"]) - as.numeric(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "PNR"], weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$vote_participation[dataset$econ_leaning == "PNR"], weight = F)) == "Yes")[1])))])
  
  sample_econ_veryleft <- as.numeric(unlist(decrit(dataset$econ_leaning, weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$econ_leaning, weight = F)) == "Very left")[1])))])
  sample_econ_left <- as.numeric(unlist(decrit(dataset$econ_leaning, weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$econ_leaning, weight = F)) == "Left")[1])))])
  sample_econ_center <- as.numeric(unlist(decrit(dataset$econ_leaning, weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$econ_leaning, weight = F)) == "Center")[1])))])
  sample_econ_right <- as.numeric(unlist(decrit(dataset$econ_leaning, weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$econ_leaning, weight = F)) == "Right")[1])))])
  sample_econ_veryright <- as.numeric(unlist(decrit(dataset$econ_leaning, weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$econ_leaning, weight = F)) == "Very right")[1])))])
  sample_econ_pnr <- as.numeric(unlist(decrit(dataset$econ_leaning, weight = F))[paste0("values.frequency",gsub("values.value", "", names(which(unlist(decrit(dataset$econ_leaning, weight = F)) == "PNR")[1])))])
  
  econ_veryleft <- sprintf("%.2f", round(econ_veryleft/sample_econ_veryleft, digits = 2))
  econ_left <- sprintf("%.2f", round(econ_left/sample_econ_left, digits = 2))
  econ_center <- sprintf("%.2f", round(econ_center/sample_econ_center, digits = 2))
  econ_right <- sprintf("%.2f", round(econ_right/sample_econ_right, digits = 2))
  econ_veryright <- sprintf("%.2f", round(econ_veryright/sample_econ_veryright, digits = 2))
  econ_pnr <- sprintf("%.2f", round(econ_pnr/sample_econ_pnr, digits = 2))
  
  names(econ_veryleft) <- c(vote[-length(vote)],"Vote not reported", "Did not vote")
  names(econ_left) <- c(vote[-length(vote)],"Vote not reported", "Did not vote")
  names(econ_center) <- c(vote[-length(vote)],"Vote not reported", "Did not vote")
  names(econ_right) <- c(vote[-length(vote)],"Vote not reported", "Did not vote")
  names(econ_veryright) <- c(vote[-length(vote)],"Vote not reported", "Did not vote")
  names(econ_pnr) <- c(vote[-length(vote)],"Vote not reported", "Did not vote")
  
  
  # Append the two vectors to a common data frame
  
  table_econ_vote <- t(rbind(econ_veryleft, econ_left, econ_center, econ_right, econ_veryright, econ_pnr))
  
  headers_econ_vote <- c("", "6")
  names(headers_econ_vote) <- c("", "Economic leaning")
  
  latex_output_econ_vote <- kbl(table_econ_vote, "latex",
                                col.names = c("Very left", "Left", "Center", "Right", "Very right","Not reported"),
                                linesep = c(rep("", length(vote)-1), "\\addlinespace[0.5em]"),
                                booktabs = TRUE) %>%
    add_header_above(headers_econ_vote)
  
  if (return_table) return(list(table_econ_vote))
  else {
    cat(paste(latex_output_econ_vote, collapse="\n"), file = paste0("../../oecd_latex/tables/",country,"/econ_vote_table.tex"))
    #cat(paste(latex_output_voters, collapse="\n"), file = paste0(folder, filename, "_amongvoters.tex"))
  }
}

for (country in countries[-which(countries=="CN")]){
  print(country)
  econ_vote_table(country)
}
