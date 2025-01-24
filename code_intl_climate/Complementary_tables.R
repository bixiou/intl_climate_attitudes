##### 1. Compared questions formulation #####
decrit(all$CC_dynamic[all$treatment == "None" & all$country == "US"], weights = all$weight[all$treatment == "None" & all$country == "US"])
decrit(usc$CC_dynamic[usc$extra_incentive == F], weights = usc$weight[usc$extra_incentive == F])

decrit(all$policy_tax_fuels[all$treatment == "None"] > 0, weights = all$weight[all$treatment == "None"])
decrit(all$donation_percent[all$treatment == "None"], weights = all$weight[all$treatment == "None"])
sqrt(wtd.var(all$donation_percent[all$treatment == "None"], all$weight[all$treatment == "None"]))
wtd.mean(all$donation_percent[all$treatment == "None"], all$weight[all$treatment == "None"])

weighted_cor(all$index_willing_change, all$donation_percent, weight=all$weight)
weighted_cor(all$index_main_policies, all$donation_percent, weight=all$weight)
weighted_cor(all$index_willing_change, all$donation_percent > 0, weight=all$weight)
weighted_cor(all$index_main_policies, all$donation_percent > 0, weight=all$weight)

##### 2. Non-response bias (extra incentives) #####
## P-value of differebce charac
country_list = c("usc_regular", "usc_extra")
labels_columns_stats <- c("Sample size","Man", "18-24 years old", "25-34 years old", "35-49 years old", "More than 50 years old",
                          "Below $35,000", "$35,000-$70,000", "$70,000-$120,000", "Above $120,000",
                          "White alone", "African-American/Black", "Hispanic/Latino",
                          "Midwest", "Northeast", "South", "West", "Urban", "Bachelor's degree or higher",
                          "Vote: Biden", "Vote: Trump", "Unemployment rate (15-64)", "Home ownership rate")
