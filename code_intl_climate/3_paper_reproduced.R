##### Data Cleansing and Paths Setting ####

start <- Sys.time()
# TODO: remove these four lines
Paths = c("/Users/b.planterose/Dropbox/TRAVAIL/Jobs/Stantcheva_2020:21/OECD/oecd_climate/code_oecd", "C:/Users/afabre/Documents/www/international_climate_attitudes/code_intl_climate", 
          "C:/Users/fabre/Documents/www/international_climate_attitudes/code_intl_climate", "C:/Users/ans7406/Documents/GitHub/international_climate_attitudes/code_intl_climate", 
          "C:/Users/afabre/Documents/www/international_climate_attitudes/code_intl_climate", "C:/Users/hp/Dropbox/2024/international_climate_attitudes/code_intl_climate")
names(Paths) = c("b.planterose", "afabre", "fabre", "ans7406", "SpAdmin", "hp")
if (Sys.info()[7]=="afabre") setwd(Paths["fabre"]) else setwd(Paths[Sys.info()[7]])
if (file.exists(Paths["afabre"])) .libPaths(c("C:/Users/afabre/R-4.1.1/library", "C:/Users/afabre/R-4.1.2/library", "\\\\nash/mtec-home/afabre/My Documents/R/win-library/4.0", 
                                              "C:/Users/afabre/AppData/Local/Programs/MiKTeX"))  # R-4.0.3/

# Set path to current directory, for example:
# setwd("C:/Users/path_to_folder/international_climate_attitudes/code_intl_climate")

source("0_setup.R")

# Two options:
# A. Reproduce data cleansing and preparation: ~2 hours
source("1_relabel_rename.R")
source("2_preparation.R")

save.image("after_preparation.RData") 
prepare_time <- Sys.time() - start # 1.5 hours

# B. Load cleansed and prepared data
load("after_preparation.RData") # 69 Mo 
use_plotly <- T

##### Create shortcuts (for all) df, e, and adjust settings for latex table #####
options(modelsummary_format_numeric_latex = "plain")
update_constant(all)


##### Load extended dataset for robustness check #####
allq <- readRDS("allq.rds")


##### Create additional datasets for attrition analysis #####
allx <- alla[alla$finished == 1 & no.na(alla$excluded) != "QuotaMet",] 
alln <- alla[no.na(alla$excluded) != "QuotaMet",] 
alln$reached_test <- !is.na(alln$standard_support)
alln$dropout_late <- (alln$dropout & as.numeric(alln$progress > 30))
alln$failed_test <- no.na(alln$attention_test) != 'A little' & alln$reached_test
allx$reached_test <- !is.na(allx$standard_support)
allx$failed_test <- no.na(allx$attention_test) != 'A little' & allx$reached_test
alln$income_factor <- as.character(alln$income_factor)
alln$agglo_categ <- as.character(alln$agglo_categ)
for (v in c("agglo_categ", "availability_transport", "car_dependency", "high_gas_expenses", "high_heating_expenses", "flights_agg", "polluting_sector", 
            "frequency_beef", "owner", "female", "other", "children", "age_control", "income_factor", "educ_categ", "econ_leaning", "treatment") )  {
  alln[[v]][is.na(alln[[v]])] <- -0.1 }
allr <- all[all$duration > 20,]


##### 1. Introduction #####
nrow(all) # 40,680 respondents
# Figure 1 (figures/country_comparison/CC_problem_should_fight_positive_countries)
heatmap_wrapper(vars = main_variables_opinion[2:3], labels = labels_opinion[2:3], conditions = heatmap_conditions, name = "CC_problem_should_fight", special = special, df = all)


##### 2. Survey ####
## Survey Data Collection
# Timeline
decrit(all$date) # March 2021 to March 2022

# Sample sizes
min(sapply(countries, function(c) nrow(d(c)))) # 1564
max(sapply(countries, function(c) nrow(d(c)))) # 2488

# Footnote 6
wtd.mean(all$weight >= 4 | all$weight <= 0.25, weights = all$weight) # 9%: share of trimmed responses
mean(all$weight[high_income[all$country]] >= 4 | all$weight[high_income[all$country]] <= 0.25) # 1%
mean(all$weight[!high_income[all$country]] >= 4 | all$weight[!high_income[all$country]] <= 0.25) # 30% 
wtd.mean(all$weight[high_income[all$country]] >= 4 | all$weight[high_income[all$country]] <= 0.25, weights = all$weight[high_income[all$country]]) # 2%
wtd.mean(all$weight[!high_income[all$country]] >= 4 | all$weight[!high_income[all$country]] <= 0.25, weights = all$weight[!high_income[all$country]]) # 20%
for (c in countries) print(paste(c, round(mean(d(c)$weight >= 4 | d(c)$weight <= 0.25), 3)))

# Median response time
median(all$duration) # 28 min

# Screened out respondents
sum(no.na(alla$attention_test) != "A little" & !alla$dropout & no.na(alla$excluded) != "QuotaMet") # 9858
sum(n(alla$duration) < max_duration & !alla$dropout & no.na(alla$excluded) != "QuotaMet") # 8642
alla$alln <- !(n(alla$duration) > max_duration & no.na(alla$attention_test) == "A little" & !is.na(alla$excluded)) & no.na(alla$excluded) != "QuotaMet"
sum((no.na(alla$attention_test) != "A little" | n(alla$duration) <= max_duration) & !alla$dropout & alla$alln) # 13632
9858/(nrow(all) + 13632) # Share of inattentive: 18%
8642/(nrow(all) + 13632) # Share of rushed: 16%
13632/(nrow(all) + 13632) # Share of inattentive or rushed: 25%

# Attrition 
sum(alln$dropout) - sum(alln$dropout_late) # 8689
(sum(alln$dropout) - sum(alln$dropout_late))/nrow(alln) # Dropout before end of sociodemos: 12%
sum(alln$dropout_late) # 7123
sum(alln$dropout_late)/nrow(alln) # Dropout after sociodemos: 10%
summary(lm(as.formula(paste("dropout ~ ", paste(setAt, collapse = ' + '))), data = alla, weights = alla$weight))

# Ex post checks
decrit(all$survey_biased)

# 2.1
reg_petition_policies_willing <- lm(as.formula(paste("petition ~ index_main_policies + index_willing_change + country + ", paste(setAt, collapse = '+'))), data = all, weights = weight)
reg_petition_policies_willing$coefficients[2:3]/ wtd.mean(all$petition, all$weight) # 16.6%, 8.1%

reg_donation_policies_willing <- lm(as.formula(paste("donation > 0 ~ index_main_policies + index_willing_change + country + ", paste(setAt, collapse = '+'))), data = all, weights = weight)
reg_donation_policies_willing$coefficients[2:3]/ wtd.mean(all$donation > 0, all$weight) # 8.3%, 4.6%


##### 3. Knowledge #####
# Share of deniers by country:
(CC_real_US <- barresN(along=along, parentheses=parentheses, nolabel=nolabel, vars = "CC_real", use_plotly = use_plotly, export_xls = export_xls, df = e[e$treatment=="None",], miss=F, labels="Climate change real?"))
# Share who believe CC is "a lot" or "mostly" anthropogenic

(CC_anthropogenic_US <- barresN(along=along, parentheses=parentheses, nolabel=nolabel, vars = "CC_anthropogenic", 
                                rev = F, rev_color = T, use_plotly = use_plotly, export_xls = export_xls, df = e[e$treatment=="None",], miss=F, labels="Part of climate change anthropogenic"))
# Views concerning impacts of CC by country
(CC_impacts_US <- barres(vars = variables_CC_impacts, use_plotly = use_plotly, export_xls = export_xls, df = e[e$treatment=="None",], miss=F, rev_color=T, labels=labels_CC_impacts))
decrit("GHG_CO2", all[high_income[all$country],], which = all$treatment[high_income[all$country]] == "None") # 83%
decrit("GHG_methane", all[high_income[all$country],], which = all$treatment[high_income[all$country]] == "None") # 60%
decrit("GHG_particulates", all[high_income[all$country],], which = all$treatment[high_income[all$country]] == "None") # 66%

decrit("GHG_H2", all[high_income[all$country],], which = all$treatment[high_income[all$country]] == "None") # 85% 
decrit("GHG_CO2", all, which = all$treatment == "None") # 80%
decrit("GHG_methane", all, which = all$treatment == "None") # 56% 
decrit("GHG_particulates", all, which = all$treatment == "None") # 67%
decrit("GHG_H2", all, which = all$treatment == "None") # 82%

