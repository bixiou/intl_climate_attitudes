# This script performs reverse IV bootstrap analysis on multiple outcomes using the boot package.
# It defines a function to compute the statistic for each country, performs bootstrapping for each outcome, and creates a dataframe for Stata with confidence intervals.

# Define a function to compute the statistic for each country
compute_statistic_all <- function(data, indices) {
  # Resample the data
  # Get the unique countries
  rep_count <<- rep_count + 1
  setpb(pb, rep_count)
  
  # Initialize a vector to store the differences for each country
  differences <- numeric(length(countries))
  
  # Loop over all countries
    # Subset the data for the i-th country
    resampled_data <- data[indices,]
    
    # Fit the models and compute the statistic as before
    indices_reg <- list()
    for (j in seq_along(indices_set)) {
      indices_reg[[j]] <- summary(lm(as.formula(paste(indices_set[j], " ~ ", paste(c(setAt, "factor(country)"), collapse = ' + '))), data = resampled_data, weights = resampled_data$weight))
    }
    supportA <- summary(lm(as.formula(paste(outcome, " ~ ", paste(c(setAt, "factor(country)"), collapse = ' + '))), data = resampled_data, weights = resampled_data$weight))
    supportAC <- summary(lm(as.formula(paste(outcome, " ~ ", paste(c(setA, indices_set, "factor(country)"), collapse = ' + '))), data = resampled_data[resampled_data$treatment == "None",], weights = resampled_data[resampled_data$treatment == "None","weight"]))
    
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
  return(c(difference_impact, difference_policy, difference_both))
}

tot_rep <- 1000

# Perform bootstrapping for tax_transfers_support
outcome <- "tax_transfers_support > 0"
indices_set <- setC_tax_transfers
start_time <- Sys.time()
set.seed(123)
rep_count <- 0
pb <- startpb(min = 0, max = tot_rep)
results_tax_transfers_all <- boot(data = all, statistic = compute_statistic_all, R = 1000)
end_time <- Sys.time()
print(end_time - start_time)

# Perform bootstrapping for investments_support
outcome <- "investments_support > 0"
indices_set <- setC_investments
start_time <- Sys.time()
set.seed(123)
rep_count <- 0
pb <- startpb(min = 0, max = tot_rep)
results_investments_all <- boot(data = all, statistic = compute_statistic_all, R = 1000)
end_time <- Sys.time()
print(end_time - start_time)

# Perform bootstrapping for standard_support
outcome <- "standard_support > 0"
indices_set <- setC_standard
start_time <- Sys.time()
set.seed(123)
rep_count <- 0
results_standard_all <- boot(data = all, statistic = compute_statistic_all, R = 1000)
end_time <- Sys.time()
print(end_time - start_time)

# Create DF for Stata with CI
output_stata_tax_transfers_boot <- tidy(results_tax_transfers_all, conf.int = TRUE, conf.level = 0.95, conf.method = "basic")
output_stata_tax_transfers_boot$treatment <- c("Climate Impacts", "Climate Policies", "Both Treatments")
output_stata_tax_transfers_boot$outcome <- "Carbon Tax with Cash Transfers"

output_stata_investments_boot <- tidy(results_investments_all, conf.int = TRUE, conf.level = 0.95, conf.method = "basic")
output_stata_investments_boot$treatment <- c("Climate Impacts", "Climate Policies", "Both Treatments")
output_stata_investments_boot$outcome <- "Green Infrastructure Program"

output_stata_standard_boot <- tidy(results_standard_all, conf.int = TRUE, conf.level = 0.95, conf.method = "basic")
output_stata_standard_boot$treatment <- c("Climate Impacts", "Climate Policies", "Both Treatments")
output_stata_standard_boot$outcome <- "Ban on Combustion-Engine Cars"

boot_stata_countries <- rbind(output_stata_tax_transfers_boot, output_stata_investments_boot, output_stata_standard_boot)
names(boot_stata_countries) <- c("coef", "bias", "se", "lb", "ub", "treatment", "outcome")
haven::write_dta(boot_stata_countries, "../data/boot_stata_countries_reverseIV_all_control.dta")