stats_table <- data.frame(row.names = labels_columns_stats[2:length(labels_columns_stats)])
# Loop over countries
for (i in seq_along(country_list)){
  dataset <- eval(parse(text = country_list[i]))
  # Get Sample statistics
  sample_size <- NROW(dataset)
  # Gender statistics
  sample_male <- sum(grepl("Male", dataset$gender))
  sample_male_N <- sum(!is.na(dataset$gender))
  # Age statistics
  sample_age_18_24 <- as.numeric(unlist(decrit(dataset$age, weight = F))[10])
  sample_age_25_34 <- as.numeric(unlist(decrit(dataset$age, weight = F))[11])
  sample_age_35_49 <- as.numeric(unlist(decrit(dataset$age, weight = F))[12])
  sample_age_50_64 <- as.numeric(unlist(decrit(dataset$age, weight = F))[13])
  sample_age_65_more <- as.numeric(unlist(decrit(dataset$age, weight = F))[14])
  sample_age_N <- as.numeric(unlist(decrit(dataset$age, weight = F))[2])
  # Income statistics
  sample_income_Q1 <- as.numeric(unlist(decrit(dataset$income, weight = F))[9])
  sample_income_Q2 <- as.numeric(unlist(decrit(dataset$income, weight = F))[10])
  sample_income_Q3 <- as.numeric(unlist(decrit(dataset$income, weight = F))[11])
  sample_income_Q4 <- as.numeric(unlist(decrit(dataset$income, weight = F))[12])
  sample_income_N <- as.numeric(unlist(decrit(dataset$income, weight = F))[2])
  # Race/Ethnicity
  sample_white <-  sum(grepl("White", dataset$race))
  sample_black <-  sum(grepl("Black", dataset$race))
  sample_hispanic <-  sum(grepl("Hispanic", dataset$race))
  sample_race <- c(sample_white, sample_black, sample_hispanic)
  sample_race_N <- sum(!is.na(dataset$race))
  # Region statistics
  sample_region_1 <- as.numeric(unlist(decrit(dataset$region, weight = F))[9])
  sample_region_2 <- as.numeric(unlist(decrit(dataset$region, weight = F))[10])
  sample_region_3 <- as.numeric(unlist(decrit(dataset$region, weight = F))[11])
  sample_region_4 <- as.numeric(unlist(decrit(dataset$region, weight = F))[12])
  sample_region_N <- as.numeric(unlist(decrit(dataset$region, weight = F))[2])
  # Urban statistics
  sample_urban <-  as.numeric(unlist(decrit(dataset$urban, weight = F))[8])
  sample_urban_N <- as.numeric(unlist(decrit(dataset$urban, weight = F))[2])
  # Education statistics
  sample_bachelor <- sum(dataset$education_good %in% c("4-year College Degree", "Professional Degree (JD, MD, MBA)",
                                                       "Doctoral Degree", "Master's Degree"))
  sample_bachelor_N <- sum(!is.na(dataset$education_good))
  # Unemployment statistics
  sample_unemployment_rate <- as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[18])
  sample_unemployment_rate_N <-(as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[18]) +
                                  as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[12]) +
                                  as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[14]) +
                                  as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[16]))
  # Vote statistics
  sample_candidate_1_mean <- sum(grepl("Biden", dataset$vote_voters))
  sample_candidate_2_mean <- sum(grepl("Trump", dataset$vote_voters))
  sample_vote_N <- sum(!is.na(dataset$vote_voters))
  sample_vote <- c(sample_candidate_1_mean, sample_candidate_2_mean)
  
  # Home ownership statistics
  sample_home_ownership <- sum(dataset$home_owner)
  sample_home_ownership_N <- length(dataset$home_owner)
  # Combine Statistics
  sample <- c(sample_male, sample_age_18_24, sample_age_25_34, sample_age_35_49, sample_age_50_64 + sample_age_65_more,
              sample_income_Q1, sample_income_Q2, sample_income_Q3, sample_income_Q4, sample_race, sample_region_1, sample_region_2,
              sample_region_3, sample_region_4, sample_urban, sample_bachelor, sample_vote,
              sample_unemployment_rate, sample_home_ownership)
  sample_N <- c(sample_male_N, rep(sample_age_N, 4), rep(sample_income_N, 4), rep(sample_race_N, 3), rep(sample_region_N, 4),
                sample_urban_N, sample_bachelor_N, rep(sample_vote_N, 2), sample_unemployment_rate_N, sample_home_ownership_N)
  names(sample) <- labels_columns_stats[2:length(labels_columns_stats)]
  #sample_rounded <- c(prettyNum(sample[1], big.mark = ","), sprintf("%.2f",round(sample[2:length(sample)], digits = 2)))
  #names(sample_rounded) <- labels_columns_stats
  # Append the two vectors to a common data frame
  stats_table[,(i*2-1)] <- sample
  stats_table[,(i*2)] <- sample_N
  names(stats_table)[(i*2-1)] <- paste0(country_list[i])
  names(stats_table)[(i*2)] <- paste0(country_list[i], "_N")
} 
# Function to calculate p-value
calculate_p_value <- function(row) {
  x1 <- row['usc_regular']
  x2 <- row['usc_extra']
  n1 <- row['usc_regular_N']
  n2 <- row['usc_extra_N']
  
  test_result <- prop.test(c(x1, x2), c(n1, n2))
  return(test_result$p.value)
}
# Apply the function to each row
stats_table$P_Value <- apply(stats_table, 1, calculate_p_value)
stats_table$usc_regular <-  sprintf("%.2f",round(stats_table$usc_regular/stats_table$usc_regular_N, digits = 2))
stats_table$usc_extra <-  sprintf("%.2f",round(stats_table$usc_extra/stats_table$usc_extra_N, digits = 2))
stats_table$P_Value <-  sprintf("%.3f",round(stats_table$P_Value, digits = 3))
stats_table <- stats_table[,c(1,3,5)]

# Create the LaTeX table
filename <- paste0("usc_non_response")
line_sep <- c("\\addlinespace", "", "", "", "\\addlinespace","", "", "",
              "\\addlinespace", "", "", "\\addlinespace", "", "", "",
              "\\addlinespace","\\addlinespace", "\\addlinespace","","\\addlinespace", "\\addlinespace")
latex_output <- kbl(stats_table, "latex", align = "ccc",
                    col.names = c("Regular Incentives Share", "Extra Incentives Share", "P-value of difference"), booktabs = TRUE,
                    linesep = line_sep)
cat(paste(latex_output, collapse="\n"), file = paste0("../tables/", filename, ".tex"))