# Figure 6 (figures/country_comparison/Heatplot_knowledge_full_countries)
heatmap_plot(heatmap_table(vars = c(main_variables_knowledge[c(1,3)], "GHG_CO2", "GHG_methane", "GHG_H2", "GHG_particulates", "CC_impacts_droughts", "CC_impacts_sea_rise", 
                                    "CC_impacts_volcanos", "footprint_el_nuclear", "footprint_fd_beef", "footprint_tr_plane", "footprint_reg_china", "footprint_pc_US"), 
                           filename = "knowledge_full", conditions = c("> 0", "== 0", rep("> 0", 2), rep("<= 0", 2), rep("> 0", 2), "< 0", "== 3", rep("== 1", 4)), special = special, 
                           labels = c(labels_main_knowledge[1], "Cutting emissions by half insufficient to stop global warning", "CO2 is a greenhouse gas", "Methane is a greenhouse gas", 
                                      "Hydrogen is not a greenhouse gas", "Particulate matter is not a greenhouse gas", "Severe droughts and heatwaves are likely if CC goes unabated", 
                                      "Sea-level rise is likely if CC goes unabated", "More frequent volcanic eruptions are unlikely if CC goes unabated", 
                                      "GHG footprint of nuclear is lower than gas or coal", "GHG footprint of beef/meat is higher than chicken or pasta", 
                                      "GHG footprint of plane is higher than car or train/bus", "Total emissions of China are higher than other regions", 
                                      "Per capita emissions of the US are higher than other regions")))
save_plot(filename = paste0(folder, "knowledge_full", replacement_text), width = 1650, height = 650, format = 'pdf') 
save_plot(filename = paste0(folder, "knowledge_full", replacement_text), width = 1650, height = 650, format = 'xlsx') 


# Figure 8 (figures/country_comparison/Heatplot_willingness_conditions_all_positive_countries)
heatmap_wrapper(vars = c(variables_willingness_all[c(1:9,12,13)]), labels = c(labels_willingness_all[c(1:9,12,13)]), name = 'willingness_conditions_all', special = special, conditions = heatmap_conditions)

# Figure A4A (figures/country_comparison/Heatplot_future_signed_positive_countries)
temp <- heatmap_table(vars = variables_future, conditions = c(rep("> 0", 3), "< 0", "< 0", "> 0", "< 0"), labels = labels_future_signed, special = special)
save_plot(temp, filename = "country_comparison/future_signed_positive_countries", format = 'xlsx')
heatmap_plot(temp)
save_plot(filename = "../figures/country_comparison/future_signed_positive", width = 1550, height = 400, format = 'pdf')


# Footnote 12
cor(all$index_willing_change, all$index_main_policies) # 60%
weighted_cor(all$index_willing_change, all$index_main_policies, weight=all$weight) #60%

        
##### 4. Support #####
# Figure 9 (figures/country_comparison/national_policies_new_positive_countries)
heatmap_wrapper(name = "national_policies_new", vars = c(variables_policies_main[c(4,2,3,1)], "tax_transfers_progressive_support", variables_policy[c(2,1,3:5)], 
                                                         "insulation_mandatory_support_no_priming", variables_beef[1:4], variables_tax[1:9]), 
                labels = c(labels_policies_main[c(4,2,3,1)], "Carbon tax with progressive transfers", labels_policy_short[c(2,1,3:5)], "Mandatory and subsidized insulation of buildings", 
                           labels_beef[1:4], c(paste("Carbon tax (CT) funding:<br>", labels_tax[1]), paste("CT:", labels_tax[2:9]))), conditions = heatmap_conditions, special = special)

# Average support for 3 main policies by country
support_main <- sapply(countries, function(c) mean(sapply(paste0(names_policies, "_support"), function(p) return(wtd.mean(d(c)[[p]][d(c)$treatment == "None"] > 0, d(c)$weight[d(c)$treatment == "None"])))))
round(sort(support_main), 3) 

heatmap_wrapper(vars = variables_scale, labels = labels_heatmap_scale, conditions = ">= 1", name = "support_main", alphabetical = alphabetical, special = special, df = e)
for (c in countries) print(paste(c, wtd.mean(d(c)$scale_global, d(c)$weight)))

# R2 of various indices regressed on different sets of predictors
# index_main_policies: Support for main policies
# index_policies_emissions_plus: Effectiveness
# index_lose_policies_subjective: Impact on oneself
# index_lose_policies_poor: Impact on low-income HHs
colsR2 <- c("index_knowledge", "index_policies_emissions_plus", "index_policies_pollution", "index_lose_policies_subjective", "index_lose_policies_poor", "index_main_policies", "index_willing_change")
formulasR2 <- c(paste(" ~ ", paste(c(setAt, setB), collapse = ' + ')),
                paste(" ~ ", paste(c(setAt, setB, "country"), collapse = ' + ')),
                paste(" ~ age_control*income_factor*educ_categ*vote_agg + ", paste(c(setAt, setB), collapse = ' + ')),
                paste(" ~ age_control*income_factor*educ_categ*vote_agg + ", paste(c(setAt, setB, "country", "country:income_factor", "country:age", "country:econ_leaning", "country:educ_categ"), collapse = ' + ')))
names(formulasR2) <- rowsR2 <- c("AB", "ABc", "A*B", "A*Bc")
R2 <- matrix(NA, nrow = 4, ncol = 7, dimnames = list(rowsR2, colsR2))
for (c in colsR2) for (i in rowsR2) {
  R2[i, c] <- round(summary(lm(as.formula(paste(c, formulasR2[i])), data = all, weights = all$weight))$adj.r.squared, 4)
}
R2


##### 5. Mechanisms #####
# the 5 lowest countries in "effectiveness" are in order: Germany, France, Australia, Denmark, US
# the 5 highest countires in "effectiveness" are in order: India, Turkey, Indonesia, Brazil, South Africa
effectivness <- sapply(countries, function(c) return(wtd.mean(d(c)$index_policies_effective[d(c)$treatment == "None"], d(c)$weight[d(c)$treatment == "None"])))
round(sort(effectivness), 3)
less_emission_pollution <- sapply(countries, function(c) mean(sapply(c("investments_effect_less_pollution", "tax_transfers_effect_less_pollution", 
                                                                       "standard_effect_less_emission", "tax_transfers_effect_less_emission", "standard_effect_less_pollution"), 
                                                                     function(p) return(wtd.mean(d(c)[[p]][d(c)$treatment == "None"] > 0, d(c)$weight[d(c)$treatment == "None"])))))
round(sort(less_emission_pollution), 3)
cost_carbon_tax <- sapply(countries, function(c) mean(sapply(c("tax_transfers_costless_costly", "tax_transfers_positive_negative"), 
     function(p) return(wtd.mean(d(c)[[p]][d(c)$treatment == "None"] > 0, d(c)$weight[d(c)$treatment == "None"])))))
round(sort(cost_carbon_tax), 3)


drive_less_avg <- sapply(countries, function(c) return(wtd.mean(d(c)$tax_transfers_effect_driving[d(c)$treatment == "None"] >= 1, d(c)$weight[d(c)$treatment == "None"])))
round(sort(drive_less_avg), 3)

rich_win_pol <- sapply("all", function(c) mean(sapply(c("standard_win_lose_rich", "standard_win_lose_rich", "tax_transfers_win_lose_rich"), 
      function(p) return(wtd.mean(d(c)[[p]][d(c)$treatment == "None"] > 0, d(c)$weight[d(c)$treatment == "None"])))))
round(sort(rich_win_pol), 3)

# Figure 11 (figures/country_comparison/Heatplot_main_policies_all_win_positive_3)
heatmap_wrapper(vars = rev(c("investments_support", "investments_fair", variables_investments_win_lose, "investments_costless_costly", "investments_positive_negative", 
                             "investments_large_effect", "investments_effect_less_pollution", "investments_effect_public_transport", "investments_effect_elec_greener")), 
                alphabetical = alphabetical, special = special, name = "investments_all_win", 
                labels = rev(c("Support", "Is fair", paste("Would gain:", labels_investments_win_lose), "Costless way to fight climate change", 
                               "Positive effect on economy and employment", "Large effect on economy and employment", "Reduce air pollution", "Increase the use of public transport", 
                               "Make electricity production greener")), conditions = c(heatmap_conditions, "<= -1"), df = e)
heatmap_wrapper(vars = rev(c("standard_support", "standard_fair", variables_standard_win_lose, "standard_costless_costly", "standard_positive_negative", 
                             "standard_large_effect", "standard_effect_less_pollution", "standard_effect_less_emission")), 
                alphabetical = alphabetical, special = special, name = "standard_all_win", 
                labels = rev(c("Support", "Is fair", paste("Would gain:", labels_standard_win_lose), "Costless way to fight climate change", 
                               "Positive effect on economy and employment", "Large effect on economy and employment", "Reduce air pollution", "Reduce CO2 emissions from cars")), 
                conditions = c(heatmap_conditions, "<= -1"), df = e)
