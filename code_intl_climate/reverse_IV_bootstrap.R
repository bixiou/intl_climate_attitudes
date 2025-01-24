# This script performs reverse IV bootstrap analysis on climate policy data for multiple countries.
# It uses the boot package to perform bootstrapping and compute statistics for each country.
# The compute_statistic_country function is defined to compute the statistic for each country.
# The script then performs bootstrapping for three different outcomes: tax_transfers_support, investments_support, and standard_support.
# For each outcome, it computes the statistic using the compute_statistic_country function and stores the results.
# Finally, it creates a data frame with the results and writes it to a Stata file.


# Define a function to compute the statistic for each country
compute_statistic_country <- function(data, indices) {
  # Resample the data
  # Get the unique countries
  resampled_data <- data[indices,]
  rep_count <<- rep_count + 1
  setpb(pb, rep_count)
  
  
  # Initialize a vector to store the differences for each country
  differences_impact <- numeric(length(countries))
  differences_policy <- numeric(length(countries))
  differences_both <- numeric(length(countries))
  differences_impact_weighted <- numeric(length(countries))
  differences_policy_weighted <- numeric(length(countries))
  differences_both_weighted <- numeric(length(countries))

  # Loop over all countries
  for (i in seq_along(countries)) {
    # Subset the data for the i-th country
    cat(paste("\rcountry:", countries[i]))
    resampled_data_country <- resampled_data[resampled_data$country == countries[i],]
    weight_country <- nrow(data[data$country == countries[i],]) / nrow(data)
    
    # Fit the models and compute the statistic as before
    indices_reg <- list()
    for (j in seq_along(indices_set)) {
      indices_reg[[j]] <- summary(lm(as.formula(paste(indices_set[j], " ~ ", paste(c(setAt), collapse = ' + '))), data = resampled_data_country, weights = resampled_data_country$weight))
    }
    supportA <- summary(lm(as.formula(paste(outcome, " ~ ", paste(c(setAt), collapse = ' + '))), data = resampled_data_country, weights = resampled_data_country$weight))
    supportAC <- summary(lm(as.formula(paste(outcome, " ~ ", paste(c(setA, indices_set), collapse = ' + '))), data = resampled_data_country[resampled_data_country$treatment == "None",], weights = resampled_data_country[resampled_data_country$treatment == "None",]$weight))
    
    sum_of_products_impact <- 0
    sum_of_products_policy <- 0
    sum_of_products_both <- 0
    for (j in seq_along(indices_set)) {
      sum_of_products_impact <- sum_of_products_impact + coef(indices_reg[[j]])["treatmentClimate impacts","Estimate"] * coef(supportAC)[indices_set[j],"Estimate"]
      sum_of_products_policy <- sum_of_products_policy + coef(indices_reg[[j]])["treatmentClimate policy","Estimate"] * coef(supportAC)[indices_set[j],"Estimate"]
      sum_of_products_both <- sum_of_products_both + coef(indices_reg[[j]])["treatmentBoth","Estimate"] * coef(supportAC)[indices_set[j],"Estimate"]
    }
    coef_supportA_impact <- coef(supportA)["treatmentClimate impacts", "Estimate"]
    coef_supportA_policy <- coef(supportA)["treatmentClimate policy", "Estimate"]
    coef_supportA_both <- coef(supportA)["treatmentBoth", "Estimate"]
    difference_impact <- coef_supportA_impact - sum_of_products_impact
    difference_policy <- coef_supportA_policy - sum_of_products_policy
    difference_both <- coef_supportA_both - sum_of_products_both
    
    # Store the difference for the i-th country
    differences_impact[i] <- difference_impact
    differences_policy[i] <- difference_policy
    differences_both[i] <- difference_both
    differences_impact_weighted[i] <- difference_impact*weight_country
    differences_policy_weighted[i] <- difference_policy*weight_country
    differences_both_weighted[i] <- difference_both*weight_country

  }
  
  return(c(differences_impact, mean(differences_impact), sum(differences_impact_weighted),
  differences_policy, mean(differences_policy), sum(differences_policy_weighted),
  differences_both, mean(differences_both), sum(differences_both_weighted)))
}

tot_rep <- 1000

# Perform bootstrapping for tax_transfers_support
outcome <- "tax_transfers_support > 0"
indices_set <- setC_tax_transfers
indices_set <- sub("index", "index_c", indices_set)
start_time <- Sys.time()
set.seed(123)
rep_count <- 0
pb <- startpb(min = 0, max = tot_rep)
results_tax_transfers <- boot(data = all, statistic = compute_statistic_country, R = 1000, strata = as.factor(all$country))
end_time <- Sys.time()
print(end_time - start_time)

# Perform bootstrapping for investments_support
outcome <- "investments_support > 0"
indices_set <- setC_investments
indices_set <- sub("index", "index_c", indices_set)
start_time <- Sys.time()
set.seed(123)
rep_count <- 0
pb <- startpb(min = 0, max = tot_rep)
results_investments <- boot(data = all, statistic = compute_statistic_country, R = 1000, strata = as.factor(all$country))
end_time <- Sys.time()
print(end_time - start_time)

# Perform bootstrapping for standard_support
outcome <- "standard_support > 0"
indices_set <- setC_standard
indices_set <- sub("index", "index_c", indices_set)
start_time <- Sys.time()
set.seed(123)
rep_count <- 0
pb <- startpb(min = 0, max = tot_rep)
results_standard <- boot(data = all, statistic = compute_statistic_country, R = 1000, strata = as.factor(all$country))
end_time <- Sys.time()
print(end_time - start_time)

# Create DF for Stata with CI
output_stata_tax_transfers_boot <- tidy(results_tax_transfers, conf.int = TRUE, conf.level = 0.95, conf.method = "basic")
output_stata_tax_transfers_boot$country <- rep(c(countries3,"Mean", "Weighted Mean"), 3)
output_stata_tax_transfers_boot$treatment <- rep(c("Climate Impacts", "Climate Policies", "Both Treatments"), each = length(countries3) + 2)
output_stata_tax_transfers_boot$outcome <- "Carbon Tax with Cash Transfers"

output_stata_investments_boot <- tidy(results_investments, conf.int = TRUE, conf.level = 0.95, conf.method = "basic")
output_stata_investments_boot$country <- rep(c(countries3,"Mean", "Weighted Mean"), 3)
output_stata_investments_boot$treatment <- rep(c("Climate Impacts", "Climate Policies", "Both Treatments"), each = length(countries3) + 2)
output_stata_investments_boot$outcome <- "Green Infrastructure Program"

output_stata_standard_boot <- tidy(results_standard, conf.int = TRUE, conf.level = 0.95, conf.method = "basic")
output_stata_standard_boot$country <- rep(c(countries3,"Mean", "Weighted Mean"), 3)
output_stata_standard_boot$treatment <- rep(c("Climate Impacts", "Climate Policies", "Both Treatments"), each = length(countries3) + 2)
output_stata_standard_boot$outcome <- "Ban on Combustion-Engine Cars"

boot_stata_countries <- rbind(output_stata_tax_transfers_boot, output_stata_investments_boot, output_stata_standard_boot)
names(boot_stata_countries) <- c("coef", "bias", "se", "lb", "ub", "country", "treatment", "outcome")
haven::write_dta(boot_stata_countries, "../data/boot_stata_countries_reverseIV_control.dta")