## Complementary Survey
# Sets A
desc_table(dep_vars = c("index_main_policies", "investments_support > 0", "standard_support > 0", "tax_transfers_support > 0"), 
           dep.var.labels = c("\\makecell{Main climate\\\\policies index}",
                              "\\makecell{Green\\\\infrastructure\\\\program}",
                              "\\makecell{Ban on\\\\combustion-engine\\\\cars}",
                              "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "usc_support_At_extra", dep.var.caption = "Support", data = usc, indep_vars = c(setA, "extra_incentive"),
           keep = c("extra_incentive"), mean_control = T, robust_SE = T)

##### 3. Motivated Reasoning (section incentives) #####
### Effects of incentives on outcomes
## Knowledge
desc_table(dep_vars = c("index_knowledge_fundamentals", "index_knowledge_footprint", "index_knowledge_gases"), 
           dep.var.labels = c("\\makecell{CC is real, human-made\\\\ \\& its dynamic index}",
                              "\\makecell{GHG emission ranking\\\\index}", "\\makecell{CC gases\\\\index}"),
           filename = "usc_knowledge_motiv_res", data = usc,
           indep_vars = c(setA, "treatment_knowledge", "extra_incentive"), robust_SE = T,
           keep = c("treatment_knowledge"), mean_control = T)
control_group_mean_knowledge <- c(wtd.mean(unlist(usc[usc$treatment_knowledge==F,
                                                      "index_knowledge_fundamentals"]),
                                           na.rm =T, weights = usc[usc$treatment_knowledge==F, "weight"]),
                                  wtd.mean(unlist(usc[usc$treatment_knowledge==F,
                                                      "index_knowledge_footprint"]),
                                           na.rm =T, weights = usc[usc$treatment_knowledge==F, "weight"]),
                                  wtd.mean(unlist(usc[usc$treatment_knowledge==F,
                                                      "index_knowledge_gases"]),
                                           na.rm =T, weights = usc[usc$treatment_knowledge==F, "weight"]))

## Policy Perceptions
# Effectiveness
desc_table(dep_vars = c("standard_effect_less_emission_new*(-1)",
                        "investments_effect_elec_greener_new*(-1)",
                        "tax_transfers_effect_less_emission_new*(-1)"), 
           dep.var.labels = c("\\makecell{Believes a ban on combustion\\\\engine cars would decrease\\\\CO2 emissions from cars}",
                              "\\makecell{Believes a green infrastructure\\\\program would decrease carbon\\\\emissions from electricity sector}",
                              "\\makecell{Believes a carbon tax with\\\\cash transfers would\\\\decrease carbon emissions}"),
           filename = "usc_beliefs_At_motiv_res_eff", data = usc,
           indep_vars_included = list(c(rep(T, length(setA)), T, F, F, T),
                                      c(rep(T, length(setA)), F, T, F, T),
                                      c(rep(T, length(setA)), F, F, T, T)),
           keep = c("treatment_ban", "treatment_investments", "treatment_tax"),
           indep_vars = c(setA,"treatment_ban", "treatment_investments", "treatment_tax", "extra_incentive"), robust_SE = T,
           mean_control = T)

control_group_mean_eff <- c(-1*wtd.mean(unlist(usc[usc$treatment_ban==F,
                                               "standard_effect_less_emission_new"]),
                                    na.rm =T, weights = usc[usc$treatment_ban==F, "weight"]),
                        -1*wtd.mean(unlist(usc[usc$treatment_investments==F,
                                               "investments_effect_elec_greener_new"]),
                                    na.rm =T, weights = usc[usc$treatment_investments==F, "weight"]),
                     -1*wtd.mean(unlist(usc[usc$treatment_tax==F,
                                               "tax_transfers_effect_less_emission_new"]),
                                    na.rm =T, weights = usc[usc$treatment_tax==F, "weight"]))
# Distributional
desc_table(dep_vars = c("standard_win_lose_poor_new*(-1)",
                        "investments_effect_low_skill_jobs",
                        "tax_transfers_win_lose_poor_new"), 
           dep.var.labels = c("\\makecell{Believes a ban on combustion\\\\engine cars would decrease\\\\cost of owning a car for\\\\low-income families}",
                              "\\makecell{Believes a green infrastructure\\\\program would increase jobs\\\\for people without a college degree}",
                              "\\makecell{Believes low-income earners\\\\would win under a carbon\\\\tax with cash transfers}"),
           filename = "usc_beliefs_At_motiv_res_distrib", data = usc,
           indep_vars_included = list(c(rep(T, length(setA)), T, F, F, T),
                                      c(rep(T, length(setA)), F, T, F, T),
                                      c(rep(T, length(setA)), F, F, T, T)),
           keep = c("treatment_ban", "treatment_investments", "treatment_tax"),
           indep_vars = c(setA,"treatment_ban", "treatment_investments", "treatment_tax", "extra_incentive"), robust_SE = T,
           mean_control = T)

control_group_mean_distrib <- c(-1*wtd.mean(unlist(usc[usc$treatment_ban==F,
                                            "standard_win_lose_poor_new"]),
                                 na.rm =T, weights = usc[usc$treatment_ban==F, "weight"]),
                        wtd.mean(unlist(usc[usc$treatment_investments==F,
                                            "investments_effect_low_skill_jobs"]),
                                 na.rm =T, weights = usc[usc$treatment_investments==F, "weight"]),
                       wtd.mean(unlist(usc[usc$treatment_tax==F,
                                            "tax_transfers_win_lose_poor_new"]),
                                 na.rm =T, weights = usc[usc$treatment_tax==F, "weight"]))
## Combine tables together
extract_values <- function(line) {
  parts <- strsplit(line, "&")[[1]]
  parts <- trimws(parts)
  values <- parts[parts != ""]
  values <- values[values != "\\\\"]
  if (nchar(parts[1]) == 0) {
    values <- values
  } else {
    values <- values[-1]
  }
  return(values)
}

table_knowledge <- readLines("../tables/usc_knowledge_motiv_res.tex")
table_eff <- readLines("../tables/usc_beliefs_At_motiv_res_eff.tex")
table_distrib <- readLines("../tables/usc_beliefs_At_motiv_res_distrib.tex")
table <- c(table_knowledge[2:4],
           " & & & \\\\",
           sub(".*?&", "\\\\textbf{\\\\makecell{Panel A: Knowledge of\\\\\\\\Climate Policies}} & ", table_knowledge[5]),
           table_knowledge[6:7],
           sub(".*?&", "Incentives treatment &", table_knowledge[9]),
           table_knowledge[10:11],
           paste0("Control group mean &", round(control_group_mean_knowledge[1], 3),"&",
                  round(control_group_mean_knowledge[2], 3), "&",  round(control_group_mean_knowledge[3], 3),
                  "\\\\"),
           table_knowledge[13:14],
           " & & & \\\\ \\hline  & & & \\\\",
           sub(".*?&", "\\\\textbf{\\\\makecell{Panel B: Beliefs about Effectiveness\\\\\\\\of Climate Policies}} &  ", table_eff[5]),
           table_eff[6:7], 
           paste("Incentives treatment &", paste(unlist(lapply(table_eff[c(9, 11, 13)], extract_values)), collapse = " & ")),
           paste(" &", paste(unlist(lapply(table_eff[c(10, 12, 14)], extract_values)), collapse = " & ")), table_eff[15],
           paste0("Control group mean &", round(control_group_mean_eff[1], 3),"&",
                  round(control_group_mean_eff[2], 3), "&",  round(control_group_mean_eff[3], 3),
                  "\\\\"),
           table_eff[17:18],
           " & & & \\\\ \\hline  & & & \\\\",
           sub(".*?&", "\\\\textbf{\\\\makecell{Panel C: Beliefs about Distributional\\\\\\\\Effects of Climate Policies}} &  ", table_distrib[5]),
           table_distrib[6:7],
           paste("Incentives treatment &", paste(unlist(lapply(table_distrib[c(9, 11, 13)], extract_values)), collapse = " & ")),
           paste(" &", paste(unlist(lapply(table_distrib[c(10, 12, 14)], extract_values)), collapse = " & ")), table_distrib[15],
           paste0("Control group mean &", round(control_group_mean_distrib[1], 3),"&",
                  round(control_group_mean_distrib[2], 3), "&",  round(control_group_mean_distrib[3], 3),
                  "\\\\"),
           table_distrib[17:21])

cat(paste(table, collapse="\n"), file = "../tables/usc_beliefs_knowledge_motiv_res.tex") 

### Comparisons of effects of beliefs depending on incentives
desc_table(dep_vars = c("standard_support > 0"), 
           dep.var.labels = c("\\makecell{Ban on\\\\combustion-engine\\\\cars}"),
           filename = "usc_standard_C_interact_new_rep", dep.var.caption = "Support", data = usc,
           indep_vars = c(setA, "extra_incentive", setC_standard[-c(12, 14)],
                          "index_standard_emissions_plus_new_rep",
                          "index_lose_standard_poor_new_rep",
                          "treatment_ban",
                          "index_standard_emissions_plus_new_rep*treatment_ban",
                          "index_lose_standard_poor_new_rep*treatment_ban"),
           keep = c("index_standard_pollution", "index_lose_standard_subjective",
                    "index_standard_emissions_plus_new_rep",
                    "index_lose_standard_poor_new_rep",
                    "index_lose_standard_poor_new_rep*treatment_ban",
                    "index_standard_emissions_plus_new_rep*treatment_ban"),
           mean_control = T, robust_SE = T)
desc_table(dep_vars = c("investments_support > 0"), 
           dep.var.labels = c("\\makecell{Green\\\\infrastructure\\\\program}"),
           filename = "usc_investments_C_interact_new_rep", dep.var.caption = "Support", data = usc,
           indep_vars = c(setA, "extra_incentive", setC_investments[-c(12,14)],
                          "index_investments_emissions_plus_new_rep",
                          "index_lose_investments_poor_new_rep",
                          "treatment_investments",
                          "index_investments_emissions_plus_new_rep*treatment_investments",
                          "index_lose_investments_poor_new_rep*treatment_investments"),
           keep = c("index_investments_pollution","index_lose_investments_subjective",
                    "index_investments_emissions_plus_new_rep",
                    "index_lose_investments_poor_new_rep",
                    "index_lose_investments_poor_new_rep*treatment_investments",
                    "index_investments_emissions_plus_new_rep*treatment_investments"),
           mean_control = T, robust_SE = T)
desc_table(dep_vars = c("tax_transfers_support > 0"), 
           dep.var.labels = c("\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
           filename = "usc_tax_C_interact_new_rep", dep.var.caption = "Support", data = usc,
           indep_vars = c(setA, "extra_incentive", setC_tax_transfers[-c(12,14)],
                          "index_tax_emissions_plus_new_rep",
                          "index_lose_tax_transfers_poor_new_rep",
                          "treatment_tax",
                          "index_tax_emissions_plus_new_rep*treatment_tax",
                          "index_lose_tax_transfers_poor_new_rep*treatment_tax"),
           keep = c("index_tax_transfers_pollution", "index_lose_tax_transfers_subjective",
                    "index_tax_emissions_plus_new_rep",
                    "index_lose_tax_transfers_poor_new_rep",
                    "index_lose_tax_transfers_poor_new_rep*treatment_tax",
                    "index_tax_emissions_plus_new_rep*treatment_tax"),
           mean_control = T, robust_SE = T)

# Function to read a LaTeX table from a .tex file and convert it to a data frame
read_latex_table <- function(file_path) {
  lines <- readLines(file_path)
  table_start <- grep("\\\\begin\\{tabular\\}", lines)
  table_end <- grep("\\\\end\\{tabular\\}", lines)
  table_content <- lines[(table_start + 1):(table_end - 1)]
  
  # Remove unnecessary LaTeX commands and extract data
  table_content <- table_content[!grepl("\\\\hline|\\\\[-1.8ex]|\\\\cline", table_content)]
  table_content <- gsub("\\\\$", "", table_content)
  
  # Split rows by LaTeX table row delimiters
  table_rows <- str_split(table_content, " \\\\ ")
  table_rows <- lapply(table_rows, function(row) str_split(row, " & ")[[1]])
  
  # Convert to data frame
  table_df <- do.call(rbind, table_rows)
  table_df <- as.data.frame(table_df, stringsAsFactors = FALSE)
  
  # Remove empty rows (if any)
  table_df <- table_df[apply(table_df, 1, function(x) any(x != "")), ]
  
  return(table_df)
}

usc_standard_C_interact <- read_latex_table("../tables/usc_standard_C_interact_new_rep.tex")
usc_standard_C_interact$V2 <- gsub("\\\\ ", "", gsub(" \\\\", "", usc_standard_C_interact$V2))
usc_investments_C_interact <- read_latex_table("../tables/usc_investments_C_interact_new_rep.tex")
usc_investments_C_interact$V2 <- gsub("\\\\ ", "", gsub(" \\\\", "", usc_investments_C_interact$V2))
usc_tax_C_interact <- read_latex_table("../tables/usc_tax_C_interact_new_rep.tex")
usc_tax_C_interact$V2 <- gsub("\\\\ ", "", gsub(" \\\\", "", usc_tax_C_interact$V2))

# Assuming the first row is the header and rest are the data rows
usc_standard_C_interact <- usc_standard_C_interact[c(-2:-1), ]
usc_investments_C_interact <- usc_investments_C_interact[c(-2:-1), ]
usc_tax_C_interact <- usc_tax_C_interact[c(-2:-1), ]

# Merge the data frames by a common column
merged_df <- cbind( usc_standard_C_interact, usc_investments_C_interact[,-1],
                    usc_tax_C_interact[,-1])


header <- c("", "3")
names(header) <- c("", "Support")

## Create the LaTeX table
latex_output <- kbl(merged_df, "latex", align = "lccc", row.names = F,
                    booktabs = TRUE, escape = F,
                    col.names = c("", "\\makecell{Ban on\\\\combustion-engine\\\\cars}",
                                  "\\makecell{Green\\\\infrastructure\\\\program}",
                                  "\\makecell{Carbon tax\\\\with\\\\cash transfers}"),
                    linesep = "") %>%
  add_header_above(header, escape = F)

cat(paste(latex_output, collapse="\n"), file = "../tables/usc_motiv_interact_new_rep.tex")
table <- readLines("../tables/usc_motiv_interact_new_rep.tex")

control_group_mean <- c(wtd.mean(usc[usc$treatment_investments==F,
                                     "investments_support"] > 0,
                                 na.rm =T, weights = usc[usc$treatment_investments==F, "weight"]),
                        wtd.mean(usc[usc$treatment_ban==F,
                                     "standard_support"] > 0,
                                 na.rm =T, weights = usc[usc$treatment_ban==F, "weight"]),
                        wtd.mean(usc[usc$treatment_tax==F,
                                     "tax_transfers_support"] > 0,
                                 na.rm =T, weights = usc[usc$treatment_tax==F, "weight"]))

table <- c(table[2:6], " & (1) & (2) & (3) \\\\",
           "\\midrule",paste0("Control group mean &", paste(round(control_group_mean, digits = 3), collapse = "&"), "\\\\"), table[7:19],
           "\\midrule", table[20:23])
cat(paste(table, collapse="\n"), file = "../tables/usc_motiv_interact_new_rep.tex")

##### 4. Comparisons with other surveys #####
# Rows
labels_rows <- c()
CC_problem_usc <- weighted.mean(usc$CC_problem > 0, usc$weight)
CC_problem_us <- weighted.mean(us_control$CC_problem > 0, us_control$weight)
CC_problem_pew <-weighted.mean(usc$CC_problem_pew > 0, usc$weight)
CC_affects_self_gallup <- weighted.mean(usc$CC_affects_self_gallup >= 0, usc$weight, na.rm = T)

labels_rows <- c("\\makecell{Do you agree or disagree with the following statement?\\\\“Climate change is an important
                   problem.”\\\\
                   \\textit{[Somewhat agree/Strongly agree]}\\\\(Our own survey)}",
                 "\\makecell{In your view, is global climate change\\\\a very serious problem,
                 somewhat serious,\\\\not too serious or not a problem?\\\\
                   \\textit{[A somewhat serious problem/A very serious problem]}\\\\(Pew Research Center, 2015)}",
                 "\\makecell{Do you think climate change will\\\\be a threat to people in your country in\\\\the next 20 years?\\\\
                 \\textit{[Somewhat serious threat/Very serious threat]}\\\\(Gallup, 2022)}")