heatmap_wrapper(vars = rev(c("tax_transfers_support", "tax_transfers_fair", variables_tax_transfers_win_lose, "tax_transfers_costless_costly", "tax_transfers_positive_negative", 
                             "tax_transfers_large_effect", "tax_transfers_effect_less_pollution", "tax_transfers_effect_less_emission", "tax_transfers_effect_insulation", "tax_transfers_effect_driving")), 
                alphabetical = alphabetical, special = special, name = "tax_transfers_all_win", 
                labels = rev(c("Support", "Is fair", paste("Would gain:", labels_tax_transfers_win_lose), "Costless way to fight climate change", "Positive effect on economy and employment", 
                               "Large effect on economy and employment", "Reduce air pollution", "Reduce GHG emissions", "Encourage insulation of buildings", "Encourage people to drive less")), 
                conditions = c(heatmap_conditions, "<= -1"), df = e)
inv <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "investments_all_win_positive_countries.xlsx"), colNames = F)
tax <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "tax_transfers_all_win_positive_countries.xlsx"), colNames = F)
ban <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "standard_all_win_positive_countries.xlsx"), colNames = F)
inv[2:nrow(inv), 15] <- rowMeans(apply(as.matrix.noquote(inv[2:nrow(inv), c(16,20:23)]), 2, as.numeric))
tax[2:nrow(tax), 15] <- rowMeans(apply(as.matrix.noquote(tax[2:nrow(tax), c(16,20:23)]), 2, as.numeric))
ban[2:nrow(ban), 15] <- rowMeans(apply(as.matrix.noquote(ban[2:nrow(ban), c(16,20:23)]), 2, as.numeric))
inv[2:nrow(inv), 16] <- rowMeans(apply(as.matrix.noquote(inv[2:nrow(inv), 17:19]), 2, as.numeric))
tax[2:nrow(tax), 16] <- rowMeans(apply(as.matrix.noquote(tax[2:nrow(tax), 17:19]), 2, as.numeric))
ban[2:nrow(ban), 16] <- rowMeans(apply(as.matrix.noquote(ban[2:nrow(ban), 17:19]), 2, as.numeric))
join <- rbind(c("", "Green infrastructure program", "", "", "Carbon tax with cash transfers", "", "", "Ban on combustion-engine cars", "", ""), 
              c("", rep(c("High-income", "CHN, IND, IDN", "Other middle-income"), 3)),
              c(t(inv[2, c(1,2,16,15)]), rep("", 6)), 
              c("Increase the use of public transport/Encourage people to drive less", t(inv[3, c(2,16,15)]), t(tax[2, c(2,16,15)]), rep("", 3)), 
              c(tax[3, 1], "", "", "", t(tax[3, c(2,16,15)]), "", "", ""), 
              c("Reduce GHG emissions/Reduce CO2 emissions from cars", "", "", "", t(tax[4, c(2,16,15)]), t(ban[2, c(2,16,15)])), 
              cbind(inv[c(4,6:14),c(1,2,16,15)], tax[c(5,7:15),c(2,16,15)], ban[c(3,5:13),c(2,16,15)]))
write.xlsx(join, paste0("../xlsx", sub("../figures", "", folder), "main_policies_all_win_positive_3.xlsx"), overwrite = T, col.names = F)

invs <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "investments_all_win_share_countries.xlsx"), colNames = F)
taxs <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "tax_transfers_all_win_share_countries.xlsx"), colNames = F)
bans <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "standard_all_win_share_countries.xlsx"), colNames = F)
invs[2:nrow(invs), 15] <- rowMeans(apply(as.matrix.noquote(invs[2:nrow(invs), c(16,20:23)]), 2, as.numeric))
taxs[2:nrow(taxs), 15] <- rowMeans(apply(as.matrix.noquote(taxs[2:nrow(taxs), c(16,20:23)]), 2, as.numeric))
bans[2:nrow(bans), 15] <- rowMeans(apply(as.matrix.noquote(bans[2:nrow(bans), c(16,20:23)]), 2, as.numeric))
invs[2:nrow(invs), 16] <- rowMeans(apply(as.matrix.noquote(invs[2:nrow(invs), 17:19]), 2, as.numeric))
taxs[2:nrow(taxs), 16] <- rowMeans(apply(as.matrix.noquote(taxs[2:nrow(taxs), 17:19]), 2, as.numeric))
bans[2:nrow(bans), 16] <- rowMeans(apply(as.matrix.noquote(bans[2:nrow(bans), 17:19]), 2, as.numeric))
joins <- rbind(c("", "Green infrastructure program", "", "", "Carbon tax with cash transfers", "", "", "Ban on combustion-engine cars", "", ""), 
               c("", rep(c("High-income", "CHN, IND, IDN", "Other middle-income"), 3)),
               c(t(invs[2, c(1,2,16,15)]), rep("", 6)), 
               c("Increase the use of public transport/Encourage people to drive less", t(invs[3, c(2,16,15)]), t(taxs[2, c(2,16,15)]), rep("", 3)), 
               c(taxs[3, 1], "", "", "", t(taxs[3, c(2,16,15)]), "", "", ""), 
               c("Reduce GHG emissions/Reduce CO2 emissions from cars", "", "", "", t(taxs[4, c(2,16,15)]), t(bans[2, c(2,16,15)])), 
               cbind(invs[c(4,6:14),c(1,2,16,15)], taxs[c(5,7:15),c(2,16,15)], bans[c(3,5:13),c(2,16,15)]))
write.xlsx(joins, paste0("../xlsx", sub("../figures", "", folder), "main_policies_all_win_share_3.xlsx"), overwrite = T, col.names = F)

join_cn <- join
join_cn[3:16,2:10] <- sapply(join[3:16,2:10], as.numeric)/sapply(joins[3:16,2:10], as.numeric) - sapply(join[3:16,2:10], as.numeric)
write.xlsx(join_cn, paste0("../xlsx", sub("../figures", "", folder), "main_policies_all_win_negative_3.xlsx"), overwrite = T, col.names = F)

# Figure 13B (figures/all/lmg_main_policies_C): R^2 = 70%
summary(lm(as.formula(paste("index_main_policies ~ ", paste(c(setAt, setC, "factor(country)"), collapse = ' + '))), data = all, weights = all$weight))$adj.r.squared
R2
reg_policies_C <- lm(as.formula(paste("index_main_policies ~ ", paste(c(setC[c(1,3:5,7,10:14)], "factor(country)"), collapse = ' + '))), data = all, weights = all$weight) 
variance_main_policies_C_all <- calc.relimp(reg_policies_C, type = c("lmg"), rela = F, rank= F)
(lmg_main_policies_C_US <- barres(data = unname(t(as.matrix(variance_main_policies_C_all@lmg))), labels = gsub("\\&", "&", unname(regressors_names[names(variance_main_policies_C_all@lmg)]), fixed = T), 
                                  legend = "% of response variances", use_plotly = use_plotly, show_ticks = F, rev = F, digits = 1))
if (use_plotly) save_plotly(lmg_main_policies_C_US, width= 720, height=500, folder = "../figures/all/", filename = "lmg_main_policies_C")
write.csv(variance_main_policies_C_all@lmg, paste0("../tables/all/LMG_main_policies_C.csv")) # 14%

# /!\ the next line of code takes hours to run 
variance_main_policies_AtC_all <- calc.relimp(lm(as.formula(paste("index_main_policies", " ~ ", paste(c(setAt[-2], setC, "country"), collapse = ' + '))), 
                                                 data = all, weights = all$weight), type = c("lmg"), rela = F, rank= F)
(lmg_main_policies_AtC_US <- barres(data = unname(t(as.matrix(variance_main_policies_AtC_all@lmg))), labels = gsub("\\&", "&", unname(regressors_names[names(variance_main_policies_AtC_all@lmg)]), fixed = T), 
                                    legend = "% of response variances", use_plotly = use_plotly, show_ticks = F, rev = F, digits = 1))
if (use_plotly) save_plotly(lmg_main_policies_AtC_US, width= 720, height=500, folder = "../figures/all/", filename = "lmg_main_policies_AtC")
write.csv(variance_main_policies_AtC_all@lmg, paste0("../tables/all/LMG_main_policies_AtC.csv"))

weighted_cor(all$index_main_policies, all$index_fairness, weight=all$weight) # 89%