CC_affects_self_usc <- weighted.mean(usc$CC_affects_self >= 0, usc$weight)
CC_affects_self_us <- weighted.mean(us_control$CC_affects_self >= 0, us_control$weight)
CC_affects_self_pew <- weighted.mean(usc$CC_affects_self_pew > 0, usc$weight, na.rm = T)
CC_affects_self_leiserowitz <- weighted.mean(usc$CC_affects_self_leiserowitz > 0, usc$weight, na.rm = T)

labels_rows <- c(labels_rows,
                 "\\makecell{To what extent do you think\\\\climate change already affects or
                 will affect\\\\your personal life negatively?\\\\
                   \\textit{[A lot/A great deal]}\\\\(Our own survey)}",
                 "\\makecell{How concerned are you, if at all,\\\\that global climate change
                 will harm you\\\\personally at some point in your lifetime?\\\\
                 \\textit{[Somewhat concerned/Very concerned]}\\\\(Pew Research Center, 2021)}",
                 "\\makecell{How much do you think climate\\\\change will harm you personally?\\\\
                 \\textit{[A moderate amount/A great deal]}\\\\(Leiserowitz et al., 2022)}")

CC_will_end_usc <- weighted.mean(usc$CC_will_end > 0, usc$weight)
CC_will_end_us <- weighted.mean(us_control$CC_will_end > 0, us_control$weight)
CC_will_end_pew <- weighted.mean(usc$CC_will_end_pew > 0, usc$weight)
labels_rows <- c(labels_rows,
                 "\\makecell{How likely is it that humankind\\\\halts climate change by the end\\\\of the century?\\\\
                 \\textit{[Somewhat likely/Very likely]}\\\\(Our own survey)}",
                 "\\makecell{How confident are you that actions\\\\taken by the international
                 community\\\\will significantly reduce the effects\\\\of global climate change?\\\\
                 \\texit{[Somewhat confident/Very confident]}\\\\(Pew Research Center, 2021)}")

should_fight_CC_usc <- NA
should_fight_CC_us <- weighted.mean(us_control$should_fight_CC > 0, us_control$weight)
should_fight_CC_wb <- weighted.mean(usc$should_fight_CC_wb == 1, usc$weight)
labels_rows <- c(labels_rows,
                 "\\makecell{Do you agree or disagree with the following statement:\\\\
                 “The U.S. should take measures to fight climate change.”\\\\
                 \\textit{[Somewhat agree/Strongly agree]}\\\\(Our own survey)}",
                 "\\makecell{Do you think our country does or\\\\does not have a responsibility
                 to take\\\\steps to deal with climate change?\\\\
                 \\textit{[Does]}\\\\(World Bank, 2009)}"
)

effect_halt_CC_economy_usc <- weighted.mean(usc$effect_halt_CC_economy > 0, usc$weight)
effect_halt_CC_economy_us <- weighted.mean(us_control$effect_halt_CC_economy > 0, us_control$weight)
effect_halt_CC_economy_pew <- weighted.mean(usc$effect_halt_CC_economy_pew > 0, usc$weight)
labels_rows <- c(labels_rows,
                 "\\makecell{If we decide to halt climate change\\\\through ambitious policies, 
                 what would be\\\\the effects on the U.S. economy and employment?\\\\
                 \\textit{[Positive/Very positive]}\\\\(Our own survey)}",
                 "\\makecell{Do you think actions taken by the international\\\\community to 
                 address global climate change,\\\\such as the Paris climate agreement,\\\\
                 will mostly benefit the U.S. economy,\\\\mostly harm the U.S. economy,\\\\
                 or have no impact?\\\\
                 \\textit{[Mostly benefit the U.S. economy]}\\\\(Pew Research Center, 2021)}")