##### 6. Reasoning #####
# 6.2 Treatment effects on support for climate policies
countries_treatment_pvalues <- array(NA, dim = c(3, 20, 3), dimnames = c(list(c("investments_support > 0", "standard_support > 0", "tax_transfers_support > 0")), list(countries), list(c("Climate impacts", "Climate policy", "Both"))))
countries_treatment_sign_effects <- countries_treatment_effects <- countries_treatment_relative_effects <- countries_treatment_inv_relative_effects <- countries_treatment_left_right_gap_effects <- countries_treatment_pvalues
countries_main_support <- countries_main_oppose <- countries_main_left_right_gap <- array(NA, dim = c(3, 20), dimnames = c(list(c("investments_support > 0", "standard_support > 0", "tax_transfers_support > 0")), list(countries)))
for (pol in c("investments_support > 0", "standard_support > 0", "tax_transfers_support > 0")) {
  for (c in countries) {
    countries_main_support[pol, c] <- eval(str2expression(paste0("wtd.mean(d('", c, "')$", pol, ", weights = d('", c, "')$weight * (d('", c, "')$treatment == 'None'))")))
    countries_main_oppose[pol, c] <- eval(str2expression(paste0("wtd.mean(d('", c, "')$", sub(">", "<", pol), ", weights = d('", c, "')$weight * (d('", c, "')$treatment == 'None'))")))
    countries_main_left_right_gap[pol, c] <- eval(str2expression(paste0("wtd.mean(d('", c, "')$", pol, ", weights = d('", c, "')$weight * (d('", c, "')$left_right <= -1) * (d('", c, "')$treatment == 'None'))"))) - 
      eval(str2expression(paste0("wtd.mean(d('", c, "')$", pol, ", weights = d('", c, "')$weight * (d('", c, "')$left_right > 0) * (d('", c, "')$treatment == 'None'))")))
    for (t in c("Climate impacts", "Climate policy", "Both")) { 
    reg <- lm(as.formula(paste(pol, " ~ ", paste(setAt, collapse = '+'))), data = all, weights = weight, subset = country == c)
    reg <- coeftest(reg, vcov = vcovHC(reg, type="HC1")) # Robust SEs, equivalent to robust or vce(robust) in Stata
    countries_treatment_effects[pol, c, t] <- reg[paste0("treatment", t), 1]
    countries_treatment_pvalues[pol, c, t] <- reg[paste0("treatment", t), 4]
    countries_treatment_sign_effects[pol, c, t] <- ifelse(countries_treatment_pvalues[pol, c, t] < .1, countries_treatment_effects[pol, c, t], 0)
    countries_treatment_relative_effects[pol, c, t] <- countries_treatment_effects[pol, c, t]/countries_main_support[pol, c]
    countries_treatment_inv_relative_effects[pol, c, t] <- countries_treatment_effects[pol, c, t]/countries_main_oppose[pol, c]
    countries_treatment_left_right_gap_effects[pol, c, t] <- countries_treatment_effects[pol, c, t]/countries_main_left_right_gap[pol, c]
  } }
}

(countries_with_sign_effect_Both_on_investment_support <- sort(names(countries_treatment_sign_effects["investments_support > 0",,"Both"])[countries_treatment_sign_effects["investments_support > 0",,"Both"] > 0])) 
mean(countries_treatment_relative_effects["investments_support > 0", countries_with_sign_effect_Both_on_investment_support, "Both"]) # 13% without IT  
mean(countries_treatment_inv_relative_effects["investments_support > 0",  intersect(countries[high_income], countries_with_sign_effect_Both_on_investment_support), "Both"]) # 54% 

(countries_with_sign_effect_Policy_on_standard_support <- sort(names(countries_treatment_sign_effects["standard_support > 0",,"Climate policy"])[countries_treatment_sign_effects["standard_support > 0",,"Climate policy"] > 0]))
(countries_with_sign_effect_Both_on_standard_support <- sort(names(countries_treatment_sign_effects["standard_support > 0",,"Both"])[countries_treatment_sign_effects["standard_support > 0",,"Both"] > 0]))
mean(countries_treatment_relative_effects["standard_support > 0", countries_with_sign_effect_Both_on_standard_support, "Both"]) # 21%
sort(countries_treatment_relative_effects["standard_support > 0", countries_with_sign_effect_Both_on_standard_support, "Both"]) # 7% ID to 43% AU
mean(countries_treatment_inv_relative_effects["standard_support > 0",  countries_with_sign_effect_Both_on_standard_support, "Both"]) # 56%
mean(countries_treatment_left_right_gap_effects["standard_support > 0",  countries_with_sign_effect_Both_on_standard_support, "Both"]) # 33% 

setdiff(countries, countries_with_sign_effect_Policy_on_tax_transfers_support <- sort(names(countries_treatment_sign_effects["tax_transfers_support > 0",,"Climate policy"])[countries_treatment_sign_effects["tax_transfers_support > 0",,"Climate policy"] > 0])) #MX
mean(countries_treatment_relative_effects["tax_transfers_support > 0", countries_with_sign_effect_Policy_on_tax_transfers_support, "Climate policy"]) # 27%
sort(countries_treatment_relative_effects["tax_transfers_support > 0", countries_with_sign_effect_Policy_on_tax_transfers_support, "Climate policy"]) # 11% IA-CN to 49% DE
mean(countries_treatment_inv_relative_effects["tax_transfers_support > 0", countries_with_sign_effect_Policy_on_tax_transfers_support, "Climate policy"]) # 62%
mean(countries_treatment_left_right_gap_effects["tax_transfers_support > 0",  countries_with_sign_effect_Policy_on_tax_transfers_support, "Climate policy"]) # 59% TODO output of this line is 3.89
names(which(countries_treatment_effects["tax_transfers_support > 0",, 'Both'] <= countries_treatment_effects["tax_transfers_support > 0",, 'Climate policy'])) # CA, DE, TR, CN, IA
countries_with_sign_effect_Both_on_tax_transfers_support <- sort(names(countries_treatment_sign_effects["tax_transfers_support > 0",,"Both"])[countries_treatment_sign_effects["tax_transfers_support > 0",,"Both"] > 0])
mean(countries_treatment_relative_effects["tax_transfers_support > 0", countries_with_sign_effect_Both_on_tax_transfers_support, "Both"]) # 33%
sort(countries_treatment_relative_effects["tax_transfers_support > 0", countries_with_sign_effect_Both_on_tax_transfers_support, "Both"]) # 7% CN to 60% DK 
mean(countries_treatment_inv_relative_effects["tax_transfers_support > 0", countries_with_sign_effect_Both_on_tax_transfers_support, "Both"]) # 67%

# lm(as.formula(paste("policy_tax_fuels > 0 ~ treatment")), data = all, weights = all$weight)$coefficient[paste0("treatment", c("Both", "Climate policy"))]/wtd.mean(all$policy_tax_fuels > 0, weights = all$weight * (all$treatment == 'None'))
lm(as.formula(paste("policy_tax_fuels > 0 ~ country + ", paste(setAt, collapse = ' + '))), data = all, weights = all$weight)$coefficient[paste0("treatment", c("Both", "Climate policy"))]/wtd.mean(all$policy_tax_fuels > 0, weights = all$weight * (all$treatment == 'None')) # 17-23% 

# Figure A18B (figures/all/lmg_fairness_C): R^2 = 70% 
summary(lm(as.formula(paste("index_fairness ~ ", paste(c(setAt, setC, "factor(country)"), collapse = ' + '))), data = all, weights = all$weight))$adj.r.squared
reg_fairness_C <- lm(as.formula(paste("index_fairness ~ ", paste(c(setC[c(1,3:5,7,10:14)], "factor(country)"), collapse = ' + '))), data = all, weights = all$weight) 
variance_fairness_C_all <- calc.relimp(reg_fairness_C, type = c("lmg"), rela = F, rank= F)
(lmg_fairness_C_US <- barres(data = unname(t(as.matrix(variance_fairness_C_all@lmg))), use_plotly = use_plotly, labels = gsub("\\&", "&", unname(regressors_names[names(variance_fairness_C_all@lmg)]), fixed = T), legend = "% of response variances", show_ticks = F, rev = F, digits = 1))
if (use_plotly) save_plotly(lmg_fairness_C_US, width= 720, height=500, folder = "../figures/all/", filename = "lmg_fairness_C")
write.csv(variance_fairness_C_all@lmg, paste0("../tables/all/LMG_fairness_C.csv"))


# Figure A18B (figures/all/lmg_willingness_C)
summary(lm(as.formula(paste("index_willing_change ~ ", paste(c(setAt, setC, "factor(country)"), collapse = ' + '))), data = all, weights = all$weight))$adj.r.squared
reg_willingness_C <- lm(as.formula(paste("index_willing_change ~ ", paste(c(setC[c(1,3:5,7,10:14)], "factor(country)"), collapse = ' + '))), data = all, weights = all$weight) 
variance_willingness_C_all <- calc.relimp(reg_willingness_C, type = c("lmg"), rela = F, rank= F)
(lmg_willingness_C_US <- barres(data = unname(t(as.matrix(variance_willingness_C_all@lmg))), use_plotly = use_plotly, labels = gsub("\\&", "&", unname(regressors_names[names(variance_willingness_C_all@lmg)]), fixed = T), legend = "% of response variances", show_ticks = F, rev = F, digits = 1))
if (use_plotly) save_plotly(lmg_willingness_C_US, width= 720, height=500, folder = "../figures/all/", filename = "lmg_willingness_C")
write.csv(variance_willingness_C_all@lmg, paste0("../tables/all/LMG_willingness_C.csv"))

wtd.mean(all$tax_transfers_win_lose_poor > 0, weights = all$weight * (all$treatment == 'None')) # 30% 
wtd.mean(all$tax_transfers_win_lose_poor > 0, weights = all$weight * (all$treatment == 'Climate policy')) # 47%