CC_concern_group_leiserowitz_not <-  weighted.mean(usc$CC_concern_group_leiserowitz == -1, usc$weight)
CC_concern_group_leiserowitz_family <-  weighted.mean(usc$CC_concern_group_leiserowitz == 0, usc$weight)
CC_concern_group_leiserowitz_community <-  weighted.mean(usc$CC_concern_group_leiserowitz == 1, usc$weight)
CC_concern_group_leiserowitz_usa <-  weighted.mean(usc$CC_concern_group_leiserowitz == 2, usc$weight)
CC_concern_group_leiserowitz_world <-  weighted.mean(usc$CC_concern_group_leiserowitz == 3, usc$weight)
CC_concern_group_leiserowitz_nature <-  weighted.mean(usc$CC_concern_group_leiserowitz == 4, usc$weight)

labels_rows <- c(labels_rows,
                 "\\makecell{Which of the following are\\\\
                 you most concerned about?\\\\
                 The impacts of global warming on... \\\\ (Leiserowitz et al., 2006)}",
                 "\\makecell{\\textit{[Not at all concerned]}}",
                 "\\makecell{\\textit{[You and your family]}}",
                 "\\makecell{\\textit{[Your local community]}}",
                 "\\makecell{\\textit{[The U.S. as a whole]}}",
                 "\\makecell{\\textit{[People all over the world]}}",
                 "\\makecell{\\textit{[Non-human nature]}}")


# Columns
output_table <- data.frame(new_survey = round(c(CC_problem_pew,CC_affects_self_gallup,
                             CC_affects_self_pew,CC_affects_self_leiserowitz,
                             CC_will_end_pew, should_fight_CC_wb,
                             effect_halt_CC_economy_pew, 999,
                             CC_concern_group_leiserowitz_not, CC_concern_group_leiserowitz_family,
                             CC_concern_group_leiserowitz_community, CC_concern_group_leiserowitz_usa,
                             CC_concern_group_leiserowitz_world, CC_concern_group_leiserowitz_nature)*100),
                 old_survey = round(c(.74, .75, .60, .52,
                             .45, .82,
                             .32, 999,
                             .1, .12, .01, .09, .5, .18)*100),
                 row.names = labels_rows[!grepl("Our own", labels_rows)])

output_table$new_survey <- as.character(output_table$new_survey)
output_table$new_survey[output_table$new_survey == "99900"] <- ""
output_table$old_survey <- as.character(output_table$old_survey)
output_table$old_survey[output_table$old_survey == "99900"] <- ""

## Tables
latex_output <- kbl(output_table, "latex",
                    col.names = c("Our Complementary Survey", "Original Survey"), booktabs = TRUE, escape = F,
                    align = "cc",
                    linesep = c("\\addlinespace", "\\midrule",
                                "\\addlinespace", "\\midrule",
                                "\\midrule",
                                "\\midrule", "\\midrule", 
                                "\\addlinespace","\\addlinespace", "\\addlinespace",
                                "\\addlinespace", "\\addlinespace", "\\addlinespace", ""))