##### A2. Survey #####
## A2.1 Duration
# Survey timeline
mean(sapply(countries, function(c) return(mean(d(c)$date <= as.Date(d(c)$date[1])+30)))) # 81% collected in first month

median(all$duration) # 28 min

# survey_launch <- c("09-28", "10-04", "05-11", "05-25", "07-30", "09-23", "09-23", "10-01", "09-28", "10-20", "09-23", "10-06", "09-23", "03-25", "10-07", "10-14", "10-06", "09-27", "09-30", "11-11")
one_month_after_survey_launch <- c("10-28", "11-04", "06-11", "06-25", "08-30", "10-23", "10-23", "11-01", "10-28", "11-20", "10-23", "11-06", "10-23", "04-25", "11-07", "11-14", "11-06", "10-27", "10-30", "12-11")
round(mean(sapply(countries, FUN = function(c) { mean(d(c)$date < paste0("2021-", one_month_after_survey_launch[c], " 23:59:00")) } )), 2)

# Median duration by country
sort(sapply(paste0(countries), function(c) median(all$duration[all$finished_attentive == T  & alla$country == c], na.rm = T)))

# Figure A1 (figures/all/cdf_duration)
# Time distribution
mar_old <- par()$mar
cex_old <- par()$cex
par(mar = c(3.4, 3.4, 1.1, 0.1), xpd = FALSE, cex=1.5)
cdf_time_sk <- n(d("SK", alla)$duration[d("SK", alla)$finished_attentive==T]) %>% Ecdf()
cdf_time_sa <- n(d("SA", alla)$duration[d("SA", alla)$finished_attentive==T]) %>% Ecdf()
cdf_time_us <- n(d("US", alla)$duration[d("US", alla)$finished_attentive==T]) %>% Ecdf()
cdf_time_pl <- n(d("PL", alla)$duration[d("PL", alla)$finished_attentive==T]) %>% Ecdf()
cdf_time_hi <- Ecdf(n(alla$duration[alla$finished_attentive==T & high_income[alla$country]]))
cdf_time_mi <- Ecdf(n(alla$duration[alla$finished_attentive==T & !high_income[alla$country]]))
plot(cdf_time_hi$x, cdf_time_hi$y , type="s", lwd=2, col="darkblue", main="", ylab="",  xlim = c(11, 50), xlab="") 
grid()
abline(v = max_duration)
lines(cdf_time_sk$x, cdf_time_sk$y, lwd=1, lty = 2, col="orange")
lines(cdf_time_us$x, cdf_time_us$y, lwd=1, lty = 3, col="green")
lines(cdf_time_pl$x, cdf_time_pl$y, lwd=1, lty = 4, col="purple")
lines(cdf_time_sa$x, cdf_time_sa$y, lwd=1, lty = 5, col="red")
title(ylab=expression("Proportion of duration < x"), xlab="Duration (in min)", line=2.3)
legend("bottomright", col=c("darkblue", "orange", "green", "purple", "red"), cex = 0.85, lty = 1:5, lwd=c(2, rep(1, 4)), legend = c("All countries", "South Korea", "U.S.", "Poland", "South Africa")) 
par(mar = mar_old, cex = cex_old)
save_plot(filename = "../figures/FigureA1", width = 750, height = 450, format = 'pdf')

# ## A2.2 Data quality
# 20% of matrices are rushed (27% in Turkey)
for (c in c("all", countries)) print(paste(c, round(mean(d(c)$share_all_same, na.rm = T), 3)))
# 11% who rush at least half of the matrices (19% in Indonesia)
for (c in c("all", countries)) print(paste(c, round(mean(d(c)$share_all_same > 0.5, na.rm = T), 3)))
summary(lm(tax_transfers_support == 0 ~ share_all_same, data = all, weights = all$weight)) # +24pp
# 15% leave open-field empty (38% in China) 
for (c in c("all", countries)) print(paste(c, round(wtd.mean(is.na(d(c)$CC_field), d(c)$weight, na.rm = T), 3)))
# 14% have inconsistent answers on carbon tax (22% in Canada) 
for (c in c("all", countries)) print(paste(c, round(wtd.mean(d(c)$tax_transfers_support * d(c)$tax_transfer_all < 0, d(c)$weight, na.rm = T), 3)))
# 93% respondents rank one country highest in total emissions (although they did not have to) 
decrit(all$most_footprint_reg != "PNR")


##### A3. Additional figures #####

# Figure A6 (figures/country_comparison/standard_variants_positive)
heatmap_plot(heatmap_table(vars = c("standard_support", "standard_10k_fine", "standard_100k_fine", "standard_prefer_ban", "standard_prefer_10k_fine", 
                                    "standard_prefer_10k_fine", "standard_prefer_100k_fine", "standard_prefer_ban"), 
                           conditions = c(rep("> 0", 3), "== 1", "== 1", "== 2", "== 3", "== 3"), 
                           labels = c("Supports a ban", "Supports a 10,000€ fine", "Supports a 100,000€ fine", "Prefers a ban", "Prefers a 10,000€ fine", 
                                      "Places a 10,000€ fine as second-preferred option", "Places a 100,000€ fine as least-preferred option", "Places a ban as least-preferred option"), 
                           data = all[all$country %in% c("DE", "IT", "PL", "SP"), ], special = "EU"))
save_plot(filename = "../figures/FigureA6", width = 1550, height = 400, format = 'pdf')


##### A4. Additional tables #####
# Table A1 (tables/sample_composition/AU_CA_DK_FR_ageCombined)
summary_stats_table(c("AU", "CA", "DK", "FR"))
# Table A2 (tables/sample_composition/DE_IT_JP_PL_ageCombined)
summary_stats_table(c("DE", "IT", "JP", "PL"))
# Table A3 (tables/sample_composition/SK_SP_UK_US_ageCombined)
summary_stats_table(c("SK", "SP", "UK", "US"))
# Table A4 (tables/sample_composition/BR_CN_IA_ID_ageCombined)
summary_stats_table(c("BR", "CN", "IA", "ID"), hi = F)
# Table A5 (tables/sample_composition/MX_TR_SA_UA_ageCombined)
summary_stats_table(c("MX", "TR", "SA", "UA"), hi = F)


# Table A6 (tables/knowledge_AtB) 
# /!\ In case of "Error in if (is.na(s)) { :...", install the patched version of stargazer (cf. .Rprofile)
reg_appendix(dep_vars = c("index_knowledge", "index_knowledge_footprint", "index_knowledge_fundamentals", "index_knowledge_gases", "index_knowledge_impacts"), filename = "knowledge_AtB", 
             dep.var.labels = c("\\makecell{Knowledge\\\\index}", "Footprint", "Fundamentals", "Greenhouse gases", "Impacts"), 
             dep.var.caption = "Knowledge of climate change", A = T, B = T, C = FALSE, data = all, add_linesAB = T)

# Table A7 (tables/regs_countries/index_knowledge_AtB_hi)
# Table A8 (tables/regs_countries/index_knowledge_AtB_mi)
reg_appendix("index_knowledge", along = "country3", A = T, B = T, C = FALSE, data = all)