cat(paste(latex_output, collapse="\n"), file = paste0("../tables/", "usc_comparison_survey", ".tex"))

##### 5. Social Desirability Bias (list experiment) #####
# Tax transfers
tacit_support_tax_transfers <- wtd.mean(usc$list_experiment_policy_num[usc$treatment_list_experiment_policy == T],
                                        weights = usc$weight[usc$treatment_list_experiment_policy == T]) - wtd.mean(
                                          usc$list_experiment_policy_num[usc$treatment_list_experiment_policy == F],
                                          weights = usc$weight[usc$treatment_list_experiment_policy == F])
stated_support_tax_transfers <- sum((us_control$tax_transfers_support > 0)*us_control$weight)/
  (sum((us_control$tax_transfers_support <= -1)*us_control$weight)+sum((us_control$tax_transfers_support > 0)*us_control$weight))
# Willing to limit beef
tacit_willing_limt_beef <- wtd.mean(usc$list_experiment_behavior_num[usc$treatment_list_experiment_behavior == T],
                                        weights = usc$weight[usc$treatment_list_experiment_behavior == T]) - wtd.mean(
                                          usc$list_experiment_behavior_num[usc$treatment_list_experiment_behavior == F],
                                          weights = usc$weight[usc$treatment_list_experiment_behavior == F])
stated_willing_limt_beef <- sum((us_control$willing_limit_beef > 0)*us_control$weight)/
  (sum((us_control$willing_limit_beef != -.1)*us_control$weight))
labels_rows <- c("\\makecell{Support for carbon tax with cash transfers}",
                 "\\makecell{Willing to limit beef/meat consumption}")
# Proportion test
p_value_tax_transfers <-prop.test(c(tacit_support_tax_transfers*NROW(usc),
                                    stated_support_tax_transfers*NROW(us_control[as.numeric(us_control$tax_transfers_support) %in% c(-2, -1, 1, 2),])),
                                  c(NROW(usc), NROW(us_control[as.numeric(us_control$tax_transfers_support) %in% c(-2, -1, 1, 2),])))
p_value_willing_limt_beef <- prop.test(c(tacit_willing_limt_beef*NROW(usc),
                                         stated_willing_limt_beef*NROW(us_control)),
                                       c(NROW(usc), NROW(us_control[!is.na(as.numeric(us_control$willing_limit_beef)),])))

# Latex Output
output_table <- data.frame(new_survey = round(c(tacit_support_tax_transfers, tacit_willing_limt_beef), digits = 2),
                           old_survey = round(c(stated_support_tax_transfers, stated_willing_limt_beef), digits = 2),
                           p_values = round(c(p_value_tax_transfers$p.value, p_value_willing_limt_beef$p.value), digits = 3),
                           row.names = labels_rows)

latex_output <- kbl(output_table, "latex",
                    col.names = c("Tacit", "Stated", "P-value of difference"), booktabs = TRUE, escape = F,
                    align = "ccc",
                    linesep = c("", ""))

cat(paste(latex_output, collapse="\n"), file = paste0("../tables/", "usc_list_experiment", ".tex"))