# Table A9 (tables/support_AtB)
desc_table(dep_vars = c("index_main_policies", "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0"), 
           dep.var.labels = c("\\makecell{Main climate\\\\policies index}", "\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", 
                              "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "support_AtB", dep.var.caption = "Support", data = all, indep_vars = c(setAt, setB, "country"), keep = c(setAt, setB), mean_control = T, 
           add_lines = c(list(c(49, "Panel B: Energy usage indicators")), list(c(11, "Panel A: Socio-economic indicators"))))

# Table A10 (tables/regs_countries/index_main_policies_AtB_hi) 
# Table A11 (tables/regs_countries/index_main_policies_AtB_mi)
reg_appendix("index_main_policies", along = "country3", A = T, B = T, C = FALSE, data = all)

# Table A12 (tables/support_AtC_keepC)
desc_table(dep_vars = c("index_main_policies", "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0"),
           dep.var.labels = c("\\makecell{Main climate\\\\policies index}", "\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", 
                              "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "support_AtC_keepC", dep.var.caption = c("Support"), data = all, indep_vars = c(setAt, setC, "country"), keep = setC, mean_control = T)

# Table A13 (tables/regs_countries/index_main_policies_AtC_keepC_hi) 
# Table A14 (tables/regs_countries/index_main_policies_AtC_keepC_mi)
reg_appendix("index_main_policies", along = "country3", A = T, B = FALSE, C = T, data = all)

# Table A15 (tables/support_fair_willing_treatment)
desc_table(dep_vars = c(#"index_main_policies",
  "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0",
  "index_fairness", "index_willing_change"),
  dep.var.labels = c("\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", "\\makecell{Carbon tax\\\\with\\\\cash transfers}", 
                     "\\makecell{Fairness of\\\\main climate\\\\policies index}", "\\makecell{Adopt\\\\climate-friendly\\\\behaviors}"),
  filename = "support_fair_willing_treatment", dep.var.caption = c("Support or Agreement"), data = all, indep_vars = c(setAt, "country"), keep = "treatment", 
  indep_labels = c("Treatment: Climate impacts", "Treatment: Climate policy", "Treatment: Both"), mean_control = T)

# Table A16 (tables/policies_treatment_hi)
treatment_table_oecd(list_countries = countries[high_income], dep_vars_all = main_outcomes, dep.var.labels_all = labels_main_outcomes,
                     filename = "policies_treatment_hi", save_folder = paste0("../tables/"), robust_SE = T,
                     dep.var.caption = c("Support or Agreement"), indep_vars = c(setAt), keep = "treatment",
                     indep_labels = c("Treatment: Both", "Treatment: Climate Policies", "Treatment: Climate Impacts"))

# Table A17 (tables/policies_treatment_mi)
treatment_table_oecd(list_countries = countries[!high_income][order(countries[!high_income])], dep_vars_all = main_outcomes, dep.var.labels_all = labels_main_outcomes,
                     filename = "policies_treatment_mi", save_folder = paste0("../tables/"), robust_SE = T,
                     dep.var.caption = c("Support or Agreement"), indep_vars = c(setAt), keep = "treatment",
                     indep_labels = c("Treatment: Both", "Treatment: Climate Policies", "Treatment: Climate Impacts"))


# Table A18 (tables/future_treatment)
desc_table(dep_vars = c("net_zero_feasible > 0", "CC_affects_self > 0", "CC_impacts_extinction > 0", "future_richness > 0", "CC_will_end > 0"),
           dep.var.labels = c("\\makecell{Net-zero\\\\by 2100\\\\is feasible}", "\\makecell{Unabated CC\\\\will negatively\\\\affect oneself}", 
                              "\\makecell{Unabated CC\\\\will cause\\\\extinction of humanity}", "\\makecell{World will\\\\be richer\\\\in 2100}", "\\makecell{Humans will\\\\halt CC\\\\by 2100}"),
           filename = "future_treatment", dep.var.caption = c("Agreement"), data = all, indep_vars = c(setAt, "country"), keep = "treatment", 
           indep_labels = c("Treatment: Climate impacts", "Treatment: Climate policy", "Treatment: Both"), mean_control = T)


##### A9. Robustness checks #####
##### A9.1 Among attentive #####

# Table A25 (tables/support_fair_willing_treatment_among_attentive)
desc_table(dep_vars = c(#"index_main_policies",
  "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0",
  "index_fairness", "index_willing_change"),
  dep.var.labels = c("\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", "\\makecell{Carbon tax\\\\with\\\\cash transfers}", 
                     "\\makecell{Fairness of\\\\main climate\\\\policies index}", "\\makecell{Adopt\\\\climate-friendly\\\\behaviors}"),
  filename = "support_fair_willing_treatment_among_attentive", dep.var.caption = c("Support or Agreement"), data = all[replace_na(all$know_treatment_climate != 0 & all$know_treatment_policy != 0, T),], 
  indep_vars = c(setAt, "country"), keep = "treatment", indep_labels = c("Treatment: Climate impacts", "Treatment: Climate policy", "Treatment: Both"), mean_control = T)


##### A9.2 Including quality fail #####
print(paste(nrow(allq), "complete in more than 11 min")) # 45349 
nrow(all) # 40680
nrow(all)/nrow(allq) # 90%
print(paste(nrow(allr), "complete in more than 20 min")) # 30775 (cf. A9.5 for the Tables)


# Table A26 (tables/knowledge_AtB_allq) 
reg_appendix(dep_vars = c("index_knowledge", "index_knowledge_footprint", "index_knowledge_fundamentals", "index_knowledge_gases", "index_knowledge_impacts"), filename = "knowledge_AtB_allq", 
             dep.var.labels = c("\\makecell{Knowledge\\\\index}", "Footprint", "Fundamentals", "Greenhouse gases", "Impacts"), dep.var.caption = "Knowledge of climate change", 
             A = T, B = T, C = FALSE, data = allq, add_linesAB = T)

# Table A27 (tables/support_AtB_allq) 
desc_table(dep_vars = c("index_main_policies", "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0"), 
           dep.var.labels = c("\\makecell{Main climate\\\\policies index}", "\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", 
                              "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "support_AtB_allq", dep.var.caption = "Support", data = allq, indep_vars = c(setAt, setB, "country"), keep = c(setAt, setB), mean_control = T, 
           add_lines = c(list(c(49, "Panel B: Energy usage indicators")), list(c(11, "Panel A: Socio-economic indicators"))))

# Table A28 (tables/regs_countries/index_main_policies_allq_AtB_hi) 
# Table A29 (tables/regs_countries/index_main_policies_allq_AtB_mi) 
reg_appendix("index_main_policies", along = "country3", A = T, B = T, C = FALSE, data = allq, filename = "index_main_policies_allq") 

# Table A30 (tables/knowledge_support_AtC_keepC_allq)
desc_table(dep_vars = c("index_knowledge", "index_main_policies", "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0"),
           dep.var.labels = c("\\makecell{Knowledge\\\\index}", "\\makecell{Main climate\\\\policies index}", "\\makecell{Green\\\\infrastructure\\\\program}", 
                              "\\makecell{Ban on\\\\combustion-engine\\\\cars}", "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "knowledge_support_AtC_keepC_allq", dep.var.caption = c("Knowledge or Support"), data = allq, indep_vars = c(setAt, setC, "country"), keep = setC, mean_control = T)




##### A9.3 Attrition analysis #####
print(paste(nrow(alla), "start"))
print(paste(sum(no.na(alla$excluded)=="QuotaMet"), "are excluded for their quota is met"))
print(paste(nrow(alln), "allowed to participate"))
print(paste(sum(alln$dropout), "dropout"))
print(paste(sum(alln$dropout_late), "dropout after socio-demos"))
print(paste(sum(!alln$dropout), "are allowed and do not drop out"))
print(paste(sum(no.na(alln$attention_test) != "A little" & !alln$dropout), "fail the attention test"))
print(paste(sum(alln$duration <= max_duration & !alln$dropout & (no.na(alln$attention_test) == "A little")), "complete in less than 11.5 min"))
print(paste(sum(((no.na(alln$attention_test) != "A little") | alln$duration <= max_duration) & !alln$dropout), "are excluded"))
print(paste(nrow(all), "in final sample"))
summary(lm(dropout ~ treatment, data = alla, weights = alla$weight))
summary(lm(dropout ~ (treatment=="None"):country + country, data = alla, weights = alla$weight))
summary(lm(as.formula(paste("dropout ~ ", paste(setAt, collapse = ' + '))), data = alla, weights = alla$weight))
summary(lm(as.formula(paste("(dropout & as.numeric(alla$progress > 30)) ~ ", paste(c("treatment", "college", "age", "income_factor", "country"), collapse = ' + '))), data = alla, weights = alla$weight))

# Table A31 (tables/support_fair_willing_treatment_allq) 
desc_table(dep_vars = c(#"index_main_policies", 
  "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0",
  "index_fairness", "index_willing_change"),
  dep.var.labels = c("\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", "\\makecell{Carbon tax\\\\with\\\\cash transfers}", 
                     "\\makecell{Fairness of\\\\main climate\\\\policies index}", "\\makecell{Adopt\\\\climate-friendly\\\\behaviors}"),
  filename = "support_fair_willing_treatment_allq", dep.var.caption = c("Support or Agreement"), data = allq, indep_vars = c(setAt, "country"), keep = "treatment", 
  indep_labels = c("Treatment: Climate impacts", "Treatment: Climate policy", "Treatment: Both"), mean_control = T)


# Table A32 (tables/attrition_analysis)
desc_table(dep_vars = c("dropout", "dropout_late", "failed_test", "duration", "duration < 11.5"),
           dep.var.labels = c("\\makecell{Dropped out}", "\\makecell{Dropped out\\\\after\\\\socio-eco}", "\\makecell{Failed\\\\attention test}", 
                              "\\makecell{Duration\\\\(in min)}", "\\makecell{Duration\\\\below\\\\11.5 min}"),
           filename = "attrition_analysis", data = c(list(alln), list(alln), list(alln), list(alln), list(alln)), indep_vars = c(setAt, setB, "country"), 
           keep = c(setAt, setB), omit = c("Below high-school", "Q1", "18-24", "other", "Rural"), mean_control = T) 

# Table A33 (tables/balance_analysis)
desc_table(dep_vars = rep(c("treatment == 'Climate impacts'", "treatment == 'Climate policy'", "treatment == 'Both'"), 2),
           dep.var.labels = rep(c("\\makecell{Treatment\\\\Climate impacts}", "\\makecell{Treatment\\\\Climate policy}", "\\makecell{Treatment\\\\Both}"), 2),
           filename = "balance_analysis", dep.var.caption = c("grep"), data = c(rep(list(all), 3), rep(list(allx), 3)), indep_vars = c(setA, setB, "country"), 
           keep = c(setA, setB), mean_control = T)
temp  <- readLines("../tables/balance_analysis.tex")
temp <- gsub(pattern = "\\multicolumn{6}{c}{grep}", replace = " \\multicolumn{3}{c}{Analysis sample} & \\multicolumn{3}{c}{Full sample}", x = temp, fixed = T)
writeLines(temp, con="../tables/balance_analysis.tex") 


##### A9.2 Excluding duration < 20 min #### 
# Table not shown in the paper for brevity"
reg_appendix(dep_vars = c("index_knowledge", "index_knowledge_footprint", "index_knowledge_fundamentals", "index_knowledge_gases", "index_knowledge_impacts"), filename = "knowledge_AtB_allr", 
             dep.var.labels = c("\\makecell{Knowledge\\\\index}", "Footprint", "Fundamentals", "Greenhouse gases", "Impacts"), dep.var.caption = "Knowledge of climate change", 
             A = T, B = T, C = FALSE, data = allr, add_linesAB = T)

reg_appendix("index_main_policies", along = "country3", A = T, B = T, C = FALSE, data = allr, filename = "index_main_policies_allr")

desc_table(dep_vars = c("index_main_policies", "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0"), 
           dep.var.labels = c("\\makecell{Main climate\\\\policies index}", "\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", 
                              "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "support_AtB_allr", dep.var.caption = "Support", data = allr, indep_vars = c(setAt, setB, "country"), keep = c(setAt, setB), mean_control = T, 
           add_lines = c(list(c(49, "Panel B: Energy usage indicators")), list(c(11, "Panel A: Socio-economic indicators"))))

desc_table(dep_vars = c("index_knowledge", "index_main_policies", "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0"),
           dep.var.labels = c("\\makecell{Knowledge\\\\index}", "\\makecell{Main climate\\\\policies index}", "\\makecell{Green\\\\infrastructure\\\\program}", 
                              "\\makecell{Ban on\\\\combustion-engine\\\\cars}", "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "knowledge_support_AtC_keepC_allr", dep.var.caption = c("Knowledge or Support"), data = allr, indep_vars = c(setAt, setC, "country"), keep = setC, mean_control = T)

desc_table(dep_vars = c(#"index_main_policies",
  "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0",
  "index_fairness", "index_willing_change"),
  dep.var.labels = c("\\makecell{Green\\\\infrastructure\\\\program}", "\\makecell{Ban on\\\\combustion-engine\\\\cars}", "\\makecell{Carbon tax\\\\with\\\\cash transfers}", 
                     "\\makecell{Fairness of\\\\main climate\\\\policies index}", "\\makecell{Adopt\\\\climate-friendly\\\\behaviors}"),
  filename = "support_fair_willing_treatment_allr", dep.var.caption = c("Support or Agreement"), data = allr, indep_vars = c(setAt, "country"), keep = "treatment", 
  indep_labels = c("Treatment: Climate impacts", "Treatment: Climate policy", "Treatment: Both"), mean_control = T)

rm(allr)


##### A10. Open-ended fields #####
# Figure A24 (figures/CC_fields/CC_field_mentions_raw_positive_countries)
heatmap_wrapper(vars = var_CC_field_names[6:18], labels = as.character(CC_field_names_names[6:18]), special = special, 
                name = "../CC_fields/CC_field_mentions_raw", conditions = ">= 1", on_control = F, proportion = F, percent = T, trim = FALSE, colors = "Blues")

# Figure A25 (figures/CC_fields/CC_field_categories_positive_countries)
heatmap_wrapper(vars = c("should_act_CC_field", "CC_field_activity_mentioned", "CC_field_instrument_mentioned", "CC_field_no_worry", "CC_field_do_not_know", "CC_field_empty", "CC_field_ambiguous"), 
                labels = c("Worry / Should act", "Activity/ies mentioned", "Instrument(s) mentioned", "No worry / Should not act", "Do not know", "Empty", "Ambiguous"), 
                name = "../CC_fields/CC_field_categories", special = special, 
                conditions = ">= 1", on_control = F, trim = FALSE, colors = "Blues")

# Figure A26 (figures/CC_fields/CC_field_contains_positive_countries)
heatmap_wrapper(vars = variables_CC_field_contains, labels = sub("_", " ", sub("CC_field_contains_", "", variables_CC_field_contains)), special = special, 
                name = "../CC_fields/CC_field_contains", conditions = ">= 1", on_control = F, proportion = F, percent = T, trim = FALSE, colors = "Blues")


##### A.5 Unweighted results ##### 
folder  <- "../figures/country_comparison_unweighted/"
reg_policies_C_unweighted <- lm(as.formula(paste("index_main_policies ~ ", paste(c(setC[c(1,3:5,7,10:14)], "factor(country)"), collapse = ' + '))), data = all) 
variance_main_policies_C_unweighted_all <- calc.relimp(reg_policies_C_unweighted, type = c("lmg"), rela = F, rank= F)
(lmg_main_policies_C_unweighted_US <- barres(data = unname(t(as.matrix(variance_main_policies_C_unweighted_all@lmg))),  use_plotly = use_plotly,
                                             labels = gsub("\\&", "&", unname(regressors_names[names(variance_main_policies_C_unweighted_all@lmg)]), fixed = T), 
                                             legend = "% of response variances", show_ticks = F, rev = F, digits = 1))
if (use_plotly) save_plotly(lmg_main_policies_C_unweighted_US, width= 720, height=500, folder = "../figures/all/", filename = "lmg_main_policies_C_unweighted")
write.csv(variance_main_policies_C_unweighted_all@lmg, paste0("../tables/all/LMG_main_policies_unweighted_C.csv"))

# Figure 6 (figures/country_comparison/Heatplot_knowledge_full_countries)
heatmap_plot(heatmap_table(vars = c(main_variables_knowledge[c(1,3)], "GHG_CO2", "GHG_methane", "GHG_H2", "GHG_particulates", "CC_impacts_droughts", "CC_impacts_sea_rise", 
                                    "CC_impacts_volcanos", "footprint_el_nuclear", "footprint_fd_beef", "footprint_tr_plane", "footprint_reg_china", "footprint_pc_US"), 
                           filename = "knowledge_full", conditions = c("> 0", "== 0", rep("> 0", 2), rep("<= 0", 2), rep("> 0", 2), "< 0", "== 3", rep("== 1", 4)), special = special, 
                           labels = c(labels_main_knowledge[1], "Cutting emissions by half insufficient to stop global warning", "CO2 is a greenhouse gas", "Methane is a greenhouse gas", 
                                      "Hydrogen is not a greenhouse gas", "Particulate matter is not a greenhouse gas", "Severe droughts and heatwaves are likely if CC goes unabated", 
                                      "Sea-level rise is likely if CC goes unabated", "More frequent volcanic eruptions are unlikely if CC goes unabated", 
                                      "GHG footprint of nuclear is lower than gas or coal", "GHG footprint of beef/meat is higher than chicken or pasta", 
                                      "GHG footprint of plane is higher than car or train/bus", "Total emissions of China are higher than other regions", 
                                      "Per capita emissions of the US are higher than other regions"), weights = NULL))
save_plot(filename = paste0(folder, "knowledge_full", replacement_text), width = 1650, height = 650, format = 'xlsx') 


# Figure 8 (figures/country_comparison/Heatplot_willingness_conditions_all_positive_countries)
heatmap_wrapper(vars = c(variables_willingness_all[c(1:9,12,13)]), labels = c(labels_willingness_all[c(1:9,12,13)]), name = 'willingness_conditions_all', special = special, conditions = rep(">= 1", 11), weights = NULL)


# Figure 11 (figures/country_comparison/Heatplot_main_policies_all_win_positive_3)
heatmap_wrapper(vars = rev(c("investments_support", "investments_fair", variables_investments_win_lose, "investments_costless_costly", "investments_positive_negative", 
                             "investments_large_effect", "investments_effect_less_pollution", "investments_effect_public_transport", "investments_effect_elec_greener")), 
                alphabetical = alphabetical, special = special, name = "investments_all_win", 
                labels = rev(c("Support", "Is fair", paste("Would gain:", labels_investments_win_lose), "Costless way to fight climate change", 
                               "Positive effect on economy and employment", "Large effect on economy and employment", "Reduce air pollution", "Increase the use of public transport", 
                               "Make electricity production greener")), conditions = c(heatmap_conditions, "<= -1"), df = e, weights = NULL)
heatmap_wrapper(vars = rev(c("standard_support", "standard_fair", variables_standard_win_lose, "standard_costless_costly", "standard_positive_negative", 
                             "standard_large_effect", "standard_effect_less_pollution", "standard_effect_less_emission")), 
                alphabetical = alphabetical, special = special, name = "standard_all_win", 
                labels = rev(c("Support", "Is fair", paste("Would gain:", labels_standard_win_lose), "Costless way to fight climate change", 
                               "Positive effect on economy and employment", "Large effect on economy and employment", "Reduce air pollution", "Reduce CO2 emissions from cars")), 
                conditions = c(heatmap_conditions, "<= -1"), df = e, weights = NULL)
heatmap_wrapper(vars = rev(c("tax_transfers_support", "tax_transfers_fair", variables_tax_transfers_win_lose, "tax_transfers_costless_costly", "tax_transfers_positive_negative", 
                             "tax_transfers_large_effect", "tax_transfers_effect_less_pollution", "tax_transfers_effect_less_emission", "tax_transfers_effect_insulation", "tax_transfers_effect_driving")), 
                alphabetical = alphabetical, special = special, name = "tax_transfers_all_win", 
                labels = rev(c("Support", "Is fair", paste("Would gain:", labels_tax_transfers_win_lose), "Costless way to fight climate change", "Positive effect on economy and employment", 
                               "Large effect on economy and employment", "Reduce air pollution", "Reduce GHG emissions", "Encourage insulation of buildings", "Encourage people to drive less")), 
                conditions = c(heatmap_conditions, "<= -1"), df = e, weights = NULL)
inv <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "investments_all_win_positive_countries.xlsx"), colNames = F)
tax <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "tax_transfers_all_win_positive_countries.xlsx"), colNames = F)
ban <- read.xlsx(paste0("../xlsx", sub("../figures", "", folder), "standard_all_win_positive_countries.xlsx"), colNames = F)
inv[2:nrow(inv), 15] <- rowMeans(apply(as.matrix.noquote(inv[2:nrow(inv), c(16,20:23)]), 2, as.numeric))
tax[2:nrow(tax), 15] <- rowMeans(apply(as.matrix.noquote(tax[2:nrow(tax), c(16,20:23)]), 2, as.numeric))
ban[2:nrow(ban), 15] <- rowMeans(apply(as.matrix.noquote(ban[2:nrow(ban), c(16,20:23)]), 2, as.numeric))
inv[2:nrow(inv), 16] <- rowMeans(apply(as.matrix.noquote(inv[2:nrow(inv), 17:19]), 2, as.numeric))
tax[2:nrow(tax), 16] <- rowMeans(apply(as.matrix.noquote(tax[2:nrow(tax), 17:19]), 2, as.numeric))
ban[2:nrow(ban), 16] <- rowMeans(apply(as.matrix.noquote(ban[2:nrow(ban), 17:19]), 2, as.numeric))
join <- rbind(c("", "Green infrastructure program", "", "", "Carbon tax with cash transfers", "", "", "Ban on combustion-engine cars", "", ""), 
              c("", rep(c("High-income", "CHN, IND, IDN", "Other middle-income"), 3)),
              c(t(inv[2, c(1,2,16,15)]), rep("", 6)), 
              c("Increase the use of public transport/Encourage people to drive less", t(inv[3, c(2,16,15)]), t(tax[2, c(2,16,15)]), rep("", 3)), 
              c(tax[3, 1], "", "", "", t(tax[3, c(2,16,15)]), "", "", ""), 
              c("Reduce GHG emissions/Reduce CO2 emissions from cars", "", "", "", t(tax[4, c(2,16,15)]), t(ban[2, c(2,16,15)])), 
              cbind(inv[c(4,6:14),c(1,2,16,15)], tax[c(5,7:15),c(2,16,15)], ban[c(3,5:13),c(2,16,15)]))
write.xlsx(join, paste0("../xlsx", sub("../figures", "", folder), "main_policies_all_win_positive_3.xlsx"), overwrite = T, col.names = F)


# Figure 9 (figures/country_comparison/national_policies_new_positive_countries)
heatmap_wrapper(name = "national_policies_new", vars = c(variables_policies_main[c(4,2,3,1)], "tax_transfers_progressive_support", variables_policy[c(2,1,3:5)], 
                                                         "insulation_mandatory_support_no_priming", variables_beef[1:4], variables_tax[1:9]), 
                labels = c(labels_policies_main[c(4,2,3,1)], "Carbon tax with progressive transfers", labels_policy_short[c(2,1,3:5)], "Mandatory and subsidized insulation of buildings", 
                           labels_beef[1:4], c(paste("Carbon tax (CT) funding:<br>", labels_tax[1]), paste("CT:", labels_tax[2:9]))), conditions = heatmap_conditions, special = special, weights = NULL)

# Average support for 3 main policies by country
support_main <- sapply(countries, function(c) mean(sapply(paste0(names_policies, "_support"), function(p) return(wtd.mean(d(c)[[p]][d(c)$treatment == "None"] > 0, weights = NULL)))))
round(sort(support_main), 3)

heatmap_wrapper(vars = variables_scale, labels = labels_heatmap_scale, conditions = ">= 1", name = "support_main", alphabetical = alphabetical, special = special, df = e, weights = NULL)

folder  <- "../figures/country_comparison/"


##### A.8 Complementary surveys #####
source("Complementary_tables.R")


##### For Referee: on original 6 countries
summary(lm(as.formula(paste("index_main_policies ~ ", paste(c(setAt, setC, "factor(country)"), collapse = ' + '))), data = all[all$country %in% c("DE", "DK", "FR", "IT", "UK", "US"),], 
           weights = all[all$country %in% c("DE", "DK", "FR", "IT", "UK", "US"),"weight"]))$adj.r.squared
R2
reg_policies_C <- lm(as.formula(paste("index_main_policies ~ ", paste(c(setC[c(1,3:5,7,10:14)], "factor(country)"), collapse = ' + '))), 
                     data = all[all$country %in% c("DE", "DK", "FR", "IT", "UK", "US"),], weights = all[all$country %in% c("DE", "DK", "FR", "IT", "UK", "US"),"weight"]) 
variance_main_policies_C_all <- calc.relimp(reg_policies_C, type = c("lmg"), rela = F, rank= F)
(lmg_main_policies_C_US <- barres(data = unname(t(as.matrix(variance_main_policies_C_all@lmg))),  use_plotly = use_plotly,
                                  labels = gsub("\\&", "&", unname(regressors_names[names(variance_main_policies_C_all@lmg)]), fixed = T), 
                                  legend = "% of response variances", show_ticks = F, rev = F, digits = 1))
if (use_plotly) save_plotly(lmg_main_policies_C_US, width= 720, height=500, folder = "../figures/all/", filename = "lmg_main_policies_C_restricted")
write.csv(variance_main_policies_C_all@lmg, paste0("../tables/all/LMG_main_policies_C_restricted.csv"))

# vars_heterogeneity_concern <- c("know_anthropogenic" = "CC_anthropogenic > 0", "knowledge" = "index_knowledge_simple", "concern" = "index_concerned_about_CC", "denier" = "CC_anthropogenic == -2", "CC_problem" = "CC_problem > 0")
# regs_heterogeneity_concern <- list()
# for (v in names(vars_heterogeneity_concern)) {
#   print(v)
#   e$temp <- 1* eval(str2expression(paste0("e$", vars_heterogeneity_concern[v])))
#   regs_heterogeneity_concern[[v]] <- reg_lm("index_main_policies", c(setAt, setB, "country", setC, "temp * index_policies_emissions_plus", "temp * index_lose_policies_subjective", "temp * index_lose_policies_poor")) }
# table_heterogeneity_concern <- stargazer(regs_heterogeneity_concern,  title="Heterogeneous effects of perceptions on support, depending on climate concern or knowledge", 
#                                          model.names = F, header = F, model.numbers = F, dep.var.caption = "Interacted variable:",  #star.cutoffs = c(0.1, 1e-5, 1e-30),
#                                          column.labels = c("Know CC anthropogenic", "Index Knowledge", "Index Concern", "Denies CC", "Agrees CC problem"), out = "../tables/heterogeneity_concern.tex",
#                                          covariate.labels = c("Believes policies would reduce emissions", "Believes will personally lose", "Believes poor people will lose", 
#                                                               "Interacted variable", "Interacted var $\\times$ Believes policies would reduce emissions", 
#                                                               "Interacted var $\\times$ Believes will personally lose", "Interacted var $\\times$ Believes poor people will lose"),
#                                          add.lines = list(c("Controls (sets A, B, C): Socio-demographics, country FE, perceptions, treatment", "\\checkmark", "\\checkmark", "\\checkmark", "\\checkmark", "\\checkmark")),
#                                          keep = c("temp", "index_policies_emissions_plus", "index_lose_policies_subjective", "index_lose_policies_poor"), no.space=TRUE, intercept.bottom=FALSE, 
#                                          intercept.top=TRUE, omit.stat=c("adj.rsq", "f", "ser", "ll", "aic"), label="tab:heterogeneity_concern")

save.image("after_paper_produced.RData") 
(run_time <- Sys.time() - start - prepare_time) # 30 min


##### Reverse IV ####
bootstart <- Sys.time()
source("reverse_IV_bootstrap.R") # 15h = 3*5h
source("reverse_IV_bootstrap_all.R") # 3h = 3*1h
save.image("after_paper_produced.RData") 
Sys.time() - bootstart # 18 hours
