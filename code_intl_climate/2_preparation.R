# This file prepares the final dataset (all), as well as the entire dataset (alla, which merges raw samples) and the extended dataset (allq, does not exclude respondents who failed the quality tests).
# It also defines all constants, variables, and labels used in paper_reproduced.R, and exports the datasets to Stata (all.dta, alla.dta) as well as the codebooks of variables. 
# The workflow is as follows:
# 1. Definitions of quota variables and population frequencies; constants (e.g. the list of 'countries'); functions are defined.
# 2. 'prepare_all' defines the dataset, by calling in turn 'prepare' (cleansing each country raw sample) and 'merge_all_countries'
# 3. 'prepare' excludes certain respondents (e.g. who fail the quality test), cf. its documentation to understand how we get the final sample. 
#    It then calls 'relabel_and_rename' to define variable names and labels, and 'convert' to cleanse the raw data.
# 4. 'convert' is the main function. It converts original variables to the right format/class and defines derivate variables. It heavily relies on the library 'memisc'. It then defines individual weights.
# 5. 'weighting' defines the individual weights to match population frequencies.
# The function 'Label' can be used to find the variable description, e.g. Label(all$CC_real): "CC_real: In your opinion, is climate change real?"
# The function 'decrit' can be used to get descriptive statistics, e.g. decrit("CC_real") or (equivalently) decrit(all$CC_real)

##### Quotas #####
{
  # The default weight variable ('weight') is computed using the following quota variables as well as 'college_OECD', and 'employment' (cf. the 'weighting' function).
  quotas <- list("US_vote" = c("gender", "income", "age", "region", "urban", "race", "vote_2020"),
                 "AU" = c("gender", "income", "age", "region", "urban"),
                 "CA" = c("gender", "income", "age", "region", "urban"),
                 "DK" = c("gender", "income", "age", "region", "urban"),
                 "FR" = c("gender", "income", "age", "region", "diploma"), 
                 "DE" = c("gender", "income", "age", "region", "urban_category"),
                 "IT" = c("gender", "income", "age", "region", "urban_category"),
                 "JP" = c("gender", "income", "age", "region", "urban"),
                 "MX" = c("gender", "income", "age", "region", "urban_category"),
                 "PL" = c("gender", "income", "age", "region", "urban"),
                 "SK" = c("gender", "income", "age", "region", "urban_category"),
                 "SP" = c("gender", "income", "age", "region", "urban"),
                 "TR" = c("gender", "income", "age", "region", "urban"),
                 "UK" = c("gender", "income", "age", "region", "urban_category"),
                 "US" = c("gender", "income", "age", "region", "urban", "race"), 
                 "BR" = c("gender", "income", "age", "region", "urban"),
                 "CN" = c("gender", "income", "age", "region", "urban_category"),
                 "IA" = c("gender", "income", "age", "region", "urban"),
                 "ID" = c("gender", "income", "age", "region", "urban"),
                 "SA" = c("gender", "income", "age", "region", "urban"),
                 "UA" = c("gender", "income", "age", "region", "urban")
  )
  
  levels_quotas <- list(
    "gender" = c("Female", "Other", "Male"), 
    "income" = c("Q1", "Q2", "Q3", "Q4"),
    "age" = c("18-24", "25-34", "35-49", "50-64", "65+"),
    "urban" = c(FALSE, TRUE),
    "college_OECD" = c("College Degree", "No college"),
    "employment" = c(TRUE, FALSE),
    "diploma" = c("No secondary", "Vocational", "High school", "College"), 
    "US_region" = c("Northeast", "Midwest","South", "West"),
    "US_core_metropolitan" = c(FALSE, TRUE),
    "US_race" = c("White only", "Hispanic", "Black", "Other"),
    "US_vote_2020" = c("Biden", "Trump", "Other/Non-voter"), 
    "DK_region" = c("Hovedstaden", "Midtjylland", "Nordjylland", "Sjælland", "Syddanmark"),
    "FR_region" = c("autre", "IDF", "Nord-Est", "Nord-Ouest", "Sud-Est", "Sud-Ouest"),
    "FR_urban_category" = c("GP", "Couronne_GP", "Other"),
    "FR_diploma" = c("Aucun diplôme ou brevet", "CAP ou BEP", "Baccalauréat", "Supérieur"),
    "FR_CSP" = c("Inactif", "Ouvrier", "Cadre", "Indépendant", "Intermédiaire", "Retraité", "Employé", "Agriculteur"),
    "FR_region9" = c("autre","ARA", "Est", "Nord", "IDF", "Ouest", "SO", "Occ", "Centre", "PACA"),
    "FR_taille_agglo" = c("rural", "2-20k", "20-99k", ">100k", "Paris"),
    "IA_region" = c("Northern", "Southern", "Central", "Eastern", "Western"),
    "IT_region" = c("North-West", "North-East" ,"Center", "South", "Islands"),
    "IT_urban_category" = c("Cities", "Small_Cities", "Rural"),
    "UK_region" = c("London", "Southern England", "Central UK", "Northern England", "Northern UK"),
    "UK_urban_category" = c("Rural", "City_Town", "Large_urban"),
    "PL_region" = c("North", "Central", "South-West", "Central-East", "South-East"),
    "SP_region" = c("East", "Center",  "South", "North", "North-West"),
    "DE_region" = c("Northern", "Western", "Central", "Eastern", "Southern"),
    "DE_urban_category" = c("Rural", "Towns_and_Suburbs", "Cities"),
    "JP_region" = c("Kanto", "Kansai", "North", "Chubu", "South"),
    "ID_region" = c("Western Java", "Eastern Java", "Northern Islands", "Eastern Islands", "Sumatra"),
    "SA_region" = c("Gauteng", "West", "Center", "North-East", "South-East"),
    "CN_region" = c("North", "Northeast", "East", "South Central", "West"),
    "CN_urban_category" = c("Xiang", "Zhèn", "Jiedào"),
    "BR_region" = c("North", "North-East", "South-East", "South", "Central-West"),
    "MX_region" = c("Central-Western", "Central-Eastern", "North-East", "North-West", "South"),
    "MX_urban_category" = c("Rural", "Semiurbano", "Urbano"),
    "SK_region" = c("Seoul", "North", "West", "East"),
    "SK_urban_category" = c("District", "Town", "City"),
    "AU_region" = c("Western_Australia", "Queensland", "Broad_NSW", "South_Australia", "Victoria_Tasmania"),
    "CA_region" = c("North_West", "Central", "Ontario", "Quebec", "East"),
    "TR_region" = c("Marmara", "West", "Central", "East"),
    "UA_region" = c("Center", "East", "South", "West")
    
  )
  
  pop_freq <- list(
    "AU" = list(
      "gender" = c(0.506, 0.000001, 0.494),
      "income" = rep(.25, 4),
      "age" = c(0.112, 0.186, 0.262, 0.230, 0.210),
      "urban" = c(0.284, 0.716), 
      "AU_region" = c(0.113539668, 0.202217231, 0.334920221, 0.06893035,  0.280392531),
      "college_OECD" = c(.49, .51),
      "employment" = c(.73, .27)
    ),
    "CA" = list(
      "gender" = c(0.507, 0.000001, 0.493),
      "income" = rep(.25, 4),
      "age" = c(0.104, 0.175, 0.245, 0.253, 0.223),
      "urban" = c(0.167, 0.833), 
      "CA_region" = c(0.255595117, 0.067210485, 0.387866504, 0.225157997, 0.064169897),
      "college_OECD" = c(.60, .4),
      "employment" = c(.7, .3)
    ),  
    "DK" = list(
      "gender" = c(0.503, 0.000001, 0.497),
      "income" = c(0.2634, 0.2334, 0.2782, 0.2249),
      "age" = c(0.110, 0.165, 0.230, 0.245, 0.251),
      "urban" = c(0.4703, 0.5297),
      "DK_region" = c(0.3176, 0.2281, 0.1011, 0.1436, 0.2095),
      "college_OECD" = c(.42, .58),
      "employment" = c(.74, .26) 
    ),
    "FR" = list(
      "gender" = c(0.516, 0.000001, 0.484),
      "income" = rep(.25, 4),
      "urban" = c(0.405, 0.595),
      "age" = c(0.120,0.150,0.240,0.240,0.250),
      "diploma" = c(0.290, 0.248, 0.169, 0.293),
      "FR_region" = c(0.000001, 0.18920, 0.21968, 0.20041, 0.25097, 0.13980),
      "FR_urban_category" = c(0.595, 0.184, 0.222),
      "FR_diploma" = c(0.290, 0.248, 0.169, 0.293),
      "FR_CSP" = c(0.129,0.114,0.101,0.035,0.136,0.325,0.15,0.008),
      "FR_region9" = c(0.0001,0.12446,0.12848,0.09237,0.1902,0.10294,0.09299,0.09178,0.09853,0.07831),
      "FR_taille_agglo" = c(0.2166,0.1710,0.1408,0.3083,0.1633),
      "college_OECD" = c(.4, .6),
      "employment" = c(.65, .35)
    ),
    "DE" = list(
      "gender" = c(0.512, 0.000001, 0.488),
      "income" = rep(.25, 4),
      "age" = c(0.085, 0.150, 0.222, 0.280, 0.263),
      "urban" = c(FALSE, TRUE), 
      "DE_region" = c(0.1808, 0.2769, 0.1013, 0.1498, 0.2913),
      "DE_urban_category" = c(0.2020653, 0.4032331, 0.395),
      "college_OECD" = c(.31, .69),
      "employment" = c(.76, .24)
    ),
    "IT" = list(
      "gender" = c(0.524, 0.000001, 0.476),
      "income" = rep(.25, 4),
      "urban" = c(0.4699139, 0.5300861), 
      "IT_region" = c(0.2659,  0.1920,  0.1971,  0.2340,  0.1109),
      "IT_urban_category" = c(0.349, 0.480, 0.170),
      "age" = c(0.080, 0.122, 0.242, 0.271, 0.285),
      "college_OECD" = c(.29, .71),
      "employment" = c(.58, .42)
    ),
    "JP" = list(
      "gender" = c(0.519, 0.000001, 0.481),
      "income" = rep(.25, 4),
      "age" = c(0.078, 0.121, 0.244, 0.224, 0.334),
      "urban" = c(0.304, 0.696), 
      "JP_region" = c(0.345997408, 0.176839094, 0.109666596, 0.167605084, 0.199891819),
      "college_OECD" = c(.53, .47),
      "employment" = c(.77, .23)
    ),
    "MX" = list(
      "gender" = c(0.518, 0.000001, 0.482),
      "income" = rep(.25, 4),
      "age" = c(0.176, 0.233, 0.300, 0.183, 0.109),
      "urban" = c(FALSE, TRUE),
      "MX_urban_category" = c(0.214, 0.149, 0.637),
      "MX_region" = c(0.215061603, 0.329736673, 0.098869535, 0.127872823, 0.228459366),
      "college_OECD" = c(.19, .81),
      "employment" = c(.59, .41)
    ),
    "PL" = list(
      "gender" = c(0.519, 0.000001, 0.481),
      "income" = rep(.25, 4),
      "age" = c(0.087, 0.170, 0.282, 0.236, 0.225),
      "urban" = c(0.433, 0.567), 
      "PL_region" = c(0.226997438, 0.117602275, 0.218682176, 0.144438833, 0.292279278),
      "college_OECD" = c(.33, .67),
      "employment" = c(.69, .31)
    ),
    "SK" = list(
      "gender" = c(0.498, 0.000001, 0.502),
      "income" = rep(.25, 4),
      "age" = c(0.098, 0.159, 0.274, 0.282, 0.187),
      "urban" = c(FALSE, TRUE),
      "SK_urban_category" = c(0.08407891, 0.4967454, 0.4191757),
      "SK_region" = c(0.186166268, 0.343251015, 0.220256596, 0.25032612),
      "college_OECD" = c(.51, .49),
      "employment" = c(.66, .34)
    ),
    "SP" = list(
      "gender" = c(0.506, 0.000001, 0.494),
      "income" = rep(.25, 4),
      "age" = c(0.079, 0.124, 0.285, 0.266, 0.246),
      "urban" = c(0.3026822, 0.6973178), 
      "SP_region" = c(0.295240048, 0.185984429, 0.28212128,  0.107772926, 0.128881318),
      "college_OECD" = c(.4, .6),
      "employment" = c(.62, .38)
    ),
    "TR" = list(
      "gender" = c(0.513, 0.000001, 0.487),
      "income" = rep(.25, 4),
      "age" = c(0.158, 0.213, 0.297, 0.206, 0.126),
      "urban" = c(0.130, 0.870), 
      "TR_region" = c(0.303696271, 0.259076086, 0.252983823, 0.18424382),
      "college_OECD" = c(.16, .84),
      "employment" = c(.48, .52)
    ),
    "UK" = list(
      "gender" = c(0.504, 0.000001, 0.496),
      "income" = rep(.25, 4),
      "age" = c(0.102, 0.168, 0.244, 0.246, 0.241),
      "urban" = c(FALSE, TRUE),
      "UK_urban_category" = c(0.176, 0.423, 0.401),
      "UK_region" = c(0.1297,  0.3122,  0.2095,  0.2365,  0.1121),
      "college_OECD" = c(.49, .51),
      "employment" = c(.75, .25)
    ),
    "US" = list(
      "gender" = c(0.5075,0.000001,0.4925),
      "income" = c(0.2034,0.239,0.2439,0.3137),
      "age" = c(0.118,0.180,0.243,0.2467,0.2118),
      "US_core_metropolitan" = c(0.2676,0.7324),
      "urban" = c(0.2676,0.7324),
      "US_region" = c(0.171,0.208,0.383,0.239),
      "US_race" = c(.601, .185, .134, .080),
      "US_vote_2020" = c(0.342171, 0.312823, 0.345006),
      "college_OECD" = c(.609, .391),
      "employment" = c(.67, .33) #c(.61, .39)
    ),
    "US2023" = list(
      "gender" = c(0.509,0.000001,0.491),
      "income" = c(0.2044,0.2265,0.2385,0.3307),
      "age" = c(0.1198,0.1733,0.2441,0.2413,0.2216),
      "US_core_metropolitan" = c(0.2676,0.7324),
      "urban" = c(0.2676,0.7324),
      "US_region" = c(0.174,0.205,0.386,0.236),
      "US_race" = c(.6049, .1718, .1186, .1047),
      "US_vote_2020" = c(0.342171, 0.312823, 0.345006),
      "college_OECD" = c(.6228, .3772),
      "employment" = c(.713, .287) #c(.61, .39)
    ),
    "BR" = list(
      "gender" = c(0.512, 0.000001, 0.488),
      "income" = rep(.25, 4),
      "age" = c(0.149, 0.215, 0.296, 0.212, 0.128),
      "urban" = c(0.310, 0.690), 
      "BR_region" = c(0.088179878, 0.270945458, 0.42035347,  0.14258089,  0.077940304),
      "college_OECD" = c(.2, .8),
      "employment" = c(.57, .43)
    ),
    "CN" = list(
      "gender" = c(0.492, 0.000001, 0.508),
      "income" = rep(.25, 4),
      "age" = c(0.099, 0.204, 0.279, 0.265, 0.154),
      "urban" = c(FALSE, TRUE), 
      "CN_urban_category" = c(0.369993069, 0.352742656, 0.277264275),
      "CN_region" = c(0.123751183, 0.082229515, 0.28858566,  0.287981136, 0.217452506),
      "college_OECD" = c(.1, .9),
      "employment" = c(.75, .25)
    ),
    "IA" = list(
      "gender" = c(0.486, 0.000001, 0.514),
      "income" = rep(.25, 4),
      "age" = c(0.1835398, 0.24282507, 0.28895456, 0.18828387, 0.09639664),
      "urban" = c(0.639, 0.361),
      "IA_region" = c(0.1317, 0.2015, 0.2654, 0.2635, 0.1380),
      "college_OECD" = c(.12, .88),
      "employment" = c(.49, .51)
    ),
    "ID" = list(
      "gender" = c(0.500, 0.000001, 0.500),
      "income" = rep(.25, 4),
      "age" = c(0.170, 0.228, 0.310, 0.208, 0.084),
      "urban" = c(0.433, 0.567), 
      "ID_region" = c(0.269977941, 0.299427716, 0.133590934, 0.082251799, 0.21475161),
      "college_OECD" = c(.13, .87),
      "employment" = c(.66, .34)
    ),
    "SA" = list(
      "gender" = c(0.506, 0.000001, 0.494),
      "income" = rep(.25, 4),
      "age" = c(0.213, 0.285, 0.283, 0.161, 0.058),
      "urban" = c(0.511, 0.489), 
      "SA_region" = c(0.237050995, 0.13460536,  0.12083205,  0.182435864, 0.325075732),
      "college_OECD" = c(.16, .84),
      "employment" = c(.38, .62)
    ),
    "UA" = list(
      "gender" = c(0.549, 0.000001, 0.451),
      "income" = rep(.25, 4),
      "age" = c(0.082, 0.178, 0.282, 0.249, 0.209),
      "urban" = c(0.3046, 0.6954), 
      "UA_region" = c(0.311308744, 0.213095418, 0.224565659, 0.251030179),
      "college_OECD" = c(.473, .527),
      "employment" = c(.56, .44)
    )    
  )
}


##### Constants #####
qinc <- read.csv("../data/equivalised_income_deciles.tsv", sep = "\t")
euro_countries <- c("DK", "FR", "DE", "IT", "PL", "SP", "UK") # , "TR"
euro_countries_names <- c("Denmark", "France", "Germany", "Italy", "Poland", "Spain", "United Kingdom") 
year_countries <- c(2020, 2019, 2019, 2019, 2019, 2019, 2018) # , 2019
names(year_countries) <- euro_countries # /!\ inc_deciles in US are not deciles because we need to account for differentiated household size per income bracket
inc_deciles <- matrix(NA, nrow = 2, ncol = 9, dimnames = list(c("IT", "ES"), 1:9)) # equivalised disposable income deciles in LCU
for (i in 1:9) for (c in c("IT", "ES")) inc_deciles[c,i] <- as.numeric(gsub(" b", "", qinc[[paste0("X", 2019)]][qinc[[1]]==paste0("D", i, ",TC,NAC,", c)])) # euro_countries / year_countries[c]
countries <- c("AU", "CA", "DK", "FR", "DE", "IT", "JP", "MX", "PL", "SK", "SP", "TR", "UK", "US", "BR", "CN", "IA", "ID", "SA", "UA")  
countries3 <- c("AUS", "CAN", "DNK", "FRA", "DEU", "ITA", "JPN", "MEX", "POL", "KOR", "ESP", "TUR", "GBR", "USA", "BRA", "CHN", "IND", "IDN", "ZAF", "UKR")
countries_names <- c("Australia", "Canada", "Denmark", "France", "Germany", "Italy", "Japan", "Mexico", "Poland", "South Korea", "Spain", "Turkey", "United Kingdom", "United States", "Brazil", "China", "India", "Indonesia", "South Africa", "Ukraine") 
Country_names <- c("Australia", "Canada", "Denmark", "France", "Germany", "Italy", "Japan", "Mexico", "Poland", "South Korea", "Spain", "Turkey", "the U.K.", "the U.S.", "Brazil", "China", "India", "Indonesia", "South Africa", "Ukraine")
Country_Names <- c("Australia", "Canada", "Denmark", "France", "Germany", "Italy", "Japan", "Mexico", "Poland", "South Korea", "Spain", "Turkey", "U.K.", "U.S.", "Brazil", "China", "India", "Indonesia", "South Africa", "Ukraine")
country_names <- c("Australian", "Canadian", "Danish", "French", "German", "Italian", "Japanese", "Mexican", "Polish", "South Korean", "Spanish", "Turkish", "British", "American", "Brazilian", "Chinese", "Indian", "Indonesian", "South African", "Ukrainian")
vulnerability <- c(.306, .292, .34, .29, .284, .314, .361, .404, .317, .366, .287, .348, .287, .321, .381, .388, .503, .446, .406, .368) # Notre Dame https://gain.nd.edu/our-work/country-index/rankings/ 
GDPpcPPP <- c(55492.205, 53089.455, 63404.856, 50876.226, 58150.203, 45267.352, 44934.938, 20820.363, 37322.871, 48308.905, 42074.498, 33963.104, 48693.183, 69375.375, 16168.703, 19090.228, 7314.129, 12967.303, 14239.405, 14145.874) # IMF Oct 2021
pop_home_ownership <- c(66.3, 66.5, 59.2, 64.7, 49.1, 73.7, 55, 80, 86.8, 57.3, 76, 57.5, 63, 65.9, 72.5, 89.7, 86.6, 84, 69.7, 93)/100 
poor_countries <- c("IA", "ID", "SA", "UA") 
rich_countries <- c("AU", "CA", "DK", "FR", "DE", "IT", "JP", "PL", "SK", "SP", "UK", "US") # countries for which net_zero_feasible was asked using "maintaining" instead of "sustaining" satisfactory standards of living
tropical_countries <- c("MX", "BR", "IA", "ID") # countries for which the questions on heating and insulation were not asked. (For AU: the questions were asked with cooling instead of heating)."
tax_price_increase <- c("AU$0.15/L", "CA$0.14/L", "2 kr./L", "0.10 €/L", "0.10 €/L", "0.10 €/L", "¥12/L", "Mex$2.2/L", "0.40 zł/L", "₩125/L", "0.10 €/L", "₺1/L", "£0.08/L", "$0.40/gallon", "0.60 R$/L", "¥0.7/L", "Rs 8/L", "Rp 1600/L", "R 1.60/L", "3₴/L")
prices <- list()
prices[["gas"]] <- c(0.074, 0.027, 0.106, 0.07, 0.066, 0.097, NA, 0.035, NA, NA, 0.077, 0.017, 0.054, NA, NA, NA, NA, NA, NA, 0.019) # $/kWh
prices[["gasoline"]] <- c(1.094, 1.247, 2.006, 1.857, 1.804, 1.942, 1.389, 1.114, 1.449, 1.446, 1.651, 0.933, 1.836, 3.479, 1.118, 1.148, 1.368, 0.735, 1.196, 1.118) # $/L (except US, $/gallon)
prices[["electricity"]] <- c(0.227, 0.111, 0.339, 0.216, 0.368, 0.264, 0.258, 0.083, 0.197, 0.111, 0.233, 0.082, 0.261, 0.148, 0.137, 0.085, 0.077, 0.1, 0.153, 0.048) # $/kWh
prices[["oil"]] <- c(NA, 0.972, 1.754, 1.053, 0.903, 1.533, NA, NA, 0.946, NA, 0.868, 0.755, 0.81, NA, NA, NA, NA, NA, NA, NA) # $/L
prices[["coal"]] <- c(NA, NA, NA, NA, NA, NA, NA, NA, 61.82262211, NA, NA, NA, NA, NA, NA, 82.43451464, NA, NA, 72.2007722, NA) # $/t
prices[["elec_factor"]] <- c(0.79, 0.13, 0.15444, 0.03895, 0.37862, 0.33854, 0.506, 0.449, 0.79107, 0.5, 0.22026, 0.481, 0.23314, 0.45322, 0.074, 0.555, 0.708, 0.761, 0.928, 0.807) # kgCO2/kWh
for (v in c("gas", "gasoline", "electricity", "oil", "coal", "elec_factor")) {
  prices[[v]] <- replace_na(prices[[v]], mean(prices[[v]], na.rm = T))
  names(prices[[v]]) <- countries }
bus_countries <- c("AU", "CA", "MX", "TR", "US", "BR", "SA") # countries where bus/coach appear in the transport footprint question rather than train (either because train routes are lacking, or because trains are not low-carbon)
adult_pop <- c(19.6, 30.3, 4.5, 50.4, 68.5, 49.7, 108, 92.8, 31.4, 43.2, 38.2, 59.8, 51.6, 246, 160, 1130, 860, 173, 36.0, 35.4)
population <- c(26, 38, 6, 65, 84, 60, 127, 129, 38, 51, 47, 84, 68, 331, 213, 1439, 1380, 274, 59, 44) # World: 4560/7800, Asia: 3350/4600, Europe: 412/750 (UE: 300/448, euro: 256/342), Africa: 59/1300, North America: 498/580, South America: 213/420 (Northern America: 369/369, Latin America: 306/631), Oceania: 26/42 (OECD: 1154/1371). 
# Under-sampled: Africa, ex-URSS, Middle East. Slightly over-sampled: North America. Slightly under-sampled: South America. Not worth it to correct the small under/over-sampling (by increasing weights of BR, MX and reducing weight of US, CA) as the total weights would be changed by only 5%. The big problem is the lack of coverage of Africa, Russia, Middle East.
oecd <- c(rep(T, 14), rep(FALSE, 6))
high_income <- c(rep(T, 7), F, rep(T, 3), F, T, T, rep(F, 6))
max_donation_country <- c(100, 100, 600, 100, 100, 100, 10^4, 1000, 500, 10^5, 100, 1000, 100, 100, 500, 1000, 10^4, 10^6, 1000, 1000)
duration_climate_video <- 120 + c(20, 20, 24, 18, 30, 20, 32, 7, 8, 10, 30, 7, 29, 61, 25, 17, 25, 40, 12, 31) 
duration_policy_video <- 240 + c(6, 22, 38, 33, 73, 74, 66, 44, 63, 67, 94, 35, 59, 44, 42, 36, 38, 16, 10, 69) 
max_duration <- 686/60
names(countries3) <- names(oecd) <- names(vulnerability) <- names(GDPpcPPP) <- names(pop_home_ownership) <- names(high_income) <- names(population) <- names(adult_pop) <- names(tax_price_increase) <- names(countries_names) <- names(country_names) <- names(Country_names) <- names(Country_Names) <- names(max_donation_country) <- names(duration_climate_video) <- names(duration_policy_video) <- countries
levels <- countries_names
countries_names_hm <- countries_names[c(1:7,9:11,13:18,8,19,12,20)]
heatmap_countries <- c("var", "HI", countries[high_income], "MI", sort(countries[!high_income]))
parties_leaning <- list()
loadings_efa <- list()
thresholds_expenses <- list()
tr <- de <- sp <- id <- tr <- all <- df <- NULL # To re-assign the variable named locked by package 'stats' and prevent a bug when running the code.


##### Functions #####
remove_id <- function(file, folder = "../data/") {
  # Anonymize the data by removing respondent ID from the raw samples.
  filename <- paste(folder, file, ".csv", sep = "")
  
  filename_copy <- paste("./deprecated/", file, sample.int(10^5, 1), ".csv", sep = "") # in case the three last lines don't work
  file.copy(filename, filename_copy)
  data <- read_csv(filename_copy)
  data <- data[,which(!(names(data) %in% c("PSID", "ResponseId", "PID", "tic")))]
  write_csv(data, filename, na = "")
  file.remove(filename_copy)
} 

relabel_and_rename <- function(e, country, wave = NULL) {
  # Calls country-specific variable names (and labels) defined in relabel_rename.R
  
  # Notation: ~ means that it's a random variant / * that the question is only displayed under certain condition
  
  if (missing(wave) | wave == "full") {
    e <- match.fun(paste0("relabel_and_rename_", country))(e)
    e <- e[,-c((which(names(e) %in% c("clicked_petition", "positive_treatment"))+1):length(names(e)))]
  }  else e <- match.fun(paste0("relabel_and_rename_", country, wave))(e)
  
  for (i in 1:length(e)) {
    label(e[[i]]) <- paste(names(e)[i], ": ", label(e[[i]]), e[[i]][1], sep="")
    # print(paste(i, label(e[[i]])))
  }
  e <- e[-c(1:2),]
  
  return(e)
}

create_education <- function(e, country, only = TRUE) {
  # Minimal version of 'convert', used to prepare the entire dataset, where using 'convert' would result in bugs because of incomplete data.
  
  text_education_no <- c("US" = "No schooling completed", 
                         "FR" = "Aucun")
  text_education_primary <- c("US" = "Primary school", 
                              "FR" = "École primaire")
  text_education_secondary <- c("US" = "Lower secondary school", 
                                "FR" = "Brevet")
  text_education_vocational <- c("US" = "Vocational degree", 
                                 "FR" = "CAP ou BEP")
  text_education_high <- c("US" = "High school", 
                           "FR" = "Baccalauréat")
  text_education_college <- c("US" = "College degree", 
                              "FR" = "Bac +2 ou Bac +3 (licence, BTS, DUT, DEUG...)")
  text_education_master <- c("US" = "Master's degree or above", 
                             "FR" = "Bac +5 ou plus (master, école d'ingénieur ou de commerce, doctorat, médecine, maîtrise, DEA, DESS...)")
  
  text_college_border <- c("US" = "2-year college degree or associates degree (for example: AA, AS)", "US" = "Some college, no degree", "AU" = "Certificate IV", "UK" = "Higher vocational education (Level 4+ award, level 4+ certificate, level 4+ diploma, higher apprenticeship, etc.)", "CA" = "Apprenticeship program of 3 or 4 years", 
                           "IT" = "Higher Technical Diploma (ITS) / Higher Technical Specialization Certificate (IFTS)", "JP" = "Short-term college", "JP" = "Technical short-term college", "SK" = "College dropout", "SP" = "Medium professional training", "TR" = "High school graduate or Vocational or Technical High School graduate",
                           "CN" = "Secondary school education pre university type", "SA" = "N6 NATED part-qualification or National N Diploma")
  text_college_strict <- c("US" = "Bachelor's degree (for example: BA, BS)", "US" = "Master’s degree (for example: MA, MS, MEng, MEd, MSW, MBA)", "US" = "Professional degree beyond bachelor’s degree (for example: MD, DDS, DVM, LLB, JD)", "US" = "Doctorate degree (for example, PhD, EdD)",
                           "AU" = "Advanced Diploma, Diploma, Associate Degree", "AU" = "Bachelor's Degree", "AU" = "Graduate Diploma, Graduate Certificate", "AU" = "Postgraduate Degree (Honours, Master's or Doctoral Degree)",
                           "UK" = "Bachelor's Degree (BA, BSc, BEng, etc.)", "UK" = "Postgraduate diploma or certificate", "UK" = "Master's Degree (MSc, MA, MBA, etc.) or Ph.D.", "CA" = "Master's degree or Doctorate", "CA" = "Bachelor's degree (3 or 4 years)", "CA" = "Postsecondary general career, technical or professional program (Technical diploma)",
                           "IT" = "Bachelor", "IT" = "Master's degree or higher", "JP" = "Professional Graduate School", "JP" = "College", "JP" = "Master", "JP" = "Doctorate", 
                           "MX" = "Master's or Specialty or Doctorate", "MX" = "University degree", "MX" = "Higher professional training (Bachelor's Degree, Higher University Technician)", "SK" = "University graduation", "SK" = "Drop out of graduate school", "SK" = "Graduate school",
                           "SP" = "Higher professional training", "SP" = "University degree", "SP" = "Master or PhD", "TR" = "Associate's degree", "TR" = "Licence", "TR" = "Master's degree or higher", "CN" = "Incomplete university education", "CN" = "University education",
                           "SA" = "Bachelor's Degree", "SA" = "Diploma, Advanced Diploma (AD), Higher Certificate or Advanced Certificate (AC)", "SA" = "Bachelor's Honours or Postgraduate Diploma (PGD)", "SA" = "Master's Degree or Doctorate") 
  
  if ("education" %in% names(e)) {
    e$education_original <- e$education
    temp <-  (e$education %in% text_education_primary) + 2 * (e$education %in% text_education_secondary) + 3 * (e$education %in% text_education_vocational) + 4 * (e$education %in% text_education_high) + 5 * (e$education %in% text_education_college) + 6 * (e$education %in% text_education_master) - 0.1*is.pnr(e$education)
    if (country == "DK") {
      temp[temp == 4] <- 5
      temp[temp == 2] <- 4
    }
    e$education <- as.item(temp, missing.values = -0.1, labels = structure(c(-0.1, 0:6), names = c(NA, "None", "Primary", "Lower secondary", "Vocational", "High school", "College degree", "Master degree")),
                           annotation=Label(e$education))
    
    temp <- case_when(e$education < 3 ~ 0, e$education == 3 ~ 1,  e$education == 4 ~ 2, e$education > 4 ~ 3) 
    e$diploma <- as.item(temp, labels = structure(c(0:3), names = c("No secondary", "Vocational", "High school", "College")), annotation="diploma: recoded from education - What is the highest level of education you have completed?")
    
    e$college <- NA
    e$college[e$education < 5 & e$education >= 0] <- "No college"
    e$college[e$education >= 5] <- "College Degree"
    e$college <- factor(e$college, levels = c("No college", "College Degree"))
    e$high_school <- e$education >= 3
    e$high_school[e$education < 0] <- NA
    e$educ_categ <- case_when(e$education %between% list(5,6) ~ "College degree", e$education %between% list(3,4) ~ "High-school non-College", e$education %between% list(0,2) ~ "Below high-school", TRUE ~ as.character(NA))
    
    # College we use for statistics
    e$college_OECD <- NA
    if (country %in% c("AU", "CA", "DK", "FR", "DE", "PL", "SK", "SP", "TR", "BR", "CN", "IA", "ID", "SA", "JP", "UK")){
      e$college_OECD[e$education >= 5 & grepl("25|35|50", e$age)] <- "College Degree"
      e$college_OECD[e$education < 5 & e$education >= 0 & grepl("25|35|50", e$age)] <- "No college"
    } else if (country %in% c("IT", "MX")){
      e$college_OECD[(e$education >= 5 | e$education == 3) & grepl("25|35|50", e$age)] <- "College Degree"
      e$college_OECD[e$education < 5 & e$education >= 0 & e$education != 3 & grepl("25|35|50", e$age)] <- "No college"
    } else if (country %in% c("US", "UA")){
      e$college_OECD[e$education >= 5 ] <- "College Degree"
      e$college_OECD[e$education < 5 & e$education >= 0] <- "No college"
    }  
    
    e$college_OECD <- factor(e$college_OECD, levels = c("No college", "College Degree"))
    label(e$college_OECD) <- "college_OECD: T/F/NA indicator that the respondent has a College Degree and is (for most countries) 25-64 (NA if s/he is not in the country's age category for which national College statistics are produced). Variable used to assess the representativity."
  }
  if ("education_good" %in% names(e)) { 
    if ("education_good" %in% names(e)) {
      e$college_border <- e$education_good %in% text_college_border
      e$college_strict <- e$education_good %in% text_college_strict
      e$college_broad <- e$college_strict | e$college_border }
    if ("college_border" %in% names(e)) e$college_border[is.na(e$education_good)] <- e$college_strict[is.na(e$education_good)] <- e$college_border[is.na(e$education_good)] <- NA
    if ("college_border" %in% names(e)) label(e$college_border) <- "college_border: T/F Indicator that the respondent has some college education (in the broad sense) but no college degree (in the strict sense); i.e. college_strict == F & college_broad == T."
    if ("college_strict" %in% names(e)) label(e$college_strict) <- "college_strict: T/F Indicator that the respondent has a college degree (in the strict sense)."
    if ("college_broad" %in% names(e)) label(e$college_broad) <- "college_broad: T/F Indicator that the respondent has some college education (in the broad sense)."
    # For the complementary wave:
    if (!("education" %in% names(e))) {
      e$educ_categ <- case_when(e$education_good %in% c("Master's Degree", "4-year College Degree", "Doctoral Degree", "2-year College Degree", "Professional Degree (JD, MD, MBA)", "Some College") ~ "College degree", e$education_good %in% c("High School degree/GED") ~ "High-school non-College", e$education_good %in% c("Primary education or less", "Some High School") ~ "Below high-school", TRUE ~ as.character(NA))  
      e$college_OECD <- "No college"
      e$college_OECD[e$educ_categ == "College degree"] <- "College Degree"
      e$college_OECD <- factor(e$college_OECD, levels = c("No college", "College Degree"))
    } 
  }
  
  ##### other than education #####
  text_sector_no <- c("US" = "No, none of the above")
  
  text__18 <- c("US" = "18 to 24", "FR" = "Moins de 18 ans")
  text_18_24 <- c("US" = "18 to 24", "FR" = "Entre 18 et 24 ans")
  text_25_34 <- c("US" = "25 to 34", "FR" = "Entre 25 et 34 ans")
  text_35_49 <- c("US" = "35 to 49", "FR" = "Entre 35 et 49 ans")
  text_50_64 <- c("US" = "50 to 64", "FR" = "Entre 50 et 64 ans")
  text_65_ <- c("US" = "65 or above", "FR" = "65 ans ou plus")
  
  text_rural <- c("US" = "A rural area", "CN" = "A rural area (less than 10,000 inhabitants)",
                  "FR" = "en zone rurale")
  text_small_town <- c("US" = "A small town (between 5,000 and 20,000 inhabitants)", "US" = "A small town (5,000 – 20,000 inhabitants)", "US" = "A small town (5,000 - 20,000 inhabitants)",
                       "FR" = "dans une petite ville (entre 5 000 et 20 000 habitants)", "CN" = "A small town (10,000 – 50,000 inhabitants)")
  text_large_town <- c("US" = "A large town (between 20,000 and 50,000 inhabitants)", "US" = "A large town (20,000 – 50,000 inhabitants)", "US" = "A large town (20,000 - 50,000 inhabitants)",
                       "FR" = "dans une ville moyenne (entre 20 000 et 50 000 habitants)", "CN" = "A large town (50,000 – 100,000 inhabitants)")
  text_small_city <- c("US" = "A small city (between 50,000 and 250,000 inhabitants)", "US" = "A small city (50,000 – 250,000 inhabitants)", "CA" = "A small city or its suburbs (50,000 – 250,000 inhabitants)",
                       "FR" = "dans une grande ville (entre 50 000 et 250 000 habitants)", "CN" = "A small city or its suburbs (100,000 – 500,000 inhabitants)", "IA" = "A small city or its suburbs (50,000 – 2,50,000 inhabitants)", "US" = "A small city or its suburbs (50,000 - 250,000 inhabitants)")
  text_medium_city <- c("US" = " A medium-size city (between 250,000 and 3,000,000 inhabitants)", "US" = "A medium-sized city (250,000 – 3,000,000 inhabitants)", "PL" = "A large city (250,000 – 3,000,000 inhabitants)", "CA" = "A large city or its suburbs (250,000 – 2,000,000 inhabitants)",
                        "FR" = "dans une métropole (plus de 250 000 habitants, hors Paris)", "CN" = "A large city or its suburbs (500,000 – 1,000,000 inhabitants)", "SA" = "A large city or its suburbs (250,000 – 3,000,000 inhabitants)", "IA" = "A large city or its suburbs (2,50,000 – 30,00,000 inhabitants)", "US" = "A large city or its suburbs (250,000 to 3,000,000 inhabitants)")
  text_large_city <- c("US" = "A large city (more than 3 million inhabitants)", "PL" = "A very large city (more than 3 million inhabitants)", "SA" = "A very large city or its suburbs (more than 3 million inhabitants)", "IA" = "A very large city or its suburbs (more than 30 lakh inhabitants)", 
                       "FR" = "en région parisienne", "CN" = "A very large city or its suburbs (1,000,000 – 10,000,000 inhabitants)", "CA" = "A very large city or its suburbs (more than 2 million inhabitants)")
  text_megalopolis <- c("CN" = "A megalopolis or its suburbs (more than 10 million inhabitants)")
  
  text_transport_available_yes_easily <- c("US" = "Yes, public transport is easily and frequently available")
  text_transport_available_yes_limited <- c("US" = "Yes, public transport is available but with limitations")
  text_transport_available_not_so_much <- c("US" = "Not so much, public transport is available but with many limitations")
  text_transport_available_not_at_all <- c("US" = "No, there is no public transport")
  
  text_heating_expenses_10 <- c("US" = "Less than $20", "FR" = "Moins de 15€", "DK" = "Mindre end 125 kr.")
  text_heating_expenses_50 <- c("US" = "$20 – $75", "FR" = "De 15 à 60€", "DK" = "125 - 465 kr.")
  text_heating_expenses_100 <- c("US" = "$76 – $125", "FR" = "De 61 à 100€", "DK" = "466 - 775 kr.")
  text_heating_expenses_167 <- c("US" = "$126 – $200", "FR" = "De 101 à 165€", "DK" = "776 - 1.240 kr.")
  text_heating_expenses_225 <- c("US" = "$201 – $250", "FR" = "De 166 à 210€", "DK" = "1.241 - 1.550 kr.")
  text_heating_expenses_275 <- c("US" = "$251 – $300", "FR" = "De 211 à 350€", "DK" = "1.551 - 1.860 kr.") # we regroup the 225, 275 and 350 categories for 300
  text_heating_expenses_350 <- c("US" = "More than $300", "FR" = "Plus de 350€", "DK" = "Mere end 1.860 kr.")
  
  text_gas_expenses_0 <- c("US" = "Less than $5", "FR" = "Moins de 5€", "DK" = "Mindre end 30 kr.")
  text_gas_expenses_15 <- c("US" = "$5 – $25", "FR" = "De 5 à 20€", "DK" = "31 - 155 kr.")
  text_gas_expenses_50 <- c("US" = "$26 – $75", "FR" = "De 15 à 60€", "DK" = "156 - 460 kr.")
  text_gas_expenses_100 <- c("US" = "$76 – $125", "FR" = "De 61 à 100€", "DK" = "461 - 770 kr.")
  text_gas_expenses_150 <- c("US" = "$126 – $175", "FR" = "De 101 à 145€", "DK" = "771 - 1.100 kr.") # we regroup the 150 and 201 categories for 200
  text_gas_expenses_201 <- c("US" = "$176 – $225", "FR" = "De 146 à 185€", "DK" = "1.101 - 1.400 kr.")
  text_gas_expenses_220 <- c("US" = "More than $225", "FR" = "Plus de 185€", "DK" = "Mere end 1.400 kr.")
  # English-speaking countries surveyed with EN: CA (use CA), SA (use SA), US (use the above) / EN-GB: AU (use AU), UK (use EN)
  # These two last sets have 6 and 4 bins: they correspond to the other countries (except BR, IA, ID, MX for which the question was not asked)
  text_heating_expenses_125 <- c("EN" = "Less than $20", "US" = "Less than $20", "EU" = "Less than €250", "DK" = "Mindre end 125 kr.", "DE" = "Unter €250", "AU" = "Less than $200", "CN" = "人民币800元以下",
                                 "UA" = "Менше 2,000₴", "UK" = "Less than £200", "TR" = "2000₺'den az", "SP" = "Menos de 200 €", "SK" = "200,000원 미만", "SA" = "Less than R2,000", "ZU" = "Ngaphansi kuka- R2,000", "CA" = "Less than $200", "FR" = "Moins de 15€", "IT" = "Meno di 200€", "JP" = "20,000円未満", "PL" = "Mniej niż 1.000 zł")
  text_heating_expenses_600 <- c("EN" = "$20 – $75", "US" = "$20 – $75", "EU" = "€251 – €1,000", "DK" = "125 - 465 kr.", "DE" = "€251 – €1000", "AU" = "$201 – $800",  "CN" = "人民币800至3,000元",
                                 "UA" = "2,000₴ – 8,000₴", "UK" = "£201 – £800", "TR" = "2,000 - 8,000 ₺ arası", "SP" = "200 € - 800 €", "SK" = "200,000 – 800,000원", "SA" = "R2,000 - R8,000", "CA" = "$200 – $800", "FR" = "De 15 à 60€", "IT" = "201€ - 800€", "JP" = "20,001円 – 80,000円", "PL" = "1.001 – 3.000 zł")
  text_heating_expenses_1250 <- c("EN" = "$76 – $125", "US" = "$76 – $125", "EU" = "€1,001 – €1,500", "DK" = "466 - 775 kr.", "DE" = "€1001 – €1.500", "AU" = "$801 – $1,300",  "CN" = "人民币3,000至5,000元",
                                  "UA" = "8,000₴ – 13,000₴", "UK" = "£801 – £1,300", "TR" = "8,000 ₺ - 13,000 ₺ arası", "SP" = "800 € - 1300 €", "SK" = "800,000 – 1,300,000원", "SA" = "R8,000 - R13,000", "CA" = "$800 – $1,300", "FR" = "De 61 à 100€", "IT" = "8001€ - 1300€", "JP" = "80,001 – 130,000円", "PL" = "3.001 – 5.000 zł")
  text_heating_expenses_2000 <- c("EN" = "$126 – $200", "US" = "$126 – $200", "EU" = "€1,1501 - €2,500", "DK" = "776 - 1.240 kr.", "DE" = "€1.501 – €2.500", "AU" = "$1,301 – $2,000",  "CN" = "人民币5,000至8,000元",
                                  "UA" = "13,000₴ –20,000₴", "UK" = "£1,301 – £2,000", "TR" = "13,000 ₺ - 20,000 ₺ arası", "SP" = "1300 € - 2000 €", "SK" = "1,300,000 – 2,000,000원", "SA" = "R13,000 - R20,000", "CA" = "$1,300 – $2,000", "FR" = "De 101 à 165€", "IT" = "1301€ - 2000€", "JP" = "130,001円 – 200,000円", "PL" = "5.001 – 8.000 zł")
  text_heating_expenses_3000 <- c("EN" = "More than $300", "US" = "More than $200", "EU" = "More than €2,500", "DK" = "Mere end 1.241 kr.", "DE" = "Über €2.500", "AU" = "More than $2,000",  "CN" = "人民币8,000元以上",
                                  "UA" = "Понад 20,000₴", "UK" = "More than £2,000", "TR" = "20,000 ₺'den çok", "SP" = "Más de 2000 €", "SK" = "2,000,000원 이상", "SA" = "More than R20,000", "ZU" = "Ngaphezu kuka R20,000", "CA" = "More than $2,000", "FR" = "Plus de 166€", "IT" = "Più di 2000€", "JP" = "200,000円以上", "PL" = "Ponad 8.000 zł")
  
  text_gas_expenses_0 <- c("EN" = "Less than $5", "US" = "Less than $5", "EU" = "Less than €5", "DK" = "Mindre end 30 kr.", "DE" = "Unter €5", "AU" = "Less than $5",  "CN" = "人民币20元以下", "ID" = "Kurang dari Rp 50.000,00",
                           "UA" = "Менше 50₴", "UK" = "Less than £5", "TR" = "50 ₺'den az", "SP" = "Menos de 5 €", "SK" = "5,000원 미만", "SA" = "Less than R50", "ZU" = "Ngaphansi kuka- R50", "PL" = "Mniej niż 20 zł", "BR" = "Menos de R$20,00", "CA" = "Less than $5", "FR" = "Moins de 5€", "IT" = "Meno di 5 €", "JP" = "500円未満", "MX" = "Menos de 50 pesos")
  text_gas_expenses_20 <- c("EN" = "$5 – $25", "US" = "$5 – $25", "EU" = "€5 - €30", "DK" = "31 - 155 kr.", "DE" = "€5 - €30", "AU" = "$5 – $25",  "CN" = "人民币20至100元", "ID" = "Rp 50.001,00 - Rp 250.000,00",
                            "UA" = "50₴ – 250₴", "UK" = "£5 – £25", "TR" = "50 ₺ - 250 ₺ arası", "SP" = "5 € - 25 €", "SK" = "5,000 – 25,000원", "SA" = "R50 - R250", "PL" = "20 – 100 zł", "BR" = "R$20,00- R$100,00", "CA" = "$5 – $25", "FR" = "De 5 à 20€", "IT" = "5 €- 25 €", "JP" = "500円 – 2,500円", "MX" = "50 - 250 pesos")
  text_gas_expenses_60 <- c("EN" = "$26 – $75", "US" = "$26 – $75", "EU" = "€31 - €90", "DK" = "156 - 460 kr.", "DE" = "€31 - €90", "AU" = "$26 – $75",  "CN" = "人民币100至300元", "ID" = "Rp 250.001,00 - Rp 750.000,00",
                            "UA" = "250₴ – 750₴", "UK" = "£26 – £75", "TR" = "250 ₺ - 750 ₺ arası", "SP" = "26 € - 75 €", "SK" = "25,000 – 75,000원", "SA" = "R250 - R750", "PL" = "101 – 300 zł", "BR" = "R$100,00 - R$300,00", "CA" = "$26 – $75", "FR" = "De 15 à 60€", "IT" = "26 €- 75 €", "JP" = "2,501円 – 7,500円", "MX" = "250 -750 pesos")
  text_gas_expenses_120 <- c("EN" = "$76 – $125", "US" = "$76 – $125", "EU" = "€91 - €150", "DK" = "461 - 770 kr.", "DE" = "€91 - €150", "AU" = "$76 – $125",  "CN" = "人民币300至500元", "ID" = "Rp 750.001,00 - Rp 1.300.000,00",
                             "UA" = "750₴ – 1250₴", "UK" = "£76 – £125", "TR" = "750 ₺ - 1,250 ₺ arası", "SP" = "76 € - 125 €", "SK" = "75,000 – 125,000원", "SA" = "R750 - R1,250", "PL" = "301 – 500 zł", "BR" = "R$300,00 - R$500,00", "CA" = "$76 – $125", "FR" = "De 61 à 100€", "IT" = "76 €- 125 €", "JP" = "7,501円 – 13,000円", "MX" = "750 - 1250 pesos")
  text_gas_expenses_200 <- c("EN" = "$126 – $175", "US" = "$126 – $225", "EU" = "€151 - €250", "DK" = "771 - 1.400 kr.", "DE" = "€151 - €250", "AU" = "$126 – $200",  "CN" = "人民币500至800元", "ID" = "Rp 1.300.001,00 - Rp 2.000.000,00",
                             "UA" = "1250₴ – 2000₴", "UK" = "£126 – £200", "TR" = "1,250 ₺ - 2,000 ₺ arası", "SP" = "126 € - 200 €", "SK" = "125,000 – 200,000원", "SA" = "R1,250 - R2,000", "PL" = "501 – 800 zł", "BR" = "R$500,00 - R$800,00", "CA" = "$126 – $200", "FR" = "De 101 à 185€", "IT" = "126 €- 200 €", "JP" = "13,001円 – 20,000円", "MX" = "1250 - 2000 pesos")
  text_gas_expenses_300 <- c("EN" = "More than $225", "US" = "More than $225", "EU" = "More than €250", "DK" = "Mere end 1.400 kr.", "DE" = "Über €250", "AU" = "More than $200",  "CN" = "人民币800元以上", "ID" = "Lebih dari Rp 2.000.000,00",
                             "UA" = "Понад 2000₴", "UK" = "More than £200", "TR" = "2,000 ₺'den fazla", "SP" = "Más de 200 €", "SK" = "200,000원 이상", "SA" = "More than R2,000", "ZU" = "Ngaphezulu kuka R2,000", "PL" = "Więcej niż 800 złotych", "BR" = "Mais de R$800,00", "CA" = "More than $200", "FR" = "Plus de 185€", "IT" = "Più di 200 €", "JP" = "20,000円以上", "MX" = "Más de 2000 pesos")
  
  
  text_income_q1 <<- c("US" = "less than $35,000", "FR" = "Moins de 35,000€/mois", "AU" = "less than $51,000", "less than $10,000", "between $10,000 and $20,000", "between $20,000 and $25,000", "15", "22", "SA" = "between R10,000 and R20,000 per month", "SA" = "between R20,000 and R25,000 per month", "SA" = "less than R10,000 per month", 
                       "US" = "less than $16,000", "US" = "between $16,000 and $28,000", "US" = "between $28,000 and $35,000", "CA" = "less than CA$10,000", "CA" = "between CA$10,000 and CA$20,000", "CA" = "between CA$20,000 and CA$25,000", "US" = "$25,000 - $34,999", "US" = "$15,000 - $24,999", "US" = "$0 - $14,999",
                       "CA" = "less than CA$22,000", "IA" = "less than ₹50,000", "SA" = "less than R35,000 per month", "UK" = "less than £35,000", "IA" = "between ₹10,000 and ₹20,000", "IA" = "between ₹20,000 and ₹25,000", "IA" = "less than ₹10,000", "ID" = "5", "ID" = "11", "ID" = "12")
  text_income_q2 <<- c("US" = "between $35,000 and $70,000", "FR" = "Entre 35,000 et 70,000€/mois", "AU" = "between $51,000 and $80,000", "between $25,000 and $30,000", "between $30,000 and $40,000", "between $40,000 and $50,000", "35", "45", "SA" = "between R25,000 and R30,000 per month", "SA" = "between R30,000 and R40,000 per month", "SA" = "between R40,000 and R50,000 per month", 
                       "US" = "between $35,000 and $41,000", "US" = "between $41,000 and $54,000", "US" = "between $54,000 and $70,000", "CA" = "between CA$25,000 and CA$30,000", "CA" = "between CA$30,000 and CA$40,000", "CA" = "between CA$40,000 and CA$50,000",  "US" = "$60,000 - $69,999", "US" = "$50,000 - $59,999", "US" = "$35,000 - $49,999",
                       "CA" = "between CA$22,000 and CA$39,000", "IA" = "between ₹50,000 and ₹100,000", "SA" = "between R35,000 and R70,000 per month", "IA" = "between ₹25,000 and ₹30,000", "IA" = "between ₹30,000 and ₹40,000", "IA" = "between ₹40,000 and ₹50,000", "ID" = "6", "ID" = "13", "ID" = "14")
  text_income_q3 <<- c("US" = "between $70,000 and $120,000", "FR" = "Entre 70,000 et 120,000€/mois", "AU" = "between $80,000 and $122,000", "between $50,000 and $60,000", "between $60,000 and $70,000", "between $70,000 and $75,000", "65", "72", "SA" = "between R50,000 and R60,000 per month", "SA" = "between R60,000 and R70,000 per month", "SA" = "between R70,000 and R75,000 per month", 
                       "US" = "between $70,000 and $87,000", "US" = "between $87,000 and $110,000", "US" = "between $110,000 and $120,000", "CA" = "between CA$50,000 and CA$60,000", "CA" = "between CA$60,000 and CA$70,000", "CA" = "between CA$70,000 and CA$75,000",  "US" = "$100,000 - $119,999", "US" = "$80,000 - $99,999", "US" = "$70,000 - $79,999",
                       "CA" = "between CA$39,000 and CA$74,000", "IA" = "between ₹100,000 and ₹200,000", "SA" = "between R70,000 and R120,000 per month", "IA" = "between ₹50,000 and ₹60,000", "IA" = "between ₹60,000 and ₹70,000", "IA" = "between ₹70,000 and ₹75,000", "IA" = "between ₹60,000 and ₹<span class=d7\">70,000", "ID" = "8", "ID" = "15", "ID" = "16")
  text_income_q4 <<- c("US" = "more than $120,000", "FR" = "Plus de 120,000€/mois", "AU" = "more than $122,000", "between $75,000 and $80,000", "between $80,000 and $90,000", "more than $90,000", "85", "95",  "US" = "more than $200,000", "US" = "$150,000 - $199,999", "US" = "$120,000 - $149,999",# TODO! check income missing
                       "US" = "between $120,000 and $143,000", "US" = "between $143,000 and $200,000", "US" = "more than $200,000", "CA" = "between CA$75,000 and CA$80,000", "CA" = "between CA$80,000 and CA$90,000", "CA" = "more than CA$90,000", "SA" = "more than R90,000 per month", "SA" = "between R75,000 and R80,000 per month", "SA" = "between R80,000 and R90,000 per month", 
                       "CA" = "more than CA$74,000", "IA" = "more than ₹200,000", "SA" = "more than R120,000 per month", "IA" = "between ₹75,000 and ₹80,000", "IA" = "between ₹80,000 and ₹90,000", "IA" = "more than ₹90,000", "ID" = "9", "ID" = "17", "ID" = "18")
  
  text_excellent <- c("US" = "Excellent")
  text_good <- c("US" = "Good")
  text_fair <- c("US" = "Fair")
  text_poor <- c("US" = "Poor")
  text_very_poor <- c("US" = "Very poor")
  
  text_male <- c("US" = "Male", "FR" = "Homme")
  text_female <- c("US" = "Female", "FR" = "Femme")
  text_other <- c("US" = "Other", "FR" = "Autre")
  
  text_pnr <- c("US" = "I don't know", "US" = "Prefer not to say",  "US" = "Don't know, or prefer not to say",  "US" = "Don't know",  "US" = "Don't know or prefer not to say", "US" = "I don't know",
                "US" = "Don't know, prefer not to say",  "US" = "Don't know, or prefer not to say.",  "US" = "Don't know,  or prefer not to say", "US" = "I am not in charge of paying for heating; utilities are included in my rent", "PNR",
                "FR" = "Je ne sais pas", "FR" = "Ne sais pas, ne souhaite pas répondre", "FR" = "NSP (Ne sais pas, ne se prononce pas)", "FR" = "NSP (Ne sait pas, ne se prononce pas)", "FR" = "Préfère ne pas le dire",
                "UK" = "I don't know", "CN" = "我不知道", "DE" = "Ich weiß es nicht", "CA" = "I don't know", "AU" = "I don't know", "SA" = "I don't know", "DK" = "Jeg ved det ikke", "IT" = "Non lo so", "UA" = "Не знаю", "TR" = "Bilmiyorum", "SP" = "No lo sé", "MX" = "No lo sé", "JP" = "わからない", "PL" = "Nie wiem", "ZU" = "Angazi", "SK" = "잘 모르겠습니다")
  
  text_very_liberal <- c("US" = "Very liberal")
  text_liberal <- c("US" = "Liberal")
  text_moderate <- c("US" = "Moderate")
  text_conservative <- c("US" = "Conservative")
  text_very_conservative <- c("US" = "Very conservative")
  
  text_frequency_beef_daily <- c("US" = "Almost or at least daily")
  text_frequency_beef_weekly <- c("US" = "One to four times per week")
  text_frequency_beef_rarely <- c("US" = "Less than once a week")
  text_frequency_beef_never <- c("US" = "Never")
  
  if (only) {
    for (j in intersect(c(
      "heating", "transport_available", "trust_govt", "trust_public_spending", "inequality_problem", "CC_exists", "CC_dynamics", "CC_stoppable", 
      "CC_talks", "CC_worries", "interest_politics"
    ), names(e))) {
      e[j][[1]] <- as.item(as.factor(e[j][[1]]), missing.values = c("PNR", "", NA), annotation=paste(attr(e[j][[1]], "label"))) 
    } 
    
    for (j in names(e)) {
      if ((grepl('race_|home_|CC_factor_|CC_responsible_|CC_affected_|change_condition_|effect_policies_|kaya_|scale_|Beef_|far_left|left$|center$|gilets_jaunes', j)
           | grepl('^right|far_right|liberal|conservative|humanist|patriot|apolitical|^environmentalist|feminist|political_identity_other_choice|GHG_|investments_funding_|obstacles_insulation_', j))
          & !(grepl('_other$|order_|liberal_conservative', j))) {
        temp <- label(e[[j]])
        e[[j]] <- e[[j]]!="" 
        e[[j]][is.na(e[[j]])] <- FALSE
        label(e[[j]]) <- temp
      }
    }
    
    e$owner <- e$home_owner == T | e$home_landlord == T
    label(e$owner) <- "owner: Owner or Landlord renting out property to: Are you a homeowner or a tenant?"
    
    temp <-  -1*(e$frequency_beef %in% text_frequency_beef_never) + 1 * (e$frequency_beef %in% text_frequency_beef_weekly) + 2 * (e$frequency_beef %in% text_frequency_beef_daily) 
    e$frequency_beef <- as.item(temp, labels = structure(c(-1:2), names = c("Never", "Rarely", "Weekly", "Daily")), annotation=Label(e$frequency_beef))
    
    e$income_original <- e$income
    temp <-  (e$income %in% text_income_q1) + 2 * (e$income %in% text_income_q2) + 3 * (e$income %in% text_income_q3) + 4 * (e$income %in% text_income_q4) 
    e$income <- as.item(temp, labels = structure(c(1:4), names = c("Q1","Q2","Q3","Q4")),  annotation=Label(e$income))
    e$income_factor <- as.factor(e$income)
    
    if (!("flights_agg" %in% names(e)) & ("flights" %in% names(e))) {
      e$flights_agg <- 1.8*(e$flights %in% 1:2) + 5*(e$flights %in% 3:7) + 11*(e$flights %in% 8:14) + 25*(e$flights > 14) 
      e$flights_agg <- as.item(e$flights_agg, labels = structure(c(0,1.8,5,11,25), names = c("0", "1 or 2", "3 to 7", "8 to 14", "15 or more")), annotation="flights_agg: Round-trip flights taken per year (on average).")
      e$flights_agg <- e$flights_agg/5
    } else {
      if ("flights_3y" %in% names(e)) {
        e$flights_agg <- 1*(e$flights_3y == "1") + 2*(e$flights_3y == "2") + 3.5*(e$flights_3y == "3 or 4") + 6*(e$flights_3y == "5 to 7") + 11*(e$flights_3y == "8 to 14") + 20*(e$flights_3y == "15 or more")
        e$flights_agg <- as.item(e$flights_agg, labels = structure(c(0,1,2,3.5,6,11,20), names = c("0", "1", "2", "3 or 4", "5 to 7", "8 to 14", "15 or more")), annotation="flights_agg: Round-trip flights taken per year (on average).")      
        e$flights_3y <- as.item(e$flights_agg, labels = structure(c(0,1,2,3.5,6,11,20), names = c("0", "1", "2", "3 or 4", "5 to 7", "8 to 14", "15 or more")), annotation="flights_3y: Round-trip flights taken between 2017 and 2019.")      
        e$flights_agg <- round(e$flights_agg/3, 3)
      } else {
        e$flights_agg <- 1*(e$flights_agg == "1") + 2*(e$flights_agg == "2") + 3.5*(e$flights_agg == "3 or 4") + 7*(e$flights_agg == "5 to 10") + 12*(e$flights_agg == "10 or more")
        e$flights_agg <- as.item(e$flights_agg, labels = structure(c(0,1,2,3.5,7,12), names = c("0", "1", "2", "3 or 4", "5 to 10", "10 or more")), annotation="flights_agg: Round-trip flights taken per year (on average).") } 
    } 
    
    if ("heating_expenses" %in% names(e)) temp <- 125*(e$heating_expenses %in% c(text_heating_expenses_125[c("EN", country)], text_heating_expenses_10["US"])) + 600*(e$heating_expenses %in% c(text_heating_expenses_600[c("EN", country)], text_heating_expenses_50["US"])) + 1250*(e$heating_expenses %in% c(text_heating_expenses_1250[c("EN", country)], text_heating_expenses_100["US"])) + 
      2000*(e$heating_expenses %in% c(text_heating_expenses_2000[c("EN", country)], text_heating_expenses_167["US"])) + 3000*(e$heating_expenses %in% c(text_heating_expenses_3000[c("EN", country)], text_heating_expenses_225["US"], text_heating_expenses_275["US"], text_heating_expenses_350["US"])) - 0.1*((e$heating_expenses %in% text_pnr) | is.na(e$heating_expenses))
    if ("heating_expenses" %in% names(e)) e$heating_expenses <- as.item(temp, labels = structure(c(-0.1, 125, 600, 1250, 2000, 3000), names = c("Don't know","< 250","251-1,000", "1,001-1,500","1,501-2,500", "> 2,500")), missing.values=-0.1, annotation=Label(e$heating_expenses))
    if ("heating_expenses" %in% names(e)) e$heating_expenses_country <- as.item(temp, labels = structure(c(-0.1, 125, 600, 1250, 2000, 3000), 
                                                                                                         names = c(text_pnr[country], text_heating_expenses_125[country], text_heating_expenses_600[country], text_heating_expenses_1250[country], text_heating_expenses_2000[country], text_heating_expenses_3000[country])), missing.values=-0.1, annotation=Label(e$heating_expenses))
    
    # /!\ For India, there was a mistake and we have no data on gas_expenses (heating_expenses were asked instead, with everyone in the lowest category).
    if ("gas_expenses" %in% names(e)) temp <-  0*(e$gas_expenses %in% c(text_gas_expenses_0[c("EN", country)], text_gas_expenses_0["US"])) + 20*(e$gas_expenses %in% c(text_gas_expenses_20[c("EN", country)], text_gas_expenses_15["US"])) + 60*(e$gas_expenses %in% c(text_gas_expenses_60[c("EN", country)], text_gas_expenses_50["US"])) + 
      120*(e$gas_expenses %in% c(text_gas_expenses_120[c("EN", country)], text_gas_expenses_100["US"])) + 200*(e$gas_expenses %in% c(text_gas_expenses_200[c("EN", country)], text_gas_expenses_150["US"], text_gas_expenses_201["US"])) + 300*(e$gas_expenses %in% c(text_gas_expenses_300[c("EN", country)], text_gas_expenses_220["US"]))
    if ("gas_expenses" %in% names(e)) e$gas_expenses <- as.item(temp, labels = structure(c(0, 20, 60, 120, 200, 300), names = c("< 5","5-30","31-90", "91-150", "151-250", "> 250")), annotation=Label(e$gas_expenses))
    if ("gas_expenses" %in% names(e) & country != "IA") e$gas_expenses_country <- as.item(temp, labels = structure(c(0, 20, 60, 120, 200, 300),   names = c(text_gas_expenses_0[country], text_gas_expenses_20[country], text_gas_expenses_60[country], text_gas_expenses_120[country], text_gas_expenses_200[country], text_gas_expenses_300[country])), annotation=Label(e$gas_expenses))
    
    tryCatch({  
      for (v in intersect(c("heating_expenses", "gas_expenses"), names(e))) {
        for (i in 1:4) {
          gap <- 1
          for (m in c(10, 50, 100, 150, 250, 500, 1000, 1500)) {
            share_i <- mean(e$income == i & e[[v]] > m, na.rm = T)/mean(e$income == i, na.rm = T) # paste0("Q", i) memisc
            if (gap > abs(share_i - 0.5)) {
              gap <- abs(share_i - 0.5)
              e[[paste0(v, "_above_median")]][replace_na(e$income == i, F)] <- replace_na(e[[v]][e$income == i] > m, F)
            }
          }
        }
        label(e[[paste0(v, "_above_median")]]) <- paste0(v, "_above_median: T/F indicator that ", v, " are above the median expenses of the respondent's income quartile, given by thresholds_expenses.")
      }
      e$high_gas_expenses <- e$gas_expenses_above_median # could also be: (gas_expenses > 100)
      if ("heating_expenses_above_median" %in% names(e)) { e$high_heating_expenses <- e$heating_expenses_above_median == T # or (heating_expenses > 1000)
      } else e$high_heating_expenses <- FALSE
      label(e$high_heating_expenses) <- "high_heating_expenses: T/F indicator heating_expenses_above_median where NA have been replaced by FALSE."
      label(e$high_heating_expenses) <- "high_heating_expenses: T/F indicator gas_expenses_above_median"
    }, error = function(cond) { print("Couldn't create high_heating_expenses") } )
    
    e$affected_transport <- (e$transport_work=="Car or Motorbike") + (e$transport_shopping=="Car or Motorbike") + (e$transport_leisure=="Car or Motorbike")
    label(e$affected_transport) <- "affected_transport: Sum of activities for which a car or motorbike is used (work, leisure, shopping)."
    e$car_dependency <- e$affected_transport > 0
    
    if ("treatment_climate" %in% names(e)) {
      e$treatment_climate <- ifelse(e$treatment_climate > sqrt(5/17), 1, 0)
      e$treatment_policy <- ifelse(e$treatment_policy > sqrt(5/17), 1, 0)
      e$treatment <- "None"
      e$treatment[e$treatment_climate == 1 & e$treatment_policy == 0] <- "Climate impacts"
      e$treatment[e$treatment_climate == 0 & e$treatment_policy == 1] <- "Climate policy"
      e$treatment[e$treatment_climate == 1 & e$treatment_policy == 1] <- "Both"
      e$treatment <- relevel(relevel(relevel(as.factor(e$treatment), "Climate policy"), "Climate impacts"), "None")
    }
    
    for (v in c("insulation", "availability_transport")) { 
      if (v %in% names(e)) {
        temp <-  2 * (e[[v]] %in% text_excellent) + (e[[v]] %in% text_good) - (e[[v]] %in% text_poor) - 2 * (e[[v]] %in% text_very_poor) - 0.1 * (e[[v]] %in% text_pnr | is.na(e[[v]]))
        e[[v]] <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Very poor", "Poor", "Fair", "Good", "Excellent", "PNR")),
                          missing.values=-0.1, annotation=Label(e[[v]])) 
      } }
    
    if ("liberal_conservative" %in% names(e) & !("left_right" %in% names(e))) e$left_right <- e$liberal_conservative
    if ("left_right" %in% names(e)) {
      temp <- -2 * (as.character(e$left_right) %in% c(text_very_liberal, "1")) - (as.character(e$left_right) %in% c(text_liberal, "2")) + (as.character(e$left_right) %in% c(text_conservative, "4")) + 2 * (as.character(e$left_right) %in% c(text_very_conservative, "5")) - 0.1 * (e$left_right %in% text_pnr | is.na(e$left_right))
      if ("liberal_conservative" %in% names(e)) e$liberal_conservative <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                                                                           names = c("Very liberal", "Liberal", "Moderate", "Conservative", "Very conservative", "PNR")),
                                                                                  missing.values=-0.1, annotation=Label(e$left_right))
      e$left_right <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Very left", "Left", "Center", "Right", "Very right", "PNR")),
                              missing.values=-0.1, annotation=Label(e$left_right))
    }
    
    e$age[e$age %in% text_18_24] <- "18-24"
    e$age[e$age %in% text_25_34] <- "25-34"
    e$age[e$age %in% text_35_49] <- "35-49"
    e$age[e$age %in% text_50_64] <- "50-64"
    e$age[e$age %in% text_65_] <- "65+" 
    e$age_control <- e$age
    e$age_control[e$age == "Below 18"] <- "18-24"
    e$age_control[e$age %in% c("50-64", "65+", "50 to 64", "65 or above")] <- "50+"
    
    e$employment_agg <-  "Not working"
    e$employment_agg[e$employment_status == "Student"] <- "Student"
    e$employment_agg[e$employment_status == "Retired"] <- "Retired"
    e$employment_agg[e$employment_status == "Self-employed" | e$employment_status == "Full-time employed" | e$employment_status == "Part-time employed"] <- "Working"
    e$employment_agg <- as.factor(e$employment_agg)
    
    e$inactive <- e$employment_agg %in% c("Retired", "Not working")
    e$employment <- e$employment_agg == "Working"
    e$employment[e$age == "65+"] <- NA
    
    if ("sector_active" %in% names(e)) {
      e$which_polluting_sector[e$employment_agg == "Working"] <- e$polluting_sector_active[e$employment_agg == "Working"]
      e$which_polluting_sector[e$inactive == T] <- e$polluting_sector_inactive[e$inactive == T]
      e$polluting_sector <- !(e$which_polluting_sector %in% c(text_sector_no, "Other energy industries")) & !is.pnr(e$which_polluting_sector)
    }
    
    if (country == "DK") temp <- (e$urbanity %in% text_large_town) + 2 * (e$urbanity %in% text_small_city) + 3 * (e$urbanity %in% text_medium_city) + 4 * (e$urbanity %in% text_large_city) + 5 * (e$urbanity == "Copenhagen")
    else temp <-  (e$urbanity %in% text_small_town) + 2 * (e$urbanity %in% text_large_town) + 3 * (e$urbanity %in% text_small_city) + 4 * (e$urbanity %in% text_medium_city) + 5 * (e$urbanity %in% c(text_large_city, text_megalopolis))
    e$urbanity <- as.item(temp, labels = structure(c(0:5), names = c("Rural","5-20k","20-50k","50-250k","250k-3M",">3M")), 
                          annotation=paste(Label(e$urbanity), "(Beware, the bins are not defined the same way in each country: e.g. for DK, 5/20/50/250/3M are replaced by 1/10/20/100/1.2M)"))
    
    e$agglo_categ[e$urbanity == 0] <- "Rural"
    e$agglo_categ[e$urbanity %between% list(1,2)] <- "Small agglo"
    e$agglo_categ[e$urbanity == 3] <- "Medium agglo"
    e$agglo_categ[e$urbanity %between% list(4,5)] <- "Large agglo"
    e$agglo_categ <- factor(e$agglo_categ, levels = c("Rural", "Small agglo", "Medium agglo", "Large agglo"))
    e$econ_leaning <- factor(as.character(e$left_right), levels = c("Left", "Very left", "Center", "Right", "Very right", "PNR"))
    
    e$children <- F
    if ("nb_children" %in% names(e)) { e$children[e$nb_children >= 1] <- T
    } else if ("Nb_children" %in% names(e)) { e$children[!(e$Nb_children %in% c(0, "0"))] <- T
    } else if ("Nb_children__14" %in% names(e)) e$children[!(e$Nb_children__14 %in% c(0, "0"))] <- T
    
    e$female <- e$gender == "Female"
    e$other <- e$gender == "Other"
  }
  
  return(e)
}

convert <- function(e, country, wave = NULL, weighting = T, zscores = T, zscores_dummies = FALSE, efa = FALSE, combine_age_50 = T) {
  text_pnr <- c("US" = "I don't know", "US" = "Prefer not to say",  "US" = "Don't know, or prefer not to say",  "US" = "Don't know",  "US" = "Don't know or prefer not to say", "US" = "I don't know",
                "US" = "Don't know, prefer not to say",  "US" = "Don't know, or prefer not to say.",  "US" = "Don't know,  or prefer not to say", "US" = "I am not in charge of paying for heating; utilities are included in my rent", "PNR",
                "FR" = "Je ne sais pas", "FR" = "Ne sais pas, ne souhaite pas répondre", "FR" = "NSP (Ne sais pas, ne se prononce pas)", "FR" = "NSP (Ne sait pas, ne se prononce pas)", "FR" = "Préfère ne pas le dire",
                "UK" = "I don't know", "CN" = "我不知道", "DE" = "Ich weiß es nicht", "CA" = "I don't know", "AU" = "I don't know", "SA" = "I don't know", "DK" = "Jeg ved det ikke", "IT" = "Non lo so", "UA" = "Не знаю", "TR" = "Bilmiyorum", "SP" = "No lo sé", "MX" = "No lo sé", "JP" = "わからない", "PL" = "Nie wiem", "ZU" = "Angazi", "SK" = "잘 모르겠습니다")
  text_yes <- c("US" = "Yes", 
                "FR" = "Oui")
  text_no <- c("US" = "No", "US" = "No or I don't have a partner", 
               "FR" = "Non ou je n'ai pas de partenaire")
  names_policies <<- c("standard", "investments", "tax_transfers")
  
  ## 1. Convert variables to the appropriate class (often 'item' from package 'memisc')
  for (i in 1:length(e)) {
    e[[i]][e[[i]] %in% text_pnr] <- "PNR"
  }
  
  for (v in intersect(names(e), c("urban_category", "region"))) e[[v]] <- sub("\r$", "", gsub('"', '', sub("\n$", "", e[[v]])))
  
  variables_duration <<- names(e)[grepl('duration', names(e))]
  if (length(grep('footprint', names(e)))>0) variables_footprint <<- names(e)[grepl('footprint', names(e)) & !grepl('order', names(e))]
  else variables_footprint <- c()
  for (i in intersect(c(variables_duration, variables_footprint, 
                        "statist", "trust_people", "flights", "km_driven", "hh_adults", "hh_children", "hh_size", "nb_children", "zipcode", "donation"
  ), names(e))) {
    lab <- label(e[[i]])
    if (!(country %in% c("CA", "UK") & i=="zipcode")) e[[i]] <- as.numeric(as.vector( gsub("[^0-9\\.]", "", e[[i]]))) # this may have created an issue with UK zipcodes as it removes letters
    label(e[[i]]) <- lab
  }
  for (v in variables_duration) e[[v]] <- e[[v]]/60
  
  if (country=="US" & "km_driven" %in% names(e)) {
    e$miles_driven <- e$km_driven
    e$km_driven <- 1.60934 * e$miles_driven
    label(e$km_driven) <- "km_driven: How many kilometers have you and your household members driven in 2019?" }
  if ("hh_children" %in% names(e)) {
    e$hh_size <- e$hh_adults + e$hh_children
    e$hh_size <- pmin(e$hh_size, 12)
    label(e$hh_size) <- "hh_size: How many people are in you household?" }
  if ("hh_children" %in% names(e)) e$hh_children <- pmin(e$hh_children, 10)
  if ("hh_adults" %in% names(e)) e$hh_adults <- pmin(e$hh_adults, 5)
  
  if (country=="US") yes_no_names <- c("","No","PNR","Yes")
  if (country=="FR") yes_no_names <- c("","Non","PNR","Oui")
  for (j in intersect(c("couple", "CC_real", "CC_dynamic", "change_lifestyle", "pro_global_assembly", "pro_global_tax", "pro_tax_1p", "tax_transfers_trust", "investments_trust",
                        "standard_trust", "tax_transfers_effective", "investments_effective", "standard_effective", "tax_transfers_supports", "investments_supports",
                        "standard_supports", "hit_by_covid", "member_environmental_orga", "relative_environmentalist", "standard_exists", "petition", paste0("wtp_", c(10, 30, 50, 100, 300, 500, 1000))
  ), names(e))) {
    temp <- 1*(e[j][[1]] %in% text_yes) - 0.1*(e[j][[1]] %in% text_pnr) 
    temp[is.na(e[j][[1]])] <- NA
    e[j][[1]] <- as.item(temp, labels = structure(c(0,-0.1,1), names = c("No","PNR","Yes")),
                         missing.values = c("",NA,"PNR"), annotation=attr(e[j][[1]], "label"))
  }
  
  for (j in intersect(c(
    "heating", "transport_available", "trust_govt", "trust_public_spending", "inequality_problem", "CC_exists", "CC_dynamics", "CC_stoppable", 
    "CC_talks", "CC_worries", "interest_politics"
  ), names(e))) {
    e[j][[1]] <- as.item(as.factor(e[j][[1]]), missing.values = c("PNR", "", NA), annotation=paste(attr(e[j][[1]], "label"))) 
  }
  
  for (j in names(e)) {
    if ((grepl('race_|home_|CC_factor_|CC_responsible_|CC_affected_|change_condition_|effect_policies_|kaya_|scale_|Beef_|far_left|left$|center$|gilets_jaunes', j)
         | grepl('^right|far_right|liberal|conservative|humanist|patriot|apolitical|^environmentalist|feminist|political_identity_other_choice|GHG_|investments_funding_|obstacles_insulation_', j))
        & !(grepl('_other$|order_|liberal_conservative', j))) {
      temp <- label(e[[j]])
      e[[j]] <- e[[j]]!="" 
      e[[j]][is.na(e[[j]])] <- FALSE
      label(e[[j]]) <- temp
    }
  }
  
  ## 2. Define variable groupings (including for index definitions) and labels, used here and in other files.
  variables_fine_support <<- c("standard_10k_fine", "standard_100k_fine") # DE, IT, PL, SP
  variables_fine_prefer <<- c("standard_prefer_ban", "standard_prefer_10k_fine", "standard_prefer_100k_fine") # DE, IT, PL, SP
  variables_gas_spike <<- c("gas_spike_transition_needed", "gas_spike_policies_costly", "gas_spike_higher_tax_rich", "gas_spike_not_related") # UK
  variables_policy_additional <<- c("policy_ban_coal", "policy_ban_deforestation", "tax_ecological_protection", "tax_reduction_EEG_Umlage", "tax_more_commuter_allowance", "insulation_mandatory_support_progressive") # DE: coal, EEG, commuter; UA: ecological protection; SP: insulation_mandatory_support_progressive; BR, ID: policy_ban_deforestation  # also variables_gilets_jaunes in FR
  variables_race <<- names(e)[grepl('race_', names(e))]
  variables_home <<- names(e)[grepl('home_', names(e))]
  variables_transport <<- names(e)[grepl('transport_', names(e))]
  variables_CC_factor <<- names(e)[grepl('CC_factor_', names(e))]
  variables_CC_responsible <<- names(e)[grepl('CC_responsible_', names(e)) & !grepl("order_", names(e))]
  variables_responsible_CC <<- names(e)[grepl('responsible_CC_', names(e)) & !grepl("order_", names(e))]
  variables_CC_affected <<- names(e)[grepl('CC_affected_', names(e))]
  variables_change_condition <<- names(e)[grepl('change_condition_', names(e))]
  variables_effect_policies <<- names(e)[grepl('effect_policies_', names(e))]
  variables_effect_policies <<- names(e)[grepl('effect_halt_CC_', names(e))]
  variables_kaya <<- names(e)[grepl('kaya_', names(e))]
  variables_scale <<- names(e)[grepl('scale_', names(e))]
  variables_beef <<- names(e)[grepl('beef_', names(e)) & !grepl("order_", names(e))]
  variables_burden_sharing <<- names(e)[grepl('burden_sharing_', names(e))] 
  variables_burden_share <<- names(e)[grepl('burden_share_', names(e))]
  variables_standard_effect <<- names(e)[grepl('standard_', names(e)) & grepl('_effect', names(e)) & !grepl('_new|_jobs', names(e))]
  variables_investments_effect <<- names(e)[grepl('investments_', names(e)) & grepl('_effect', names(e))  & !grepl('_new|_jobs', names(e))]
  variables_tax_transfers_effect <<- names(e)[grepl('tax_transfers_', names(e)) & grepl('_effect', names(e))  & !grepl('_new|_jobs', names(e))]
  variables_standard_effect_all <<- c(variables_standard_effect[1:2], "standard_positive_effect", "standard_negative_effect", "standard_large_effect", "standard_costless", "standard_cost_effective")
  variables_tax_transfers_effect_all <<- c(variables_tax_transfers_effect[1:4], "tax_transfers_positive_effect", "tax_transfers_negative_effect", "tax_transfers_large_effect", "tax_transfers_costless", "tax_transfers_cost_effective")
  variables_investments_effect_all <<- c(variables_investments_effect[1:3], "investments_positive_effect", "investments_negative_effect", "investments_large_effect", "investments_costless", "investments_cost_effective")
  variables_policies_effect <<- c(variables_standard_effect, variables_investments_effect, variables_tax_transfers_effect)
  variables_policies_fair  <<- names(e)[grepl('_fair', names(e))]
  variables_policies_support <<- c("standard_support", "investments_support", "tax_transfers_support")
  variables_policies_attitudes <<- paste0("policies_", c("effect_less_pollution", "positive_negative", "large_effect", "costless_costly", "poor", "middle", "rich", "rural", "self", "fair"))
  variables_policies_attitudes_treatment <<- paste0("policies_", c("effect_less_pollution", "positive_effect", "negative_effect", "large_effect", "costless", "cost_effective", "poor", "middle", "rich", "rural", "self", "fair"))
  variables_support <<- names(e)[grepl('_support', names(e)) & !grepl('order_', names(e))]
  variables_incidence <<- names(e)[grepl('incidence_', names(e))]
  variables_standard_incidence <<- names(e)[grepl('standard_incidence_', names(e))]
  variables_investments_incidence <<- names(e)[grepl('investments_incidence_', names(e))]
  variables_tax_transfers_incidence <<- names(e)[grepl('tax_transfers_incidence_', names(e))]
  variables_win_lose <<- names(e)[grepl('win_lose_', names(e)) & !grepl('_new', names(e))]
  variables_standard_win_lose <<- names(e)[grepl('standard_win_lose_', names(e)) & !grepl('_new', names(e))]
  variables_investments_win_lose <<- names(e)[grepl('investments_win_lose_', names(e)) & !grepl('_new', names(e))]
  variables_tax_transfers_win_lose <<- names(e)[grepl('tax_transfers_win_lose_', names(e)) & !grepl('_new', names(e))]
  variables_standard <<- c("standard_support", "standard_fair", "standard_positive_negative", "standard_costless_costly", variables_standard_incidence, variables_standard_win_lose)
  variables_investments <<- c("investments_support", "investments_fair", "investments_positive_negative", "investments_costless_costly", variables_investments_incidence, variables_investments_win_lose)
  variables_tax_transfers <<- c("tax_transfers_support", "tax_transfers_fair", "tax_transfers_positive_negative", "tax_transfers_costless_costly", variables_tax_transfers_incidence, variables_tax_transfers_win_lose)
  variables_side_effects <<- names(e)[grepl('_side_effects', names(e))]
  variables_willing <<- names(e)[grepl('willing_', names(e))]
  variables_employment <<- names(e)[grepl('_employment', names(e))]
  variables_condition <<- names(e)[grepl('condition_', names(e))]
  variables_CC_impacts <<- names(e)[grepl('CC_impacts_', names(e))]
  variables_policy <<- names(e)[grepl('policy_', names(e)) & !grepl("order_|list_", names(e))]
  variables_policy_common <<- names(e)[grepl('policy_', names(e)) & !grepl("order_|deforest|_coal|list_", names(e))]
  variables_tax <<- names(e)[grepl('^tax_', names(e)) & !grepl("order_|transfers_|1p", names(e))]
  variables_tax_common <<- names(e)[grepl('^tax_', names(e)) & !grepl("order_|transfers_|1p|EEG_Umlage|commuter_allowance|ecological_protection", names(e))]
  variables_political_identity <<- c("liberal", "conservative", "humanist", "patriot", "apolitical", "environmentalist", "feminist", "political_identity_other")
  variables_socio_demo <<- c("gender", "age", "region", "race_white", "education", "hit_by_covid", "employment_status", "income", "wealth", "urban", "nb_children", "hh_children", "hh_adults", "heating", "km_driven", "flights", "frequency_beef")
  variables_main_controls_pilot12 <<- c("gender", "age", "income", "education", "hit_by_covid", "employment_status", "Left_right", "vote_agg", "as.factor(urbanity)", "urban")
  variables_main_controls_pilot3 <<- c("gender", "age", "income", "education", "hit_by_covid", "employment_agg", "left_right", "vote_agg", "as.factor(urbanity)", "urban", "rush")
  variables_main_controls <<- c("gender", "age", "income", "education", "hit_by_covid", "employment_agg", "children", "left_right", "vote_agg", "as.factor(urbanity)", "urban", "rush")
  variables_pro <<- names(e)[grepl('^pro_', names(e))]
  variables_know_treatment_climate <<- c("know_local_damage", "know_temperature_2100")
  if ("know_standard" %in% names(e)) variables_know_treatment_policy <<- c("know_standard", "know_investments_jobs")
  else variables_know_treatment_policy <<- c("know_ban", "know_investments_funding")
  variables_know_treatment <<- c(variables_know_treatment_climate, variables_know_treatment_policy)
  variables_GHG <<- names(e)[grepl('GHG_', names(e))]
  variables_investments_funding <<- names(e)[grepl('investments_funding_', names(e)) & !grepl('global_', names(e))]
  variables_if_other_do <<- names(e)[grepl('if_other_do_', names(e))]
  variables_obstacles_insulation <<- names(e)[grepl('obstacles_insulation_', names(e)) & !grepl('other$', names(e))]
  if (length(grep('footprint', names(e)))>0) {
    Variables_footprint <<- Labels_footprint <<- list()
    for (v in c("el", "fd", "tr", "reg", "pc")) {
      Variables_footprint[[v]] <<- names(e)[grepl(paste("footprint_", v, "_", sep=""), names(e)) & !grepl("order", names(e))]
      Labels_footprint[[v]] <<- capitalize(sub(paste("footprint_", v, "_", sep=""), "", Variables_footprint[[v]]))
    }
  }
  variables_wtp <<- names(e)[grepl('wtp_', names(e))]
  variables_global_policies <<- c("global_assembly_support", "global_tax_support", "tax_1p_support")
  variables_gilets_jaunes <<- c("gilets_jaunes_dedans", "gilets_jaunes_soutien", "gilets_jaunes_compris", "gilets_jaunes_oppose", "gilets_jaunes_NSP") 
  variables_willingness_all <<- c(variables_willing, variables_condition, "will_insulate", "wtp", "donation_percent", "petition")
  labels_willingness <<- paste("A lot willing to", c("Limit flying", "Limit driving", "Have a fuel-efficient or electric vehicle", "Limit beef consumption", "Limit heating or cooling your home"))
  labels_condition <<- c("Ambitious climate policies", "Having enough financial support", "People around you also changing their behavior", "The most well off also changing their behavior")
  labels_willingness_all <<- c(labels_willingness, paste("Condition willing:", labels_condition), "Will insulate home in next 5 years", "Willing To Pay to keep global warning below 2°C", "Donation to reforest (positive amount)", "Willing to sign petition")
  variables_scores_footprint <<- c("score_footprint_elec", "score_footprint_food", "score_footprint_transport", "score_footprint_pc", "score_footprint_region")
  labels_scores_footprint <<- c("Electricity", "Food", "Transport", "Countries per capita", "Countries in absolute")
  main_variables_knowledge <<- c("CC_anthropogenic", "CC_knowledgeable", "CC_dynamic", "score_GHG", "score_CC_impacts", variables_scores_footprint, "correct_footprint_pc_compare_own", "index_knowledge_efa_global")
  labels_main_knowledge <<- c("CC exists, is anthropogenic", "Considers one's self knowledgeable", "Cutting emissions by half enough to stop global warning (False)", "Score to knowledge of greenhouse gases in [0;+4]", "Knowledge score of impacts in [0;4] (droughts, sea-level, volcanos)", paste("Distance to true ranking of footprints: ", labels_scores_footprint), "Correctly compares p.c. emissions of own region vs. China (or India)", "Standardised knowledge index")
  
  variables_matrices <<- list("CC_impacts" = variables_CC_impacts, 
                              "responsible_CC" = variables_responsible_CC, 
                              "willing" = variables_willing, 
                              "condition" = variables_condition, 
                              "standard_win_lose" = variables_standard_win_lose, 
                              "tax_transfers_win_lose" = variables_tax_transfers_win_lose, 
                              "investments_win_lose" = variables_investments_win_lose, 
                              "standard_effect" = variables_standard_effect, 
                              "tax_transfers_effect" = variables_tax_transfers_effect, 
                              "investments_effect" = variables_investments_effect, 
                              "policy" = variables_policy, 
                              "tax" = variables_tax, 
                              "burden_share" = variables_burden_share, 
                              "beef" = variables_beef
  )
  
  e$affected_transport <- (e$transport_work=="Car or Motorbike") + (e$transport_shopping=="Car or Motorbike") + (e$transport_leisure=="Car or Motorbike")
  label(e$affected_transport) <- "affected_transport: Sum of activities for which a car or motorbike is used (work, leisure, shopping)."
  e$car_dependency <- e$affected_transport > 0
  label(e$car_dependency) <- "car_dependency: Car or motorbike is used for at least one activity (work, leisure, shopping)."
  
  ## 2bis. Characterize the definitions of indices.
  variables_knowledge <<- c("score_footprint_transport", "score_footprint_elec", "score_footprint_food", "score_footprint_pc", "score_footprint_region", "CC_dynamic", "CC_anthropogenic", "CC_real", "score_CC_impacts", "CC_knowledgeable", "score_GHG")
  negatives_knowledge <<- c(T, T, T, T, T, T, F, F, F, F, F) # For EFA
  
  variables_index_knowledge_not_dum <<- c("score_footprint_transport", "score_footprint_elec", "score_footprint_food", "score_footprint_pc", "score_footprint_region", "CC_dynamic", "CC_anthropogenic", "CC_real", "CC_impacts_droughts", "CC_impacts_sea_rise", "know_GHG_methane", "know_GHG_CO2", "know_GHG_H2", "know_GHG_particulates", "CC_impacts_volcanos")
  negatives_index_knowledge_not_dum <<- c(T, T, T, T, T, T, F, F, F, F, F, F, F, F, T)
  conditions_index_knowledge_not_dum <<- c(rep(" > -1", 6), rep(" > 0", 8), " > 0.1")
  before_treatment_index_knowledge_not_dum <<- rep(F, 15)
  
  variables_index_knowledge <<- c("score_footprint_transport", "score_footprint_elec", "score_footprint_food", "score_footprint_pc", "score_footprint_region", "CC_dynamic", "knows_anthropogenic", "CC_real", "know_impacts_droughts", "know_impacts_sea_rise", "know_GHG_methane", "know_GHG_CO2", "know_GHG_H2", "know_GHG_particulates", "know_impacts_volcanos")
  negatives_index_knowledge <<- c(T, T, T, T, T, T, F, F, F, F, F, F, F, F, F)
  conditions_index_knowledge <<- c(rep(" > -1", 6), rep(" > 0", 8), " > 0.1")
  before_treatment_index_knowledge <<- rep(F, 15)
  
  variables_index_knowledge_footprint <<- c("score_footprint_transport", "score_footprint_elec", "score_footprint_food", "score_footprint_pc", "score_footprint_region")
  negatives_index_knowledge_footprint <<- c(T, T, T, T, T)
  conditions_index_knowledge_footprint <<- c(rep(" > -1", 1))
  before_treatment_index_knowledge_footprint <<- rep(F, 5)
  
  variables_index_knowledge_fundamentals <<- c("CC_dynamic", "knows_anthropogenic", "CC_real")
  negatives_index_knowledge_fundamentals <<- c(T, F, F)
  conditions_index_knowledge_fundamentals <<- c(" > -1", rep(" > 0", 2))
  before_treatment_index_knowledge_fundamentals <<- rep(F, 3)
  
  variables_index_knowledge_gases <<- c("know_GHG_methane", "know_GHG_CO2", "know_GHG_H2", "know_GHG_particulates") 
  negatives_index_knowledge_gases <<- rep(F, 4)
  conditions_index_knowledge_gases <<- rep(" > 0", 4)
  before_treatment_index_knowledge_gases <<- rep(F, 4)
  
  variables_index_knowledge_impacts <<- c("know_impacts_droughts", "know_impacts_sea_rise", "know_impacts_volcanos")
  negatives_index_knowledge_impacts <<- rep(F, 3)
  conditions_index_knowledge_impacts <<- rep(" > 0", 3)
  before_treatment_index_knowledge_impacts <<- rep(F, 3)
  
  variables_index_affected <<- c("polluting_sector", "affected_transport", "gas_expenses", "heating_expenses", "availability_transport", "urbanity", "urban")
  negatives_index_affected <<- c(F, F, F, F, T, T, T)
  conditions_index_affected <<- c(rep("> 0", 5), "> -2", " > -1") 
  before_treatment_index_affected <<- rep(T, 7)
  
  variables_index_affected_income <<- c("polluting_sector", "gas_expenses", "heating_expenses")
  negatives_index_affected_income <<- c(F, F, F)
  conditions_index_affected_income <<- rep("> 0", 3)
  before_treatment_index_affected_income <<- rep(T, 3)
  
  variables_index_affected_lifestyle <<- c("affected_transport", "frequency_beef", "availability_transport", "urbanity", "urban")
  negatives_index_affected_lifestyle <<- c(F, F, T, T, T)
  conditions_index_affected_lifestyle <<- c("> 1", "> 0", "> 0", "> -2", " > -1")
  before_treatment_index_affected_lifestyle <<- rep(T, 5)
  
  variables_index_pricing_vs_norms <<- c("tax_transfers_support", "beef_tax_support", "policy_tax_flying", "standard_support", "beef_ban_intensive_support", "policy_ban_city_centers")
  negatives_index_pricing_vs_norms <<- c(F, F, F, T, T, T)
  conditions_index_pricing_vs_norms <<- rep("> 0", 6)
  before_treatment_index_pricing_vs_norms <<- c(F, F, F, F, F, F)
  
  variables_index_pricing_vs_norms_all <<- c("tax_transfers_support", "policy_tax_flying", "standard_support", "policy_ban_city_centers")
  negatives_index_pricing_vs_norms_all <<- c(F, F, T, T)
  conditions_index_pricing_vs_norms_all <<- rep("> 0", 4)
  before_treatment_index_pricing_vs_norms_all <<- c(F, F, F, F)
  
  variables_index_net_zero_feasible <<- c("net_zero_feasible")
  negatives_index_net_zero_feasible <<- c(F)
  conditions_index_net_zero_feasible <<- c("> 0.1")
  before_treatment_index_net_zero_feasible <<- c(F)
  
  variables_index_progressist <<- c("left_right", "vote_agg", "view_govt")
  negatives_index_progressist <<- c(T, T, F)
  conditions_index_progressist <<- c(rep(" > 0.1", 2), " > 0") 
  before_treatment_index_progressist <<- c(T, T, F)
  
  variables_index_concerned_about_CC <<- c("CC_talks", "CC_problem", "should_fight_CC", "member_environmental_orga")
  negatives_index_concerned_about_CC <<- rep(F, 4)
  conditions_index_concerned_about_CC <<- rep("> 0", 4)
  before_treatment_index_concerned_about_CC <<- c(F, F, F, F)
  
  variables_index_worried_old <<- c("CC_impacts_more_migration", "CC_impacts_more_wars", "CC_impacts_extinction", "CC_impacts_drop_conso", "CC_will_end", "net_zero_feasible", "future_richness")
  negatives_index_worried_old <<- c(F, F, F, F, T, T, T)
  conditions_index_worried_old <<- c(rep(" %in% c(0, 1, 2)", 4), rep(" > 0.1", 3))
  before_treatment_index_worried_old <<- rep(F, 7)
  
  variables_index_bad_things_CC <<- c("CC_impacts_more_migration", "CC_impacts_more_wars", "CC_impacts_drop_conso")
  negatives_index_bad_things_CC <<- c(F, F, F)
  conditions_index_bad_things_CC <<- c(rep(" %in% c(0, 1, 2)", 3))
  before_treatment_index_bad_things_CC <<- rep(F, 3)
  
  variables_index_worried <<- c("CC_impacts_more_migration", "CC_impacts_more_wars", "CC_impacts_extinction", "CC_impacts_drop_conso", "CC_problem", "member_environmental_orga") 
  negatives_index_worried <<- rep(F, 6)
  conditions_index_worried <<- c(rep(" %in% c(0, 1, 2)", 4), rep(" > 0", 2))
  before_treatment_index_worried <<- rep(F, 6)
  
  variables_index_positive_economy <<- c("effect_halt_CC_economy", "investments_positive_negative", "tax_transfers_positive_negative", "standard_positive_negative")
  negatives_index_positive_economy <<- rep(F, 4)
  conditions_index_positive_economy <<- rep(" > 0", 4)
  before_treatment_index_positive_economy <<- rep(F, 4)
  
  variables_index_investments_emissions_plus_new_rep <<- c("investments_effect_elec_greener_new", "investments_effect_public_transport")
  negatives_index_investments_emissions_plus_new_rep <<- c(T, rep(F, 1))
  conditions_index_investments_emissions_plus_new_rep <<- rep(" > 0", 2)
  before_treatment_index_investments_emissions_plus_new_rep <<- rep(F, 2)
  
  variables_index_tax_emissions_plus_new_rep <<- c("tax_transfers_effect_less_emission_new",
                                                   "tax_transfers_effect_driving",
                                                   "tax_transfers_effect_insulation")
  negatives_index_tax_emissions_plus_new_rep <<- c(T, rep(F, 2))
  conditions_index_tax_emissions_plus_new_rep <<- rep(" > 0", 3)
  before_treatment_index_tax_emissions_plus_new_rep <<- rep(F, 3)
  
  variables_index_standard_emissions_plus_new_rep <<- c("standard_effect_less_emission_new")
  negatives_index_standard_emissions_plus_new_rep <<- rep(T, 1)
  conditions_index_standard_emissions_plus_new_rep <<- rep(" > 0", 1)
  before_treatment_index_standard_emissions_plus_new_rep <<- rep(F, 1)
  
  variables_index_lose_investments_poor_new_rep <<- c("investments_effect_low_skill_jobs")
  negatives_index_lose_investments_poor_new_rep <<- rep(T, 1)
  conditions_index_lose_investments_poor_new_rep <<- rep(" > 0.1", 1)
  before_treatment_index_lose_investments_poor_new_rep <<- rep(F, 1)
  
  variables_index_lose_tax_transfers_poor_new_rep <<- c("tax_transfers_win_lose_poor_new")
  negatives_index_lose_tax_transfers_poor_new_rep <<- rep(T, 1)
  conditions_index_lose_tax_transfers_poor_new_rep <<- rep(" > 0.1", 1)
  before_treatment_index_lose_tax_transfers_poor_new_rep <<- rep(F, 1)
  
  variables_index_lose_standard_poor_new_rep <<- c("standard_win_lose_poor_new")
  negatives_index_lose_standard_poor_new_rep <<- rep(F, 1)
  conditions_index_lose_standard_poor_new_rep <<- rep(" > 0.1", 1)
  before_treatment_index_lose_standard_poor_new_rep <<- rep(F, 1)
  
  variables_index_investments_positive_economy <<- c("effect_halt_CC_economy", "investments_positive_negative")
  negatives_index_investments_positive_economy <<- rep(F, 2)
  conditions_index_investments_positive_economy <<- rep(" > 0", 2)
  before_treatment_index_investments_positive_economy <<- rep(F, 2)
  
  variables_index_tax_transfers_positive_economy <<- c("effect_halt_CC_economy", "tax_transfers_positive_negative")
  negatives_index_tax_transfers_positive_economy <<- rep(F, 2)
  conditions_index_tax_transfers_positive_economy <<- rep(" > 0", 2)
  before_treatment_index_tax_transfers_positive_economy <<- rep(F, 2)
  
  variables_index_standard_positive_economy <<- c("effect_halt_CC_economy", "standard_positive_negative")
  negatives_index_standard_positive_economy <<- rep(F, 2)
  conditions_index_standard_positive_economy <<- rep(" > 0", 2)
  before_treatment_index_standard_positive_economy <<- rep(F, 2)
  
  variables_index_distribution_critical <<- c("tax_transfer_poor", "tax_transfer_constrained_hh", "tax_1p_support", "responsible_CC_rich", "condition_rich_change", "investments_funding_wealth_tax", "policies_fair_support_same_sign", "policies_support_poor_same_sign")
  negatives_index_distribution_critical <<- before_treatment_index_distribution_critical <<- rep(F, 8)
  conditions_index_distribution_critical <<- c(rep(" > 0", 5), rep("== T", 3) )
  
  variables_index_attentive <<- c("duration", "length_CC_field", "duration_burden_sharing", "duration_tax_transfers", "duration_policies") 
  negatives_index_attentive <<- before_treatment_index_attentive <<-rep(F, length(variables_index_attentive))
  conditions_index_attentive <<- c("> 25", "> 35", "> 750", "> 650", "> 900")
  
  variables_index_constrained <<- c("condition_financial_aid", "income", "wealth")
  negatives_index_constrained <<- c(F, T, T)
  conditions_index_constrained <<- c(" > 0", " > -3", " > -3")
  before_treatment_index_constrained <<- c(F, T, T)
  
  variables_index_policies_pollution <<- c("investments_effect_less_pollution", "tax_transfers_effect_less_pollution","standard_effect_less_pollution")
  negatives_index_policies_pollution <<- rep(F, 3)
  conditions_index_policies_pollution <<- rep(" > 0", 3)
  before_treatment_index_policies_pollution <<- rep(F, 3)
  
  variables_index_policies_emissions <<- c("investments_effect_elec_greener", "tax_transfers_effect_less_emission","standard_effect_less_emission")
  negatives_index_policies_emissions <<- rep(F, 6)
  conditions_index_policies_emissions <<- rep(" > 0", 6)
  before_treatment_index_policies_emissions <<- rep(F, 6)
  
  variables_index_policies_emissions_plus <<- c("investments_effect_elec_greener", "tax_transfers_effect_less_emission","standard_effect_less_emission", "investments_effect_public_transport", "tax_transfers_effect_driving", "tax_transfers_effect_insulation")
  negatives_index_policies_emissions_plus <<- rep(F, 6)
  conditions_index_policies_emissions_plus <<- rep(" > 0", 6)
  before_treatment_index_policies_emissions_plus <<- rep(F, 6)
  
  variables_index_investments_emissions_plus <<- c("investments_effect_elec_greener", "investments_effect_public_transport")
  negatives_index_investments_emissions_plus <<- rep(F, 2)
  conditions_index_investments_emissions_plus <<- rep(" > 0", 2)
  before_treatment_index_investments_emissions_plus <<- rep(F, 2)
  
  variables_index_tax_emissions_plus <<- c("tax_transfers_effect_less_emission", "tax_transfers_effect_driving", "tax_transfers_effect_insulation")
  negatives_index_tax_emissions_plus <<- rep(F, 3)
  conditions_index_tax_emissions_plus <<- rep(" > 0", 3)
  before_treatment_index_tax_emissions_plus <<- rep(F, 3)
  
  variables_index_standard_emissions_plus <<- c("standard_effect_less_emission")
  negatives_index_standard_emissions_plus <<- rep(F, 1)
  conditions_index_standard_emissions_plus <<- rep(" > 0", 1)
  before_treatment_index_standard_emissions_plus <<- rep(F, 1)
  
  variables_index_investments_pollution <<- c("investments_effect_less_pollution")
  negatives_index_investments_pollution <<- rep(F, 1)
  conditions_index_investments_pollution <<- rep(" > 0", 1)
  before_treatment_index_investments_pollution <<- rep(F, 1)
  
  variables_index_tax_transfers_pollution <<- c("tax_transfers_effect_less_pollution")
  negatives_index_tax_transfers_pollution <<- rep(F, 1)
  conditions_index_tax_transfers_pollution <<- rep(" > 0", 1)
  before_treatment_index_tax_transfers_pollution <<- rep(F, 1)
  
  variables_index_standard_pollution <<- c("standard_effect_less_pollution")
  negatives_index_standard_pollution <<- rep(F, 1)
  conditions_index_standard_pollution <<- rep(" > 0", 1)
  before_treatment_index_standard_pollution <<- rep(F, 1)
  
  variables_index_tax_emissions <<- c("tax_transfers_effect_less_emission")
  negatives_index_tax_emissions <<- rep(F, 1)
  conditions_index_tax_emissions <<- rep(" > 0", 1)
  before_treatment_index_tax_emissions <<- rep(F, 1)
  
  variables_index_investments_emissions <<- c("investments_effect_elec_greener")
  negatives_index_investments_emissions <<- rep(F, 1)
  conditions_index_investments_emissions <<- rep(" > 0", 1)
  before_treatment_index_investments_emissions <<- rep(F, 1)
  
  variables_index_standard_emissions <<- c("standard_effect_less_emission")
  negatives_index_standard_emissions <<- rep(F, 1)
  conditions_index_standard_emissions <<- rep(" > 0", 1)
  before_treatment_index_standard_emissions <<- rep(F, 1)
  
  variables_index_policies_effective <<- c("investments_effect_elec_greener", "investments_effect_public_transport", "investments_effect_less_pollution", "tax_transfers_effect_driving", "tax_transfers_effect_insulation", "tax_transfers_effect_less_emission", "tax_transfers_effect_less_pollution", "standard_effect_less_emission", "standard_effect_less_pollution")
  negatives_index_policies_effective <<- rep(F, 9)
  conditions_index_policies_effective <<- rep(" > 0", 9)
  before_treatment_index_policies_effective <<- rep(F, 9)
  
  variables_index_investments_effective <<- c("investments_effect_elec_greener", "investments_effect_public_transport", "investments_effect_less_pollution")
  negatives_index_investments_effective <<- rep(F, 3)
  conditions_index_investments_effective <<- rep(" > 0", 3)
  before_treatment_index_investments_effective <<- rep(F, 3)
  
  variables_index_tax_transfers_effective <<- c("tax_transfers_effect_driving", "tax_transfers_effect_insulation", "tax_transfers_effect_less_emission", "tax_transfers_effect_less_pollution")
  negatives_index_tax_transfers_effective <<- rep(F, 4)
  conditions_index_tax_transfers_effective <<- rep(" > 0", 4)
  before_treatment_index_tax_transfers_effective <<- rep(F, 4)
  
  variables_index_standard_effective <<- c("standard_effect_less_emission", "standard_effect_less_pollution")
  negatives_index_standard_effective <<- rep(F, 2)
  conditions_index_standard_effective <<- rep(" > 0", 2)
  before_treatment_index_standard_effective <<- rep(F, 2)
  
  variables_index_care_poverty <<- c("tax_transfer_poor", "tax_transfer_constrained_hh", "problem_inequality")
  negatives_index_care_poverty <<- rep(F, 3)
  conditions_index_care_poverty <<- rep(" > 0", 3)
  before_treatment_index_care_poverty <<- rep(F, 3)
  
  variables_index_problem_inequality <<- "problem_inequality"
  negatives_index_problem_inequality <<- F
  conditions_index_problem_inequality <<- " > 0"
  before_treatment_index_problem_inequality <<- F
  
  variables_index_altruism <<- c("donation")
  negatives_index_altruism <<- c(F)
  conditions_index_altruism <<- c("> median(df$donation)")
  before_treatment_index_altruism <<- c(F)  
  
  variables_index_affected_subjective <<- c("CC_affects_self")
  negatives_index_affected_subjective <<- c(F)
  conditions_index_affected_subjective <<- c(" > 0")
  before_treatment_index_affected_subjective <<- rep(F, 1)
  
  variables_index_lose_policies_subjective <<- c("investments_win_lose_self", "tax_transfers_win_lose_self", "standard_win_lose_self")
  negatives_index_lose_policies_subjective <<- rep(T, 3)
  conditions_index_lose_policies_subjective <<- rep(" > 0.1", 3)
  before_treatment_index_lose_policies_subjective <<- rep(F, 3)
  
  variables_index_lose_policies_poor <<- c("investments_win_lose_poor", "tax_transfers_win_lose_poor", "standard_win_lose_poor")
  negatives_index_lose_policies_poor <<- rep(T, 3)
  conditions_index_lose_policies_poor <<- rep(" > 0.1", 3)
  before_treatment_index_lose_policies_poor <<- rep(F, 3)
  
  variables_index_lose_policies_rich <<- c("investments_win_lose_rich", "tax_transfers_win_lose_rich", "standard_win_lose_rich")
  negatives_index_lose_policies_rich <<- rep(T, 3)
  conditions_index_lose_policies_rich <<- rep(" > 0.1", 3)
  before_treatment_index_lose_policies_rich <<- rep(F, 3)
  
  variables_index_lose_investments_subjective <<- c("investments_win_lose_self")
  negatives_index_lose_investments_subjective <<- rep(T, 1)
  conditions_index_lose_investments_subjective <<- rep(" > 0.1", 1)
  before_treatment_index_lose_investments_subjective <<- rep(F, 1)
  
  variables_index_lose_investments_poor <<- c("investments_win_lose_poor")
  negatives_index_lose_investments_poor <<- rep(T, 1)
  conditions_index_lose_investments_poor <<- rep(" > 0.1", 1)
  before_treatment_index_lose_investments_poor <<- rep(F, 1)
  
  variables_index_lose_investments_rich <<- c("investments_win_lose_rich")
  negatives_index_lose_investments_rich <<- rep(T, 1)
  conditions_index_lose_investments_rich <<- rep(" > 0.1", 1)
  before_treatment_index_lose_investments_rich <<- rep(F, 1)
  
  variables_index_lose_tax_transfers_subjective <<- c("tax_transfers_win_lose_self")
  negatives_index_lose_tax_transfers_subjective <<- rep(T, 1)
  conditions_index_lose_tax_transfers_subjective <<- rep(" > 0.1", 1)
  before_treatment_index_lose_tax_transfers_subjective <<- rep(F, 1)
  
  variables_index_lose_tax_transfers_poor <<- c("tax_transfers_win_lose_poor")
  negatives_index_lose_tax_transfers_poor <<- rep(T, 1)
  conditions_index_lose_tax_transfers_poor <<- rep(" > 0.1", 1)
  before_treatment_index_lose_tax_transfers_poor <<- rep(F, 1)
  
  variables_index_lose_tax_transfers_rich <<- c("tax_transfers_win_lose_rich")
  negatives_index_lose_tax_transfers_rich <<- rep(T, 1)
  conditions_index_lose_tax_transfers_rich <<- rep(" > 0.1", 1)
  before_treatment_index_lose_tax_transfers_rich <<- rep(F, 1)
  
  variables_index_lose_standard_subjective <<- c("standard_win_lose_self")
  negatives_index_lose_standard_subjective <<- rep(T, 1)
  conditions_index_lose_standard_subjective <<- rep(" > 0.1", 1)
  before_treatment_index_lose_standard_subjective <<- rep(F, 1)
  
  variables_index_lose_standard_poor <<- c("standard_win_lose_poor")
  negatives_index_lose_standard_poor <<- rep(T, 1)
  conditions_index_lose_standard_poor <<- rep(" > 0.1", 1)
  before_treatment_index_lose_standard_poor <<- rep(F, 1)
  
  variables_index_lose_standard_rich <<- c("standard_win_lose_rich")
  negatives_index_lose_standard_rich <<- rep(T, 1)
  conditions_index_lose_standard_rich <<- rep(" > 0.1", 1)
  before_treatment_index_lose_standard_rich <<- rep(F, 1)
  
  variables_index_fairness <<- c("standard_fair", "tax_transfers_fair", "investments_fair")
  negatives_index_fairness <<- rep(F, 3)
  conditions_index_fairness <<- rep(" > 0", 3)
  before_treatment_index_fairness <<- rep(F,3)
  
  variables_index_fairness_standard <<- c("standard_fair")
  negatives_index_fairness_standard <<- rep(F, 1)
  conditions_index_fairness_standard <<- rep(" > 0", 1)
  before_treatment_index_fairness_standard <<- rep(F,1)
  
  variables_index_fairness_tax_transfers <<- c("tax_transfers_fair")
  negatives_index_fairness_tax_transfers <<- rep(F, 1)
  conditions_index_fairness_tax_transfers <<- rep(" > 0", 1)
  before_treatment_index_fairness_tax_transfers <<- rep(F,1)
  
  variables_index_fairness_investments <<- c("investments_fair")
  negatives_index_fairness_investments <<- rep(F, 1)
  conditions_index_fairness_investments <<- rep(" > 0", 1)
  before_treatment_index_fairness_investments <<- rep(F,1)
  
  variables_index_trust_govt <<- c("can_trust_govt")
  negatives_index_trust_govt <<- rep(F, 1)
  conditions_index_trust_govt <<- rep(" > 0", 1)
  before_treatment_index_trust_govt <<- rep(F,1)
  
  variables_index_donation <<- c("donation_percent")
  negatives_index_donation <<- rep(F, 1)
  conditions_index_donation <<- rep("", 1)
  before_treatment_index_donation <<- rep(F,1)
  
  variables_index_willing_change <<- c("willing_electric_car", "willing_limit_driving", "willing_limit_flying", "willing_limit_beef", "willing_limit_heating")
  negatives_index_willing_change <<- rep(F, 5)
  conditions_index_willing_change <<- rep(" > 0", 5)
  before_treatment_index_willing_change <<- rep(F, 5)
  
  variables_index_standard_policy <<- c("standard_support", "standard_public_transport_support")
  negatives_index_standard_policy <<- rep(F, 2)
  conditions_index_standard_policy <<- rep(" > 0", 2)
  before_treatment_index_standard_policy <<- rep(F, 2)
  
  variables_index_tax_transfers_policy <<- c("tax_transfers_support")
  negatives_index_tax_transfers_policy <<- rep(F, 1)
  conditions_index_tax_transfers_policy <<- rep(" > 0", 1)
  before_treatment_index_tax_transfers_policy <<- rep(F, 1)
  
  variables_index_investments_policy <<- c("investments_support")
  negatives_index_investments_policy <<- rep(F, 1)
  conditions_index_investments_policy <<- rep(" > 0", 1)
  before_treatment_index_investments_policy <<- rep(F, 1)
  
  variables_index_effect_halt_CC_lifestyle <<- c("effect_halt_CC_lifestyle")
  negatives_index_effect_halt_CC_lifestyle <<- rep(F, 1)
  conditions_index_effect_halt_CC_lifestyle <<- rep(" > 0", 1)
  before_treatment_index_effect_halt_CC_lifestyle <<- rep(F, 1)
  
  variables_index_main_policies_all <<- c(variables_index_investments_policy, variables_index_tax_transfers_policy, variables_index_standard_policy)
  negatives_index_main_policies_all <<- c(negatives_index_investments_policy, negatives_index_tax_transfers_policy, negatives_index_standard_policy)
  conditions_index_main_policies_all <<- c(conditions_index_investments_policy, conditions_index_tax_transfers_policy, conditions_index_standard_policy)
  before_treatment_index_main_policies_all <<- c(before_treatment_index_investments_policy, before_treatment_index_tax_transfers_policy, before_treatment_index_standard_policy)
  
  variables_index_main_policies_difference <<- variables_index_main_policies <<- variables_index_main_policies_all[1:3]
  negatives_index_main_policies <<- negatives_index_main_policies_all[1:3] 
  negatives_index_main_policies_difference <<- c(T, FALSE, T)
  conditions_index_main_policies_difference <<- conditions_index_main_policies <<- conditions_index_main_policies_all[1:3]
  before_treatment_index_main_policies_difference <<- before_treatment_index_main_policies <<- before_treatment_index_main_policies_all[1:3]
  
  variables_index_beef_policies <<- c("beef_tax_support", "beef_subsidies_vegetables_support", "beef_subsidies_removal_support", "beef_ban_intensive_support")
  negatives_index_beef_policies <<- rep(F, 4)
  conditions_index_beef_policies <<- rep(" > 0", 4)
  before_treatment_index_beef_policies <<- rep(F, 4)
  
  variables_index_international_policies <<- c("global_tax_support", "global_assembly_support", "tax_1p_support")
  negatives_index_international_policies <<- rep(F, 3)
  conditions_index_international_policies <<- rep(" > 0", 3)
  before_treatment_index_international_policies <<- rep(F, 3)
  
  variables_index_other_policies <<- c("insulation_support", "policy_tax_flying", "policy_ban_city_centers", "policy_subsidies", "policy_climate_fund")
  negatives_index_other_policies <<- rep(F, 5)
  conditions_index_other_policies <<- rep(" > 0", 5)
  before_treatment_index_other_policies <<- rep(F, 5) 
  
  variables_index_all_policies <<- c(variables_index_main_policies, variables_index_beef_policies, variables_index_international_policies, variables_index_other_policies)
  negatives_index_all_policies <<- c(negatives_index_main_policies, negatives_index_beef_policies, negatives_index_international_policies, negatives_index_other_policies)
  conditions_index_all_policies <<- c(conditions_index_main_policies, conditions_index_beef_policies, conditions_index_international_policies, conditions_index_other_policies)
  before_treatment_index_all_policies <<- c(before_treatment_index_main_policies, before_treatment_index_beef_policies, before_treatment_index_international_policies, before_treatment_index_other_policies)
  
  variables_index_common_policies <<- c("standard_support", "investments_support", "tax_transfers_support", "standard_public_transport_support", "policy_tax_flying", "policy_tax_fuels", "policy_ban_city_centers", 
                                        "policy_subsidies", "policy_climate_fund", "tax_transfer_constrained_hh", "tax_transfer_poor", "tax_transfer_all", "tax_reduction_personal_tax", "tax_reduction_corporate_tax", 
                                        "tax_rebates_affected_firms", "tax_investments", "tax_subsidies", "tax_reduction_deficit", "global_assembly_support", "global_tax_support", "tax_1p_support")
  negatives_index_common_policies <<- before_treatment_index_common_policies <<- rep(F, length(variables_index_common_policies))
  conditions_index_common_policies <<- rep(" > 0", length(variables_index_common_policies))
  
  variables_index_pro_climate <<- c(variables_index_common_policies, variables_index_willing_change, variables_index_concerned_about_CC) 
  negatives_index_pro_climate <<- before_treatment_index_pro_climate <<- rep(F, length(variables_index_pro_climate))
  conditions_index_pro_climate <<- rep(" > 0", length(variables_index_pro_climate))
  
  variables_index_earmarking_vs_transfers <<- c("tax_subsidies", "tax_investments", "tax_transfer_all", "tax_transfer_poor") 
  negatives_index_earmarking_vs_transfers <<- c(F, F, T, T)
  conditions_index_earmarking_vs_transfers <<- rep(" > 0", 4)
  before_treatment_index_earmarking_vs_transfers <<- rep(F, 4) 
  
  variables_index_pro_redistribution <<- c("tax_transfer_poor", "tax_transfer_constrained_hh", "view_govt", "tax_1p_support", "problem_inequality", "investments_funding_wealth_tax")
  negatives_index_pro_redistribution <<- rep(F, 6)
  conditions_index_pro_redistribution <<- c(rep(" > 0", 5), "== T")
  before_treatment_index_pro_redistribution <<- rep(F, 6)
  
  ## 2ter. Defines the possible values of variables.
  text_strongly_agree <- c( "US" = "Strongly agree",  "US" = "I fully agree")
  text_somewhat_agree <- c( "US" = "Somewhat agree",  "US" = "I somewhat agree")
  text_neutral <- c( "US" = "Neither agree or disagree",  "US" = "Neither agree nor disagree",  "US" = "I neither agree nor disagree")
  text_somewhat_disagree <- c( "US" = "Somewhat disagree",  "US" = "I somewhat disagree")
  text_strongly_disagree <- c("US" = "Strongly disagree", "US" = "Fully disagree")
  
  text_support_strongly <- c("US" = "Yes, absolutely", "US" = "Strongly support") # first: policy / second: tax
  text_support_somewhat <- c("US" = "Yes, somewhat", "US" = "Rather support", "US" = "Somewhat support")
  text_support_indifferent <- c("US" = "Indifferent", "US" = "Neither support nor oppose")
  text_support_not_really <- c("US" = "No, not really", "US" = "Rather oppose", "US" = "Somewhat oppose")
  text_support_not_at_all <- c("US" = "No, not at all", "US" = "Strongly oppose")
  
  text_excellent <- c("US" = "Excellent")
  text_good <- c("US" = "Good")
  text_fair <- c("US" = "Fair")
  text_poor <- c("US" = "Poor")
  text_very_poor <- c("US" = "Very poor")
  
  text_male <- c("US" = "Male", "FR" = "Homme")
  text_female <- c("US" = "Female", "FR" = "Femme")
  text_other <- c("US" = "Other", "FR" = "Autre")
  
  text__18 <- c("US" = "18 to 24", "FR" = "Moins de 18 ans")
  text_18_24 <- c("US" = "18 to 24", "FR" = "Entre 18 et 24 ans")
  text_25_34 <- c("US" = "25 to 34", "FR" = "Entre 25 et 34 ans")
  text_35_49 <- c("US" = "35 to 49", "FR" = "Entre 35 et 49 ans")
  text_50_64 <- c("US" = "50 to 64", "FR" = "Entre 50 et 64 ans")
  text_65_ <- c("US" = "65 or above", "FR" = "65 ans ou plus")
  
  text_rural <- c("US" = "A rural area", "CN" = "A rural area (less than 10,000 inhabitants)",
                  "FR" = "en zone rurale")
  text_small_town <- c("US" = "A small town (between 5,000 and 20,000 inhabitants)", "US" = "A small town (5,000 – 20,000 inhabitants)", "US" = "A small town (5,000 - 20,000 inhabitants)",
                       "FR" = "dans une petite ville (entre 5 000 et 20 000 habitants)", "CN" = "A small town (10,000 – 50,000 inhabitants)")
  text_large_town <- c("US" = "A large town (between 20,000 and 50,000 inhabitants)", "US" = "A large town (20,000 – 50,000 inhabitants)", "US" = "A large town (20,000 - 50,000 inhabitants)",
                       "FR" = "dans une ville moyenne (entre 20 000 et 50 000 habitants)", "CN" = "A large town (50,000 – 100,000 inhabitants)")
  text_small_city <- c("US" = "A small city (between 50,000 and 250,000 inhabitants)", "US" = "A small city (50,000 – 250,000 inhabitants)", "CA" = "A small city or its suburbs (50,000 – 250,000 inhabitants)",
                       "FR" = "dans une grande ville (entre 50 000 et 250 000 habitants)", "CN" = "A small city or its suburbs (100,000 – 500,000 inhabitants)", "IA" = "A small city or its suburbs (50,000 – 2,50,000 inhabitants)", "US" = "A small city or its suburbs (50,000 - 250,000 inhabitants)")
  text_medium_city <- c("US" = " A medium-size city (between 250,000 and 3,000,000 inhabitants)", "US" = "A medium-sized city (250,000 – 3,000,000 inhabitants)", "PL" = "A large city (250,000 – 3,000,000 inhabitants)", "CA" = "A large city or its suburbs (250,000 – 2,000,000 inhabitants)",
                        "FR" = "dans une métropole (plus de 250 000 habitants, hors Paris)", "CN" = "A large city or its suburbs (500,000 – 1,000,000 inhabitants)", "SA" = "A large city or its suburbs (250,000 – 3,000,000 inhabitants)", "IA" = "A large city or its suburbs (2,50,000 – 30,00,000 inhabitants)", "US" = "A large city or its suburbs (250,000 to 3,000,000 inhabitants)")
  text_large_city <- c("US" = "A large city (more than 3 million inhabitants)", "PL" = "A very large city (more than 3 million inhabitants)", "SA" = "A very large city or its suburbs (more than 3 million inhabitants)", "IA" = "A very large city or its suburbs (more than 30 lakh inhabitants)",
                       "FR" = "en région parisienne", "CN" = "A very large city or its suburbs (1,000,000 – 10,000,000 inhabitants)", "CA" = "A very large city or its suburbs (more than 2 million inhabitants)")
  text_megalopolis <- c("CN" = "A megalopolis or its suburbs (more than 10 million inhabitants)")
  
  text_area_small <- c("SA" = "In a District municipality other than the District capital", "CN" = "Xiāng", "ID" = "Kota")
  text_area_middle <- c("SA" = "In a capital of a District municipality", "CN" = "Zhèn", "ID" = "In a Kabupaten outside of the Capital town")
  text_area_large <- c("SA" = "In a metropolitan municipality", "CN" = "Jiedào", "ID" = "Capital town of a Kabupaten")
  
  text_4_ <- c("US" = "4 or more", "FR" = "4 ou plus")
  text_5_ <- c("US" = "5 or more", "FR" = "5 ou plus")
  
  text_speaks_native <- c("US" = "Native")
  text_speaks_well <- c("US" = "Well or very well")
  text_speaks_somewhat <- c("US" = "Somewhat well")
  text_speaks_no <- c("US" = "I cannot speak English")
  
  # AU, CA, IT, JP, SK, ES, US, MX, TR, UK, CN, SA
  text_education_no <- c("US" = "No schooling completed", 
                         "FR" = "Aucun")
  text_education_primary <- c("US" = "Primary school", 
                              "FR" = "École primaire")
  text_education_secondary <- c("US" = "Lower secondary school", 
                                "FR" = "Brevet")
  text_education_vocational <- c("US" = "Vocational degree", 
                                 "FR" = "CAP ou BEP")
  text_education_high <- c("US" = "High school", 
                           "FR" = "Baccalauréat")
  text_education_college <- c("US" = "College degree", 
                              "FR" = "Bac +2 ou Bac +3 (licence, BTS, DUT, DEUG...)")
  text_education_master <- c("US" = "Master's degree or above", 
                             "FR" = "Bac +5 ou plus (master, école d'ingénieur ou de commerce, doctorat, médecine, maîtrise, DEA, DESS...)")
  
  # These two first sets have 7 and 6 bins: this was the case for US, DK and FR only. heating_expenses are also monthly for these countries.
  text_heating_expenses_10 <- c("US" = "Less than $20", "FR" = "Moins de 15€", "DK" = "Mindre end 125 kr.")
  text_heating_expenses_50 <- c("US" = "$20 – $75", "FR" = "De 15 à 60€", "DK" = "125 - 465 kr.")
  text_heating_expenses_100 <- c("US" = "$76 – $125", "FR" = "De 61 à 100€", "DK" = "466 - 775 kr.")
  text_heating_expenses_167 <- c("US" = "$126 – $200", "FR" = "De 101 à 165€", "DK" = "776 - 1.240 kr.")
  text_heating_expenses_225 <- c("US" = "$201 – $250", "FR" = "De 166 à 210€", "DK" = "1.241 - 1.550 kr.")
  text_heating_expenses_275 <- c("US" = "$251 – $300", "FR" = "De 211 à 350€", "DK" = "1.551 - 1.860 kr.") # we regroup the 225, 275 and 350 categories for 300
  text_heating_expenses_350 <- c("US" = "More than $300", "FR" = "Plus de 350€", "DK" = "Mere end 1.860 kr.")
  
  text_gas_expenses_0 <- c("US" = "Less than $5", "FR" = "Moins de 5€", "DK" = "Mindre end 30 kr.")
  text_gas_expenses_15 <- c("US" = "$5 – $25", "FR" = "De 5 à 20€", "DK" = "31 - 155 kr.")
  text_gas_expenses_50 <- c("US" = "$26 – $75", "FR" = "De 15 à 60€", "DK" = "156 - 460 kr.")
  text_gas_expenses_100 <- c("US" = "$76 – $125", "FR" = "De 61 à 100€", "DK" = "461 - 770 kr.")
  text_gas_expenses_150 <- c("US" = "$126 – $175", "FR" = "De 101 à 145€", "DK" = "771 - 1.100 kr.") # we regroup the 150 and 201 categories for 200
  text_gas_expenses_201 <- c("US" = "$176 – $225", "FR" = "De 146 à 185€", "DK" = "1.101 - 1.400 kr.")
  text_gas_expenses_220 <- c("US" = "More than $225", "FR" = "Plus de 185€", "DK" = "Mere end 1.400 kr.")
  # English-speaking countries surveyed with EN: CA (use CA), SA (use SA), US (use the above) / EN-GB: AU (use AU), UK (use EN)
  # These two last sets have 6 and 4 bins: they correspond to the other countries (except BR, IA, ID, MX for which the question was not asked)
  text_heating_expenses_125 <- c("EN" = "Less than $20", "US" = "Less than $20", "EU" = "Less than €250", "DK" = "Mindre end 125 kr.", "DE" = "Unter €250", "AU" = "Less than $200", "CN" = "人民币800元以下",
                                 "UA" = "Менше 2,000₴", "UK" = "Less than £200", "TR" = "2000₺'den az", "SP" = "Menos de 200 €", "SK" = "200,000원 미만", "SA" = "Less than R2,000", "ZU" = "Ngaphansi kuka- R2,000", "CA" = "Less than $200", "FR" = "Moins de 15€", "IT" = "Meno di 200€", "JP" = "20,000円未満", "PL" = "Mniej niż 1.000 zł")
  text_heating_expenses_600 <- c("EN" = "$20 – $75", "US" = "$20 – $75", "EU" = "€251 – €1,000", "DK" = "125 - 465 kr.", "DE" = "€251 – €1000", "AU" = "$201 – $800",  "CN" = "人民币800至3,000元",
                                 "UA" = "2,000₴ – 8,000₴", "UK" = "£201 – £800", "TR" = "2,000 - 8,000 ₺ arası", "SP" = "200 € - 800 €", "SK" = "200,000 – 800,000원", "SA" = "R2,000 - R8,000", "CA" = "$200 – $800", "FR" = "De 15 à 60€", "IT" = "201€ - 800€", "JP" = "20,001円 – 80,000円", "PL" = "1.001 – 3.000 zł")
  text_heating_expenses_1250 <- c("EN" = "$76 – $125", "US" = "$76 – $125", "EU" = "€1,001 – €1,500", "DK" = "466 - 775 kr.", "DE" = "€1001 – €1.500", "AU" = "$801 – $1,300",  "CN" = "人民币3,000至5,000元",
                                  "UA" = "8,000₴ – 13,000₴", "UK" = "£801 – £1,300", "TR" = "8,000 ₺ - 13,000 ₺ arası", "SP" = "800 € - 1300 €", "SK" = "800,000 – 1,300,000원", "SA" = "R8,000 - R13,000", "CA" = "$800 – $1,300", "FR" = "De 61 à 100€", "IT" = "8001€ - 1300€", "JP" = "80,001 – 130,000円", "PL" = "3.001 – 5.000 zł")
  text_heating_expenses_2000 <- c("EN" = "$126 – $200", "US" = "$126 – $200", "EU" = "€1,1501 - €2,500", "DK" = "776 - 1.240 kr.", "DE" = "€1.501 – €2.500", "AU" = "$1,301 – $2,000",  "CN" = "人民币5,000至8,000元",
                                  "UA" = "13,000₴ –20,000₴", "UK" = "£1,301 – £2,000", "TR" = "13,000 ₺ - 20,000 ₺ arası", "SP" = "1300 € - 2000 €", "SK" = "1,300,000 – 2,000,000원", "SA" = "R13,000 - R20,000", "CA" = "$1,300 – $2,000", "FR" = "De 101 à 165€", "IT" = "1301€ - 2000€", "JP" = "130,001円 – 200,000円", "PL" = "5.001 – 8.000 zł")
  text_heating_expenses_3000 <- c("EN" = "More than $300", "US" = "More than $200", "EU" = "More than €2,500", "DK" = "Mere end 1.241 kr.", "DE" = "Über €2.500", "AU" = "More than $2,000",  "CN" = "人民币8,000元以上",
                                  "UA" = "Понад 20,000₴", "UK" = "More than £2,000", "TR" = "20,000 ₺'den çok", "SP" = "Más de 2000 €", "SK" = "2,000,000원 이상", "SA" = "More than R20,000", "ZU" = "Ngaphezu kuka R20,000", "CA" = "More than $2,000", "FR" = "Plus de 166€", "IT" = "Più di 2000€", "JP" = "200,000円以上", "PL" = "Ponad 8.000 zł")
  
  text_gas_expenses_0 <- c("EN" = "Less than $5", "US" = "Less than $5", "EU" = "Less than €5", "DK" = "Mindre end 30 kr.", "DE" = "Unter €5", "AU" = "Less than $5",  "CN" = "人民币20元以下", "ID" = "Kurang dari Rp 50.000,00",
                           "UA" = "Менше 50₴", "UK" = "Less than £5", "TR" = "50 ₺'den az", "SP" = "Menos de 5 €", "SK" = "5,000원 미만", "SA" = "Less than R50", "ZU" = "Ngaphansi kuka- R50", "PL" = "Mniej niż 20 zł", "BR" = "Menos de R$20,00", "CA" = "Less than $5", "FR" = "Moins de 5€", "IT" = "Meno di 5 €", "JP" = "500円未満", "MX" = "Menos de 50 pesos")
  text_gas_expenses_20 <- c("EN" = "$5 – $25", "US" = "$5 – $25", "EU" = "€5 - €30", "DK" = "31 - 155 kr.", "DE" = "€5 - €30", "AU" = "$5 – $25",  "CN" = "人民币20至100元", "ID" = "Rp 50.001,00 - Rp 250.000,00",
                            "UA" = "50₴ – 250₴", "UK" = "£5 – £25", "TR" = "50 ₺ - 250 ₺ arası", "SP" = "5 € - 25 €", "SK" = "5,000 – 25,000원", "SA" = "R50 - R250", "PL" = "20 – 100 zł", "BR" = "R$20,00- R$100,00", "CA" = "$5 – $25", "FR" = "De 5 à 20€", "IT" = "5 €- 25 €", "JP" = "500円 – 2,500円", "MX" = "50 - 250 pesos")
  text_gas_expenses_60 <- c("EN" = "$26 – $75", "US" = "$26 – $75", "EU" = "€31 - €90", "DK" = "156 - 460 kr.", "DE" = "€31 - €90", "AU" = "$26 – $75",  "CN" = "人民币100至300元", "ID" = "Rp 250.001,00 - Rp 750.000,00",
                            "UA" = "250₴ – 750₴", "UK" = "£26 – £75", "TR" = "250 ₺ - 750 ₺ arası", "SP" = "26 € - 75 €", "SK" = "25,000 – 75,000원", "SA" = "R250 - R750", "PL" = "101 – 300 zł", "BR" = "R$100,00 - R$300,00", "CA" = "$26 – $75", "FR" = "De 15 à 60€", "IT" = "26 €- 75 €", "JP" = "2,501円 – 7,500円", "MX" = "250 -750 pesos")
  text_gas_expenses_120 <- c("EN" = "$76 – $125", "US" = "$76 – $125", "EU" = "€91 - €150", "DK" = "461 - 770 kr.", "DE" = "€91 - €150", "AU" = "$76 – $125",  "CN" = "人民币300至500元", "ID" = "Rp 750.001,00 - Rp 1.300.000,00",
                             "UA" = "750₴ – 1250₴", "UK" = "£76 – £125", "TR" = "750 ₺ - 1,250 ₺ arası", "SP" = "76 € - 125 €", "SK" = "75,000 – 125,000원", "SA" = "R750 - R1,250", "PL" = "301 – 500 zł", "BR" = "R$300,00 - R$500,00", "CA" = "$76 – $125", "FR" = "De 61 à 100€", "IT" = "76 €- 125 €", "JP" = "7,501円 – 13,000円", "MX" = "750 - 1250 pesos")
  text_gas_expenses_200 <- c("EN" = "$126 – $175", "US" = "$126 – $225", "EU" = "€151 - €250", "DK" = "771 - 1.400 kr.", "DE" = "€151 - €250", "AU" = "$126 – $200",  "CN" = "人民币500至800元", "ID" = "Rp 1.300.001,00 - Rp 2.000.000,00",
                             "UA" = "1250₴ – 2000₴", "UK" = "£126 – £200", "TR" = "1,250 ₺ - 2,000 ₺ arası", "SP" = "126 € - 200 €", "SK" = "125,000 – 200,000원", "SA" = "R1,250 - R2,000", "PL" = "501 – 800 zł", "BR" = "R$500,00 - R$800,00", "CA" = "$126 – $200", "FR" = "De 101 à 185€", "IT" = "126 €- 200 €", "JP" = "13,001円 – 20,000円", "MX" = "1250 - 2000 pesos")
  text_gas_expenses_300 <- c("EN" = "More than $225", "US" = "More than $225", "EU" = "More than €250", "DK" = "Mere end 1.400 kr.", "DE" = "Über €250", "AU" = "More than $200",  "CN" = "人民币800元以上", "ID" = "Lebih dari Rp 2.000.000,00",
                             "UA" = "Понад 2000₴", "UK" = "More than £200", "TR" = "2,000 ₺'den fazla", "SP" = "Más de 200 €", "SK" = "200,000원 이상", "SA" = "More than R2,000", "ZU" = "Ngaphezulu kuka R2,000", "PL" = "Więcej niż 800 złotych", "BR" = "Mais de R$800,00", "CA" = "More than $200", "FR" = "Plus de 185€", "IT" = "Più di 200 €", "JP" = "20,000円以上", "MX" = "Más de 2000 pesos")
  
  text_income_q1 <<- c("US" = "less than $35,000", "FR" = "Moins de 35,000€/mois", "AU" = "less than $51,000", "less than $10,000", "between $10,000 and $20,000", "between $20,000 and $25,000", "15", "22", "SA" = "between R10,000 and R20,000 per month", "SA" = "between R20,000 and R25,000 per month", "SA" = "less than R10,000 per month", 
                       "US" = "less than $16,000", "US" = "between $16,000 and $28,000", "US" = "between $28,000 and $35,000", "CA" = "less than CA$10,000", "CA" = "between CA$10,000 and CA$20,000", "CA" = "between CA$20,000 and CA$25,000", "US" = "$25,000 - $34,999", "US" = "$15,000 - $24,999", "US" = "$0 - $14,999",
                       "CA" = "less than CA$22,000", "IA" = "less than ₹50,000", "SA" = "less than R35,000 per month", "UK" = "less than £35,000", "IA" = "between ₹10,000 and ₹20,000", "IA" = "between ₹20,000 and ₹25,000", "IA" = "less than ₹10,000", "ID" = "5", "ID" = "11", "ID" = "12")
  text_income_q2 <<- c("US" = "between $35,000 and $70,000", "FR" = "Entre 35,000 et 70,000€/mois", "AU" = "between $51,000 and $80,000", "between $25,000 and $30,000", "between $30,000 and $40,000", "between $40,000 and $50,000", "35", "45", "SA" = "between R25,000 and R30,000 per month", "SA" = "between R30,000 and R40,000 per month", "SA" = "between R40,000 and R50,000 per month", 
                       "US" = "between $35,000 and $41,000", "US" = "between $41,000 and $54,000", "US" = "between $54,000 and $70,000", "CA" = "between CA$25,000 and CA$30,000", "CA" = "between CA$30,000 and CA$40,000", "CA" = "between CA$40,000 and CA$50,000",  "US" = "$60,000 - $69,999", "US" = "$50,000 - $59,999", "US" = "$35,000 - $49,999",
                       "CA" = "between CA$22,000 and CA$39,000", "IA" = "between ₹50,000 and ₹100,000", "SA" = "between R35,000 and R70,000 per month", "IA" = "between ₹25,000 and ₹30,000", "IA" = "between ₹30,000 and ₹40,000", "IA" = "between ₹40,000 and ₹50,000", "ID" = "6", "ID" = "13", "ID" = "14")
  text_income_q3 <<- c("US" = "between $70,000 and $120,000", "FR" = "Entre 70,000 et 120,000€/mois", "AU" = "between $80,000 and $122,000", "between $50,000 and $60,000", "between $60,000 and $70,000", "between $70,000 and $75,000", "65", "72", "SA" = "between R50,000 and R60,000 per month", "SA" = "between R60,000 and R70,000 per month", "SA" = "between R70,000 and R75,000 per month", 
                       "US" = "between $70,000 and $87,000", "US" = "between $87,000 and $110,000", "US" = "between $110,000 and $120,000", "CA" = "between CA$50,000 and CA$60,000", "CA" = "between CA$60,000 and CA$70,000", "CA" = "between CA$70,000 and CA$75,000",  "US" = "$100,000 - $119,999", "US" = "$80,000 - $99,999", "US" = "$70,000 - $79,999",
                       "CA" = "between CA$39,000 and CA$74,000", "IA" = "between ₹100,000 and ₹200,000", "SA" = "between R70,000 and R120,000 per month", "IA" = "between ₹50,000 and ₹60,000", "IA" = "between ₹60,000 and ₹70,000", "IA" = "between ₹70,000 and ₹75,000", "IA" = "between ₹60,000 and ₹<span class=d7\">70,000", "ID" = "8", "ID" = "15", "ID" = "16")
  text_income_q4 <<- c("US" = "more than $120,000", "FR" = "Plus de 120,000€/mois", "AU" = "more than $122,000", "between $75,000 and $80,000", "between $80,000 and $90,000", "more than $90,000", "85", "95",  "US" = "more than $200,000", "US" = "$150,000 - $199,999", "US" = "$120,000 - $149,999",# TODO! check income missing
                       "US" = "between $120,000 and $143,000", "US" = "between $143,000 and $200,000", "US" = "more than $200,000", "CA" = "between CA$75,000 and CA$80,000", "CA" = "between CA$80,000 and CA$90,000", "CA" = "more than CA$90,000", "SA" = "more than R90,000 per month", "SA" = "between R75,000 and R80,000 per month", "SA" = "between R80,000 and R90,000 per month", 
                       "CA" = "more than CA$74,000", "IA" = "more than ₹200,000", "SA" = "more than R120,000 per month", "IA" = "between ₹75,000 and ₹80,000", "IA" = "between ₹80,000 and ₹90,000", "IA" = "more than ₹90,000", "ID" = "9", "ID" = "17", "ID" = "18")
  
  text_wealth_q1 <- c("US" = "Less than $0 (I have a net debt)", "FR" = "Moins de 10 000€", "CA" = "Less than CA$20,000",
                      "AU" = "Less than $70,000", "IA" = "Less than ₹2,00,000", "SA" = "Less than R0 (I have a net debt)")
  text_wealth_q2 <- c("US" = "Close to $0", "FR" = "Entre 10 001€ et 60 000€", "CA" = "Between CA$20,000 and CA$150,000",
                      "AU" = "Between $70,000 and $300,000", "IA" = "Between ₹2,00,000 and ₹5,00,000", "SA" = "Between R0 and R80,000")
  text_wealth_q3 <- c("US" = "Between $4,000 and $120,000", "FR" = "Entre 60 001€ et 180 000€", "CA" = "Between CA$150,000 and CA$350,000",
                      "AU" = "Between $300,000 and $550,000", "IA" = "Between ₹5,00,000 and ₹10,00,000", "SA" = "Between R80,000 and R160,000")
  text_wealth_q4 <- c("US" = "Between $120,000 and $380,000", "FR" = "Entre 180 001€ et 350 000€", "CA" = "Between CA$350,000 and CA$700,000",
                      "AU" = "Between $550,000 and $1,000,000", "IA" = "Between ₹10,00,000 and ₹20,00,000", "SA" = "Between R160,000 and R500,000")
  text_wealth_q5 <- c("US" = "More than $380,000", "FR" = "Plus de 350 001€", "CA" = "More than CA$700,000",
                      "AU" = "More than $1,000,000", "IA" = "More than ₹20,00,000", "SA" = "More than R500,000")
  
  text_full_time <- c("US" = "Full-time employed", "FR" = "Employé⋅e à temps plein")
  text_part_time <- c("US" = "Part-time employed", "FR" = "Employé⋅e à temps partiel")
  text_self_employed <- c("US" = "Self-employed", "FR" = "Indépendant⋅e", "US_cs" = "Self-employed or small business owner")
  text_student <- c("US" = "Student", "FR" = "Étudiante⋅e")
  text_retired <- c("US" = "Retired", "FR" = "Retraité⋅e")
  text_unemployed <- c("US" = "Unemployed (searching for a job)", "FR" = "Au chômage (en recherche d'emploi)", "US_cs" = "Unemployed and looking for a job")
  text_inactive <- c("US" = "Inactive (not searching for a job)", "FR" = "Inactif (sans recherche d'emploi)", "US_cs" = "Not currently working and not looking for a job")
  
  text_frequency_beef_daily <- c("US" = "Almost or at least daily")
  text_frequency_beef_weekly <- c("US" = "One to four times per week")
  text_frequency_beef_rarely <- c("US" = "Less than once a week")
  text_frequency_beef_never <- c("US" = "Never")
  
  text_transport_available_yes_easily <- c("US" = "Yes, public transport is easily and frequently available")
  text_transport_available_yes_limited <- c("US" = "Yes, public transport is available but with limitations")
  text_transport_available_not_so_much <- c("US" = "Not so much, public transport is available but with many limitations")
  text_transport_available_not_at_all <- c("US" = "No, there is no public transport")
  
  text_none <- c("US" = "None")
  text_a_little <- c("US" = "A little")
  text_some <- c("US" = "Some")
  text_a_lot <- c("US" = "A lot")
  text_most <- c("US" = "Most")
  
  text_intensity_not <- c("US" = "Not at all")
  text_intensity_little <- c("US" = "A little")
  text_intensity_some <- c("US" = "Moderately")
  text_intensity_lot <- c("US" = "A lot")
  text_intensity_great_deal <- c("US" = "A great deal")
  
  text_very_unlikely <- c("US" = "Very unlikely")
  text_somewhat_unlikely <- c("US" = "Somewhat unlikely")
  text_somewhat_likely <- c("US" = "Somewhat likely")
  text_very_likely <- c("US" = "Very likely")
  
  text_very_negative_effects <- c("US" = "Very negative effects")
  text_negative_effects <- c("US" = "Somewhat negative effects")
  text_no_effects <- c("US" = "No noticeable effects")
  text_positive_effects <- c("US" = "Somewhat positive effects")
  text_very_positive_effects <- c("US" = "Very positive effects")
  
  text_trust_govt_always <- c("US" = "Nearly all the time")
  text_trust_govt_often <- c("US" = "Most of the time")
  text_trust_govt_sometimes <- c("US" = "Only some of the time")
  text_trust_govt_never <- c("US" = "Never")
  
  text_inequality_not <- c("US" = "Not a problem at all")
  text_inequality_small <- c("US" = "A small problem")
  text_inequality_problem <- c("US" = "A problem")
  text_inequality_serious <- c("US" = "A serious problem")
  text_inequality_very_serious <- c("US" = "A very serious problem")
  
  text_future_richer <- c("US" = "Richer, for example thanks to technological progress")
  text_future_poorer <- c("US" = "Poorer, for example due to resource depletion and/or climate change")
  text_future_as_rich <- c("US" = "About as rich as now on average")
  
  text_much_richer <- c("US" = "Much richer")
  text_richer <- c("US" = "Richer")
  text_as_rich <- c("US" = "As rich as now")
  text_poorer <- c("US" = "Poorer")
  text_much_poorer <- c("US" = "Much poorer")
  
  text_envi_pro_envi <- c("US" = "We should make our society as sustainable as possible to avoid irreversible damages")
  text_envi_anti_envi <- c("US" = "I believe we have more important goals than sustainability")
  text_envi_progress <- c("US" = "Our civilization will develop so much that environmental issues will not be a problem in the distant future")
  text_envi_collapse <- c("US" = "Our civilization will eventually collapse, it is useless to try making society more sustainable")
  
  text_CC_exists_not <- c("US" = "is not a reality")
  text_CC_exists_natural <- c("US" = "is mainly due to natural climate variability")
  text_CC_exists_human <- c("US" = "is mainly due to human activity")
  
  text_CC_dynamics_rise <- c("US" = "temperatures will continue to rise, just more slowly")
  text_CC_dynamics_stabilize <- c("US" = "temperatures will stabilize")
  text_CC_dynamics_decrease <- c("US" = "temperatures will decrease")
  text_CC_dynamics_none <- c("US" = "none of the above: greenhouse gas emissions have no impact on temperatures")
  
  text_CC_stoppable_no_influence <- c("US" = "Humans have no noticeable influence on the climate.")
  text_CC_stoppable_adapt <- c("US" = "We'd better live with climate change rather than try to halt it. Stopping emissions would cause more harm than climate change itself.", "US" = "We’d better live with climate change rather than try to halt it. Stopping emissions would cause more harm than climate change itself.")
  text_CC_stoppable_pessimistic <- c("US" = "We should stop emissions, but unfortunately this is not going to happen.")
  text_CC_stoppable_policies <- c("US" = "Ambitious policies and raising awareness will eventually succeed in stopping emissions within the next century.")
  text_CC_stoppable_optimistic <- c("US" = "Technologies and habits are changing and this will suffice to prevent disastrous climate change. We do not need ambitious policies.")
  
  text_CC_talks_yearly <- c("US" = "Several times a year")
  text_CC_talks_monthly <- c("US" = "Several times a month")
  text_CC_talks_never <- c("US" = "Almost never")
  
  text_CC_impacts_insignificant <- c("US" = "Insignificant, or even beneficial")
  text_CC_impacts_small <- c("US" = "Small, because humans would be able to live with it")
  text_CC_impacts_grave <- c("US" = "Grave, because there would be more natural disasters")
  text_CC_impacts_disastrous <- c("US" = "Disastrous, lifestyles would be largely altered")
  text_CC_impacts_cataclysmic <- c("US" = "Cataclysmic, humankind would disappear")
  
  text_equal_quota_yes <- c("US" = "Yes, this would be a fair solution")
  text_equal_quota_no_grand_fathering <- c("US" = "No, those who currently pollute more should have more rights to pollute")
  text_equal_quota_no_redistribution <- c("US" = "No, the poor or those who will be hurt more by climate change should be compensated more")
  text_equal_quota_no_scale <- c("US" = "No, rights to pollute should not be defined at the individual level but at another level, for example at the country level")
  text_equal_quota_no_restriction <- c("US" = "No, we should not restrict greenhouse gas emissions")
  
  text_should_act_yes <- c("US" = "Yes")
  text_should_act_depends <- c("US" = "It depends: only if it is part of a fair international agreement")
  text_should_act_no <- c("US" = "No, by no means")
  
  text_should_act_condition_compensation <- c("US" = "The US should take even more ambitious measures if other countries are less ambitious")
  text_should_act_condition_reciprocity <- c("US" = "The US should take even more ambitious measures if other countries also take similar measures")
  text_should_act_condition_free_riding <- c("US" = "The US should be less ambitious if other countries take ambitious measures")
  
  text_effects_positive <- c("US" = "Positive impacts", "US" = "Positive side effects")
  text_effects_no_impact <- c("US" = "No notable impact", "US" = "No notable side effects")
  text_effects_negative <- c("US" = "Negative impacts", "US" = "Negative side effects")
  
  text_incidence_win <- c("US" = "Would win", "US" = "Win")
  text_incidence_lose <- c("US" = "Would lose", "US" = "Would be lose", "US" = "Lose")
  text_incidence_unaffected <- c("US" = "Would not be severely affected", "US" = "Neither win nor lose", "US" = "Be unaffected")
  
  text_win_a_lot <- c("US" = "Win a lot")
  text_mostly_win <- c("US" = "Mostly win")
  text_mostly_lose <- c("US" = "Mostly lose")
  text_lose_a_lot <- c("US" = "Lose a lot")
  text_unaffected <- c("US" = "Neither win nor lose")
  
  text_much_more <- c("US" = "Much more")
  text_more <- c("US" = "More")
  text_same <- c("US" = "About the same")
  text_less <- c("US" = "Less")
  text_much_less <- c("US" = "Much less")
  
  text_govt_do_too_much <- c("US" = "Government is doing too much")
  text_govt_doing_right <- c("US" = "Government is doing just the right amount")
  text_govt_should_do_more <- c("US" = "Government should do more")
  
  text_issue_not <- c("US" = "Not an issue at all")
  text_issue_small <- c("US" = "A small issue")
  text_issue_issue <- c("US" = "An issue")
  text_issue_serious <- c("US" = "A serious issue")
  text_issue_very_serious <- c("US" = "A very serious issue")
  
  text_CC_worries_very <- c("US" = "Very worried")
  text_CC_worries_worried <- c("US" = "Worried")
  text_CC_worries_not <- c("US" = "Not worried")
  text_CC_worries_not_at_all <- c("US" = "Not worried at all")
  
  text_insulation_mandatory <- c("US" = "Mandatory: every building should be renovated before a certain date")
  text_insulation_voluntary <- c("US" = "Voluntary: an owner should be able to not renovate their house")
  
  # first: 1000km / second: 3000km / third: one_trip
  text_flight_quota_rationing <- c("US" = "No one would be allowed to fly more than 12,000 miles between now and 2040.", "US" = "No one would be allowed to fly more than 40,000 miles between now and 2040.",
                                   "US" = "No one would be allowed to fly more than one round-trip every two years.")
  text_flight_quota_tradable <- c("US" = "Those who plan to not fly within a given year would be allowed to sell their “right to fly” to someone who wants to fly but has already reached their quota of 12,000 miles.",
                                  "US" = "Those who plan to not fly within a given year would be allowed to sell their “right to fly” to someone who wants to fly but has already reached their quota of 40,000 miles.",
                                  "US" = "Those who plan to not fly within a two-year period would be allowed to sell their “right to fly” to someone who wants to fly more than once during these two years.")
  
  text_ban_incentives_force <- c("US" = "Governments should force people to protect the environment, even if it prevents people from doing what they want")
  text_ban_incentives_encourage <- c("US" = "Governments should only encourage people to protect the environment, even if it means people do not always do the right thing")
  
  text_interest_politics_no <- c("US" = "Not really or not at all")
  text_interest_politics_little <- c("US" = "A little")
  text_interest_politics_lot <- c("US" = "A lot")
  
  text_very_liberal <- c("US" = "Very liberal")
  text_liberal <- c("US" = "Liberal")
  text_moderate <- c("US" = "Moderate")
  text_conservative <- c("US" = "Conservative")
  text_very_conservative <- c("US" = "Very conservative")
  
  text_media_TV_public <- c("US" = "TV (mostly public broadcasting channels)")
  text_media_TV_private <- c("US" = "TV (mostly private channels)")
  text_media_radio <- c("US" = "Radio")
  text_media_social <- c("US" = "Social media (e.g., Facebook, Twitter, etc.)")
  text_media_print <- c("US" = "Print media (e.g., print newspapers, magazines etc.)")
  text_media_web <- c("US" = "News websites (e.g. online newspapers)")
  text_media_other <- c("US" = "Other")
  
  text_vote_participation_no_right <- c("US" = "I don't have the right to vote in the US", "I don't have the right to vote in [Country]",
                                        "US" = "I didn't have the right to vote in the US", "I didn't have the right to vote in [Country]", 
                                        "US" = "I don't have the right to vote in the U.S.",
                                        "US" = "I didn't have the right to vote in the U.S.")
  
  text_survey_biased_no <- c("US" = "No, I do not feel it was biased")
  text_survey_biased_pro_envi <- c("US" = "Yes, biased towards environmental causes")
  text_survey_biased_anti_envi <- c("US" = "Yes, biased against the environment")
  text_survey_biased_left <- c("US" = "Yes, left-wing biased")
  text_survey_biased_right <- c("US" = "Yes, right-wing biased")
  
  text_independent <- c("US" = "Manager or independent (e.g. manager, executive, health or independent professional, teacher, lawyer, architect, researcher, artist...)")
  text_clerc <- c("US" = "Clerical support or services (e.g. caring, sales, leisure, administrative...)")
  text_skilled <- c("US" = "Skilled work (e.g. craft worker, plants and machine operator, farmer...)")
  text_manual <- c("US" = "Manual operations (e.g. cleaning, agriculture, delivery, transport, military...)")
  text_none_above <- c("US" = "None of the above")
  
  text_know_temperature_2100 <- c("US" = "8 °F", "UK" = "4 °C")
  text_know_local_damage <- c("US" = "70 days per year", "FR" = "Ozone hole", "DK" = "Ozone hole")
  text_know_standard <- c("US" = "A limit on CO2 emissions from cars")
  text_know_investments_jobs <- c("US" = "1.5 million people")
  text_know_ban <- c("US" = "A ban on combustion-engine cars")
  text_know_investments_funding <- c("US" = "Additional government debt")
  
  text_sector_no <- c("US" = "No, none of the above")
  
  text_college_border <- c("US" = "2-year college degree or associates degree (for example: AA, AS)", "US" = "Some college, no degree", "AU" = "Certificate IV", "UK" = "Higher vocational education (Level 4+ award, level 4+ certificate, level 4+ diploma, higher apprenticeship, etc.)", "CA" = "Apprenticeship program of 3 or 4 years", 
                           "IT" = "Higher Technical Diploma (ITS) / Higher Technical Specialization Certificate (IFTS)", "JP" = "Short-term college", "JP" = "Technical short-term college", "SK" = "College dropout", "SP" = "Medium professional training", "TR" = "High school graduate or Vocational or Technical High School graduate",
                           "CN" = "Secondary school education pre university type", "SA" = "N6 NATED part-qualification or National N Diploma")
  text_college_strict <- c("US" = "Bachelor's degree (for example: BA, BS)", "US" = "Master’s degree (for example: MA, MS, MEng, MEd, MSW, MBA)", "US" = "Professional degree beyond bachelor’s degree (for example: MD, DDS, DVM, LLB, JD)", "US" = "Doctorate degree (for example, PhD, EdD)",
                           "AU" = "Advanced Diploma, Diploma, Associate Degree", "AU" = "Bachelor's Degree", "AU" = "Graduate Diploma, Graduate Certificate", "AU" = "Postgraduate Degree (Honours, Master's or Doctoral Degree)",
                           "UK" = "Bachelor's Degree (BA, BSc, BEng, etc.)", "UK" = "Postgraduate diploma or certificate", "UK" = "Master's Degree (MSc, MA, MBA, etc.) or Ph.D.", "CA" = "Master's degree or Doctorate", "CA" = "Bachelor's degree (3 or 4 years)", "CA" = "Postsecondary general career, technical or professional program (Technical diploma)",
                           "IT" = "Bachelor", "IT" = "Master's degree or higher", "JP" = "Professional Graduate School", "JP" = "College", "JP" = "Master", "JP" = "Doctorate", 
                           "MX" = "Master's or Specialty or Doctorate", "MX" = "University degree", "MX" = "Higher professional training (Bachelor's Degree, Higher University Technician)", "SK" = "University graduation", "SK" = "Drop out of graduate school", "SK" = "Graduate school",
                           "SP" = "Higher professional training", "SP" = "University degree", "SP" = "Master or PhD", "TR" = "Associate's degree", "TR" = "Licence", "TR" = "Master's degree or higher", "CN" = "Incomplete university education", "CN" = "University education",
                           "SA" = "Bachelor's Degree", "SA" = "Diploma, Advanced Diploma (AD), Higher Certificate or Advanced Certificate (AC)", "SA" = "Bachelor's Honours or Postgraduate Diploma (PGD)", "SA" = "Master's Degree or Doctorate") 
  
  ## 3. Converts variables to an appropriate format/class, generally associating a numerical value to a string, and defines derivate variables.
  if ("attention_test" %in% names(e)) e$attentive <- e$attention_test %in% text_a_little
  
  if (grepl("compl", wave)) e$treatment <- "None"
  
  for (v in intersect(names(e), c(variables_burden_sharing, variables_burden_share, variables_policies_effect, variables_policies_fair, "should_fight_CC", "can_trust_people", "can_trust_govt", "trust_public_spending", "CC_problem"))) { 
    temp <-  2 * (e[[v]] %in% text_strongly_agree) + (e[[v]] %in% text_somewhat_agree) - (e[[v]] %in% text_somewhat_disagree) - 2 * (e[[v]] %in% text_strongly_disagree) - 0.1 * (e[[v]] %in% text_pnr | is.na(e[[v]]))
    e[[v]] <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                               names = c("Strongly disagree","Somewhat disagree","Neither agree or disagree","Somewhat agree","Strongly agree","PNR")),
                      missing.values=-0.1, annotation=Label(e[[v]]))
  }
  
  for (v in intersect(names(e), c(variables_CC_impacts, "will_insulate", "CC_will_end"))) { 
    temp <-  2 * (e[[v]] %in% text_very_likely) + (e[[v]] %in% text_somewhat_likely) - (e[[v]] %in% text_somewhat_unlikely) - 2 * (e[[v]] %in% text_very_unlikely) - 0.1 * (e[[v]] %in% text_pnr | is.na(e[[v]])) 
    e[[v]] <- as.item(temp, labels = structure(c(-2,-1,1,2,-0.1),
                                               names = c("Very unlikely","Somewhat unlikely","Somewhat likely","Very likely","PNR")),
                      missing.values=c(-0.1,NA), annotation=Label(e[[v]])) 
  }
  for (v in intersect(names(e), c(variables_obstacles_insulation, "will_insulate"))) e[[v]][e$home_landlord==F & e$home_owner==F] <- NA # Questions not asked for non-owners
  e$owner <- e$home_owner == T | e$home_landlord == T
  label(e$owner) <- "owner: Owner or Landlord renting out property to: Are you a homeowner or a tenant?"
  
  for (v in intersect(names(e), c(variables_responsible_CC, variables_willing, variables_condition, "CC_knowledgeable", "net_zero_feasible", "CC_affects_self", "pro_ambitious_policies", "effect_halt_CC_lifestyle", "interested_politics"))) { 
    temp <-  2 * (e[[v]] %in% text_intensity_great_deal) + (e[[v]] %in% text_intensity_lot) - (e[[v]] %in% text_intensity_little) - 2 * (e[[v]] %in% text_intensity_not) - 0.1 * (e[[v]] %in% text_pnr | is.na(e[[v]])) 
    e[[v]] <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                               names = c("Not at all","A little","Moderately","A lot","A great deal","PNR")),
                      missing.values=-0.1, annotation=Label(e[[v]]))
  }
  
  if ("insulation_mandatory_support_no_priming" %in% names(e)) {
    e$insulation_disruption_variant <- ifelse(is.na(e$insulation_mandatory_support_no_priming), T, F)
    label(e$insulation_disruption_variant) <- "insulation_disruption_variant: Random priming that insulation cause disruption: 'Insulating your home can take long, may cause disruptions to your daily life during the renovation works, and may even require you to leave your home until the renovation is completed.'"
    e$insulation_support <- ifelse(e$insulation_disruption_variant, e$insulation_mandatory_support_priming, e$insulation_mandatory_support_no_priming)
    annotation(e$insulation_support) <- "insulation_support: [with or without priming] Imagine that the [country] government makes it mandatory for all residential buildings to have insulation that meets a certain energy efficiency standard before 2040. [Priming if insulation_mandatory_support_priming] The government would subsidize half of the insulation costs to help households with the transition. Do you support or oppose such policy?"
  }
  
  for (v in c(variables_policy , variables_tax, variables_support, "insulation_support", "global_quota", variables_gas_spike, variables_fine_support)) { 
    if (v %in% names(e)) {
      temp <-  2 * (e[[v]] %in% text_support_strongly) + (e[[v]] %in% text_support_somewhat) - (e[[v]] %in% text_support_not_really) - 2 * (e[[v]] %in% text_support_not_at_all) - 0.1 * (e[[v]] %in% text_pnr) 
      temp[is.na(e[[v]])] <- NA
      e[[v]] <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                 names = c("Strongly oppose","Somewhat oppose","Indifferent","Somewhat support","Strongly support","PNR")),
                        missing.values=c(-0.1,NA), annotation=Label(e[[v]])) 
    } }
  if ("policy_climate_fund" %in% names(e)) annotation(e$policy_climate_fund) <- "policy_climate_fund: Do you support or oppose the following climate policies? - [depending on whether country %in% poor_countries] OECD, BR, CN: A contribution to a global climate fund to finance clean energy in low-income countries / IA, ID, SA, UA: Assistance from high-income countries to finance clean energy in [Country]"
  
  if (country == "DK") temp <- (e$urbanity %in% text_large_town) + 2 * (e$urbanity %in% text_small_city) + 3 * (e$urbanity %in% text_medium_city) + 4 * (e$urbanity %in% text_large_city) + 5 * (e$urbanity == "Copenhagen")
  else temp <-  (e$urbanity %in% text_small_town) + 2 * (e$urbanity %in% text_large_town) + 3 * (e$urbanity %in% text_small_city) + 4 * (e$urbanity %in% text_medium_city) + 5 * (e$urbanity %in% c(text_large_city, text_megalopolis))
  e$urbanity <- as.item(temp, labels = structure(c(0:5), names = c("Rural","5-20k","20-50k","50-250k","250k-3M",">3M")), 
                        annotation=paste(Label(e$urbanity), "(Beware, the bins are not defined the same way in each country: e.g. for DK, 5/20/50/250/3M are replaced by 1/10/20/100/1.2M)"))
  
  e$size_agglo <- e$urbanity
  e$size_agglo[e$urbanity == 5 & e$country %in% c("DK", "IT", "PL", "UA")] <- 4
  e$size_agglo[e$urbanity == 4 & e$country == "DK"] <- 3
  e$size_agglo[e$urbanity == 3 & e$country == "DK"] <- 2
  e$size_agglo[e$urbanity == 3 & e$country == "CN"] <- 4
  e$size_agglo[e$urbanity == 2 & e$country == "CN"] <- 3
  e$size_agglo[e$urbanity == 1 & e$country == "CN"] <- 2
  e$size_agglo <- as.item(e$size_agglo, labels = structure(c(0:5), names = c("Rural","5-20k","20-50k","50-250k","250k-3M",">3M")), 
                          annotation=paste(Label(e$urbanity), "... (similar to urbanity but harmonized across countries: re-coded in bins 5k/20k/50k/250k/3M, by assuming 1M -> 250k (DK, IT, PL, UA), 2M -> 3M (CA), DK: 20k -> 50k, 100k -> 250k, and CN: </>10k -> 5k/20k, 100k -> 250k, 1M -> 3M).")) #  100k -> 50k (DK)
  
  if ("speaks_well" %in% names(e)) temp <-  (e$speaks_well %in% text_speaks_well) + 2 * (e$speaks_well %in% text_speaks_native) - 1 * (e$speaks_well %in% text_speaks_no) 
  if ("speaks_well" %in% names(e)) e$speaks_well <- as.item(temp, labels = structure(c(-1:2),
                                                                                     names = c("Cannot speak","Somewhat well","Well or very well","Native")),
                                                            annotation=Label(e$speaks_well))
  
  e <- create_education(e, country, only = FALSE)
  
  e$income_original <- e$income
  temp <-  (e$income %in% text_income_q1) + 2 * (e$income %in% text_income_q2) + 3 * (e$income %in% text_income_q3) + 4 * (e$income %in% text_income_q4) 
  e$income <- as.item(temp, labels = structure(c(1:4), names = c("Q1","Q2","Q3","Q4")),  annotation=Label(e$income))
  
  if ("wealth" %in% names(e)) {
    temp <-  (e$wealth %in% text_wealth_q1) + 2 * (e$wealth %in% text_wealth_q2) + 3 * (e$wealth %in% text_wealth_q3) + 4 * (e$wealth %in% text_wealth_q4) + 5 * (e$wealth %in% text_wealth_q5) 
    e$wealth <- as.item(temp, labels = structure(c(1:5), names = c("Q1","Q2","Q3","Q4","Q5")), annotation=Label(e$wealth))
  }
  temp <-  -1*(e$frequency_beef %in% text_frequency_beef_never) + 1 * (e$frequency_beef %in% text_frequency_beef_weekly) + 2 * (e$frequency_beef %in% text_frequency_beef_daily) 
  e$frequency_beef <- as.item(temp, labels = structure(c(-1:2), names = c("Never", "Rarely", "Weekly", "Daily")), annotation=Label(e$frequency_beef))
  
  for (v in c("insulation", "availability_transport")) { 
    if (v %in% names(e)) {
      temp <-  2 * (e[[v]] %in% text_excellent) + (e[[v]] %in% text_good) - (e[[v]] %in% text_poor) - 2 * (e[[v]] %in% text_very_poor) - 0.1 * (e[[v]] %in% text_pnr | is.na(e[[v]]))
      e[[v]] <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Very poor", "Poor", "Fair", "Good", "Excellent", "PNR")),
                        missing.values=-0.1, annotation=Label(e[[v]])) 
    } }
  
  if ("CC_anthropogenic" %in% names(e)) temp <- 2 * (e$CC_anthropogenic %in% text_most) + (e$CC_anthropogenic %in% text_a_lot) - (e$CC_anthropogenic %in% text_a_little) - 2 * (e$CC_anthropogenic %in% text_none | e$CC_real %in% 'No') - 0.1 * ((e$CC_anthropogenic %in% text_pnr | is.na(e$CC_anthropogenic)) & e$CC_real %in% 'Yes')
  if ("CC_anthropogenic" %in% names(e)) e$CC_anthropogenic <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("None", "A little", "Some", "A lot", "Most", "PNR")),
                                                                      missing.values=-0.1, annotation=Label(e$CC_anthropogenic))
  
  
  if ("effect_halt_CC_economy" %in% names(e)) temp <- 2 * (e$effect_halt_CC_economy %in% text_very_positive_effects) + (e$effect_halt_CC_economy %in% text_positive_effects) - (e$effect_halt_CC_economy %in% text_negative_effects) - 2 * (e$effect_halt_CC_economy %in% text_very_negative_effects) - 0.1 * (e$effect_halt_CC_economy %in% text_pnr | is.na(e$effect_halt_CC_economy))
  if ("effect_halt_CC_economy" %in% names(e)) e$effect_halt_CC_economy <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                                                                           names = c("Very negative", "Negative", "None", "Positive", "Very positive", "PNR")),
                                                                                  missing.values=-0.1, annotation=Label(e$effect_halt_CC_economy))
  
  
  for (v in intersect(names(e), c("if_other_do_more", "if_other_do_less"))) {
    temp <- 2 * (e[[v]] %in% text_much_more) + (e[[v]] %in% text_more) - (e[[v]] %in% text_less) - 2 * (e[[v]] %in% text_much_less) - 0.1 * (e[[v]] %in% text_pnr | is.na(e[[v]]))
    e[[v]] <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Much less", "Less", "About the same", "More", "Much more", "PNR")),
                      missing.values=-0.1, annotation=Label(e[[v]])) }
  
  if ("view_govt" %in% names(e)) temp <- (e$view_govt %in% text_govt_should_do_more) - (e$view_govt %in% text_govt_do_too_much) - 0.1 * (e$view_govt %in% text_pnr | is.na(e$view_govt))
  if ("view_govt" %in% names(e)) e$view_govt <- as.item(temp, labels = structure(c(-1:1,-0.1), names = c("Does too much", "Doing right amount", "Should do more", "PNR")),
                                                        missing.values=-0.1, annotation=Label(e$view_govt))
  
  
  if ("problem_inequality" %in% names(e)) temp <- 2 * (e$problem_inequality %in% text_issue_very_serious) + (e$problem_inequality %in% text_issue_serious) - (e$problem_inequality %in% text_issue_small) - 2 * (e$problem_inequality %in% text_issue_not) - 0.1 * (e$problem_inequality %in% text_pnr | is.na(e$problem_inequality))
  if ("problem_inequality" %in% names(e)) e$problem_inequality <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                                                                   names = c("Not an issue at all", "A small issue", "An issue", "A serious issue", "A very serious issue", "PNR")),
                                                                          missing.values=-0.1, annotation=Label(e$problem_inequality))
  
  if ("future_richness" %in% names(e)) temp <- 2 * (e$future_richness %in% text_much_richer) + (e$future_richness %in% text_richer) - (e$future_richness %in% text_poorer) - 2 * (e$future_richness %in% text_much_poorer) - 0.1 * (e$future_richness %in% text_pnr | is.na(e$future_richness))
  if ("future_richness" %in% names(e)) e$future_richness <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                                                             names = c("Much poorer", "Poorer", "As rich as now", "Richer", "Much richer", "PNR")),
                                                                    missing.values=-0.1, annotation=Label(e$future_richness))
  
  if ("liberal_conservative" %in% names(e) & !("left_right" %in% names(e))) e$left_right <- e$liberal_conservative
  if ("left_right" %in% names(e)) {
    temp <- -2 * (as.character(e$left_right) %in% c(text_very_liberal, "1")) - (as.character(e$left_right) %in% c(text_liberal, "2")) + (as.character(e$left_right) %in% c(text_conservative, "4")) + 2 * (as.character(e$left_right) %in% c(text_very_conservative, "5")) - 0.1 * (e$left_right %in% text_pnr | is.na(e$left_right))
    if ("liberal_conservative" %in% names(e)) e$liberal_conservative <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                                                                         names = c("Very liberal", "Liberal", "Moderate", "Conservative", "Very conservative", "PNR")),
                                                                                missing.values=-0.1, annotation=Label(e$left_right))
    e$left_right <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Very left", "Left", "Center", "Right", "Very right", "PNR")),
                            missing.values=-0.1, annotation=Label(e$left_right))
  }
  
  if ("transport_available" %in% names(e)) temp <-  (e$transport_available %in% text_transport_available_yes_limited) + 2 * (e$transport_available %in% text_transport_available_yes_easily) - (e$transport_available %in% text_transport_available_not_at_all) - 0.1*(e$transport_available %in% text_pnr)
  if ("transport_available" %in% names(e)) e$transport_available <- as.item(temp, labels = structure(c(-1:2,-0.1),
                                                                                                     names = c("Not at all", "Not so much", "Yes but limited", "Yes, easily", "PNR")),
                                                                            missing.values=-0.1, annotation=Label(e$transport_available)) 
  
  if ("trust_govt" %in% names(e)) temp <-  (e$trust_govt %in% text_trust_govt_sometimes) + 2 * (e$trust_govt %in% text_trust_govt_often) + 3 * (e$trust_govt %in% text_trust_govt_always) - 0.1*(e$trust_govt %in% text_pnr)
  if ("trust_govt" %in% names(e)) e$trust_govt <- as.item(temp, labels = structure(c(0:3,-0.1),
                                                                                   names = c("Never","Only some of the time","Most of the time","Nearly all the time","PNR")),
                                                          missing.values=-0.1, annotation=Label(e$trust_govt))
  
  if ("inequality_problem" %in% names(e)) temp <-  2 * (e$inequality_problem %in% text_inequality_very_serious) + (e$inequality_problem %in% text_inequality_serious) - (e$inequality_problem %in% text_inequality_small) - 2 * (e$inequality_problem %in% text_inequality_not) - 0.1 * (e$inequality_problem %in% text_pnr)
  if ("inequality_problem" %in% names(e)) e$inequality_problem <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                                                                   names = c("Very serious problem","Serious problem","A problem","Small problem","Not a problem at all","PNR")),
                                                                          missing.values=-0.1, annotation=Label(e$inequality_problem)) 
  
  if ("future_gdp" %in% names(e)) temp <-  (e$future_gdp %in% text_future_richer) - (e$future_gdp %in% text_future_poorer) - 0.1 * (e$future_gdp %in% text_pnr)
  if ("future_gdp" %in% names(e)) e$future_gdp <- as.item(temp, labels = structure(c(-1:1,-0.1),
                                                                                   names = c("Poorer","About as rich", "Richer","PNR")),
                                                          missing.values=-0.1, annotation=Label(e$future_gdp))
  
  if ("envi" %in% names(e)) {
    e$envi[e$envi %in% text_envi_pro_envi] <- "Pro environmental action"
    e$envi[e$envi %in% text_envi_collapse] <- "Useless: collapse"
    e$envi[e$envi %in% text_envi_anti_envi] <- "Other goals"
    e$envi[e$envi %in% text_envi_progress] <- "Not a pb: progress"
    e$envi <- as.item(as.factor(e$envi), missing.values = c("PNR", "", NA), annotation=paste(attr(e$envi, "label")))
  }
  
  if ("CC_exists" %in% names(e)) temp <-  (e$CC_exists %in% text_CC_exists_human) - (e$CC_exists %in% text_CC_exists_not) - 0.1 * (e$CC_exists %in% text_pnr)
  if ("CC_exists" %in% names(e)) e$CC_exists <- as.item(temp, labels = structure(c(-1:1,-0.1),
                                                                                 names = c("Not a reality","Natural", "Anthropogenic","PNR")),
                                                        missing.values=-0.1, annotation=Label(e$CC_exists))
  
  if ("CC_dynamics" %in% names(e)) temp <-  (e$CC_dynamics %in% text_CC_dynamics_rise) - (e$CC_dynamics %in% text_CC_dynamics_decrease) - 2 * (e$CC_dynamics %in% text_CC_dynamics_none) - 0.1 * (e$CC_dynamics %in% text_pnr)
  if ("CC_dynamics" %in% names(e)) e$CC_dynamics <- as.item(temp, labels = structure(c(-2:1,-0.1),
                                                                                     names = c("No impact","Decrease", "Stabilize","Rise more slowly","PNR")),
                                                            missing.values=-0.1, annotation=Label(e$CC_dynamics))
  
  if ("CC_stoppable" %in% names(e)) {
    e$CC_stoppable <- as.character(e$CC_stoppable)
    e$CC_stoppable[e$CC_stoppable %in% text_CC_stoppable_no_influence] <- "No influence"
    e$CC_stoppable[e$CC_stoppable %in% text_CC_stoppable_adapt] <- "Better to adapt"
    e$CC_stoppable[e$CC_stoppable %in% text_CC_stoppable_optimistic] <- "Progress will suffice"
    e$CC_stoppable[e$CC_stoppable %in% text_CC_stoppable_policies] <- "Policies & awareness will"
    e$CC_stoppable[e$CC_stoppable %in% text_CC_stoppable_pessimistic] <- "Should but not happening"
    e$CC_stoppable <- relevel(relevel(relevel(relevel(relevel(as.factor(e$CC_stoppable), "No influence"), "Better to adapt"), "Should but not happening"), "Policies & awareness will"), "Progress will suffice") 
  }
  
  if ("CC_talks" %in% names(e)) {
    temp <-  (as.character(e$CC_talks) %in% text_CC_talks_monthly) - (as.character(e$CC_talks) %in% text_CC_talks_never) - 0.1 * (as.character(e$CC_talks) %in% text_pnr)
    e$CC_talks <- as.item(temp, labels = structure(c(-1:1,-0.1), names = c("Never","Yearly","Monthly","PNR")), missing.values=-0.1, annotation=Label(e$CC_talks))
  }
  
  e$investments_standard_minus_tax_transfers <- (e$standard_support + e$investments_support)/2 - e$tax_transfers_support
  label(e$investments_standard_minus_tax_transfers) <- "investments_standard_minus_tax_transfers: (standard_support + investments_support)/2 - tax_transfers_support"
  
  if ("equal_quota" %in% names(e)) temp <-  2 * (e$equal_quota %in% text_equal_quota_no_redistribution) + (e$equal_quota %in% text_equal_quota_yes) - (e$equal_quota %in% text_equal_quota_no_grand_fathering) - 2 * (e$equal_quota %in% text_equal_quota_no_restriction) - 0.1 * (e$equal_quota %in% text_pnr)
  if ("equal_quota" %in% names(e)) e$equal_quota <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                                                                     names = c("No, against restriction","No, grand-fathering","No, not individual level","Yes","No, more to vulnerable","PNR")),
                                                            missing.values=-0.1, annotation=Label(e$equal_quota))
  
  if ("scale_global" %in% names(e)) {
    if (variables_scale[2] != "scale_national" | variables_scale[3] == "scale_state") e$scale_federal_continent <- e[[variables_scale[2]]]
    else e$scale_state_national <- e$scale_national # these three lines of exception concern SK, JP for which only three possibilities were given (global/national/local)
    if (variables_scale[3] != "scale_local" | variables_scale[3] == "scale_state") e$scale_state_national <- e[[variables_scale[3]]]
    variables_scale <<- c("scale_global", "scale_federal_continent", "scale_state_national", "scale_local")
  }
  
  if ("burden_sharing_income" %in% names(e)) {
    e$pro_polluter_pay <- (e$burden_sharing_income > 0 | e$burden_sharing_emissions > 0 | e$burden_sharing_cumulative > 0)
    label(e$pro_polluter_pay) <- "pro_polluter_pay: In favor of a burden_sharing option where polluter pay: agree to _income, _emissions or _cumulative."
    e$pro_rich_pay <- (e$burden_sharing_rich_pay > 0 | e$burden_sharing_poor_receive > 0)
    label(e$pro_rich_pay) <- "pro_rich_pay: In favor of burden_sharing where rich countries pay it all (including where vulnerable countries receive): agree to _rich_pay or _poor_receive."
    e$pro_grand_fathering <- pmax(e$burden_sharing_cumulative, e$burden_sharing_rich_pay, e$burden_sharing_poor_receive) < 0
    label(e$pro_grand_fathering) <- "pro_grand_fathering: In favor of burden_sharing akin to grand-fathering. Inferred as disagreement to _cumulative, _rich_pay and _poor_receive, i.e.: countries pay in proportion to cumulative emissions, and to options where poor and vulnerable countries don't pay. Results are in line with US pilot on 502 people, where the more explicit usp$equal_quota == grand-fathering gathered 6%."
    e$pro_polluter_and_rich_pay <- (e$burden_sharing_income > 0 | e$burden_sharing_emissions > 0 | e$burden_sharing_cumulative > 0) & (e$burden_sharing_rich_pay > 0 | e$burden_sharing_poor_receive > 0)
    e$pro_global_tax_dividend <- (e$burden_sharing_emissions > 0) & (e$burden_sharing_rich_pay > 0 | e$burden_sharing_poor_receive > 0)
    label(e$pro_polluter_and_rich_pay) <- "pro_polluter_and_rich_pay: In favor of burden_sharing where polluters and only rich countries pay. Inferred as agreeing to at least one polluter-pay option and one option where rich countries pay it all: (_income, _emissions or _cumulative) and (_rich_pay or _poor_receive)."
    label(e$pro_global_tax_dividend) <- "pro_global_tax_dividend: In favor of burden_sharing akin to global tax & dividend. Inferred as agreeing to paying in proportion to current emissions and one option where rich countries pay it all: _emissions and (_rich_pay or _poor_receive)."
    e$pro_differentiated_responsibilities_strict <- e$burden_sharing_cumulative > 0 & e$burden_sharing_poor_receive > 0
    label(e$pro_differentiated_responsibilities_strict) <- "pro_differentiated_responsibilities_strict: In favor of a burden_sharing option akin to differentiated responsibilities, taken in a strict sense. Inferred as agreeing to paying in proportion to current emissions and that vulnerable countries receive income support in net: _emissions and _poor_receive."
    e$pro_differentiated_responsibilities_large <- e$pro_polluter_pay == T & e$burden_sharing_poor_receive > 0
    label(e$pro_differentiated_responsibilities_large) <- "pro_differentiated_responsibilities_large: In favor of a burden_sharing option akin to differentiated responsibilities, taken in a loose sense. Inferred as agreeing to at least one polluter-pay option and that vulnerable countries receive income support in net: (_emissions, _income or _cumulative) and _poor_receive "
    variables_burden_sharing_inferred <<- c("pro_polluter_pay", "pro_rich_pay",  "pro_grand_fathering", "pro_polluter_and_rich_pay", "pro_global_tax_dividend", "pro_differentiated_responsibilities_large", "pro_differentiated_responsibilities_strict")
    e$burden_share_ing_population <- e$burden_sharing_emissions 
    e$burden_share_ing_historical <- e$burden_sharing_cumulative 
    e$burden_share_ing_damages <- e$burden_sharing_poor_receive 
  } else if ("burden_share_population" %in% names(e)) {
    e$pro_rich_pay <- (e$burden_share_historical > 0 | e$burden_share_population > 0)
    label(e$pro_rich_pay) <- "pro_rich_pay: In favor of burden_share where rich countries pay: agree to _population or _historical."
    variables_burden_sharing_inferred <<- c("pro_rich_pay")
    for (v in variables_burden_share) e[[sub("share_", "share_ing_", v)]] <- e[[v]]
    variables_burden_share_ing <<- gsub("share_", "share_ing_", variables_burden_share)
  }
  
  if (country=="US" & wave=="pilot2") e$equal_quota2 <- as.item(e$equal_quota, labels = structure(c(-2,-1,1,2,-0.1),
                                                                                                  names = c("No, against restriction","No, grand-fathering","Yes","No, more to vulnerable","PNR")),
                                                                missing.values=-0.1, annotation=Label(e$equal_quota))
  
  if ("country_should_act" %in% names(e)) temp <-  (e$country_should_act %in% text_should_act_yes) - (e$country_should_act %in% text_should_act_no) - 0.1 * (e$country_should_act %in% text_pnr)
  if ("country_should_act" %in% names(e)) e$country_should_act <- as.item(temp, labels = structure(c(-1:1,-0.1),
                                                                                                   names = c("No","Only if international agreement", "Yes","PNR")),
                                                                          missing.values=-0.1, annotation=Label(e$country_should_act))
  
  if ("country_should_act_condition" %in% names(e)) temp <- (e$country_should_act_condition %in% text_should_act_condition_compensation) - (e$country_should_act_condition %in% text_should_act_condition_free_riding) - 0.1 * (e$country_should_act_condition %in% text_pnr)
  if ("country_should_act_condition" %in% names(e)) e$country_should_act_condition <- as.item(temp, labels = structure(c(-1:1), names = c("Free-riding","Reciprocity", "Compensation")),
                                                                                              annotation=Label(e$country_should_act))
  
  for (v in intersect(names(e), c(variables_side_effects, variables_employment))) {
    temp <-  (e[[v]] %in% text_effects_positive) - (e[[v]] %in% text_effects_negative) - 0.1 * (e[[v]] %in% text_pnr)
    e[[v]] <- as.item(temp, labels = structure(c(-1:1,-0.1),
                                               names = c("Negative","None notable","Positive","PNR")),
                      missing.values=-0.1, annotation=Label(e[[v]]))
  }  
  
  for (v in intersect(names(e), c(variables_incidence))) { 
    temp <-  (e[[v]] %in% text_incidence_win) - (e[[v]] %in% text_incidence_lose) - 0.1 * (e[[v]] %in% text_pnr)
    e[[v]] <- as.item(temp, labels = structure(c(-1:1,-0.1),
                                               names = c("Lose","Unaffected","Win","PNR")),
                      missing.values=-0.1, annotation=Label(e[[v]]))
  }
  
  for (v in intersect(names(e), c(variables_win_lose))) {
    temp <-  -2*(e[[v]] %in% text_lose_a_lot) - (e[[v]] %in% text_mostly_lose) + (e[[v]] %in% text_mostly_win) + 2*(e[[v]] %in% text_win_a_lot) - 0.1 * is.na(e[[v]])
    e[[v]] <- as.item(temp, labels = structure(c(-2:2,-0.1),
                                               names = c("Lose a lot", "Mostly lose", "Neither win nor lose","Mostly win", "Win a lot","PNR")),
                      missing.values=-0.1, annotation=Label(e[[v]]))
  }
  
  if ("CC_worries" %in% names(e)) temp <-  (e$CC_worries %in% text_CC_worries_very) - (e$CC_worries %in% text_CC_worries_not) - 2 * (e$CC_worries %in% text_CC_worries_not_at_all) - 0.1 * (e$CC_worries %in% text_pnr)
  if ("CC_worries" %in% names(e)) e$CC_worries <- as.item(temp, labels = structure(c(-2:1,-0.1),
                                                                                   names = c("No worried at all","Not worried", "Worried","Very worried","PNR")),
                                                          missing.values=-0.1, annotation=Label(e$CC_worries))
  
  if ("occupation" %in% names(e)) temp <-  (e$occupation %in% text_clerc) - 2*(e$occupation %in% text_none_above) - 1 * (e$occupation %in% text_manual) + 2 * (e$occupation %in% text_independent) - 0.1*(is.na(e$occupation))
  if ("occupation" %in% names(e)) e$occupation <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Other","Manual","Skilled", "Clerc","Independent","PNR")),
                                                          missing.values=-0.1, annotation=Label(e$occupation))
  
  if ("heating_expenses" %in% names(e)) temp <- 125*(e$heating_expenses %in% c(text_heating_expenses_125[c("EN", country)], text_heating_expenses_10["US"])) + 600*(e$heating_expenses %in% c(text_heating_expenses_600[c("EN", country)], text_heating_expenses_50["US"])) + 1250*(e$heating_expenses %in% c(text_heating_expenses_1250[c("EN", country)], text_heating_expenses_100["US"])) + 
    2000*(e$heating_expenses %in% c(text_heating_expenses_2000[c("EN", country)], text_heating_expenses_167["US"])) + 3000*(e$heating_expenses %in% c(text_heating_expenses_3000[c("EN", country)], text_heating_expenses_225["US"], text_heating_expenses_275["US"], text_heating_expenses_350["US"])) - 0.1*((e$heating_expenses %in% text_pnr) | is.na(e$heating_expenses))
  if ("heating_expenses" %in% names(e)) e$heating_expenses <- as.item(temp, labels = structure(c(-0.1, 125, 600, 1250, 2000, 3000), names = c("Don't know","< 250","251-1,000", "1,001-1,500","1,501-2,500", "> 2,500")), missing.values=-0.1, annotation=Label(e$heating_expenses))
  if ("heating_expenses" %in% names(e)) e$heating_expenses_country <- as.item(temp, labels = structure(c(-0.1, 125, 600, 1250, 2000, 3000), 
                                                                                                       names = c(text_pnr[country], text_heating_expenses_125[country], text_heating_expenses_600[country], text_heating_expenses_1250[country], text_heating_expenses_2000[country], text_heating_expenses_3000[country])), missing.values=-0.1, annotation=Label(e$heating_expenses))
  
  if ("gas_expenses" %in% names(e)) temp <-  0*(e$gas_expenses %in% c(text_gas_expenses_0[c("EN", country)], text_gas_expenses_0["US"])) + 20*(e$gas_expenses %in% c(text_gas_expenses_20[c("EN", country)], text_gas_expenses_15["US"])) + 60*(e$gas_expenses %in% c(text_gas_expenses_60[c("EN", country)], text_gas_expenses_50["US"])) + 
    120*(e$gas_expenses %in% c(text_gas_expenses_120[c("EN", country)], text_gas_expenses_100["US"])) + 200*(e$gas_expenses %in% c(text_gas_expenses_200[c("EN", country)], text_gas_expenses_150["US"], text_gas_expenses_201["US"])) + 300*(e$gas_expenses %in% c(text_gas_expenses_300[c("EN", country)], text_gas_expenses_220["US"]))
  if ("gas_expenses" %in% names(e)) e$gas_expenses <- as.item(temp, labels = structure(c(0, 20, 60, 120, 200, 300), names = c("< 5","5-30","31-90", "91-150", "151-250", "> 250")), annotation=Label(e$gas_expenses))
  if ("gas_expenses" %in% names(e) & country != "IA") e$gas_expenses_country <- as.item(temp, labels = structure(c(0, 20, 60, 120, 200, 300), 
                                                                                                                 names = c(text_gas_expenses_0[country], text_gas_expenses_20[country], text_gas_expenses_60[country], text_gas_expenses_120[country], text_gas_expenses_200[country], text_gas_expenses_300[country])), annotation=Label(e$gas_expenses))
  
  tryCatch({  
    for (v in intersect(c("heating_expenses", "gas_expenses"), names(e))) {
      for (i in 1:4) {
        gap <- 1
        for (m in c(10, 50, 100, 150, 250, 500, 1000, 1500)) {
          share_i <- wtd.mean(e$income == i & e[[v]] > m, weights = e$weight)/wtd.mean(e$income == i, weights = e$weight) # paste0("Q", i) memisc
          if (gap > abs(share_i - 0.5)) {
            gap <- abs(share_i - 0.5)
            e[[paste0(v, "_above_median")]][e$income == i] <- e[[v]][e$income == i] > m
            thresholds_expenses[[country]][[v]][[i]] <<- m
          }
        }
      }
      label(e[[paste0(v, "_above_median")]]) <- paste0(v, "_above_median: T/F indicator that ", v, " are above the median expenses of the respondent's income quartile, given by thresholds_expenses.")
    }
    e$high_gas_expenses <- e$gas_expenses_above_median 
    if ("heating_expenses_above_median" %in% names(e)) { e$high_heating_expenses <- e$heating_expenses_above_median == T 
    } else e$high_heating_expenses <- FALSE
    label(e$high_heating_expenses) <- "high_heating_expenses: T/F indicator heating_expenses_above_median where NA have been replaced by FALSE."
    label(e$high_heating_expenses) <- "high_heating_expenses: T/F indicator gas_expenses_above_median"
  }, error = function(cond) { print("Couldn't create high_heating_expenses") } )
  
  if ("insulation_compulsory" %in% names(e)) e$insulation_compulsory[e$insulation_compulsory %in% text_insulation_mandatory] <- "Mandatory"
  if ("insulation_compulsory" %in% names(e)) e$insulation_compulsory[e$insulation_compulsory %in% text_insulation_voluntary] <- "Voluntary"
  if ("insulation_compulsory" %in% names(e)) e$insulation_compulsory <- as.item(as.character(e$insulation_compulsory), labels = structure(c("Mandatory", "Voluntary", "PNR"), names=c("Mandatory", "Voluntary", "PNR")), 
                                                                                missing.values = "PNR", annotation=Label(e$insulation_compulsory))
  
  if(any(grepl("flight_quota", names(e)))) {
    e$flight_quota <- e$flight_quota_1000km
    if (wave == "pilot1") e$flight_quota[!is.na(e$flight_quota_3000km)] <- e$flight_quota_3000km[!is.na(e$flight_quota_3000km)]
    if (wave == "pilot2" | country %in% c("FR")) e$flight_quota[!is.na(e$flight_quota_1000km_global)] <- e$flight_quota_1000km_global[!is.na(e$flight_quota_1000km_global)]
    e$flight_quota[!is.na(e$flight_quota_one_trip)] <- e$flight_quota_one_trip[!is.na(e$flight_quota_one_trip)]
    label(e$flight_quota) <- "flight_quota: ~ Given that the govt decides to limit average flights per person, what do you prefer? Rationing / Tradable quota / PNR. Variants (distance per year): 1000km/1000km global/one round-trip every two years. [units adjusted to country]"
    variables_flight_quota <<- names(e)[grepl('flight_quota', names(e))]
    
    for (v in variables_flight_quota) {
      e[[v]][e[[v]] %in% text_flight_quota_rationing] <- "Rationing"
      e[[v]][e[[v]] %in% text_flight_quota_tradable] <- "Tradable" }
    e$variant_flight_quota <- ""
    e$variant_flight_quota[!is.na(e$flight_quota_3000km)] <- "3000km"
    e$variant_flight_quota[!is.na(e$flight_quota_1000km_global)] <- "1000km global"
    e$variant_flight_quota[!is.na(e$flight_quota_1000km)] <- "1000km"
    e$variant_flight_quota[!is.na(e$flight_quota_one_trip)] <- "1 trip"
    for (v in variables_flight_quota) { e[[v]] <- as.item(as.character(e[[v]]), labels = structure(c("Rationing", "Tradable", "PNR"), 
                                                                                                   names=c("Rationing", "Tradable", "PNR")), missing.values = "PNR", annotation=Label(e[[v]])) }
  }
  
  if ("ban_incentives" %in% names(e)) {
    e$ban_incentives[e$ban_incentives %in% text_ban_incentives_encourage] <- "Encourage"
    e$ban_incentives[e$ban_incentives %in% text_ban_incentives_force] <- "Force"
    e$ban_incentives <- as.item(as.character(e$ban_incentives), missing.values = 'PNR', annotation=Label(e$ban_incentives))
  }
  
  if ("interest_politics" %in% names(e)) temp <-  (e$interest_politics %in% text_interest_politics_lot) - (e$interest_politics %in% text_interest_politics_no) - 0.1 * (e$interest_politics %in% text_pnr)
  if ("interest_politics" %in% names(e)) e$interest_politics <- as.item(temp, labels = structure(c(-1:1,-0.1),
                                                                                                 names = c("Not really or not at all","A little", "A lot","PNR")),
                                                                        missing.values=-0.1, annotation=Label(e$interest_politics))
  
  if ("media" %in% names(e)) {
    e$media[e$media %in% text_media_other] <- "Other"
    e$media[e$media %in% text_media_print] <- "Print"
    e$media[e$media %in% text_media_radio] <- "Radio"
    e$media[e$media %in% text_media_social] <- "Social media"
    e$media[e$media %in% text_media_TV_private] <- "TV (private)"
    e$media[e$media %in% text_media_TV_public] <- "TV (public)"
    e$media[e$media %in% text_media_web] <- "News websites"
  }
  
  if ("vote_participation" %in% names(e)) {
    e$vote_participation[grepl("right to vote", e$vote_participation)] <- "No right to vote"
    if ("vote_voters_2016" %in% names(e)) {
      e$vote_participation_2016[e$vote_participation_2016 %in% text_vote_participation_no_right] <- "No right to vote"
      e$vote_2016[!is.na(e$vote_voters_2016) & e$vote_participation_2016=="Yes"] <- e$vote_voters_2016[!is.na(e$vote_voters_2016) & e$vote_participation_2016=="Yes"]
      e$vote_2016[!is.na(e$vote_non_voters_2016) & e$vote_participation_2016!="Yes"] <- e$vote_non_voters_2016[!is.na(e$vote_non_voters_2016) & e$vote_participation_2016!="Yes"]
      e$vote_participation_2016 <- as.item(as.character(e$vote_participation_2016), missing.values = 'PNR', annotation=Label(e$vote_participation_2016))
      e$vote_2016 <- as.item(as.character(e$vote_2016), missing.values = 'PNR', annotation=Label(e$vote_2016))
      e$vote_2016_factor <- as.factor(e$vote_2016)
      e$vote_2016_factor <- relevel(relevel(e$vote_2016_factor, "Stein"), "Clinton")
    }
    e$vote[!is.na(e$vote_voters) & e$vote_participation=="Yes"] <- e$vote_voters[!is.na(e$vote_voters) & e$vote_participation=="Yes"]
    e$vote[!is.na(e$vote_non_voters) & e$vote_participation!="Yes"] <- e$vote_non_voters[!is.na(e$vote_non_voters) & e$vote_participation!="Yes"]
    e$vote_participation <- as.item(as.character(e$vote_participation), missing.values = 'PNR', annotation=Label(e$vote_participation))
    e$vote <- as.item(as.character(e$vote), missing.values = 'PNR', annotation=Label(e$vote))
    e$voted <- e$vote_participation == 'Yes'
    label(e$voted) <- "voted: Has voted in last election: Yes to vote_participation."
  }
  
  e$survey_biased[e$survey_biased %in% text_survey_biased_pro_envi] <- "Yes, pro environment"
  e$survey_biased[e$survey_biased %in% text_survey_biased_anti_envi] <- "Yes, anti environment"
  e$survey_biased[e$survey_biased %in% text_survey_biased_left] <- "Yes, left"
  e$survey_biased[e$survey_biased %in% text_survey_biased_right] <- "Yes, right"
  e$survey_biased[e$survey_biased %in% text_survey_biased_no] <- "No" 
  if ("Yes, right" %in% levels(as.factor(e$survey_biased))) e$survey_biased <- relevel(relevel(as.factor(e$survey_biased), "Yes, right"), "No")
  e$survey_biased_yes <- e$survey_biased != 'No'
  e$survey_biased_left <- e$survey_biased == "Yes, left"
  e$survey_biased_right <- e$survey_biased == "Yes, right"
  label(e$survey_biased_yes) <- "survey_biased_yes: T/F Finds the survey biased (survey_biased != No)"
  label(e$survey_biased_left) <- "survey_biased_left: T/F Finds the survey left-wing biased (survey_biased == Yes, left)"
  label(e$survey_biased_right) <- "survey_biased_right: T/F Finds the survey right-wing biased (survey_biased == Yes, right)"
  
  if ("WTP" %in% names(e)) {
    e$WTP <- as.numeric(as.vector(gsub('[[:alpha:] $]', '', e$WTP))) 
    e$wtp_agg <- 5 * (e$WTP > 0 & e$WTP <= 10) + 50 * (e$WTP > 10 & e$WTP <= 70) + 100 * (e$WTP > 70 & e$WTP <= 100) + 200 * (e$WTP > 100 & e$WTP <= 300) + 500 * (e$WTP > 300 & e$WTP <= 500) + 1000 * (e$WTP > 500)
    e$wtp_agg <- as.item(e$wtp_agg, labels = structure(c(0,5,50,100,200,500,1000), names = c("0", "From 0.5 to 10", "30 to 70", "100", "150 to 300", "500", "1000 or more")), annotation=Label(e$wtp_agg))
  } 
  if ("wtp_100" %in% names(e)) {
    e$wtp_variant <- NA
    e$wtp_variant[!is.na(e$wtp_10)] <- 10
    e$wtp_variant[!is.na(e$wtp_30)] <- 30
    e$wtp_variant[!is.na(e$wtp_50)] <- 50
    e$wtp_variant[!is.na(e$wtp_100)] <- 100
    e$wtp_variant[!is.na(e$wtp_300)] <- 300
    e$wtp_variant[!is.na(e$wtp_500)] <- 500
    e$wtp_variant[!is.na(e$wtp_1000)] <- 1000
    label(e$wtp_variant) <- "wtp_variant: The amount that respondent faces in the WTP dichotmous choice, in $/year: 10/30/50/100/300/500/1000"
    e$wtp <- NA
    e$wtp[!is.na(e$wtp_10)] <- e$wtp_10[!is.na(e$wtp_10)]
    e$wtp[!is.na(e$wtp_30)] <- e$wtp_30[!is.na(e$wtp_30)]
    e$wtp[!is.na(e$wtp_50)] <- e$wtp_50[!is.na(e$wtp_50)]
    e$wtp[!is.na(e$wtp_100)] <- e$wtp_100[!is.na(e$wtp_100)]
    e$wtp[!is.na(e$wtp_300)] <- e$wtp_300[!is.na(e$wtp_300)]
    e$wtp[!is.na(e$wtp_500)] <- e$wtp_500[!is.na(e$wtp_500)]
    e$wtp[!is.na(e$wtp_1000)] <- e$wtp_1000   [!is.na(e$wtp_1000)]
    label(e$wtp) <- "wtp: Whether the respondent is willing to pay wtp_variant (in 10/30/50/100/300/500/1000) $/year to limit global warming to safe levels (2°C) through investments in clean technologies (e.g. wtp_100)."
    e$wtp <- 1*(e$wtp %in% c(1, text_yes)) - 0.1*(is.na(e$wtp) | e$wtp=="")
    e$wtp <- as.item(e$wtp, labels = structure(c(-0.1,0,1), names = c("PNR","No","Yes")), missing.values = c("",NA,"PNR"), annotation=attr(e$wtp, "label"))
  }
  
  if ("left" %in% names(e)) {
    e$left_right <- pmax(-2,pmin(2,-2 * e$far_left - 1*e$left + 1*e$right + 2 * e$far_right))
    is.na(e$left_right) <- (e$left_right == 0) & !e$center
    e$Left_right <- as.factor(e$left_right)
    e$left_right <- as.item(as.numeric(as.vector(e$left_right)), labels = structure(c(-2:2),
                                                                                    names = c("Far left", "Left or center-left", "Center", "Right or center-right", "Far right")), annotation="left_right: scale from -2 (far left) to +2 (far right) - Political leaning - How would you define yourself? Multiple answers are possible: (Far) left/Center/(Far) right/Liberal/Conservative/Humanist/Patriot/Apolitical/Environmentalist/Feminist/Other (specify)")
    levels(e$Left_right) <- c("Far left", "Left or center-left", "Center", "Right or center-right", "Far right", "Indeterminate")
    e$Left_right[is.na(e$Left_right)] <- "Indeterminate"
    e$indeterminate <- e$Left_right == "Indeterminate"
    e$left_right_pnr <- as.character(e$left_right)
    e$left_right_pnr[e$Left_right=='Indeterminate'] <- 'PNR'
    e$left_right_pnr <- as.factor(e$left_right_pnr)
    e$left_right_pnr <- relevel(relevel(e$left_right_pnr, "Left or center-left"), "Far left")
    label(e$left_right) <- "left_right: How would you define yourself? Far Left/Left or center-left/Center/Right or center-right/Far right"
    
    e$right_pol <- e$left_right > 0
    label(e$right_pol) <- "right_pol: Dummy equal to one if the person define herself as Right or Far right"
  }
  
  if ("gilets_jaunes_dedans" %in% names(e)) {
    e$gilets_jaunes[e$gilets_jaunes_NSP==T] <- -0.1
    e$gilets_jaunes[e$gilets_jaunes_compris==T] <- 0 
    e$gilets_jaunes[e$gilets_jaunes_oppose==T] <- -1
    e$gilets_jaunes[e$gilets_jaunes_soutien==T] <- 1
    e$gilets_jaunes[e$gilets_jaunes_dedans==T] <- 2
    e$gilets_jaunes <- as.item(e$gilets_jaunes, missing.values=-0.1, labels = structure(c(-0.1,-1:2), names=c('NSP', 'oppose', 'comprend', 'soutient', 'est_dedans')),
                               annotation="gilets_jaunes: -1: s'oppose / 0: comprend sans soutenir ni s'opposer / 1: soutient / 2: fait partie des gilets jaunes (gilets_jaunes_compris/oppose/soutien/dedans/NSP)" )
    e$Gilets_jaunes <- as.character(e$gilets_jaunes)
    e$Gilets_jaunes[e$gilets_jaunes=="NSP"] <- "NSP"
    e$Gilets_jaunes <- as.factor(e$Gilets_jaunes)
    e$Gilets_jaunes <- relevel(e$Gilets_jaunes, 'soutient')
    e$Gilets_jaunes <- relevel(e$Gilets_jaunes, 'comprend')
    e$Gilets_jaunes <- relevel(e$Gilets_jaunes, 'NSP')
    e$Gilets_jaunes <- relevel(e$Gilets_jaunes, 'oppose')
    
    e$Gilets_jaunes_agg <- e$Gilets_jaunes
    e$Gilets_jaunes_agg[e$Gilets_jaunes == "est_dedans"] <- "soutient"
    e$Gilets_jaunes_agg <- replace_na(as.character(e$Gilets_jaunes_agg), "NA")
  }
  
  e$country <- country
  e$country3 <- countries3[country]
  e$country_name <- countries_names[country]
  e$country_name <- factor(e$country_name, levels = countries_names)
  label(e$country) <- "country: Country of the survey."
  e$wave <- wave
  label(e$wave) <- "wave: Wave of the survey. pilot1/pilot2/full"  
  country_group <<- c("Australia, Canada", "Australia, Canada", "UE, UK", "UE, UK", "UE, UK", "UE, UK", "Japan, Korea", "Middle-income", "UE, UK", "Japan, Korea", "UE, UK", "Middle-income", "UE, UK", "US", "Middle-income", "China", "India", "Middle-income", "Middle-income", "Middle-income")
  names(country_group) <<- countries
  e$country_group <- country_group[e$country]
  label(e$country_group) <- "country_group: Categorization of the country among 7 categories: Australia, Canada; UE, UK; Japan, Korea; US; China; India; Middle-income (i.e. MX, TR, BR, ID, SA, UA)"
  
  for (p in names_policies) {
    if (paste0(p, "_cost_effective") %in% names(e)) e[[paste0(p, "_costless_costly")]] <- e[[paste0(p, "_costless")]] <- e[[paste0(p, "_cost_effective")]]
    if (paste0(p, "_negative_effect") %in% names(e)) e[[paste0(p, "_positive_negative")]] <- e[[paste0(p, "_positive_effect")]] <- e[[paste0(p, "_negative_effect")]]
    if ("positive_treatment" %in% names(e)) {
      if (paste0(p, "_cost_effective") %in% names(e)) e[[paste0(p, "_costless_costly")]][e$positive_treatment==0] <- -e[[paste0(p, "_cost_effective")]][e$positive_treatment==0]
      if (paste0(p, "_negative_effect") %in% names(e)) e[[paste0(p, "_positive_negative")]][e$positive_treatment==0] <- -e[[paste0(p, "_negative_effect")]][e$positive_treatment==0]
      e[[paste0(p, "_cost_effective")]][e$positive_treatment==1] <- NA 
      e[[paste0(p, "_negative_effect")]][e$positive_treatment==1] <- NA
      e[[paste0(p, "_positive_effect")]][e$positive_treatment==0] <- NA
      e[[paste0(p, "_costless")]][e$positive_treatment==0] <- NA
      e$positive_treatment_present <- T
    } else {
      e[[paste0(p, "_positive_effect")]] <- NA
      e[[paste0(p, "_costless")]] <- NA
      e$positive_treatment <- 0
      e$positive_treatment_present <- FALSE }
    if (paste0(p, "_positive_effect") %in% names(e)) annotation(e[[paste0(p, "_positive_effect")]]) <- sub("negative", "positive", Label(e[[paste0(p, "_positive_effect")]]))
    if (paste0(p, "_costless") %in% names(e)) annotation(e[[paste0(p, "_costless")]]) <- sub("costly|cost_effective", "costless", Label(e[[paste0(p, "_costless")]])) # _positive_negative and _costless_costly are the variables containing all obs. (the other contain only respective half)
    if (paste0(p, "_positive_negative") %in% names(e)) annotation(e[[paste0(p, "_positive_negative")]]) <- paste(sub("_negative_effect:", "_positive_negative:", sub("negative ", "positive [or negative] ", Label(e[[paste0(p, "_positive_negative")]]))), "[depending on positive_treatment = 0/1, all recoded as positive]")
    if (paste0(p, "_costless_costly") %in% names(e)) annotation(e[[paste0(p, "_costless_costly")]]) <-  paste(sub("_cost_effective:", "_costless_costly:", sub("costly ", "costless [or costly] ", Label(e[[paste0(p, "_costless_costly")]]))), "[depending on positive_treatment = 0/1, all recoded as costless]")
    if ("positive_treatment" %in% names(e)) label(e$positive_treatment) <- "positive_treatment: 0/1 If =1, questions on economic effect and cost-effectiveness of main policies asked in a positive way: positive/costless, if =0: negative/costly. Always =0 for US, DK, FR."
  }
  if ('standard_cost_effective' %in% names(e)) variables_standard_effect <<- sub("negative_effect", "positive_negative", sub("cost_effective", "costless_costly", variables_standard_effect))
  if ('standard_cost_effective' %in% names(e)) variables_investments_effect <<- sub("negative_effect", "positive_negative", sub("cost_effective", "costless_costly", variables_investments_effect))
  if ('standard_cost_effective' %in% names(e)) variables_tax_transfers_effect <<- sub("negative_effect", "positive_negative", sub("cost_effective", "costless_costly", variables_tax_transfers_effect))
  if ('standard_cost_effective' %in% names(e)) variables_policies_effect <<- c(variables_standard_effect, variables_investments_effect, variables_tax_transfers_effect)
  
  if ("standard_trust" %in% names(e)) e$policies_trust <- ((e$standard_trust %in% "Yes") + (e$investments_trust %in% "Yes") + (e$tax_transfers_trust %in% "Yes") - (e$standard_trust %in% "No") - (e$investments_trust %in% "No") - (e$tax_transfers_trust %in% "No"))/3
  if ("standard_trust" %in% names(e)) label(e$policies_trust) <- "policies_trust: Could [Country] government be trusted to correctly implement an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers? Yes/No/PNR"
  if ("standard_effective" %in% names(e)) e$policies_effective <- ((e$standard_effective %in% "Yes") + (e$investments_effective %in% "Yes") + (e$tax_transfers_effective %in% "Yes") - (e$standard_effective %in% "No") - (e$investments_effective %in% "No") - (e$tax_transfers_effective %in% "No"))/3
  if ("standard_effective" %in% names(e)) label(e$policies_effective) <- "policies_effective: Would an emission limit for cars, a green infrastrcuture program and a carbon tax be effective to fight climate change? Yes/No/PNR"
  if ("standard_employment" %in% names(e)) e$policies_employment <- ((e$standard_employment=="Positive") + (e$investments_employment=="Positive") + (e$tax_transfers_employment=="Positive") - (e$standard_employment=="Negative") - (e$investments_employment=="Negative") - (e$tax_transfers_employment=="Negative"))/3
  if ("standard_employment" %in% names(e)) label(e$policies_employment) <- "policies_employment: Would an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers have positive or negative impact on employment? Postive impacts/No notable impact/Negative impacts/PNR"
  if ("standard_side_effects" %in% names(e)) e$policies_side_effects <- ((e$standard_side_effects=="Positive") + (e$investments_side_effects=="Positive") + (e$tax_transfers_side_effects=="Positive") - (e$standard_side_effects=="Negative") - (e$investments_side_effects=="Negative") - (e$tax_transfers_side_effects=="Negative"))/3
  if ("standard_side_effects" %in% names(e)) label(e$policies_side_effects) <- "policies_side_effects: Would an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers have positive or negative side effects overall? Positive impacts/No notable impact/Negative impacts/PNR"
  if ("standard_large_effect" %in% names(e)) e$policies_large_effect <- (e$standard_large_effect + e$investments_large_effect + e$tax_transfers_large_effect)/3
  if ("standard_large_effect" %in% names(e)) label(e$policies_large_effect) <- "policies_large_effect: An emission limit for cars, a green infrastructure program and a carbon tax with cash transfers would have large effect on the economy and employment? Strongly disagree-agree"
  if ("standard_positive_negative" %in% names(e)) e$policies_positive_negative <- round((e$standard_positive_negative + e$investments_positive_negative + e$tax_transfers_positive_negative)/3, 2)
  if ("standard_positive_negative" %in% names(e)) label(e$policies_positive_negative) <- "policies_positive_negative: An emission limit for cars, a green infrastructure program and a carbon tax with cash transfers would have negative effect on the economy and employment? Strongly disagree-agree"
  if ("standard_negative_effect" %in% names(e)) e$policies_negative_effect <- (e$standard_negative_effect + e$investments_negative_effect + e$tax_transfers_negative_effect)/3
  if ("standard_negative_effect" %in% names(e)) label(e$policies_negative_effect) <- "policies_negative_effect: An emission limit for cars, a green infrastructure program and a carbon tax with cash transfers would have negative effect on the economy and employment? Strongly disagree-agree"
  if ("standard_positive_effect" %in% names(e)) e$policies_positive_effect <- (e$standard_positive_effect + e$investments_positive_effect + e$tax_transfers_positive_effect)/3
  if ("standard_positive_effect" %in% names(e)) label(e$policies_positive_effect) <- "policies_positive_effect: An emission limit for cars, a green infrastructure program and a carbon tax with cash transfers would have positive effect on the economy and employment? Strongly disagree-agree"
  if ("standard_fair" %in% names(e)) e$policies_fair <- (e$standard_fair + e$investments_fair + e$tax_transfers_fair)/3
  if ("standard_fair" %in% names(e)) label(e$policies_fair) <- "policies_fair: An emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers is fair? Strongly disagree - strongly agree"
  if ("standard_costless_costly" %in% names(e)) e$policies_costless_costly <- (e$standard_costless_costly + e$investments_costless_costly + e$tax_transfers_costless_costly)/3
  if ("standard_costless_costly" %in% names(e)) label(e$policies_costless_costly) <- "policies_costless_costly: An emission limit for cars, a green infrastrcuture program and a carbon tax would be cost-effective to fight climate change. Strongly disagree - strongly sagree"
  if ("standard_cost_effective" %in% names(e)) e$policies_cost_effective <- (e$standard_cost_effective + e$investments_cost_effective + e$tax_transfers_cost_effective)/3
  if ("standard_cost_effective" %in% names(e)) label(e$policies_cost_effective) <- "policies_cost_effective: An emission limit for cars, a green infrastrcuture program and a carbon tax would be costly to fight climate change. Strongly disagree - strongly sagree"
  if ("standard_costless" %in% names(e)) e$policies_costless <- (e$standard_costless + e$investments_costless + e$tax_transfers_costless)/3
  if ("standard_costless" %in% names(e)) label(e$policies_costless) <- "policies_costless: An emission limit for cars, a green infrastrcuture program and a carbon tax would be costless to fight climate change. Strongly disagree - strongly sagree"
  if ("standard_effect_less_pollution" %in% names(e)) e$policies_effect_less_pollution <- (e$standard_effect_less_pollution + e$investments_effect_less_pollution + e$tax_transfers_effect_less_pollution)/3
  if ("standard_effect_less_pollution" %in% names(e)) label(e$policies_effect_less_pollution) <- "policies_effect_less_pollution: An emission limit for cars, a green infrastrcuture program and a carbon tax would reduce pollution. Strongly disagree - strongly sagree"
  e$policies_support <- (e$standard_support + e$investments_support + e$tax_transfers_support) / 3
  label(e$policies_support) <- "policies_support: Average of responses in [-2;+2] to Would you support an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers?"
  e$policies_self <- e$policies_incidence <- e$policies_poor <- e$policies_middle <- e$policies_rich <- e$policies_rural <- e$policies_urban <- 0
  label(e$policies_self) <- "policies_self: Would your household win or lose financially from an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers? Average of 3 policies in [-2;+2]"
  label(e$policies_poor) <- "policies_poor: Would the poorest win or lose financially from an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers? Average of 3 policies in [-2;+2]"
  label(e$policies_middle) <- "policies_middle: Would the middle class win or lose financially from an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers? Average of 3 policies in [-2;+2]"
  label(e$policies_rich) <- "policies_rich: Would the richest financially win or lose from an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers? Average of 3 policies in [-2;+2]"
  label(e$policies_rural) <- "policies_rural: Would rural financially win or lose from an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers? Average of 3 policies in [-2;+2]"
  label(e$policies_urban) <- "policies_urban: Would urban dwellers win or lose financially from an emission limit for cars, a green infrastrcuture program and a carbon tax with cash transfers? Average of 3 policies in [-2;+2]" 
  text_incidence <- ifelse("standard_incidence_poor" %in% names(e), "incidence", "win_lose")
  for (v in names_policies) e$policies_self <- e$policies_self + e[[paste(v, text_incidence, "self", sep="_")]]/3
  for (v in names_policies) e$policies_poor <- e$policies_poor + e[[paste(v, text_incidence, "poor", sep="_")]]/3
  for (v in names_policies) if (paste(v, text_incidence, "middle", sep="_") %in% names(e)) e$policies_middle <- e$policies_middle + e[[paste(v, text_incidence, "middle", sep="_")]]/3
  for (v in names_policies) e$policies_rich <- e$policies_rich + e[[paste(v, text_incidence, "rich", sep="_")]]/3
  for (v in names_policies) if (paste(v, text_incidence, "rural", sep="_") %in% names(e)) e$policies_rural <- e$policies_rural + e[[paste(v, text_incidence, "rural", sep="_")]]/3
  if ("standard_incidence_urban" %in% names(e)) for (v in names_policies) e$policies_urban <- e$policies_urban + e[[paste(v, text_incidence, "urban", sep="_")]]/3
  if ("policies_fair" %in% names(e)) e$policies_fair_support_same_sign <- e$policies_fair * e$policies_support > 0
  e$policies_support_poor_same_sign <- e$policies_poor * e$policies_support > 0
  if ("policies_fair" %in% names(e)) label(e$policies_fair_support_same_sign) <- "policies_fair_support_same_sign: T/F policies_fair * policies_support > 0."
  label(e$policies_support_poor_same_sign) <- "policies_support_poor_same_sign: T/F policies_poor * policies_support > 0."
  
  if (country %in% c("FR", "IT", "UK", "DE", "MX", "SK")) {
    e$urban_category[e$urban_category == "0"] <- NA
  }
  if (country == "CN") e$urban_category <- e$area
  
  if (country=="US") {
    if ("urban_category" %in% names(e)) {
      e$urban <- e$core_metropolitan <- as.numeric(as.vector(e$urban_category))==1
      label(e$core_metropolitan) <- "core_metropolitan: Live in a core metropolitan zip code. TRUE/FALSE"    
    } else {
      e$urban <- e$urbanity >= 2
      e$urban_category <- NA
    }
  } else if (country %in% c("ID", "SA")) e$urban <- e$area
  else e$urban <- NA
  temp <- case_when(e$country %in% c("US") ~ e$urban == T,
                    e$country %in% c("AU", "CA", "JP", "TR", "UA") ~ e$urban_category %in% c("Urban", '"Urban'),
                    e$country %in% c("DK") ~ e$urbanity > 2, # >20k
                    e$country %in% c("PL", "SP", "IA") ~ e$urbanity > 1, 
                    e$country == "MX" ~ e$urban_category %in% c("Urbano"),
                    e$country == "FR" ~ e$urban_category == "GP",
                    e$country == "DE" ~ e$urban_category %in% c("Towns_and_Suburbs", "Cities"),
                    e$country == "IT" ~ e$urban_category %in% c("Cities", "Small_Cities"),
                    e$country == "SK" ~ e$urban_category %in% c("Town", "City"),
                    e$country == "UK" ~ e$urban_category %in% c("Large_urban", "City_Town"),
                    e$country == "BR" ~ e$urbanity > 2,# >50k
                    e$country == "CN" ~ e$urbanity > 2, # >500k; otherwise: e$urban_category %in% c("Urban", "Small_Urban"), i.e. > 10k: probably better to define it using urbanity
                    e$country == "ID" ~ e$urban %in% c("Kota", "Capital town of a Kabupaten"),
                    e$country == "SA" ~ e$urban %in% c("In a capital of a District municipality", "In a metropolitan municipality"), 
                    TRUE ~ NA)
  e$urban <- temp 
  label(e$urban) <- "urban: Live in an urban area. Computed from zipcode if possible, otherwise from answer to urbanity. US: core_metroplitan; DK: urbanity > 20k; FR: Grand Pôle; IT: Cities and small cities from Eurostat; UK: Urban city or town, or conurbation and large urban area; "
  
  if (country %in% c("CN", "ID", "SA")) {
    temp <- 1*(e$area %in% text_area_middle) + 2*(e$area %in% text_area_large) 
    e$area <- as.item(temp, labels = structure(c(0:2), names=c(text_area_small[country], text_area_middle[country], text_area_large[country])), annotation=Label(e$area) )
  } 
  
  if ("CC_affected_2050" %in% names(e)) {
    e$CC_affected_min <- 2100
    e$CC_affected_min[e$CC_affected_2050==T] <- 2050
    e$CC_affected_min[e$CC_affected_2020==T] <- 2020
    e$CC_affected_min[e$CC_affected_1990==T] <- 1990
    e$CC_affected_min[e$CC_affected_1960==T] <- 1960
    e$CC_affected_min[e$CC_affected_pnr==T] <- -0.1
    e$CC_affected_min <- as.item(e$CC_affected_min, labels = structure(c(1960,1990,2020,2050,2100,-0.1),
                                                                       names = c("1960","1990","2020","2050","None","PNR")),
                                 missing.values=-0.1, annotation=Label(e$CC_affected_min))
    label(e$CC_affected_min) <- "CC_affected_min: Youngest generation seriously affected by climate change. 2100/2050/2020/1990/1960/PNR" 
  }
  
  if ("CC_impacts" %in% names(e)) {
    temp <- -2*(e$CC_impacts %in% text_CC_impacts_cataclysmic) -1*(e$CC_impacts %in% text_CC_impacts_disastrous) + 1*(e$CC_impacts %in% text_CC_impacts_small) + 2*(e$CC_impacts %in% text_CC_impacts_insignificant) -0.1*(e$CC_impacts %in% text_pnr)
    e$CC_impacts <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Insignificant","Small","Grave","Disastrous","Cataclysmic","PNR")),
                            missing.values=-0.1, annotation=Label(e$CC_impacts))
  }
  
  if (!("flights_agg" %in% names(e)) & ("flights" %in% names(e))) {
    e$flights_agg <- 1.8*(e$flights %in% 1:2) + 5*(e$flights %in% 3:7) + 11*(e$flights %in% 8:14) + 25*(e$flights > 14)
    e$flights_agg <- as.item(e$flights_agg, labels = structure(c(0,1.8,5,11,25), names = c("0", "1 or 2", "3 to 7", "8 to 14", "15 or more")), annotation="flights_agg: Round-trip flights taken per year (on average).")
    e$flights_agg <- e$flights_agg/5
  } else {
    if ("flights_3y" %in% names(e)) {
      e$flights_agg <- 1*(e$flights_3y == "1") + 2*(e$flights_3y == "2") + 3.5*(e$flights_3y == "3 or 4") + 6*(e$flights_3y == "5 to 7") + 11*(e$flights_3y == "8 to 14") + 20*(e$flights_3y == "15 or more")
      e$flights_agg <- as.item(e$flights_agg, labels = structure(c(0,1,2,3.5,6,11,20), names = c("0", "1", "2", "3 or 4", "5 to 7", "8 to 14", "15 or more")), annotation="flights_agg: Round-trip flights taken per year (on average).")      
      e$flights_3y <- as.item(e$flights_agg, labels = structure(c(0,1,2,3.5,6,11,20), names = c("0", "1", "2", "3 or 4", "5 to 7", "8 to 14", "15 or more")), annotation="flights_3y: Round-trip flights taken between 2017 and 2019.")      
      e$flights_agg <- round(e$flights_agg/3, 3)
    } else {
      e$flights_agg <- 1*(e$flights_agg == "1") + 2*(e$flights_agg == "2") + 3.5*(e$flights_agg == "3 or 4") + 7*(e$flights_agg == "5 to 10") + 12*(e$flights_agg == "10 or more")
      e$flights_agg <- as.item(e$flights_agg, labels = structure(c(0,1,2,3.5,7,12), names = c("0", "1", "2", "3 or 4", "5 to 10", "10 or more")), annotation="flights_agg: Round-trip flights taken per year (on average).") } 
  } 
  
  if ("km_driven" %in% names(e)) {
    e$km_driven_agg <- 3000*(e$km_driven > 1000 & e$km_driven <= 5000) + 7500*(e$km_driven > 5000 & e$km_driven <= 10000) + 15000*(e$km_driven > 10000 & e$km_driven <= 20000) + 25000*(e$km_driven > 20000 & e$km_driven <= 30000) + 60000*(e$km_driven > 30000)
    e$km_driven_agg <- as.item(e$km_driven_agg, labels = structure(c(0,3000,7500,15000,25000,60000), names = c("Below 1,000", "1,001 to 5,000", "5k to 10k", "10k to 20k", "20k to 30k", "More than 30k")), annotation=attr(e$flights, "label"))
  }
  
  if ("donation" %in% names(e)) {
    max_e <- max_donation_country[country]
    e$donation_agg <- 0*(e$donation == 0) + 10*(e$donation %between% c(1, max_e/5)) + 30*(e$donation %between% c(max_e/5+1, max_e*2/5)) + 70*(e$donation %between% c(max_e*2/5+1, max_e-1)) + 100*(e$donation == max_e)
    e$donation_agg <- as.item(e$donation_agg, labels = structure(c(0,10,30,70,100), names = c("0", "1 to 20", "21 to 40", "41 to 99", "100")), annotation=attr(e$donation, "label"))
    e$donation_percent <- e$donation / (max_e/100)
    e$donation_fraction <- e$donation_percent / 100
    e$donation_above_20 <- e$donation_percent > 20
    label(e$donation_percent) <- "donation_percent: Donation amount in percentage of maximal donation (~$100)"
    label(e$donation_fraction) <- "donation_fraction: Donation amount as a fraction of maximal donation (~$100)"
    label(e$donation_above_20) <- "donation_above_20: donation is above 20% of the maximal amount"
  }
  
  if ("transport_work" %in% names(e)) {
    e$car_work <- e$transport_work == "Car or Motorbike"
    e$car_leisure <- e$transport_leisure == "Car or Motorbike"
    e$car_shopping <- e$transport_shopping == "Car or Motorbike"
    e$car_work[e$transport_work == "Not Applicable"] <- NA
    e$car_leisure[e$transport_leisure == "Not Applicable"] <- NA
    e$car_shopping[e$transport_shopping == "Not Applicable"] <- NA
    label(e$car_work) <- "car_work: Uses car or motorbike to go to work or place of study (NA if Not Applicable)"
    label(e$car_leisure) <- "car_leisure: Usually uses car or motorbike for leisure (NA if Not Applicable)"
    label(e$car_shopping) <- "car_shopping: Uses car or motorbike to go shopping (NA if Not Applicable)"
  }
  
  if ("treatment_climate" %in% names(e)) {
    e$treatment_climate <- ifelse(e$treatment_climate > sqrt(5/17), 1, 0)
    e$treatment_policy <- ifelse(e$treatment_policy > sqrt(5/17), 1, 0)
    e$treatment <- "None"
    e$treatment[e$treatment_climate == 1 & e$treatment_policy == 0] <- "Climate impacts"
    e$treatment[e$treatment_climate == 0 & e$treatment_policy == 1] <- "Climate policy"
    e$treatment[e$treatment_climate == 1 & e$treatment_policy == 1] <- "Both"
    e$treatment <- relevel(relevel(relevel(as.factor(e$treatment), "Climate policy"), "Climate impacts"), "None")
    label(e$treatment) <- "treatment: Treatment received: Climate impacts/Climate policy/Both/None" 
    
    e$rush_treatment <- e$duration_treatment_climate < duration_climate_video[country]/60 | e$duration_treatment_policy < duration_policy_video[country]/60
    e$rush_treatment[is.na(e$rush_treatment)] <- F
    label(e$rush_treatment) <- "rush_treatment: Has rushed the treatment. TRUE/FALSE" 
    
    e$rush <- e$rush_treatment | (e$duration < 15)
    label(e$rush) <- "rush: Has rushed the treatment or the survey. TRUE/FALSE" 
    e$rush_treatment[e$treatment == "None"] <- NA
    
    e$duration_wo_treatment <- e$duration
    e$duration_wo_treatment[e$treatment_climate == 1] <- (e$duration_wo_treatment - e$duration_treatment_climate)[e$treatment_climate == 1]
    e$duration_wo_treatment[e$treatment_policy == 1] <- (e$duration_wo_treatment - e$duration_treatment_policy)[e$treatment_policy == 1]
    label(e$duration_wo_treatment) <- "duration_wo_treatment: Duration (in min) to questions, excluding time spent on the video treatments."
  }
  
  if (!exists("all_policies")) {
    print("all_policies previously undefined (now instantiated)")
    all_policies <- c(variables_policies_support, "standard_public_transport_support", "tax_transfers_progressive_support", variables_fine_support, variables_policy, variables_tax, "global_quota", variables_global_policies, "insulation_support", variables_beef, variables_policy_additional) 
  }
  e$share_policies_supported <- rowMeans(e[, intersect(all_policies, names(e))] > 0, na.rm = T)
  label(e$share_policies_supported) <- "share_policies_supported: Share of all policies supported (strongly or somewhat) among all policies asked to the respondent."
  
  e$female <- e$gender == "Female"
  e$other <- e$gender == "Other"
  label(e$other) <- "other: Gender is neither Male nor Female"
  e$gender_factor <- as.factor(e$gender)
  if ("Other" %in% levels(e$gender_factor)) e$gender_factor <- relevel(relevel(as.factor(e$gender), "Other"), "Female")
  
  e$children <- F
  if ("nb_children" %in% names(e)) { e$children[e$nb_children >= 1] <- T
  } else if ("Nb_children" %in% names(e)) { e$children[!(e$Nb_children %in% c(0, "0"))] <- T
  } else if ("Nb_children__14" %in% names(e)) e$children[!(e$Nb_children__14 %in% c(0, "0"))] <- T
  label(e$children) <- "children: Live with at least one child below 14 (or has at least one child, for the US)"
  if ("nb_children" %in% names(e)) e$nb_children_ceiling_4 <- pmin(e$nb_children, 4)
  else if ("Nb_children" %in% names(e)) {
    e$nb_children_ceiling_4 <- e$Nb_children
    e$nb_children_ceiling_4[e$Nb_children %in% text_4_] <- 4
    e$nb_children_ceiling_4 <- as.numeric(as.vector(e$nb_children_ceiling_4)) }
  if ("HH_size" %in% names(e)) {
    e$HH_size[e$HH_size %in% text_5_] <- 5
    e$HH_size <- as.item(as.numeric(e$HH_size), labels = structure(c(1:5), names = c("1", "2", "3", "4", "5 or more")), annotation=attr(e$HH_size, "label"))  }
  
  # if ("education" %in% names(e)) {
  #     e$college <- NA
  #     e$college[e$education < 5 & e$education >= 0] <- "No college"
  #     e$college[e$education >= 5] <- "College Degree"
  #     e$college <- factor(e$college, levels = c("No college", "College Degree"))
  #   }
  #
  # if ("education_good" %in% names(e)) {
  #   if ("education_good" %in% names(e)) {
  #     e$college_border <- e$education_good %in% text_college_border
  #     e$college_strict <- e$education_good %in% text_college_strict
  #     e$college_broad <- e$college_strict | e$college_border }
  #   if ("college_border" %in% names(e)) e$college_border[is.na(e$education_good)] <- e$college_strict[is.na(e$education_good)] <- e$college_border[is.na(e$education_good)] <- NA
  #   if ("college_border" %in% names(e)) label(e$college_border) <- "college_border: T/F Indicator that the respondent has some college education (in the broad sense) but no college degree (in the strict sense); i.e. college_strict == F & college_broad == T."
  #   if ("college_strict" %in% names(e)) label(e$college_strict) <- "college_strict: T/F Indicator that the respondent has a college degree (in the strict sense)."
  #   if ("college_broad" %in% names(e)) label(e$college_broad) <- "college_broad: T/F Indicator that the respondent has some college education (in the broad sense)."
  # }
  
  if ("age_exact" %in% names(e)) {
    e$age_agg <- NULL
    e$age_agg[e$age_exact %in% 18:29] <- "18-29"
    e$age_agg[e$age_exact %in% 30:49] <- "30-49"
    e$age_agg[e$age_exact %in% 50:87] <- "50-87"
    e$age_agg <- as.factor(e$age_agg)
    e$age <- NULL
    e$age[e$age_exact %in% 18:24] <- "18-24"
    e$age[e$age_exact %in% 25:34] <- "25-34"
    e$age[e$age_exact %in% 35:49] <- "35-49"
    e$age[e$age_exact %in% 50:64] <- "50-64"
    e$age[e$age_exact > 64] <- "65+" 
  } else { 
    e$age[e$age %in% text_18_24] <- "18-24"
    e$age[e$age %in% text_25_34] <- "25-34"
    e$age[e$age %in% text_35_49] <- "35-49"
    e$age[e$age %in% text_50_64] <- "50-64"
    e$age[e$age %in% text_65_] <- "65+" 
  }
  
  e$age_control <- e$age
  if (country == "CA") e$age_control[e$age == "Below 18"] <- "18-24"
  e$age_control[e$age %in% c("50-64", "65+")] <- "50+"
  
  e$employment_status <- case_when(e$employment_status %in% text_full_time ~ "Full-time employed",
                                   e$employment_status %in% text_part_time ~ "Part-time employed",
                                   e$employment_status %in% text_self_employed ~ "Self-employed",
                                   e$employment_status %in% text_student ~ "Student",
                                   e$employment_status %in% text_retired ~ "Retired",
                                   e$employment_status %in% text_unemployed ~ "Unemployed",
                                   e$employment_status %in% text_inactive ~ "Inactive")
  
  e$employment_agg <-  "Not working"
  e$employment_agg[e$employment_status == "Student"] <- "Student"
  e$employment_agg[e$employment_status == "Retired"] <- "Retired"
  e$employment_agg[e$employment_status == "Self-employed" | e$employment_status == "Full-time employed" | e$employment_status == "Part-time employed"] <- "Working"
  e$employment_agg <- as.factor(e$employment_agg)
  
  e$inactive <- e$employment_agg %in% c("Retired", "Not working")
  e$employment <- e$employment_agg == "Working"
  e$employment[e$age == "65+"] <- NA
  label(e$employment) <- "employment: T/F/NA indicator that the respondent is employed (employment_agg == Working), NA if s-he is above 65."
  
  if ("sector_active" %in% names(e)) {
    e$sector[e$employment_agg == "Student"] <- "Student"
    e$sector[e$inactive == T] <- e$sector_inactive[e$inactive == T]
    e$sector[e$employment_agg == "Working"] <- e$sector_active[e$employment_agg == "Working"]
    e$which_polluting_sector[e$employment_agg == "Working"] <- e$polluting_sector_active[e$employment_agg == "Working"]
    e$which_polluting_sector[e$inactive == T] <- e$polluting_sector_inactive[e$inactive == T]
    e$polluting_sector <- !(e$which_polluting_sector %in% c(text_sector_no, "Other energy industries")) & !is.pnr(e$which_polluting_sector)
    label(e$sector) <- "sector: What is the main activity of the company or organization where you work or have last worked? (For students, the question is not asked and sector = Student)"
    label(e$polluting_sector) <- "polluting_sector: T/F whether sector is polluting (i.e. part of Oil, gas or cal/Cement/Construction/Automobile/Iron and steel/Chemical/Plastics/Pulp and paper/Farming/Air transport)"
  }
  
  e$agglo_categ[e$urbanity == 0] <- "Rural"
  e$agglo_categ[e$urbanity %between% list(1,2)] <- "Small agglo"
  e$agglo_categ[e$urbanity == 3] <- "Medium agglo"
  e$agglo_categ[e$urbanity %between% list(4,5)] <- "Large agglo"
  e$agglo_categ <- factor(e$agglo_categ, levels = c("Rural", "Small agglo", "Medium agglo", "Large agglo"))
  e$econ_leaning <- factor(as.character(e$left_right), levels = c("Left", "Very left", "Center", "Right", "Very right", "PNR"))
  
  e$nb_origin <- 0
  if ("race_white" %in% names(e)) {
    variables_origin <<- names(e)[grepl('race_', names(e)) & !grepl('other$', names(e))]
    e$race <- "Other"
    e$race[e$race_white==T & e$race_asian == FALSE & e$race_native == FALSE] <- "White only"
    e$race[e$race_hispanic==T] <- "Hispanic"
    e$race[e$race_black==T] <- "Black"
    label(e$race) <- "race: White only/Hispanic/Black/Other. True proportions: .601/.185/.134/.08"
    e$origin <- e$race    
    for (v in variables_origin) e$nb_origin[e[[v]]==T] <- e$nb_origin[e[[v]]==T] + 1
    e$majority_origin <- e$race == "White only"
  } else if (country == "IA") {
    e$majority_origin <- e$religion == "Hinduism"
  } else if (country == "SA") {
    e$majority_origin <- e$origin == "Black"
  } else if (country == "US" & grepl("compl", wave)) { # Complementary surveys
    e$race <- case_when(grepl("Black", e$race) ~ "Black", grepl("White", e$race) ~ "White only", grepl("Hispanic", e$race) ~ "Hispanic", T ~ "Other")
    e$majority_origin <- e$race == "White only"
  } else if (!"origin" %in% names(e)) {
    variables_origin <<- names(e)[grepl('origin_', names(e)) & !grepl('other$', names(e))]
    e$origin <- NA
    prop_dominant <- 0
    for (v in variables_origin) {
      if (sum(!is.na(e[[v]])) > prop_dominant) {
        prop_dominant <- sum(!is.na(e[[v]]))
        e$majority_origin <- !is.na(e[[v]])  }
      e$origin[!is.na(e[[v]])] <- e[[v]][!is.na(e[[v]])]
      e$nb_origin[!is.na(e[[v]])] <- e$nb_origin[!is.na(e[[v]])] + 1 }
    label(e$origin) <- "origin: Origin of the respondent. In case of multiple origins (nb_origins > 1), only one is retained (and not the main one in the country)."
  }
  else e$majority_origin <- e$origin
  e$majority_origin_strict <- e$majority_origin & e$nb_origin <= 1
  label(e$nb_origin) <- "nb_origin: Number of origins (or race) of the respondent."
  label(e$majority_origin) <- "majority_origin: T/F Respondent's origin is the dominant one in their country (US: white only; IA: hinduist; ID: Java; SA: Black; DK: Danish ethnic origin; Other: at least one parent's nationality = [country])."
  label(e$majority_origin_strict) <- "majority_origin: T/F Respondent's origin is (only) the dominant one in their country (US: white only; IA: hinduist; ID: Java; SA: Black; DK: Danish ethnic origin; Other: parent's nationality = [country])."
  
  e$income_factor <- as.factor(e$income)
  
  ## 4. Define individual weights 
  ### WEIGHTING
  if (weighting) {
    e$weight_simple <- weighting(e, country, wave, combine_age_50 = combine_age_50, trim = T) 
    quotas_wo_educ <- quotas[[country]]
    quotas[[country]] <<- c(quotas_wo_educ, "college_OECD")
    e$weight_educ <- weighting(e, country, wave, combine_age_50 = combine_age_50, trim = T) 
    e$weight_educ_untrim <- weighting(e, country, wave, combine_age_50 = combine_age_50, trim = FALSE, printWeights = FALSE)
    quotas[[country]] <<- c(quotas_wo_educ, "college_OECD", "employment")
    e$weight <- e$weight_all <- weighting(e, country, wave, combine_age_50 = combine_age_50, trim = T)
    e$weight_all_untrim <- weighting(e, country, wave, combine_age_50 = combine_age_50, trim = FALSE, printWeights = FALSE)
    if ("vote_2020" %in% names(e) & (sum(e$vote_2020=="PNR/no right")!=0)) e$weight_vote <- weighting(e, country, wave, variant = "vote", combine_age_50 = combine_age_50)
    quotas[[country]] <<- quotas_wo_educ  } else e$weight <- 1
  
  ## 3bis. defines derivate variables
  tryCatch({
    if (all(c("vote", "left_right", "weight") %in% names(e))) {
      thresholds <- c(-1.5, -.5, .5, 1.5)
      parties <- Levels("vote", data = e)
      adj_leaning <- mean_leaning <- mode_leaning <- rep(NA, length(parties))
      names(adj_leaning) <- names(mean_leaning) <- names(mode_leaning) <- parties
      for (i in parties) {
        mean_leaning[i] <- wtd.mean(e$left_right[e$vote==i], weights = e$weight[e$vote==i], na.rm = T)
        vote_i <- table(e$left_right[e$vote==i])
        mode_leaning[i] <- names(sort(-vote_i[names(vote_i) != "PNR"]))[1]
        adj_leaning[i] <- case_when(mean_leaning[i] < thresholds[1] ~ -2,
                                    mean_leaning[i] >= thresholds[1] & mean_leaning[i] < thresholds[2] ~ -1,
                                    mean_leaning[i] >= thresholds[2] & mean_leaning[i] < thresholds[3] ~ 0,
                                    mean_leaning[i] >= thresholds[3] & mean_leaning[i] < thresholds[4] ~ 1,
                                    mean_leaning[i] >= thresholds[4] ~ 2)  }
      round_mean_leaning <- round(mean_leaning)
      parties_leaning[country] <<- list(mode_leaning)
      e$vote_mode_leaning <- mode_leaning[e$vote]
      temp <- -2*(e$vote_mode_leaning == "Very left") -1*(e$vote_mode_leaning=="Left") -0*(e$vote_mode_leaning=="Center") + 1*(e$vote_mode_leaning=="Right") + 2*(e$vote_mode_leaning=="Very right") -0.1*(e$vote=="PNR")
      e$vote_mode_leaning <- as.item(temp, labels = structure(c(-2:2,-0.1), names = c("Very left","Left","Center","Right","Very right","PNR")),
                                     missing.values=-0.1, annotation="vote_mode_leaning: left_right leaning of respondent's vote, computed as the mode to left_right question for respondents with same vote")
      
    }  
  }, error = function(cond) { print("Error: creation of vote_mode_leaning failed.") } )  
  
  # political position
  if ("vote" %in% names(e)) {
    e$vote_agg <- as.character(e$vote) 
  }
  if (country == "US") { # Automatic classification yields Trump: Very right and all others (incl. Biden, PNR): Center
    temp <- -1*grepl("Biden", e$vote) + 2*grepl("Trump", e$vote) -0.1*(!(e$vote %in% c("Biden", "Trump")))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 2 categories. Left: Biden; Far right: Trump")
  } else if (country == "FR") {  # Automatic classification is close but leads to an inversion Fillon (center) / Macron (right) + some minor discrepancies (Arthaud as Center, Dupont-Aignan as Right, Lassalle as Center, Cheminade as Very right)
    temp <- -2*grepl("Mélenchon|Arthaud|Poutou", e$vote) -1*grepl("Hamon", e$vote) -0*grepl("Macron", e$vote) + 1*grepl("Fillon|Asselineau", e$vote) + 2*grepl("Le Pen|Dupont-Aignan", e$vote) -0.1*grepl("Cheminade|Lassalle|PNR", e$vote)
    e$vote_agg <- as.item(temp, labels = structure(c(-2, -1, 0, 1,2,-0.1), names = c("Far left", "Left","Center","Right","Far right","PNR or other")), # c("Gauche","Centre","Droite","Extrême-droite","NSP ou autre")
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 5 categories. Far left: Mélenchon|Arthaud|Poutou; Left: Hamon; Center: Macron; Right: Fillon|Asselineau; Far right: Le Pen|Dupont-Aignan")
    e$vote_main <- case_when(e$vote == "Jean-Luc Mélenchon" ~ -2,
                             e$vote == "Benoît Hamon" ~ -1,
                             e$vote == "Emmanuel Macron" ~ 0,
                             e$vote == "François Fillon" ~ 1,
                             e$vote == "Marine Le Pen" ~ 2,
                             TRUE ~ -0.1)
    e$vote_main <- as.item(e$vote_main, labels = structure(c(-2:2,-0.1), names = c("Mélenchon","Hamon","Macron","Fillon","Le Pen","PNR or other")),
                           missing.values=-0.1, annotation="vote_main: vote recoded as 5 main candidates + PNR or other.")
    # Automatic classification is the same except that Far right parties are then considered Right
  } else if (country == "DK") { 
    temp <- -2*(e$vote %in% c("Enhedslisten")) -1*(e$vote %in% c("Socialdemokratiet", "Alternativet", "Socialistisk Folkeparti")) -0*(e$vote %in% c("Radikale Venstre")) + 1*(e$vote %in% c("Det Konservative Folkeparti", "Liberal Alliance", "Venstre")) + 2*(e$vote %in% c("Dansk Folkeparti", "Nye Borgerlige")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 5 categories. Far Left: Enhedslisten; Left: Alternativet|Socialdemokratiet|Socialistisk Folkeparti; Center: Radikale Venstre; Right: Det Konservative Folkeparti|Liberal Alliance|Venstre; Far right: Dansk Folkeparti|Nye Borgerlige")
  } else if (country == "IT") { 
    temp <- -1*(e$vote %in% c("Partito Democratico", "Liberi e Uguali")) -0*(e$vote %in% c("Movimento 5 Stelle")) + 1*(e$vote %in% c("Forza Italia")) + 2*(e$vote %in% c("Lega", "Fratelli d’Italia")) -0.1*(e$vote %in% c("Other", "Altro", "PNR", "Preferisco non dirlo"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: Partito Democratico|Liberi e Uguali; Center: Movimento 5 Stelle|+Europa|Civica Popolare|Partito Autonomista Trentino Tirolese|MAIE|USEI; Right: Forza Italia|Noi con l'Italia; Far right: Lega Nord|Fratelii d'Italia")
    
  } else if (country == "PL") { 
    temp <- -1*(e$vote %in% c("Robert Biedroń", "Waldemar Witkowski")) -0*(e$vote %in% c("Szymon Hołownia", "Władysław Kosiniak-Kamysz")) + 1*(e$vote %in% c("Rafał Trzaskowski", "Stanisław Żółtek", "Marek Jakubiak", "Paweł Tanajno", "Mirosław Piotrowski")) + 2*(e$vote %in% c("Andrzej Duda", "Krzysztof Bosak")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: Robert Biedroń|Waldemar Witkowski; Center: Szymon Hołownia|Władysław Kosiniak-Kamysz; Right: Rafał Trzaskowski|Stanisław Żółtek|Marek Jakubiak|Paweł Tanajno|Mirosław Piotrowski; Far right: Andrzej Duda|Krzysztof Bosak")
    
  } else if (country == "MX") { 
    temp <- -1*(e$vote %in% c("PRD", "MORENA", "Movimiento Ciudadano", "PT", "VERDE")) -0*(e$vote %in% c("PRI")) + 1*(e$vote %in% c("PAN"))-0.1*(e$vote %in% c("Other", "Otro", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 3 categories. Left: PRD|Morena|Movimiento Ciudadano|PT|Verde; Center: PRI; Right: PAN")
    
  } else if (country == "JP") { 
    temp <- -2*(e$vote %in% c("Japanese Communist Party")) -1*(e$vote %in% c("Constitutional Democratic Party of Japan", "Social Democratic Party")) -0*(e$vote %in% c("Komeito", "Democratic Party For the People", "Japan Innovation Party")) + 1*(e$vote %in% c("Liberal Democratic Party"))-0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Far left: Japanese Communist Party; Left: Constitutional Democratic Party of Japan|Social Democratic Party; Center: Komeito|Democratic Party For the People|Japan Innovation Party; Right: Liberal Democratic Party")
    
  } else if (country == "SP") { 
    temp <- -2*(e$vote %in% c("Unidas Podemos")) -1*(e$vote %in% c("PSOE", "Esquerra Republicana")) -0*(e$vote %in% c("Ciudadanos")) + 1*(e$vote %in% c("PP")) + 2*(e$vote %in% c("VOX")) -0.1*(e$vote %in% c("Other", "Otro", "PNR", "Prefiero no decirlo"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 5 categories. Far left: Unidas Podemos; Left: PSOE|Esquerra Republicana; Center: Ciudadanos; Right: PP; Far right: VOX")
    
  } else if (country == "IA") { 
    temp <- -2*(e$vote == "Communist Party of India (Marxist) - CPI(M)") -1*(e$vote %in% c("Indian National Congress - INC", "Bahujan Samaj Party - BSP", "Samajwadi Party - SP", "All India Trinamool Congress - \tAITC", "YSR Congress Party - YSR Congress", "Dravida Munnetra Kazhagam - DMK", "Other UPA")) + 1*(e$vote %in% c("Bharatiya Janata Party - BJP", "Telugu Desam Party - TDP", "Other NDA")) + 2*(e$vote %in% c("Shiv Sena - SS")) -0.1*(e$vote %in% c("Other", "PNR", "Any other"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: Congress|BSP|TMC; Center: AAP; Right: BJP|Akaali Dal; Far right: Shiv-Sena")
    
  } else if (country == "ID") { 
    temp <- -1*(e$vote %in% c("PDI-P")) -0*(e$vote %in% c("PKB", "PAN")) + 1*(e$vote %in% c("Nasdem", "Demokrat", "PPP", "Golkar")) + 2*(e$vote %in% c("Gerindra", "PKS")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: PDI-P; Center: PKB|PAN; Right: Nasdem|Demokrat|PPP|Golkar; Far right: Gerindra|PKS")
    
  } else if (country == "SA") { 
    temp <- -2*(e$vote %in% c("Economic Freedom Fighters (EFF)")) -1*(e$vote %in% c("African National Congress (ANC)")) -0*(e$vote %in% c("Democratic Alliance (DA)")) + 1*(e$vote %in% c("Inkatha Freedom Party (IFP)")) + 2*(e$vote %in% c("Freedom Front Plus (FF Plus)")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 5 categories. Far left: Economic Freedom Fighters (EFF); Left: African National Congress (ANC); Center: Democratic Alliance (DA); Right: Inkatha Freedom Party (IFP); Far right: Freedom Front Plus (FF Plus)")
    
  } else if (country == "DE") { 
    temp <- -2*(e$vote %in% c("Die Linke")) -1*(e$vote %in% c("SPD", "Bündnis 90/ Die Grünen")) -0*(e$vote %in% c("FDP")) + 1*(e$vote %in% c("CDU/CSU")) + 2*(e$vote %in% c("AfD")) -0.1*(e$vote %in% c("Other", "Sonstige","PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 5 categories. Far left: Die Linke; Left: SPD|Bündnis 90/ Die Grünen; Center: FDP; Right: CDU/CSU; Far right: AfD")
    
  } else if (country == "CA") { 
    temp <- -1*(e$vote %in% c("Liberal", "Bloc québécois", "New Democratic", "Green")) + 1*(e$vote %in% c("Conservative")) +2*(e$vote %in% c("People's Party")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 3 categories. Left: Liberal|Bloc québécois|New Democratic|Green; Right: Conservative; Far right: People's Party")
    
  } else if (country == "AU") { 
    temp <- -1*(e$vote %in% c("Labor", "Greens")) + 1*(e$vote %in% c("Liberal/National coalition")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 2 categories. Left: Labor|Greens; Right: Liberal/National coalition")
    
  } else if (country == "UA") { 
    temp <-  -1*(e$vote %in% c("Petro Poroshenko")) -0*(e$vote %in% c("Volodymyr Zelensky", "Ioulia Tymochenko", "Iouri Boïko", "Anatoliy Hrytsenko", "Oleksandr Vilkul")) + 1*(e$vote %in% c("Ihor Smeshko", "Oleh Lyashko")) + 2*(e$vote %in% c("Ruslan Koshulynskyi")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: Petro Poroshenko; Center: Volodymyr Zelensky|Ioulia Tymochenko|Iouri Boïko|Anatoliy Hrytsenko|Oleksandr Vilkul; Right: Ihor Smeshko|Oleh Lyashko; Far right: Ruslan Koshulynskyi")
    
  } else if (country == "SK") { 
    temp <- -1*(e$vote %in% c("Moon Jae-in", "Sim Sang-jung")) -0*(e$vote %in% c("Ahn Cheol-soo")) + 1*(e$vote %in% c("Yoo Seong-min")) + 2*(e$vote %in% c("Hong Joon-pyo")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: Moon Jae-in|Sim Sang-jung; Center: Ahn Cheol-soo; Right: Yoo Seong-min; Far right: Hong Joon-pyo")
    
  } else if (country == "TR") { 
    temp <- -2*(e$vote %in% c("Vatan Partisi (VP)")) -1*(e$vote %in% c("Cumhuriyet Halk Partisi (CHP)", "Halkların Demokratik Partisi (HDP)")) -0*(e$vote %in% c("İYİ Parti")) + 1*(e$vote %in% c("Adalet ve Kalkınma Partisi (AKP)")) + 2*(e$vote %in% c("Milliyetçi Hareket Partisi (MHP)", "Saadet Partisi (SP)", "Hür Dava Partisi (HÜDAPAR)")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 5 categories. Far left: Vatan Partisi; Left: Cumhuriyet Halk Partisi|Halkların Demokratik Partisi; Center: İYİ Parti; Right: Adalet ve Kalkınma Partisi; Far right: Milliyetçi Hareket Partisi|Saadet Partisi|Hür Dava Partisi")
    
  } else if (country == "BR") { 
    temp <- -1*(e$vote %in% c("Fernando Haddad", "Marina Silva")) -0*(e$vote %in% c("Ciro Gomes", "Geraldo Alckmin", "Henrique Meirelles")) + 1*(e$vote %in% c("João Amoêdo")) + 2*(e$vote %in% c("Jair Bolsonaro", "Cabo Daciolo")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 5 categories. Far left: Guilherme Boulos; Left: Fernando Haddad|Marina Silva; Center: Ciro Gomes|Geraldo Alckmin|Henrique Meirelles|Alvaro Dias; Right: João Amoêdo; Far right: Jair Bolsonaro|Cabo Daciolo")
    
  } else if (country == "UK") { 
    temp <-  -1*(e$vote %in% c("Labour", "Green", "SNP")) -0*(e$vote %in% c("Liberal Democrats")) + 1*(e$vote %in% c("Conservative")) + 2*(e$vote %in% c("Brexit Party")) -0.1*(e$vote %in% c("Other", "PNR"))
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: Labour|Green|SNP; Center: Liberal Democrats; Right: Conservative; Far right: Brexit Party")
    
  } else if (country == "CN") { 
    temp <-  -0.1
    e$vote_agg <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1), names = c("Far left","Left", "Center", "Right","Far right","PNR or other")),
                          missing.values=-0.1, annotation="vote_agg: Vote or hypothetical vote in last election aggregated into 4 categories. Left: Labour|Green|SNP; Center: Liberal Democrats; Right: Conservative; Far right: Brexit Party")
    
  } 
  
  
  e$vote_agg_number <- as.numeric(e$vote_agg)
  label(e$vote_agg_number) <- "vote_agg_number: Numberic version of vote_agg. -2: Far left; -1: Social democratic left; 0: Center; 1: Right; 2: Far right; -0.1: PNR or other"
  
  temp <-  -1*(e$vote_agg %in% c("Far left", "Left")) -0*(e$vote_agg %in% c("Center")) + 1*(e$vote_agg %in% c("Right", "Far right")) -0.1*(e$vote_agg == -.1)
  e$vote_agg_factor <- as.factor(as.item(temp, labels = structure(c(-1,0,1,-0.1), names = c("Left", "Center", "Right","PNR or other")),
                                         annotation="vote_agg_factor: Vote or hypothetical vote in last election aggregated into 3 categories. Left/Center/Right"))
  
  
  # political position voters
  if ("vote_voters" %in% names(e)) {
    e$vote_agg_voters <- as.character(e$vote_voters) 
  }
  if (country == "US") { 
    temp <- -1*grepl("Biden", e$vote_voters) + 2*grepl("Trump", e$vote_voters) -0.3*(e$vote_participation != "Yes") -0.1*((e$vote_voters %in% c("PNR")))-0.2*((e$vote_voters %in% c("Hawkins", "Jorgensen")))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR", "Other", "Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 2 categories. Left: Biden; Far right: Trump")
    
  } else if (country == "FR") {  
    temp <- -2*grepl("Mélenchon|Arthaud|Poutou", e$vote_voters) -1*grepl("Hamon", e$vote_voters) -0*grepl("Macron", e$vote_voters) + 1*grepl("Fillon|Asselineau", e$vote_voters) + 2*grepl("Le Pen|Dupont-Aignan", e$vote_voters) -0.3*(e$vote_participation != "Yes") -0.1*grepl("PNR", e$vote_voters) -0.2*grepl("Cheminade|Lassalle", e$vote_voters)
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2, -1, 0, 1,2,-0.1,-0.2,-0.3), names = c("Far left", "Left","Center","Right","Far right","PNR","Other","Did not vote")), 
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 5 categories. Far left: Mélenchon|Arthaud|Poutou; Left: Hamon; Center: Macron; Right: Fillon|Asselineau; Far right: Le Pen|Dupont-Aignan")
    
  } else if (country == "DK") { 
    temp <- -2*(e$vote_voters %in% c("Enhedslisten")) -1*(e$vote_voters %in% c("Socialdemokratiet", "Alternativet", "Socialistisk Folkeparti")) -0*(e$vote_voters %in% c("Radikale Venstre")) + 1*(e$vote_voters %in% c("Det Konservative Folkeparti", "Liberal Alliance", "Venstre")) + 2*(e$vote_voters %in% c("Dansk Folkeparti", "Nye Borgerlige")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 5 categories. Far Left: Enhedslisten; Left: Alternativet|Socialdemokratiet|Socialistisk Folkeparti; Center: Radikale Venstre; Right: Det Konservative Folkeparti|Liberal Alliance|Venstre; Far right: Dansk Folkeparti|Nye Borgerlige")
  } else if (country == "IT") {  
    temp <- -1*(e$vote_voters %in% c("Partito Democratico", "Liberi e Uguali")) -0*(e$vote_voters %in% c("Movimento 5 Stelle")) + 1*(e$vote_voters %in% c("Forza Italia")) + 2*(e$vote_voters %in% c("Lega", "Fratelli d’Italia")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR", "Preferisco non dirlo"))-0.2*(e$vote_voters %in% c("Other", "Altro"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: Partito Democratico|Liberi e Uguali; Center: Movimento 5 Stelle|+Europa|Civica Popolare|Partito Autonomista Trentino Tirolese|MAIE|USEI; Right: Forza Italia|Noi con l'Italia; Far right: Lega Nord|Fratelii d'Italia")
    
  } else if (country == "PL") { 
    temp <- -1*(e$vote_voters %in% c("Robert Biedroń", "Waldemar Witkowski")) -0*(e$vote_voters %in% c("Szymon Hołownia", "Władysław Kosiniak-Kamysz")) + 1*(e$vote_voters %in% c("Rafał Trzaskowski", "Stanisław Żółtek", "Marek Jakubiak", "Paweł Tanajno", "Mirosław Piotrowski")) + 2*(e$vote_voters %in% c("Andrzej Duda", "Krzysztof Bosak")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: Robert Biedroń|Waldemar Witkowski; Center: Szymon Hołownia|Władysław Kosiniak-Kamysz; Right: Rafał Trzaskowski|Stanisław Żółtek|Marek Jakubiak|Paweł Tanajno|Mirosław Piotrowski; Far right: Andrzej Duda|Krzysztof Bosak")
    
  } else if (country == "MX") { 
    temp <- -1*(e$vote_voters %in% c("PRD", "MORENA", "Movimiento Ciudadano", "PT", "VERDE")) -0*(e$vote_voters %in% c("PRI")) + 1*(e$vote_voters %in% c("PAN"))-0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other", "Otro"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 3 categories. Left: PRD|Morena|Movimiento Ciudadano|PT|Verde; Center: PRI; Right: PAN")
    
  } else if (country == "JP") { 
    temp <- -2*(e$vote_voters %in% c("Japanese Communist Party")) -1*(e$vote_voters %in% c("Constitutional Democratic Party of Japan", "Social Democratic Party")) -0*(e$vote_voters %in% c("Komeito", "Democratic Party For the People", "Japan Innovation Party")) + 1*(e$vote_voters %in% c("Liberal Democratic Party"))-0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR")) -0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Far left: Japanese Communist Party; Left: Constitutional Democratic Party of Japan|Social Democratic Party; Center: Komeito|Democratic Party For the People|Japan Innovation Party; Right: Liberal Democratic Party")
    
  } else if (country == "SP") { 
    temp <- -2*(e$vote_voters %in% c("Unidas Podemos")) -1*(e$vote_voters %in% c("PSOE", "Esquerra Republicana")) -0*(e$vote_voters %in% c("Ciudadanos")) + 1*(e$vote_voters %in% c("PP")) + 2*(e$vote_voters %in% c("VOX")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR", "Prefiero no decirlo"))-0.2*(e$vote_voters %in% c("Other", "Otro"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 5 categories. Far left: Unidas Podemos; Left: PSOE|Esquerra Republicana; Center: Ciudadanos; Right: PP; Far right: VOX")
    
  } else if (country == "IA") { 
    temp <- -2*(e$vote_voters == "Communist Party of India (Marxist) - CPI(M)") -1*(e$vote_voters %in% c("Indian National Congress - INC", "Bahujan Samaj Party - BSP", "Samajwadi Party - SP", "All India Trinamool Congress - \tAITC", "YSR Congress Party - YSR Congress", "Dravida Munnetra Kazhagam - DMK", "Other UPA")) + 1*(e$vote_voters %in% c("Bharatiya Janata Party - BJP", "Telugu Desam Party - TDP", "Other NDA")) + 2*(e$vote_voters %in% c("Shiv Sena - SS")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other", "Any other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: Congress|BSP|TMC; Center: AAP; Right: BJP|Akaali Dal; Far right: Shiv-Sena")
    
  } else if (country == "ID") { 
    temp <- -1*(e$vote_voters %in% c("PDI-P")) -0*(e$vote_voters %in% c("PKB", "PAN")) + 1*(e$vote_voters %in% c("Nasdem", "Demokrat", "PPP", "Golkar")) + 2*(e$vote_voters %in% c("Gerindra", "PKS")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: PDI-P; Center: PKB|PAN; Right: Nasdem|Demokrat|PPP|Golkar; Far right: Gerindra|PKS")
    
  } else if (country == "SA") { 
    temp <- -2*(e$vote_voters %in% c("Economic Freedom Fighters (EFF)")) -1*(e$vote_voters %in% c("African National Congress (ANC)")) -0*(e$vote_voters %in% c("Democratic Alliance (DA)")) + 1*(e$vote_voters %in% c("Inkatha Freedom Party (IFP)")) + 2*(e$vote_voters %in% c("Freedom Front Plus (FF Plus)")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 5 categories. Far left: Economic Freedom Fighters (EFF); Left: African National Congress (ANC); Center: Democratic Alliance (DA); Right: Inkatha Freedom Party (IFP); Far right: Freedom Front Plus (FF Plus)")
    
  } else if (country == "DE") { 
    temp <- -2*(e$vote_voters %in% c("Die Linke")) -1*(e$vote_voters %in% c("SPD", "Bündnis 90/ Die Grünen")) -0*(e$vote_voters %in% c("FDP")) + 1*(e$vote_voters %in% c("CDU/CSU")) + 2*(e$vote_voters %in% c("AfD")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR")) -0.2*(e$vote_voters %in% c("Other", "Sonstige"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 5 categories. Far left: Die Linke; Left: SPD|Bündnis 90/ Die Grünen; Center: FDP; Right: CDU/CSU; Far right: AfD")
    
  } else if (country == "CA") { 
    temp <- -1*(e$vote_voters %in% c("Liberal", "Bloc québécois", "New Democratic", "Green")) + 1*(e$vote_voters %in% c("Conservative")) +2*(e$vote_voters %in% c("People's Party")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 3 categories. Left: Liberal|Bloc québécois|New Democratic|Green; Right: Conservative; Far right: People's Party")
    
  } else if (country == "AU") { 
    temp <- -1*(e$vote_voters %in% c("Labor", "Greens")) + 1*(e$vote_voters %in% c("Liberal/National coalition")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 2 categories. Left: Labor|Greens; Right: Liberal/National coalition")
    
  } else if (country == "UA") { 
    temp <-  -1*(e$vote_voters %in% c("Petro Poroshenko")) -0*(e$vote_voters %in% c("Volodymyr Zelensky", "Ioulia Tymochenko", "Iouri Boïko", "Anatoliy Hrytsenko", "Oleksandr Vilkul")) + 1*(e$vote_voters %in% c("Ihor Smeshko", "Oleh Lyashko")) + 2*(e$vote_voters %in% c("Ruslan Koshulynskyi")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: Petro Poroshenko; Center: Volodymyr Zelensky|Ioulia Tymochenko|Iouri Boïko|Anatoliy Hrytsenko|Oleksandr Vilkul; Right: Ihor Smeshko|Oleh Lyashko; Far right: Ruslan Koshulynskyi")
    
  } else if (country == "SK") { 
    temp <- -1*(e$vote_voters %in% c("Moon Jae-in", "Sim Sang-jung")) -0*(e$vote_voters %in% c("Ahn Cheol-soo")) + 1*(e$vote_voters %in% c("Yoo Seong-min")) + 2*(e$vote_voters %in% c("Hong Joon-pyo")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: Moon Jae-in|Sim Sang-jung; Center: Ahn Cheol-soo; Right: Yoo Seong-min; Far right: Hong Joon-pyo")
    
  } else if (country == "TR") { 
    temp <- -2*(e$vote_voters %in% c("Vatan Partisi (VP)")) -1*(e$vote_voters %in% c("Cumhuriyet Halk Partisi (CHP)", "Halkların Demokratik Partisi (HDP)")) -0*(e$vote_voters %in% c("İYİ Parti")) + 1*(e$vote_voters %in% c("Adalet ve Kalkınma Partisi (AKP)")) + 2*(e$vote_voters %in% c("Milliyetçi Hareket Partisi (MHP)", "Saadet Partisi (SP)", "Hür Dava Partisi (HÜDAPAR)")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 5 categories. Far left: Vatan Partisi; Left: Cumhuriyet Halk Partisi|Halkların Demokratik Partisi; Center: İYİ Parti; Right: Adalet ve Kalkınma Partisi; Far right: Milliyetçi Hareket Partisi|Saadet Partisi|Hür Dava Partisi")
    
  } else if (country == "BR") { 
    temp <- -1*(e$vote_voters %in% c("Fernando Haddad", "Marina Silva")) -0*(e$vote_voters %in% c("Ciro Gomes", "Geraldo Alckmin", "Henrique Meirelles")) + 1*(e$vote_voters %in% c("João Amoêdo")) + 2*(e$vote_voters %in% c("Jair Bolsonaro", "Cabo Daciolo")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 5 categories. Far left: Guilherme Boulos; Left: Fernando Haddad|Marina Silva; Center: Ciro Gomes|Geraldo Alckmin|Henrique Meirelles|Alvaro Dias; Right: João Amoêdo; Far right: Jair Bolsonaro|Cabo Daciolo")
    
  } else if (country == "UK") { 
    temp <-  -1*(e$vote_voters %in% c("Labour", "Green", "SNP")) -0*(e$vote_voters %in% c("Liberal Democrats")) + 1*(e$vote_voters %in% c("Conservative")) + 2*(e$vote_voters %in% c("Brexit Party")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_voters %in% c("PNR"))-0.2*(e$vote_voters %in% c("Other"))
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: Labour|Green|SNP; Center: Liberal Democrats; Right: Conservative; Far right: Brexit Party")
    
  } else if (country == "CN") { 
    temp <-  -0.1
    e$vote_agg_voters <- as.item(temp, labels = structure(c(-2,-1,0,1,2,-0.1,-0.2,-0.3), names = c("Far left","Left", "Center", "Right","Far right","PNR","Other","Did not vote")),
                                 missing.values=-0.1, annotation="vote_agg_voters: Vote in last election aggregated into 4 categories. Left: Labour|Green|SNP; Center: Liberal Democrats; Right: Conservative; Far right: Brexit Party")
    e$vote_participation <- NA
    
  } 
  
  
  e$vote_agg_voters_number <- as.numeric(e$vote_agg_voters)
  label(e$vote_agg_voters_number) <- "vote_agg_voters_number: Numberic version of vote_agg_voters. -2: Far left; -1: Social democratic left; 0: Center; 1: Right; 2: Far right; -0.1: PNR; -0.2: Other; -0.3: Did not vote"
  
  temp <-  -1*(e$vote_agg_voters %in% c("Far left", "Left")) -0*(e$vote_agg_voters %in% c("Center")) + 1*(e$vote_agg_voters %in% c("Right", "Far right")) -0.3*(e$vote_participation != "Yes") -0.1*(e$vote_agg_voters == -.1)-0.2*(e$vote_agg_voters == -.2)
  e$vote_agg_voters_factor <- as.factor(as.item(temp, labels = structure(c(-1,0,1,-0.1,-0.2,-0.3), names = c("Left", "Center", "Right","PNR","Other","Did not vote")),
                                                annotation="vote_agg_voters_factor: Vote in last election aggregated into 3 categories. Left/Center/Right"))
  
  
  
  if (country == "US") {
    e$vote_2020 <- "Other/Non-voter" # What respondent voted in 2020. But vote, vote_2016 is what candidate they support (i.e. what they voted or what they would have voted if they had voted)
    e$vote_2020[e$vote_participation %in% c("No right to vote", "PNR") | e$vote_voters=="PNR"] <- "PNR/no right"
    e$vote_2020[e$vote_voters == "Biden"] <- "Biden"
    e$vote_2020[e$vote_voters == "Trump"] <- "Trump"
    e$vote_2020 <- as.item(e$vote_2020, annotation = "vote_2020: Biden / Trump / Other/Non-voter / PNR/No right. True proportions: .342/.313/.333/.0")
    missing.values(e$vote_2020) <- "PNR/no right"
    e$vote3 <- e$vote_2020
    e$vote3[e$vote_2020 %in% c("PNR/no right", "Other/Non-voter")] <- "other"
  }
  
  if (country == "FR") {
    e$know_local_damage <- case_when(e$know_local_damage == "Flooding" ~ "Ozone hole",
                                     e$know_local_damage == "More rain" ~ "More heatwaves",
                                     e$know_local_damage == "Damaging of marine ecosystems" ~ "More forest fires",
                                     e$know_local_damage == "Ozone hole" ~ "Flooding",
                                     e$know_local_damage == "PNR" ~ "PNR")
  }
  
  if ("know_temperature_2100" %in% names(e)) { 
    e$know_treatment_climate <- (e$know_temperature_2100 %in% text_know_temperature_2100) + (e$know_local_damage  %in% text_know_local_damage)
    if ("know_standard" %in% names(e)) { e$know_treatment_policy <- (e$know_standard  %in% text_know_standard) + (e$know_investments_jobs  %in% text_know_investments_jobs)
    } else e$know_treatment_policy <- (e$know_ban  %in% text_know_ban) + (e$know_investments_funding  %in% text_know_investments_funding)
    e$know_treatment_climate[e$treatment_climate == 0] <- NA
    e$know_treatment_policy[e$treatment_policy == 0] <- NA
    label(e$know_treatment_climate) <- "know_treatment_climate: Number of good responses among the 2 knowledge questions related to treatment content: temperature_2100 = 8°F (4 °C) & know_local_damage = 70 days per year / Ozone hole (depending on country)"
    label(e$know_treatment_policy) <- "know_treatment_policy: Number of good responses among the 2 knowledge questions related to treatment content: ban = A ban on combustion-engine cars & investments_funding = Additional government debt (for the US, second one is 1.5 million jobs instead)"
    e$know_temperature_2100_correct <- e$know_temperature_2100 %in% text_know_temperature_2100
    e$know_local_damage_correct <- e$know_local_damage  %in% text_know_local_damage
    e$know_temperature_2100_correct[e$treatment_climate == 0] <- e$know_local_damage_correct[e$treatment_climate == 0] <- NA
    if ("know_standard" %in% names(e)) {
      e$know_standard_correct <- e$know_standard  %in% text_know_standard
      e$know_investments_jobs_correct <- e$know_investments_jobs  %in% text_know_investments_jobs
      e$know_standard_correct[e$treatment_policy == 0] <- e$know_investments_jobs_correct[e$treatment_policy == 0] <- NA
    } else {
      e$know_investments_funding_correct <- e$know_investments_funding  %in% text_know_investments_funding
      e$know_ban_correct <- e$know_ban  %in% text_know_ban
      e$know_investments_funding_correct[e$treatment_policy == 0] <- e$know_ban_correct[e$treatment_policy == 0] <- NA }
  }
  
  
  
  if ("GHG_methane" %in% names(e)) {
    e$score_GHG <- e$GHG_CO2 + e$GHG_methane - e$GHG_H2 - e$GHG_particulates + 2 
    e$know_GHG_CO2 <- e$GHG_CO2
    e$know_GHG_methane <- e$GHG_methane
    e$know_GHG_H2 <- ifelse(e$GHG_H2, F, T)
    e$know_GHG_particulates <- ifelse(e$GHG_particulates, F, T)
    label(e$score_GHG) <- "score_GHG: Score to the knowledge of GHG [0;+4] = CO2 + methane - H2 - particulates + 2"
    label(e$know_GHG_CO2) <- "know_GHG_CO2: Correct answer that CO2 is a GHG"
    label(e$know_GHG_methane) <- "know_GHG_methane: Correct answer that methane is a GHG"
    label(e$know_GHG_H2) <- "know_GHG_H2: Correct answer that H2 is not a GHG"
    label(e$know_GHG_particulates) <- "know_GHG_particulates: Correct answer that particulates is not a GHG"
  }
  
  if ("CC_anthropogenic" %in% names(e)) e$knows_anthropogenic <- e$CC_anthropogenic == 2
  
  if (all(c("CC_impacts_droughts", "CC_impacts_sea_rise", "CC_impacts_volcanos") %in% names(e))) {
    e$score_CC_impacts <- (e$CC_impacts_droughts>0) + (e$CC_impacts_sea_rise>0) + (e$CC_impacts_volcanos==-2) + (e$CC_impacts_volcanos<=-1)
    label(e$score_CC_impacts) <- "score_CC_impacts: Score of knowledge of impacts from CC. Droughts > 0 (somewhat/very likely) + sea-level rise > 0 + volcanos <= -1 (somewhat unlikely) + volcanos == -2 (very unlikely)"
    e$know_impacts_droughts <- e$CC_impacts_droughts > 0
    e$know_impacts_sea_rise <- e$CC_impacts_sea_rise > 0
    e$know_impacts_volcanos <- e$CC_impacts_volcanos <= -1
  }
  
  for (i in seq_along(variables_matrices)) if (length(intersect(variables_matrices[[i]], names(e))) > 0) {
    e[[paste0("spread_", names(variables_matrices)[i])]] <- apply(X = e[, intersect(variables_matrices[[i]], names(e))], MARGIN = 1, FUN = function(v) return(max(v, na.rm = T) - min(v, na.rm = T)))
    e[[paste0("all_same_", names(variables_matrices)[i])]] <- e[[paste0("spread_", names(variables_matrices)[i])]] == 0
    label(e[[paste0("spread_", names(variables_matrices)[i])]]) <- paste0("spread_", names(variables_matrices)[i], ": Spread between max and min value in the respondent's answers to the matrix ", names(variables_matrices)[i])
    label(e[[paste0("all_same_", names(variables_matrices)[i])]]) <- paste0("all_same_", names(variables_matrices)[i], ": T/F Indicator that all answers to the matrix ", names(variables_matrices)[i], " are identical.")
  }
  variables_spread <<- intersect(paste0("spread_", names(variables_matrices)), names(e))
  variables_all_same <<- intersect(paste0("all_same_", names(variables_matrices)), names(e))
  names_matrices <<- gsub("all_same_", "", variables_all_same)
  e$mean_spread <- rowMeans(e[, variables_spread], na.rm = T)
  e$share_all_same <- rowMeans(e[, variables_all_same], na.rm = T)
  label(e$mean_spread) <- paste0("mean_spread: Mean spread between max and min value in the respondent's answers to the matrices (averaged over the matrices: ", paste(names_matrices, collapse = ", "), "). -Inf indicates that all answers were NA.")
  label(e$share_all_same) <- paste0("mean_spread: Share of matrices to which all respondent's answers are identical (among matrices: ",  paste(names_matrices, collapse = ", "), ").")
  
  
  if ("footprint_reg_US" %in% names(e)) { # manages ties in ranking
    rerank_fully <- function(original_ranking) {
      # Re-ranks an ranking within 1-4 so that it becomes a full ranking, i.e. no number appears twice. Does so by splitting ties in a way that get closer to the true ranking: 1:4. Works only for vectors of size 4.
      ranking <- original_ranking
      for (i in 1:4) { if (is.na(ranking[i])) ranking[i] <- i }
      ranking[ranking==max(ranking)] <- 4
      ranking[ranking==min(ranking)] <- 1
      if (max(sum(ranking==2), sum(ranking==3))==2) {
        tie <- which(ranking %in% 2:3)
        ranking[min(tie)] <- 2
        ranking[max(tie)] <- 3
      } 
      if (max(sum(ranking==1), sum(ranking==4))==4) ranking <- 1:4 # respondents who have no idea of the ranking are considered as knowing the full ranking.
      if (sum(ranking==1)==3) { 
        tie <- which(ranking == 1)
        ranking[tie[1]] <- 1
        ranking[tie[2]] <- 2
        ranking[tie[3]] <- 3
      }
      if (sum(ranking==4)==3) {
        tie <- which(ranking == 4)
        ranking[tie[1]] <- 2
        ranking[tie[2]] <- 3
        ranking[tie[3]] <- 4
      }
      if (sum(ranking==1)==2) {
        tie <- which(ranking == 1)
        ranking[min(tie)] <- 1
        ranking[max(tie)] <- 2
      }
      if (sum(ranking==4)==2) {
        tie <- which(ranking == 4)
        ranking[min(tie)] <- 3
        ranking[max(tie)] <- 4
      }
      return(ranking)
    }   
    
    e$footprint_pc_nb_distinct <- apply(e[,Variables_footprint$pc], MARGIN = 1, FUN = function(vec) { length(unique(vec[!is.na(vec)])) })
    e$footprint_reg_nb_distinct <- apply(e[,Variables_footprint$reg], MARGIN = 1, FUN = function(vec) { length(unique(vec[!is.na(vec)])) })
    e$footprint_pc_full_ranking <- e$footprint_pc_nb_distinct == 4 
    e$footprint_reg_full_ranking <- e$footprint_reg_nb_distinct == 4
    label(e$footprint_pc_nb_distinct) <- "footprint_pc_nb_distinct: Number of distinct ranks in the ranking of footprint per capita"
    label(e$footprint_reg_nb_distinct) <- "footprint_reg_nb_distinct: Number of distinct ranks in the ranking of total regional footprint"
    label(e$footprint_pc_full_ranking) <- "footprint_pc_full_ranking: TRUE if the ranking of the footprint per capita is full (i.e. there is no pair of regions with the same ranking)"
    label(e$footprint_reg_full_ranking) <- "footprint_reg_full_ranking: TRUE if the ranking of the regional footprint is full (i.e. there is no pair of regions with the same ranking)"
    
    for (v in c("pc", "reg")) for (c in c("US", "EU", "china", "india")) e[[paste("footprint", v, c, "original", sep="_")]] <- e[[paste("footprint", v, c, sep="_")]]
    for (n in 1:nrow(e)) {
      if (!e$footprint_pc_full_ranking[n]) {
        corrected_ranking <- rerank_fully(c(e$footprint_pc_US[n], e$footprint_pc_EU[n], e$footprint_pc_china[n], e$footprint_pc_india[n]))
        e$footprint_pc_US[n] <- corrected_ranking[1]
        e$footprint_pc_EU[n] <- corrected_ranking[2]
        e$footprint_pc_china[n] <- corrected_ranking[3]
        e$footprint_pc_india[n] <- corrected_ranking[4]
      }
      if (!e$footprint_reg_full_ranking[n]) {
        corrected_ranking <- rerank_fully(c(e$footprint_reg_china[n], e$footprint_reg_US[n], e$footprint_reg_EU[n], e$footprint_reg_india[n]))
        e$footprint_reg_china[n] <- corrected_ranking[1]
        e$footprint_reg_US[n] <- corrected_ranking[2]
        e$footprint_reg_EU[n] <- corrected_ranking[3]
        e$footprint_reg_india[n] <- corrected_ranking[4]
      }
    }
    if (!("footprint_pc_country") %in% names(e)) {
      if (country == "US") e$footprint_pc_country <- e$footprint_pc_US
      else if (country %in% euro_countries) e$footprint_pc_country <- e$footprint_pc_EU
      else if (country == "CN") e$footprint_pc_country <- e$footprint_pc_china
      else if (country == "IA") e$footprint_pc_country <- e$footprint_pc_india
      label(e$footprint_pc_country) <- "footprint_pc_country: In which region does the consumption of an average person contribute most to greenhouse gas emissions?\n\n\n\nPlease rank the regions from 1 (most) to 4 (least). - [region]"
    }
    e$correct_footprint_pc_compare_US <- e$footprint_pc_china > e$footprint_pc_US
    e$correct_footprint_pc_compare_own <- case_when(country %in% c("US", "AU", "CA", euro_countries, "JP", "SK") ~ e$footprint_pc_china > e$footprint_pc_country, 
                                                    country %in% c("ID", "BR", "MX") ~ e$footprint_pc_country > e$footprint_pc_china,
                                                    country %in% c("TR", "SA", "UA") ~ e$footprint_pc_country < e$footprint_pc_india,
                                                    country %in% c("CN", "IA") ~ e$footprint_pc_india > e$footprint_pc_china) 
    label(e$correct_footprint_pc_compare_own) <- "correct_footprint_pc_compare_own: T/F Correctly assesses which is higher between own region's per capita emissions and those of China (or of India for CN, SA, TR, UA)"
    label(e$correct_footprint_pc_compare_US) <- "correct_footprint_pc_compare_US: T/F Correctly assesses that US per capita emissions are higher than China's"
  }
  
  if ("footprint_el_coal" %in% names(e)) {
    e$footprint_pc_nb_na <- apply(e[,Variables_footprint$pc], MARGIN = 1, FUN = function(vec) { sum(is.na(vec)) })
    e$footprint_reg_nb_na <- apply(e[,Variables_footprint$reg], MARGIN = 1, FUN = function(vec) { sum(is.na(vec)) }) 
    label(e$footprint_pc_nb_na) <- "footprint_pc_nb_na: Number of NA ranks in the ranking of footprint per capita" # https://en.wikipedia.org/wiki/List_of_countries_by_carbon_dioxide_emissions_per_capita
    label(e$footprint_reg_nb_na) <- "footprint_reg_nb_na: Number of NA ranks in the ranking of total regional footprint" # https://en.wikipedia.org/wiki/List_of_countries_by_greenhouse_gas_emissions http://www.globalcarbonatlas.org/en/CO2-emissions
    if ("footprint_el_wind" %in% names(e)) e$score_footprint_elec <- AllSeqDists(cbind(e$footprint_el_coal, e$footprint_el_gas, e$footprint_el_wind)) 
    else e$score_footprint_elec <- ifelse(is.na(e$footprint_el_coal), NA, AllSeqDists(cbind(e$footprint_el_coal, e$footprint_el_gas, e$footprint_el_nuclear)))
    e$score_footprint_food <- ifelse(is.na(e$footprint_fd_beef), NA, AllSeqDists(cbind(e$footprint_fd_beef, e$footprint_fd_chicken, e$footprint_fd_pasta)))
    e$score_footprint_transport <- ifelse(is.na(e$footprint_tr_car), NA, AllSeqDists(cbind(e$footprint_tr_plane, e$footprint_tr_car, e$footprint_tr_coach)))
    e$score_footprint_pc <- AllSeqDists(cbind(e$footprint_pc_US, e$footprint_pc_EU, e$footprint_pc_china, e$footprint_pc_india)) + 2*e$footprint_pc_nb_na
    if ("footprint_reg_US" %in% names(e)) e$score_footprint_region <- (AllSeqDists(cbind(e$footprint_reg_china, e$footprint_reg_US, e$footprint_reg_EU, e$footprint_reg_india)) + AllSeqDists(cbind(e$footprint_reg_china, e$footprint_reg_US, e$footprint_reg_india, e$footprint_reg_EU)))/2 + 2*e$footprint_reg_nb_na 
    label(e$score_footprint_elec) <- "e$score_footprint_elec: Kendall distance with true ranking of electricity footprints: coal>gas>nuclear" # Pehl et al. (2017)
    label(e$score_footprint_food) <- "e$score_footprint_food: Kendall distance with true ranking of food footprints: beef>chicken>pasta" # Poore & Nemecek (2018)
    label(e$score_footprint_transport) <- "e$score_footprint_transport: Kendall distance with true ranking of transport footprints: plane>car>coach" # US: https://jamesrivertrans.com/wp-content/uploads/2012/05/ComparativeEnergy.pdf https://www.nationalgeographic.com/travel/article/carbon-footprint-transportation-efficiency-graphic EU: http://ecopassenger.hafas.de/bin/query.exe/en?L=vs_uic&
    label(e$score_footprint_pc) <- "e$score_footprint_pc: Kendall distance with true ranking of per capita footprints: US>EU>China>India (when there is a tie in the respondent's ranking, we solve it to their advantage)"
    if ("footprint_reg_US" %in% names(e)) label(e$score_footprint_region) <- "e$score_footprint_region: Kendall distance with true ranking of region footprints: China>US>EU=India (when there is a tie in the respondent's ranking, we solve it to their advantage)"
    e$know_footprint_elec <- e$score_footprint_elec == 0
    e$know_footprint_food <- e$score_footprint_food == 0
    e$know_footprint_transport <- e$score_footprint_transport == 0
    e$know_footprint_pc <- e$score_footprint_pc == 0
    if ("footprint_reg_US" %in% names(e)) e$know_footprint_region <- e$score_footprint_region == 0
    label(e$know_footprint_elec) <- "know_footprint_elec: Correct answer to the ranking of electricity footprints"
    label(e$know_footprint_food) <- "know_footprint_food: Correct answer to the ranking of food footprints"
    label(e$know_footprint_transport) <- "know_footprint_transport: Correct answer to the ranking of transport footprints"
    label(e$know_footprint_pc) <- "know_footprint_pc: Correct answer to the ranking of per capita footprints (when there is a tie in the respondent's ranking, we solve it to their advantage)"
    if ("footprint_reg_US" %in% names(e)) label(e$know_footprint_region) <- "know_footprint_region: Correct answer to the ranking of region footprints (when there is a tie in the respondent's ranking, we solve it to their advantage)"
    e$most_footprint_el <- e$most_footprint_fd <- e$most_footprint_tr <- e$most_footprint_reg <- e$most_footprint_pc <- e$least_footprint_pc <- e$least_footprint_el <- e$least_footprint_fd <- e$least_footprint_tr <- e$least_footprint_reg <- e$least_footprint_no_pnr_reg <- e$least_footprint_no_pnr_pc <- "PNR"
    for (v in c("reg", "pc")) {
      for (i in Variables_footprint[[v]]) if (i %in% names(e)) e[[paste("least_footprint_no_pnr", v, sep="_")]][e[[paste(i, "original", sep="_")]]==1] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
      for (i in Variables_footprint[[v]]) if (i %in% names(e)) e[[paste("least_footprint_no_pnr", v, sep="_")]][e[[paste(i, "original", sep="_")]]==2] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
      for (i in Variables_footprint[[v]]) if (i %in% names(e)) e[[paste("least_footprint_no_pnr", v, sep="_")]][e[[paste(i, "original", sep="_")]]==3] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
      for (i in Variables_footprint[[v]]) if (i %in% names(e)) e[[paste("least_footprint_no_pnr", v, sep="_")]][e[[paste(i, "original", sep="_")]]==4] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
      for (i in Variables_footprint[[v]]) if (length(Variables_footprint[[v]])==5 & i %in% names(e)) e[[paste("least_footprint_no_pnr", v, sep="_")]][e[[paste(i, "original", sep="_")]]==5] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
    }
    for (v in c("el", "fd", "tr", "reg", "pc")) {
      for (i in Variables_footprint[[v]]) {
        if (i %in% names(e)) {
          if (v %in% c("el", "fd", "tr")) e[[paste("most_footprint", v, sep="_")]][e[[i]]==1] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
          if (v %in% c("el", "fd", "tr")) e[[paste("least_footprint", v, sep="_")]][e[[i]]==3] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i)) 
          if (v %in% c("reg", "pc")) e[[paste("most_footprint", v, sep="_")]][e[[paste(i, "original", sep="_")]]==1] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
          if (v %in% c("reg", "pc")) e[[paste("least_footprint", v, sep="_")]][e[[paste(i, "original", sep="_")]]==length(Variables_footprint[[v]])] <- capitalize(sub(paste("footprint_", v, "_", sep=""), "", i))
        } }
      e[[paste("most_footprint", v, sep="_")]] <- as.item(as.vector(e[[paste("most_footprint", v, sep="_")]]), missing.values = "PNR", annotation = paste("most_footprint_", v, ": Largest footprint of type ", v, " according to the respondent", sep=""))
      e[[paste("least_footprint", v, sep="_")]] <- as.item(as.vector(e[[paste("least_footprint", v, sep="_")]]), missing.values = "PNR", annotation = paste("least_footprint_", v, ": Smallest footprint of type ", v, " according to the respondent", sep=""))
      if (v %in% c("reg", "pc")) e[[paste("least_footprint_no_pnr", v, sep="_")]] <- as.item(as.vector(e[[paste("least_footprint_no_pnr", v, sep="_")]]), missing.values = "PNR", annotation = paste("least_footprint_no_pnr_", v, ": Smallest footprint of type ", v, " according to the respondent. In case of ties, a region is picked in this order of priority: IA,CN,EU,US", sep=""))
    }
    e$knows_beef_footprint <- e$footprint_fd_beef == 1
    label(e$knows_beef_footprint) <- "knows_beef_footprint: T/F Correctly ranks footprint of beef (or lamb for India) above chicken and pasta."
  }
  
  if (country %in% c("DE", "IT", "PL", "SP")) {
    e$variant_fine <- "prefer"
    e$variant_fine[!is.pnr(e$standard_10k_fine)] <- "10k"
    e$variant_fine[!is.pnr(e$standard_100k_fine)] <- "100k"
    for (v in variables_fine_prefer) {
      e$standard_prefer_most[e[[v]]==1] <- capitalize(sub("_", " ", sub("standard_prefer_", "", v)))
      e$standard_prefer_middle[e[[v]]==2] <- capitalize(sub("_", " ", sub("standard_prefer_", "", v)))
      e$standard_prefer_least[e[[v]]==3] <- capitalize(sub("_", " ", sub("standard_prefer_", "", v))) }
    label(e$standard_prefer_most) <- "standard_prefer_most: Variant of the ban of combustion-engine cars preferred by the respondent."
    label(e$standard_prefer_middle) <- "standard_prefer_middle: Variant of the ban of combustion-engine cars ranked in second position (among 3) by the respondent."
    label(e$standard_prefer_least) <- "standard_prefer_least: Variant of the ban of combustion-engine cars least preferred by the respondent."
  }
  
  ## 5. Complementary wave
  if (grepl("compl", wave)) {
    e$treatment_list_experiment_policy <- e$treatment_list_experiment_policy > .5
    e$treatment_list_experiment_behavior <- e$treatment_list_experiment_behavior > .5
    e$treatment_knowledge <- e$treatment_knowledge > .5
    
    e$treatment_investments <- e$treatment_investments > .5
    e$treatment_ban <- e$treatment_ban > .5
    e$treatment_tax <- e$treatment_tax > .5
    
    e$list_experiment_policy <- e$list_experiment_policy_tax
    e$list_experiment_policy[e$treatment_list_experiment_policy == FALSE] <- e$list_experiment_policy_control[e$treatment_list_experiment_policy == FALSE]
    e$list_experiment_behavior <- e$list_experiment_behavior_beef
    e$list_experiment_behavior[e$treatment_list_experiment_behavior == FALSE] <- e$list_experiment_behavior_control[e$treatment_list_experiment_behavior == FALSE]
    
    e$list_experiment_policy_num <- as.numeric(e$list_experiment_policy)
    e$list_experiment_behavior_num <- as.numeric(e$list_experiment_behavior)

    for (v in c("tax_transfers_win_lose_poor_new")) {
      temp <- case_when(e[[v]] == "Win" ~ 1, e[[v]] == "Neither win nor lose" ~ 0, e[[v]] == "Lose" ~ -1)
      e[[v]] <- as.item(temp, labels = structure(-1:1,  names = c("Lose", "Neither win nor lose", "Win")), annotation=Label(e[[v]]))
    }

    for (v in c("standard_win_lose_poor_new", "investments_effect_low_skill_jobs", "standard_effect_less_emission_new", "tax_transfers_effect_less_emission_new", "investments_effect_elec_greener_new")) {
      temp <- case_when(e[[v]] == "Increase" ~ 1, e[[v]] == "Neither increase nor decrease" ~ 0, e[[v]] == "Decrease" ~ -1)
      e[[v]] <- as.item(temp, labels = structure(-1:1,  names = c("Decrease", "Neither increase nor decrease", "Increase")), annotation=Label(e[[v]]))
    }
    
    temp <- case_when(e$CC_problem_pew == "Not a problem" ~ -1, e$CC_problem_pew == "Not too serious" ~ 0, e$CC_problem_pew == "A somewhat serious problem" ~ 1, e$CC_problem_pew == "A very serious problem" ~ 2)
    e$CC_problem_pew <- as.item(temp, labels = structure(-1:2,  names = c("Not a problem", "Not too serious", "A somewhat serious problem", "A very serious problem")), annotation=Label(e$CC_problem_pew))
    
    temp <- case_when(e$should_fight_CC_wb == "Does" ~ 1, e$should_fight_CC_wb == "Does not" ~ 0)
    e$should_fight_CC_wb <- as.item(temp, labels = structure(0:1,  names = c("Does not", "Does")), annotation=Label(e$should_fight_CC_wb))
    
    temp <- case_when(e$CC_affects_self_pew == "Not at all concerned" ~ -1, e$CC_affects_self_pew == "Not too concerned" ~ 0, e$CC_affects_self_pew == "Somewhat concerned" ~ 1, e$CC_affects_self_pew == "Very concerned" ~ 2)
    e$CC_affects_self_pew <- as.item(temp, labels = structure(-1:2,  names = c("Not at all concerned", "Not too concerned", "Somewhat concerned", "Very concerned")), annotation=Label(e$CC_affects_self_pew))
    
    temp <- case_when(e$CC_will_end_pew == "Not at all confident" ~ -1, e$CC_will_end_pew == "Not too confident" ~ 0, e$CC_will_end_pew == "Somewhat confident" ~ 1, e$CC_will_end_pew == "Very confident" ~ 2)
    e$CC_will_end_pew <- as.item(temp, labels = structure(-1:2,  names = c("Not at all confident", "Not too confident", "Somewhat confident", "Very confident")), annotation=Label(e$CC_will_end_pew))
    
    temp <- case_when(e$CC_affects_self_gallup == "Not a threat at all" ~ -1, e$CC_affects_self_gallup == "Somewhat serious threat" ~ 0, e$CC_affects_self_gallup == "Very serious threat" ~ 1)
    e$CC_affects_self_gallup <- as.item(temp, labels = structure(-1:1,  names = c("Not a threat at all", "Somewhat serious threat", "Very serious threat")), annotation=Label(e$CC_affects_self_gallup))
    
    temp <- case_when(e$effect_halt_CC_economy_pew == "Mostly harm the U.S. economy" ~ -1, e$effect_halt_CC_economy_pew == "Have no impact" ~ 0, e$effect_halt_CC_economy_pew == "Mostly benefit the U.S. economy" ~ 1)
    e$effect_halt_CC_economy_pew <- as.item(temp, labels = structure(-1:1,  names = c("Mostly harm the U.S. economy", "Have no impact", "Mostly benefit the U.S. economy")), annotation=Label(e$effect_halt_CC_economy_pew))
    
    temp <- case_when(e$CC_affects_self_leiserowitz == "None at all" ~ -1, e$CC_affects_self_leiserowitz == "Only a little" ~ 0, e$CC_affects_self_leiserowitz == "A moderate amount" ~ 1, e$CC_affects_self_leiserowitz == "A great deal" ~ 2)
    e$CC_affects_self_leiserowitz <- as.item(temp, labels = structure(-1:2,  names = c("None at all", "Only a little", "A moderate amount", "A great deal")), annotation=Label(e$CC_affects_self_leiserowitz))
    
    temp <- case_when(e$CC_concern_group_leiserowitz == "Not at all concerned" ~ -1, e$CC_concern_group_leiserowitz == "You and your family" ~ 0, e$CC_concern_group_leiserowitz == "Your local community" ~ 1, e$CC_concern_group_leiserowitz == "The U.S. as a whole" ~ 2, e$CC_concern_group_leiserowitz == "People all over the world" ~ 3, e$CC_concern_group_leiserowitz == "Non-human nature" ~ 4)
    e$CC_concern_group_leiserowitz <- as.item(temp, labels = structure(-1:4,  names = c("Not at all concerned", "You and your family", "Your local community", "The U.S. as a whole", "People all over the world", "Non-human nature")), annotation=Label(e$CC_concern_group_leiserowitz))
  }
  
  ## 6. Defines indices
  z_score_computation <<- function(group, df=e, weight=T){
    variable_name <- group[1]
    variable_name_zscore <-  paste(variable_name,"zscore", sep = "_")
    negative <- group[2]
    condition <- group[3]
    before_treatment <- group[4]
    
    # First we check if the variable is in the data frame, otherwise we return the NULL value
    if(variable_name %in% names(df)) {
      if (negative) df[[variable_name]] <- - 1*df[[variable_name]]
      
      # for questions asked before the treatment, we simply need the variable mean and sd (not the ones by treatment groups)
      if(before_treatment) {
        if (weight) weights <- df$weight else weights <- NULL
        
        df[[variable_name_zscore]] <- ((eval(str2expression(paste("df[[variable_name]]", condition))))-eval(str2expression(paste("wtd.mean(df[[variable_name]]", condition," , w = weights, na.rm=T)"))))/eval(str2expression(paste("sqrt(wtd.var(df[[variable_name]]", condition," , w = weights, na.rm=T))")))
        
        df[[variable_name_zscore]][is.pnr(df[[variable_name]])] <- 0
      } else {
        # get mean and sd by treatment groups
        mean_sd <- as.data.frame(sapply(split(df, df$treatment), 
                                        function(x) { if (weight) weights <- x$weight else weights <- NULL
                                        return(c(eval(str2expression(paste("wtd.mean(x[[variable_name]]", condition," , w = weights, na.rm=T)"))), eval(str2expression(paste("sqrt(wtd.var(x[[variable_name]]", condition," , w = weights, na.rm=T))"))))) } ))
        
        # compute z-score
        df[[variable_name_zscore]] <- ((eval(str2expression(paste("df[[variable_name]]", condition))))-mean_sd[1,1])/mean_sd[2,1]
        
        # replace missing values with its group mean
        df[[variable_name_zscore]][df$treatment == "None"  &  is.pnr(df[[variable_name]])] <- (mean_sd[1,1]-mean_sd[1,1])/mean_sd[2,1]
        df[[variable_name_zscore]][df$treatment == "Climate impacts"  &  is.pnr(df[[variable_name]])] <- (mean_sd[1,2]-mean_sd[1,1])/mean_sd[2,1]
        df[[variable_name_zscore]][df$treatment == "Climate policy"  &  is.pnr(df[[variable_name]])] <- (mean_sd[1,3]-mean_sd[1,1])/mean_sd[2,1]
        df[[variable_name_zscore]][df$treatment == "Both"  &  is.pnr(df[[variable_name]])] <- (mean_sd[1,4]-mean_sd[1,1])/mean_sd[2,1]
      }
      
      zscore <- as.numeric(df[[variable_name_zscore]])
    } else {
      zscore <- NULL
    }
    return(zscore)
  } 
  # Conditions : conditions to transform into dummy variables; before_treatment : T if question asked before the treatment
  # Be careful of the logical implications of using both negatives and conditions! : if no condition just set negative = T,
  # if dummy leave negative = F and inverse condition (e.g., < 0 instead of > 0) or set condition accordingly (e.g., >-1 for logical)
  index_zscore <<- function(name = NULL, variables = NULL, negatives = NULL, conditions = rep("", length(variables)), before_treatment = rep(FALSE, length(variables)), df=e, dummies = FALSE, require_all_variables = T, weight=T, efa = FALSE) {
    if (!missing(name)) {
      if (missing(variables)) variables <- eval(as.name(paste0("variables_index_", name)))
      if (missing(negatives)) negatives <- eval(as.name(paste0("negatives_index_", name)))
      if (missing(conditions)) conditions <- eval(as.name(paste0("conditions_index_", name)))
      if (missing(before_treatment)) before_treatment <- eval(as.name(paste0("before_treatment_index_", name)))
    } else name <- gsub('["\']', "", sub("variables_", "", deparse(substitute(variables))))
    variables_present <- variables %in% names(df)
    if (require_all_variables) compute_zscore <- all(variables_present)
    else {
      compute_zscore <- T
      variables <- variables[variables_present]
      negatives <- negatives[variables_present]
      conditions <- conditions[variables_present]
    }
    if (compute_zscore & (!efa || length(variables) > 2)) {
      if (!dummies) conditions <- rep("", length(variables))
      groups <- list()
      for (i in seq_along(variables)) groups <- c(groups, list(c(variables[i], negatives[i], conditions[i], before_treatment[i])))
      zscores_data <- as.data.frame(lapply(groups, z_score_computation, df=df, weight=weight))
      if (efa) {
        try({loadings <- as.numeric(factanal(zscores_data, 1)$loadings)})
        if (is.null(loadings) || class(loadings) == "function") loadings <- rep(1, length(variables))
        loadings_efa[[country]][[name]] <- loadings
        zscores <- 0
        for (i in 1:length(variables)) zscores <- zscores + loadings[i]*zscores_data[, i]
      } else zscores <- rowMeans(zscores_data)
      zscores <- (zscores - wtd.mean(zscores, w = df$weight, na.rm=T)) / sqrt(wtd.var(zscores, w = df$weight, na.rm=T))
      if (is.null(loadings) || class(loadings) == "function" || all(loadings == 1)) {
        label(zscores) <- paste0("index_", name, ": Z-score of (non-weighted) average of (first-stage) z-scores of variables: ", paste(variables, collapse = ', '), 
                                 ".", ifelse(dummies, paste0(" Variables are recoded as dummies (cf. conditions_index_", name, ")."), ""), 
                                 " Each z-score is normalized with", ifelse(weight, " survey weights,", ""), " control group (resp. sample) mean and sd. Imputes group mean to missing values. Group: treatment group (resp. whole sample) if question asked after treatment and it's a first-stage z-scores (resp. otherwise).")
      } else { label(zscores) <- paste0("index_", name, ": Z-score of weighted (with Exploratory Factor Analysis loadings) average of (first-stage) z-scores of variables: ", paste(variables, collapse = ', '), 
                                        ".", ifelse(dummies, paste0(" Variables are recoded as dummies (cf. conditions_index_", name, ")."), ""), 
                                        " Each z-score is normalized with", ifelse(weight, " survey weights,", ""), " control group (resp. sample) mean and sd. Imputes group mean to missing values. Group: treatment group (resp. whole sample) if question asked after treatment and it's a first-stage z-scores (resp. otherwise).") }
      return(zscores)
    } else browser(expr = FALSE) # Interrupts the execution without returning an error
  }
  
  names_indices <<- c("affected", "knowledge", "knowledge_not_dum", "knowledge_footprint", "net_zero_feasible", "worried", "positive_economy", "policies_effective",
                      "affected_subjective", "lose_policies_subjective", "lose_policies_poor", "lose_policies_rich", "fairness", "trust_govt", "willing_change", "care_poverty", "problem_inequality",
                      "standard_policy", "tax_transfers_policy", "investments_policy", "main_policies", "main_policies_all", "main_policies_all", "beef_policies",
                      "international_policies", "other_policies", "all_policies", "standard_effective", "effect_halt_CC_lifestyle", "donation",
                      "tax_transfers_effective", "investments_effective", "tax_transfers_positive_economy", "standard_positive_economy", "investments_positive_economy", "lose_standard_poor", "lose_standard_rich", "lose_standard_subjective",
                      "lose_investments_poor", "lose_investments_rich", "lose_investments_subjective", "lose_tax_transfers_poor", "lose_tax_transfers_rich", "lose_tax_transfers_subjective", "policies_emissions", "investments_emissions", "tax_emissions_plus", "investments_emissions_plus", "standard_emissions_plus", 
                      "policies_pollution", "investments_pollution", "tax_transfers_pollution", "standard_pollution", "tax_emissions", "standard_emissions",
                      "lose_investments_poor_new_rep", "lose_tax_transfers_poor_new_rep", "lose_standard_poor_new_rep",
                      "tax_emissions_plus_new_rep", "investments_emissions_plus_new_rep", "standard_emissions_plus_new_rep",
                      "policies_emissions_plus", "fairness_standard", "fairness_tax_transfers", "fairness_investments", "knowledge_fundamentals", "knowledge_gases", "knowledge_impacts", "worried_old", "concerned_about_CC", "bad_things_CC")
  
  for (i in names_indices) {
    tryCatch({
      if (zscores) {
        if (is.logical(efa)) { e[[paste0("index_", i)]] <- index_zscore(i, df = e, weight = weighting, dummies = FALSE, require_all_variables = TRUE, efa = efa)
        } else {
          e[[paste0("index_efa_", i)]] <- index_zscore(i, df = e, weight = weighting, dummies = FALSE, require_all_variables = TRUE, efa = TRUE)
          e[[paste0("index_", i)]] <- index_zscore(i, df = e, weight = weighting, dummies = FALSE, require_all_variables = TRUE, efa = FALSE) }
      }
      if (zscores_dummies & is.logical(efa)) e[[paste0("index_", i, "_dummies")]] <- index_zscore(i, df = e, weight = weighting, dummies = TRUE, require_all_variables = TRUE, efa = efa)
    }, error = function(cond) { print(paste("Index", i, "could not be created")) } )
  }
  
  ## 3ter. defines derivate variables
  if ("beef_tax_support" %in% names(e)) { e$pricing_vs_norms <- rowMeans(e[, c("tax_transfers_support", "beef_tax_support", "policy_tax_flying")]) - rowMeans(e[, c("standard_support", "beef_ban_intensive_support", "policy_ban_city_centers")])
  } else if ("policy_tax_flying" %in% names(e)) e$pricing_vs_norms <- rowMeans(e[, c("tax_transfers_support", "policy_tax_flying")]) - rowMeans(e[, c("standard_support", "policy_ban_city_centers")])
  
  if ("clicked_petition" %in% names(e)) {
    e$right_click_petition <- e$clicked_petition == 2
    e$left_click_petition <- e$clicked_petition == 1
    e$variant_petition_real <- e$clicked_petition == 3
    e$clicked_petition <- e$clicked_petition %in% 1:2
    e$signed_petition <- e$clicked_petition | e$petition == "Yes"
    label(e$signed_petition) <- "signed_petition: Answered that is willing to sign petition or clicked on the petition link."
    label(e$variant_petition_real) <- "variant_petition_real: True iff the respondent faces the new version of the question, without link to petition but with a real stake, as they are informed that 'we will send the results to the President of the United States’ office, informing him what share of people who took this survey were willing to support the following petition'"
  }
  
  if ("heating" %in% names(e)) {
    if (country == "US" & "heating_expenses" %in% names(e)) {
      temp <- read.csv2("../data/zipcodes/US_zipcode_state.csv")
      zipcode_state <- temp[,2]
      names(zipcode_state) <- temp[,1]
      e$state <- zipcode_state[as.character(e$zipcode)]
      temp <- read.csv("../data/zipcodes/US_elec.csv") # sources: $/MWh: https://www.eia.gov/electricity/state/ CO2/MWh: https://www.epa.gov/egrid/data-explorer, alternative source: https://www.carbonfootprint.com/docs/2020_09_emissions_factors_sources_for_2020_electricity_v14.pdf 
      CO2_factor <- temp[,8]
      names(CO2_factor) <- temp[,1]
      
      # Carbon footprint of heating gas: 3.79 kgCO2/$. Using: $1.40 per 100,000 BTU (https://energysvc.com/the-real-cost-of-heating); 53.07 kgCO2/MBTU (https://www.eia.gov/environment/emissions/co2_vol_mass.php)
      # Carbon footprint of heating oil: 3.17 kgCO2/$. Using: $3.20 per 138,500 BTU (https://energysvc.com/the-real-cost-of-heating); 73.16 kgCO2/MBTU (https://www.eia.gov/environment/emissions/co2_vol_mass.php)
      # datasummary(heating_expenses*mean ~ Factor(heating), data=us) # 
      # Carbon footprint of gasoline: 2.76 kgCO2/$. Using 8.887 kgCO2/gallon (https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references) and 3.221 gallon/$ (https://www.globalpetrolprices.com/USA/gasoline_prices/)
      # in the US gasoline much more used as diesel https://rentar.com/no-diesel-cars-u-s-diesel-popular-abroad/ (Carbon footprint of diesel: 3.31 kgCO2/$. Using 10.18 kgCO2/gallon (https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references) and 3.078 gallon/$ (https://www.globalpetrolprices.com/USA/diesel_prices/))
      # unused because we use State-wide values. Carbon footprint of electricity (US mean): 3.96 kgCO2/$. cf. US_elec.csv From https://www.eia.gov/electricity/state/unitedstates/
      # Carbon footprint of round-trip flight (US): 0.584*2.483 = 1450 kgCO2 https://www.icao.int/annual-report-2018/Documents/Annual.Report.2018_Air%20Transport%20Statistics.pdf
      e$CO2_emission_heating <- 12*(include.missings(e$heating_expenses) + 0.1) * (3.79*(e$heating %in% c("Gas", "PNR")) + CO2_factor[e$state]*(e$heating=="Electricity") + 3.17*(e$heating=="Heating oil"))/1000
      e$CO2_emission_gas <- 12*2.76*e$gas_expenses/1000 # pb: are questions are at individual level but not clearly
      e$CO2_emission <- e$CO2_emission_heating + e$CO2_emission_gas + 1.45*e$flights_agg  + (12+e$income)/1.6 # cf. Fig. 5 Green & Knittel (2020) for footprint beyond transit & housing, divided by mean nb of "adult" per HH, from questionnaire/income quota.xlsx. I do not subtract official average round-trip pc from flights because conso data do not includes flights.(e$flights_agg - 2.483)
    } else {
      if (country %in% tropical_countries) { e$CO2_emission_heating <- 0 
      } else if (country == "AU") { e$CO2_emission_heating <- (include.missings(e$heating_expenses) + 0.1) * (prices[["elec_factor"]][country]/prices[["electricity"]][country])/1000
      } else e$CO2_emission_heating <- (include.missings(e$heating_expenses) + 0.1) * (3412.14*52.91*1e-6*(e$heating %in% c("Gas", "PNR"))/prices[["gas"]][country] + prices[["elec_factor"]][country]*(e$heating=="Electricity")/prices[["electricity"]][country] + (10.19/3.7854)*(e$heating=="Heating oil")/prices[["oil"]][country] + 1.10231*1827.04*(e$heating=="Coal")/prices[["coal"]][country])/1000 # https://www.eia.gov/environment/emissions/co2_vol_mass.php ifelse(country %in% c("DK", "FR", "US"), 12, 1)*
      if (country == 'IA') { e$CO2_emission_gas <- NA 
      } else e$CO2_emission_gas <- 12 * (8.78/3.7854)*(e$gas_expenses/prices[["gasoline"]][country])/1000 
      e$CO2_emission <- e$CO2_emission_heating + e$CO2_emission_gas + 1.45*e$flights_agg  
    }
    label(e$CO2_emission_heating) <- "CO2_emission_heating: CO2 emissions (in t/year) from heating of the respondent estimated from their heating expenses and country average emission factors of electricity, heating oil and gas."
    label(e$CO2_emission_gas) <- "CO2_emission_gas: CO2 emissions (in t/year) from gasoline of the respondent estimated from their gas expenses and emission factor of gasoline."
    label(e$CO2_emission) <- "CO2_emission: CO2 emissions (in t/year) of the respondent estimated from their heating & gas expenses, flights and income." # Official average: 17.59 per capita vs. 15.63 per respondent here (we pbly underestimate then because we assume children have 0 emission).
  }
  
  if ("CC_field" %in% names(e)) {
    e$length_CC_field <- nchar(e$CC_field)
    e$length_CC_field[is.na(e$CC_field)] <- 0
    e$length_comment_field <- nchar(e$comment_field)
    e$length_comment_field[is.na(e$comment_field)] <- 0
    label(e$length_CC_field) <- "length_CC_field: Number of characters in CC_field"
    label(e$length_comment_field) <- "length_comment_field: Number of characters in comment_field"
  }
  
  ## 7. Define variables related to open-ended questions.
  if (!grepl("pilot", wave)) {
    try({
      # To recode CC_field/comment_field (pre-treatment necessary so the following code works): ~2h/country
      # 1. use line below export CSV (change country in filename). 
      # 2. Create country.xlsm: if language has special characters, from 'template - no wrap'; if not, from 'template' and jump to step 5 (a posteriori, don't understand this last instruction)
      # 3. Data>Import from text>file_path>UTF8 + Delimited>Semicolon. For language without latin characters, run Sys.setlocale("LC_CTYPE","chinese") (didn't succeed with hindi and beware, it works just one at a time). Then it doesn't always works: closing and reopening Excel sometimes works, as well as replacing remaining latin characters (e.g. "NA"), after many attempts of basically the same thing it ended up working (mystery).
      # 4. If needed, translate to English: rename .xlsm into .xslx, translate on https://www.onlinedoctranslator.com/de/translationform, rename back to .xlsm
      # 5. Widen first row until below lifestyle. 6. Home>Wrap text on first row + Format>Column width>60 7. Click on appropriate cells. 
      # automatic translation: https://www.onlinedoctranslator.com/de/translationform
      # for (i in 1:4) write.table(paste(c('"', paste(gsub("\n", "\\\\\\n ", gsub("\r", " ", gsub('\"', "\\\\\\'", e$CC_field[seq(i,nrow(e),4)]))), collapse = '";"'), '"'), collapse=""),
      #                            paste0("../data/fields/csv/CC_field", country, i, ".csv"), row.names = F, quote = F, col.names = F, fileEncoding = "UTF-8")
      # for (i in 1:4) write.table(paste(c('"', paste(gsub("\n", "\\\\\\n ", gsub("\r", " ", gsub('\"', "\\\\\\'", e$comment_field[seq(i,nrow(e),4)]))), collapse = '";"'), '"'), collapse=""),
      #                            paste0("../data/fields/csv/comment_field", country, i, ".csv"), row.names = F, quote = F, col.names = F, fileEncoding = "UTF-8")      
      # To make pre-treatment, open VBA (Alt+F11) then for each sheet needed, save:
      # Private Sub Worksheet_SelectionChange(ByVal Target As Excel.Range)
      #   Application.EnableEvents = False
      #   If Target.Cells.Count = 1 Then
      #     If Not Intersect(Target, Range("B2:ZZ50")) Is Nothing Then
      #       Select Case Target.Value
      #       Case ""
      #         Target.Value = "1"
      #       Case "1"
      #         Target.Value = ""
      #       End Select
      #       Cells(1, ActiveCell.Column).Select
      #     End If
      #   End If
      #   Application.EnableEvents = True
      # End Sub
      
      
      CC_field_names <<- c("worrying / should act" = "worry", "no need to worry/act" = "no_worry", "NA / empty content" = "empty",
                           "don't know" = "do_not_know", "spelling mistake" = "ambiguous", "damages" = "damage",
                           "adaptation" = "adaptation", "change lifestyle" = "lifestyle", "companies" = "companies",
                           "trash/recycling/plastic" = "waste", "cars/transport" = "transport", "power/energy" = "energy",
                           "housing/insulation" = "housing", "agriculture/forest" = "land_agri", "tax/incentives" = "tax",
                           "bans/sanctions" = "ban", "standard" = "standard", "subsidies/investment" = "spending")
      CC_field_names_names <<- names(CC_field_names)
      names(CC_field_names_names) <<- CC_field_names
      var_CC_field_names <<- paste0("CC_field_", CC_field_names)
      e$CC_field_english <- e$CC_field
      recode_CC_field <- list()
      for (i in 1:4) {
        if (file.exists(paste0("../data/fields/", country, "en.xlsm"))) recode_CC_field[[i]] <- read.xlsx(paste0("../data/fields/", country, "en.xlsm"), sheet = i, rowNames = T, sep.names = " ", na.strings = c(), skipEmptyCols = F)
        else if (file.exists(paste0("../data/fields/", country, ".xlsm"))) recode_CC_field[[i]] <- read.xlsx(paste0("../data/fields/", country, ".xlsm"), sheet = i, rowNames = T, sep.names = " ", na.strings = c(), skipEmptyCols = F)
        else print("No file found for recoding of CC_field.")
        indices_i <- i+4*((1:ncol(recode_CC_field[[i]])-1)) # seq(i, nrow(e), 4)
        if (file.exists(paste0("../data/fields/", country, "en.xlsm"))) e$CC_field_english[indices_i] <- names(recode_CC_field[[i]])
        row.names(recode_CC_field[[i]]) <- CC_field_names[row.names(recode_CC_field[[i]])]
        recode_CC_field[[i]] <- as.data.frame(t(recode_CC_field[[i]]), row.names = indices_i)
        if (i == 1) for (v in names(recode_CC_field[[i]])) e[[paste0("CC_field_", v)]] <- NA 
        for (v in names(recode_CC_field[[i]])) e[[paste0("CC_field_", v)]][indices_i] <- recode_CC_field[[i]][[v]]==1
        e[[paste0("CC_field_empty")]][indices_i][recode_CC_field[[i]][["empty"]]==2] <- 2
      }
      label(e$CC_field_english) <- "CC_field_english: CC_field either original (if in English, French) or translated to English."
      e$length_CC_field_english <- nchar(e$CC_field_english)
      label(e$length_CC_field_english) <- "length_CC_field_english: Number of characters in CC_field_english"
      variables_sectors_field <<- c("adaptation", "companies", "waste", "transport", "energy", "housing", "land_agri")
      variables_measures_field <<- c("lifestyle", "tax", "ban", "standard", "spending")
      variables_actions_field <<- c(variables_sectors_field, variables_measures_field)
      e$nb_sectors_CC_field <- rowSums(1*e[,paste0("CC_field_", intersect(variables_sectors_field, names(recode_CC_field[[1]])))], na.rm=T)
      e$nb_mitigations_CC_field <- rowSums(1*e[,paste0("CC_field_", intersect(variables_sectors_field[c(2,4:7)], names(recode_CC_field[[1]])))], na.rm=T)
      e$nb_measures_CC_field <- rowSums(1*e[,paste0("CC_field_", intersect(variables_measures_field, names(recode_CC_field[[1]])))], na.rm=T)
      e$CC_field_instrument_mentioned <- (e$nb_measures_CC_field > 0) %in% T
      e$CC_field_mitigation_mentioned <- (e$nb_mitigations_CC_field > 0) %in% T
      e$CC_field_activity_mentioned <- (e$nb_sectors_CC_field > 0) %in% T
      e$nb_actions_CC_field <- rowSums(1*e[,paste0("CC_field_", intersect(variables_actions_field, names(recode_CC_field[[1]])))], na.rm=T)
      if (country %in% c("DK", "FR", "US")) { e$should_act_CC_field <- (e$nb_actions_CC_field > 0 | e$CC_field_worry > 0) %in% T
      } else e$should_act_CC_field <-( e$CC_field_worry > 0) %in% T
      label(e$nb_sectors_CC_field) <- "nb_sectors_CC_field: Number of sectors for which an action is supported in CC_field, among: companies, waste, transport, energy, housing, land_agri"
      label(e$nb_measures_CC_field) <- "nb_measures_CC_field: Number of types of government measures explicitly supported in CC_field, among: lifestyle, tax, ban, standard, spending"
      label(e$CC_field_instrument_mentioned) <- "CC_field_instrument_mentioned: At least one measure mentioned and supported in CC_field."
      label(e$CC_field_mitigation_mentioned) <- "CC_field_mitigation_mentioned: At least one activity of mitigation mentioned in CC_field. Mitigation activities are defined as any activity except adaptation, waste nor companies."
      label(e$CC_field_activity_mentioned) <- "CC_field_activity_mentioned: At least one activity of mentioned in CC_field."
      label(e$nb_actions_CC_field) <- "nb_actions_CC_field: Number of types (sectors or measures) for which an action is supported in CC_field, among: companies, waste, transport, energy, housing, land_agri, lifestyle, tax, ban, standard, spending"
      label(e$should_act_CC_field) <- "should_act_CC_field: T/F Supports at least one action in CC_field (either expresses general concern/support for action (CC_field_worry) or mentions specific action(s): nb_types_CC_field > 0, or both)"
      e$weird_good_CC_field <- nchar(e$CC_field) < 15 & grepl("good|Good|PNR", e$CC_field)
      label(e$weird_good_CC_field) <- "weird_good_CC_field: T/F The answer to CC_field is weirdly 'good' or 'very good'. Flagged as low quality."
      e$nb_elements_CC_field <- rowSums(1*e[,paste0("CC_field_", names(recode_CC_field[[1]]))], na.rm=T) 
      e$nb_elements_CC_field[e$CC_field_empty %in% c(TRUE, 1)] <- -1 
      e$nb_elements_CC_field[e$CC_field_empty == 2] <- 0
      e$should_act_CC_field[e$CC_field_empty == 2] <- e$nb_actions_CC_field[e$CC_field_empty == 2] <- e$CC_field_instrument_mentioned[e$CC_field_empty == 2] <- e$nb_measures_CC_field[e$CC_field_empty == 2] <- e$nb_sectors_CC_field[e$CC_field_empty == 2] <- e$nb_elements_CC_field[e$CC_field_empty == 2] <- NA
      for (i in 1:4) {
        indices_i <- i+4*((1:nrow(recode_CC_field[[i]])-1)) 
        if (sum(e$nb_elements_CC_field[indices_i] > 0, na.rm = T) < 5) {
          e$CC_field_instrument_mentioned[indices_i] <- e$CC_field_mitigation_mentioned[indices_i] <- e$CC_field_activity_mentioned[indices_i] <- e$should_act_CC_field[indices_i] <- e$nb_actions_CC_field[indices_i] <- e$nb_measures_CC_field[indices_i] <- e$nb_sectors_CC_field[indices_i] <- e$nb_elements_CC_field[indices_i] <- e$nb_mitigations_CC_field[indices_i] <- NA    } 
        indices_without_question <- (1:nrow(e))[1:nrow(e) %% 4 == i %% 4 & !(1:nrow(e) %in% indices_i)]
        e$CC_field_instrument_mentioned[indices_without_question] <- e$CC_field_mitigation_mentioned[indices_without_question] <- e$CC_field_activity_mentioned[indices_without_question] <- e$should_act_CC_field[indices_without_question] <- e$nb_actions_CC_field[indices_without_question] <- e$nb_measures_CC_field[indices_without_question] <- e$nb_sectors_CC_field[indices_without_question] <- e$nb_elements_CC_field[indices_without_question] <- e$nb_mitigations_CC_field[indices_without_question] <- NA
      }
      label(e$nb_elements_CC_field) <- "nb_elements_CC_field: Number of elements mentioned in CC_field. NA means that the observation has not been yet treated. -1 means that its content is empty (including contents like 'lfelkfje' or 'none')"
      e$nb_actions_CC_field <- as.item(pmin(as.numeric(e$nb_actions_CC_field), 2), labels = structure(c(0:2), names=c("0", "1", "2+")), annotation=Label(e$nb_actions_CC_field))
      e$nb_elements_CC_field <- as.item(pmin(as.numeric(e$nb_elements_CC_field), 2), labels = structure(c(-1:2), names=c("Empty", "0", "1", "2+")), annotation=Label(e$nb_elements_CC_field))
      for (v in names(recode_CC_field[[1]])) {
        e[[paste0("CC_field_", v)]][!is.na(e$nb_elements_CC_field) & is.na(e[[paste0("CC_field_", v)]])] <- FALSE
        e[[paste0("CC_field_", v)]][e$CC_field_empty == 2] <- NA
        label(e[[paste0("CC_field_", v)]]) <- paste0("CC_field_", v, ": ", CC_field_names_names[v], " - Element mentioned (and supported) in CC_field. (For change lifestyle, it includes calls to reduce consumption.)") }
      variables_CC_field_contains <<- paste0("CC_field_contains_", c("meat", "natural", "world", "population", "research", "tax", "education", "renewable",  "solar", "coal", "electric", "electric_car", "public transport", "nuclear", "fossil", "plastic", "companies", "aviation", "justice", #"training", 
                                                                     "waste", "forest", "heating", "subsidies", "investment", "ban", "standard", "reduce"))
      grep_variables_CC_field_contains <<- c("meat|beef|cow|vegan|animal food|vegetarian", "natural", "international|world|countr|global", "populat", "research|innovation|technolog", "tax|incentiv", "educat|teach|campaign|school|aware|inform", "renewable|solar|wind| sun|hydro", "solar| sun", "coal", "electric", "electric car|e-auto", "public transport|public transit|train ", "nuclear|atom", "fossil|coal|oil|gas|diesel", "plastic", "compan|corporation|factories|factory|industr", "plane|flight|fly|aviation", "justice|poor|equalit|fair|low-income", #"training", 
                                             "recycl|waste|plastic", "forest|mazon|tree", "heating|insulat|renovat", "subsid", "invest", "ban |banned|interdiction|forbid|mandat|sanction|penalt|fines|punish", "standard", "reduc| less")
      names(grep_variables_CC_field_contains) <<- variables_CC_field_contains
      for (v in variables_CC_field_contains) {
        e[[v]] <- grepl(grep_variables_CC_field_contains[v], e$CC_field_english)
        label(e[[v]]) <- paste0(v, ": T/F CC_field_english contains: ", grep_variables_CC_field_contains[v])  }
    })
    
    try({
      comment_field_names <<- c("good", "bad", "bias", "problem")
      var_comment_field_names <<- paste0("comment_field_", comment_field_names)
      e$comment_field_english <- e$comment_field
      recode_comment_field <- list()
      for (i in 1:4) {
        if (file.exists(paste0("../data/fields/", country, "en.xlsm"))) recode_comment_field[[i]] <- read.xlsx(paste0("../data/fields/", country, "en.xlsm"), sheet = 4+i, rowNames = T, sep.names = " ", na.strings = c(), skipEmptyCols = F)
        else if (file.exists(paste0("../data/fields/", country, ".xlsm"))) recode_comment_field[[i]] <- read.xlsx(paste0("../data/fields/", country, ".xlsm"), sheet = 4+i, rowNames = T, sep.names = " ", na.strings = c(), skipEmptyCols = F)
        else print("No file found for recoding of comment_field.")
        indices_i <- i+4*((1:ncol(recode_comment_field[[i]])-1)) # seq(i, nrow(e), 4)
        if (file.exists(paste0("../data/fields/", country, "en.xlsm"))) e$comment_field_english[indices_i] <- names(recode_comment_field[[i]])
        recode_comment_field[[i]] <- as.data.frame(t(recode_comment_field[[i]]), row.names = indices_i)
        if (i == 1) for (v in names(recode_comment_field[[i]])) e[[paste0("comment_field_", v)]] <- NA
        for (v in names(recode_comment_field[[i]])) e[[paste0("comment_field_", v)]][indices_i] <- recode_comment_field[[i]][[v]]==1
      }
      label(e$comment_field_english) <- "comment_field_english: comment_field either original (if in English, French) or translated to English."
      e$dislike_comment_field <- (e$comment_field_bad | e$comment_field_bias) %in% T
      label(e$dislike_comment_field) <- "dislike_comment_field: T/F The respondent didn't sur survey: comment_field either says the survey is bad or biased."
      e$critic_comment_field <- (e$comment_field_bad | e$comment_field_problem | e$comment_field_bias) %in% T
      label(e$critic_comment_field) <- "critic_comment_field: T/F The answer to comment_field is critical: either mentions an issue, says that the survey is bad or biased."
      e$treated_comment_field <- FALSE
      for (i in 1:4) {
        indices_i <- i+4*((1:nrow(recode_comment_field[[i]])-1)) 
        if (sum(e$critic_comment_field[indices_i] | e$comment_field_good[indices_i], na.rm = T) >= 5) e$treated_comment_field[indices_i] <- TRUE    }
      label(e$treated_comment_field) <- "treated_comment_field: T/F comment_field has been treated/recoded. N"
      for (v in names(recode_comment_field[[1]])) {
        e[[paste0("comment_field_", v)]][e$treated_comment_field & is.na(e[[paste0("comment_field_", v)]])] <- FALSE
        label(e[[paste0("comment_field_", v)]]) <- paste0("comment_field_", v, ": ", v, " - Feeling or opinion the respondent expressed about the survey in comment_field.") }
      variables_comment_field_contains <<- paste0("comment_field_contains_", c("long", "good", "thanks", "learned", "bias"))
      grep_variables_comment_field_contains <<- c(" long", "good|Good|excellent|enjoy|interesting", "thank|Thank", "learnt|learn", "bias")
      names(grep_variables_comment_field_contains) <<- variables_comment_field_contains
      for (v in variables_comment_field_contains) {
        e[[v]] <- grepl(grep_variables_comment_field_contains[v], e$comment_field_english)
        label(e[[v]]) <- paste0(v, ": T/F comment_field_english contains: ", grep_variables_comment_field_contains[v])  }
      e$non_empty_comment_field <- !is.na(e$comment_field)
      label(e$non_empty_comment_field) <- "non_empty_comment_field: The respondent left a feedback comment, i.e. comment_field is not NA."
      print("open fields: success")
    })
    # }
  }
  
  
  print(paste("convert: success", country))
  return(e)
}

weighting <- function(e, country, wave, printWeights = T, variant = NULL, min_weight_for_missing_level = F, combine_age_50 = T, trim = T) {
  # Creates individual weights for data 'e' and 'country', searching for quota variables defined in 'quotas'/'levels_quotas'/'variant' and population frequencies in 'pop_freq'.
  # 'min_weight_for_missing_level' is just a technical fix to avoid bugs when a category is absent from the sample (e.g. gender = 'Other')
  # 'combine_age_50' combines age categories 50-64 and 65+ into one, it is activated by default.
  # 'trim' forces weights to be within [0.25; 4] by trimming extremal weights to these bounds.
  if (!missing(variant)) print(variant)
  vars <- quotas[[paste0(c(country, variant), collapse = "_")]]
  freqs <- list()
  for (v in vars) {
    if (!(v %in% names(e))) warning(paste(v, "not in data"))
    e[[v]] <- as.character(e[[v]])
    e[[v]][is.na(e[[v]])] <- "NA"
    var <- ifelse(v %in% names(levels_quotas), v, paste(country, v, sep="_"))
    if (!(var %in% names(levels_quotas))) warning(paste(var, "not in levels_quotas"))
    levels_v <- as.character(levels_quotas[[var]])
    missing_levels <- setdiff(levels(as.factor(e[[v]])), levels_v)
    present_levels <- which(levels_v %in% levels(as.factor(e[[v]])))
    if (length(present_levels) != length(levels_v)) warning(paste0("Following levels are missing from data: ", var, ": ", paste(levels_v[!1:length(levels_v) %in% present_levels], collapse = ', '), " (for ", country, "). Weights are still computed, neglecting this category."))
    
    country_pop_freq <- country
    if(wave %in% c("compl_extra", "compl_regular") & country == "US") country_pop_freq <- "US2023"
    prop_v <- pop_freq[[country]][[var]][present_levels]
    if (v == "age" & combine_age_50) {
      e$age_50 <- e$age
      e$age_50[e$age == "65+"] <- "50-64"
      prop_v[4] <- prop_v[4] + prop_v[5]
      prop_v <- prop_v[1:4]
      levels_v <- levels_v[1:4]
      present_levels <- present_levels[1:4]
      v <- "age_50"
      vars[vars == "age"] <- "age_50"
    }
    if (min_weight_for_missing_level) freq_missing <- rep(0.000001, length(missing_levels)) 
    else freq_missing <- vapply(missing_levels, function(x) sum(e[[v]]==x), FUN.VALUE = c(0))
    freq_v <- c(prop_v*(nrow(e)-sum(freq_missing)), freq_missing)
    df <- data.frame(c(levels_v[present_levels], missing_levels), freq_v)
    names(df) <- c(v, "Freq")
    freqs <- c(freqs, list(df))
  }
  
  unweigthed <- svydesign(ids=~1, data=e)
  raked <- rake(design= unweigthed, sample.margins = lapply(vars, function(x) return(as.formula(paste("~", x)))), population.margins = freqs)
  
  if (printWeights) {    print(summary(weights(raked))  )
    print(paste("(mean w)^2 / (n * mean w^2): ", representativity_index(weights(raked)), " (pb if < 0.5)")) # if <0.5 : problématique
    print(paste("proportion not in [0.25; 4]: ", round(length(which(weights(raked)<0.25 | weights(raked)>4))/ length(weights(raked)), 3), "Nb obs. in sample: ", nrow(e)))
  }
  if (trim) return(weights(trimWeights(raked, lower=0.25, upper=4, strict=TRUE)))
  else return(weights(raked, lower=0.25, upper=4, strict=TRUE))
}

summary_stats_table <- function(country_list, folder = "../tables/sample_composition/", filename = NULL, return_table = FALSE, hi = T){
  # Function to generate summary statistics table
  # Parameters:
  #   - country_list: A vector of country codes for which the summary statistics are calculated
  #   - folder: The folder path where the table will be saved (default: "../tables/sample_composition/")
  #   - filename: The name of the file to save the table (default: NULL)
  #   - return_table: Logical indicating whether to return the table as a data frame (default: FALSE)
  #   - hi: Logical indicating whether to include "Master or higher (25-64)" or "College education (25-64)" in the table (default: TRUE)
  # Returns:
  #   - If return_table is TRUE, returns the summary statistics table as a data frame
  #   - If return_table is FALSE (default), saves the summary statistics table as a file in the specified folder and filename
  
  # For Australia, we adjust the income variable using the ratio between the population share of income because the lowest income category (0-36k) we used is the population P45.
  # This stems from the fact that we were originally using LIS income categories which are not well aligned with the Census data, and that the income definition used by the LIS doesn't seem to correspond to respondents' definition of income.
  # The actual quartiles are 0-18k; 18k-42k; 42k-79k; 79k+ (from Census Data)
  # From the Census data we have that 45.06% of the population has an income below 36k; 53.42% has an income below 46k.
  # Note that string values of those variables do not accurately represent the actual values in terms of CU
  # The correspondence is as follows:
  # less than $10,000 -> 0-36k
  # between $10,000 and $20,000-> 36k-46k
  # between $20,000 and $25,000 -> 46k-51k
  # between $25,000 and $30,000 -> 51k-56k
  # between $30,000 and $40,000 -> 56k-67k
  # between $40,000 and $50,000 -> 67k-79k
  # between $50,000 and $60,000 -> 79k-93k
  # between $60,000 and $70,000 -> 93k-112k
  # between $70,000 and $75,000 -> 112k-122k
  # between $75,000 and $80,000 -> 122k-134k
  # between $80,000 and $90,000 -> 134k-174k
  # more than $90,000 -> 174k+
  
  if (hi) {
    labels_columns_stats <- c("Sample size","Man", "18-24 years old", "25-34 years old", "35-49 years old", "More than 50 years old",
                              "Income Q1", "Income Q2", "Income Q3", "Income Q4", "Region 1", "Region 2", "Region 3", "Region 4", "Region 5",
                              "Urban", "College education (25-64)", "Vote: Candidate/Party 1", "Vote: Candidate/Party 2", "Vote: Candidate/Party 3",
                              "Vote: Candidate/Party 4", "Unemployment rate (15-64)", "Home ownership rate")
  } else {
    labels_columns_stats <- c("Sample size","Man", "18-24 years old", "25-34 years old", "35-49 years old", "More than 50 years old",
                              "Income Q1", "Income Q2", "Income Q3", "Income Q4", "Region 1", "Region 2", "Region 3", "Region 4", "Region 5",
                              "Urban", "Master or higher (25-64)", "Vote: Candidate/Party 1", "Vote: Candidate/Party 2", "Vote: Candidate/Party 3",
                              "Vote: Candidate/Party 4", "Unemployment rate (15-64)", "Home ownership rate")
  }
  
  stats_table <- data.frame(row.names = labels_columns_stats)
  board <- read.xlsx("../data/stats_employment_college.xlsx", sheet = 1, colNames = T)
  
  # Loop over countries
  for (i in seq_along(country_list)){
    dataset <- d(country_list[i])
    
    # Get Sample statistics
    sample_size <- NROW(dataset)
    # Gender statistics
    if (country_list[i] %in% c("AU", "IA", "ID", "UA")){ # Countries w/o others
      sample_male <- as.numeric(unlist(decrit(dataset$gender, weight = F))[8])/as.numeric(unlist(decrit(dataset$gender, weight = F))[2])
    } else{
      sample_male <- as.numeric(unlist(decrit(dataset$gender, weight = F))[9])/as.numeric(unlist(decrit(dataset$gender, weight = F))[2])
    }
    # Age statistics
    if (country_list[i] != "CA"){
      sample_age_18_24 <- as.numeric(unlist(decrit(dataset$age, weight = F))[10])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_25_34 <- as.numeric(unlist(decrit(dataset$age, weight = F))[11])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_35_49 <- as.numeric(unlist(decrit(dataset$age, weight = F))[12])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_50_64 <- as.numeric(unlist(decrit(dataset$age, weight = F))[13])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_65_more <- as.numeric(unlist(decrit(dataset$age, weight = F))[14])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
    } else{
      sample_age_18_24 <- as.numeric(unlist(decrit(dataset$age, weight = F))[11])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_25_34 <- as.numeric(unlist(decrit(dataset$age, weight = F))[12])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_35_49 <- as.numeric(unlist(decrit(dataset$age, weight = F))[13])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_50_64 <- as.numeric(unlist(decrit(dataset$age, weight = F))[14])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
      sample_age_65_more <- as.numeric(unlist(decrit(dataset$age, weight = F))[15])/as.numeric(unlist(decrit(dataset$age, weight = F))[2])
    }
    # Income statistics
    if (country_list[i] %in% c("AU")) {
      sample_income_Q1 <- 25*mean(dataset$income_original == "less than $10,000", na.rm = T)/45.06
      sample_income_Q2 <- (45.06-25)*mean(dataset$income_original == "less than $10,000", na.rm = T)/45.06 + 50/53.42*mean(dataset$income_original == "between $10,000 and $20,000", na.rm = T)
      sample_income_Q3 <- (53.42-50)/53.42*mean(dataset$income_original == "between $10,000 and $20,000", na.rm = T)+mean(dataset$income_original %in% c("between $20,000 and $25,000", "between $25,000 and $30,000", "between $30,000 and $40,000", "between $40,000 and $50,000"), na.rm = T)
      sample_income_Q4 <- mean(dataset$income_original %in% c("between $50,000 and $60,000", "between $60,000 and $70,000", "between $70,000 and $75,000", "between $75,000 and $80,000", "between $80,000 and $90,000", "more than $90,000"), na.rm = T)
    } else {
      sample_income_Q1 <- as.numeric(unlist(decrit(dataset$income, weight = F))[9])/as.numeric(unlist(decrit(dataset$income, weight = F))[2])
      sample_income_Q2 <- as.numeric(unlist(decrit(dataset$income, weight = F))[10])/as.numeric(unlist(decrit(dataset$income, weight = F))[2])
      sample_income_Q3 <- as.numeric(unlist(decrit(dataset$income, weight = F))[11])/as.numeric(unlist(decrit(dataset$income, weight = F))[2])
      sample_income_Q4 <- as.numeric(unlist(decrit(dataset$income, weight = F))[12])/as.numeric(unlist(decrit(dataset$income, weight = F))[2])
    }
    # Region statistics
    if (country_list[i] == "FR"){
      sample_region_1 <- as.numeric(unlist(decrit(dataset$region, weight = F))[12])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_2 <- as.numeric(unlist(decrit(dataset$region, weight = F))[13])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_3 <- as.numeric(unlist(decrit(dataset$region, weight = F))[14])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_4 <- as.numeric(unlist(decrit(dataset$region, weight = F))[15])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_5 <- NA
    } else if (!(country_list[i] %in% c("SK", "TR", "US", "UA"))){
      sample_region_1 <- as.numeric(unlist(decrit(dataset$region, weight = F))[10])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_2 <- as.numeric(unlist(decrit(dataset$region, weight = F))[11])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_3 <- as.numeric(unlist(decrit(dataset$region, weight = F))[12])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_4 <- as.numeric(unlist(decrit(dataset$region, weight = F))[13])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_5 <- as.numeric(unlist(decrit(dataset$region, weight = F))[14])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
    } else{
      sample_region_1 <- as.numeric(unlist(decrit(dataset$region, weight = F))[9])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_2 <- as.numeric(unlist(decrit(dataset$region, weight = F))[10])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_3 <- as.numeric(unlist(decrit(dataset$region, weight = F))[11])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_4 <- as.numeric(unlist(decrit(dataset$region, weight = F))[12])/as.numeric(unlist(decrit(dataset$region, weight = F))[2])
      sample_region_5 <- NA
    }
    # Urban statistics
    sample_urban <-  as.numeric(unlist(decrit(dataset$urban, weight = F))[8])/as.numeric(unlist(decrit(dataset$urban, weight = F))[2])
    # Education statistics
    if (country_list[i] %in% countries[countries %in% rich_countries]) {
      sample_college <- as.numeric(unlist(decrit(dataset$college_OECD, weight = F))[8])/as.numeric(unlist(decrit(dataset$college_OECD, weight = F))[2])
    } else if (country_list[i] == "UA") {
      sample_college <- sum(dataset$education == 6, na.rm = T) / sum(!is.na(dataset$college_OECD))
    } else {
      sample_college <- sum(dataset$education[dataset$age %in% c("25-34", "35-49", "50-64")] == 6, na.rm = T) / sum(!is.na(dataset$college_OECD))
    }
    # Unemployment statistics
    sample_unemployment_rate <- as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[18])/
      (as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[18]) +
         as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[12]) +
         as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[14]) +
         as.numeric(unlist(decrit(dataset$employment_status[!(dataset$age %in% c("65+"))], weight = F))[16]))
    # Vote statistics
    if (country_list[i] == "US") {
      sample_candidate_1_mean <- sum(grepl("Biden", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Trump", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "FR") {  
      sample_candidate_1_mean <- sum(grepl("Macron", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Le Pen", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("Fillon", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- sum(grepl("Mélenchon", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
    } else if (country_list[i] == "DK") {
      sample_candidate_1_mean <- sum(grepl("Socialdemokratiet", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("^Venstre", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "IT") {  
      sample_candidate_1_mean <- sum(grepl("Movimento 5 Stelle", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Partito Democratico", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("Lega", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "PL") {
      sample_candidate_1_mean <- sum(grepl("Andrzej Duda", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Trzaskowski", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("Hołownia", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "MX") {
      sample_candidate_1_mean <- sum(grepl("MORENA", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("PAN", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("PRI", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "JP") {
      sample_candidate_1_mean <- sum(grepl("Liberal Democratic Party", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Constitutional Democratic Party of Japan", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("Japan Innovation Party", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "SP") { 
      sample_candidate_1_mean <- sum(grepl("PSOE", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("PP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("VOX", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "IA") { 
      sample_candidate_1_mean <- sum(grepl("BJP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("INC", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "ID") {
      sample_candidate_1_mean <- sum(grepl("PDI-P", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Gerindra", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("Golkar", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "SA") {
      sample_candidate_1_mean <- sum(grepl("ANC", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("(DA)", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "DE") {
      sample_candidate_1_mean <- sum(grepl("CDU/CSU", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("SPD", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "CA") {
      sample_candidate_1_mean <- sum(grepl("Conservative", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Liberal", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("New Democratic", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "AU") {
      sample_candidate_1_mean <- sum(grepl("Liberal/National coalition", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Labor", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "UA") {
      sample_candidate_1_mean <- sum(grepl("Zelensky", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Poroshenko", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "SK") {
      sample_candidate_1_mean <- sum(grepl("Jae-in", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Joon-pyo", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("Cheol-soo", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "TR") {
      sample_candidate_1_mean <- sum(grepl("AKP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("CHP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "BR") {
      sample_candidate_1_mean <- sum(grepl("Bolsonaro", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Haddad", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "UK") {
      sample_candidate_1_mean <- sum(grepl("Conservative", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_mean <- sum(grepl("Labour", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_mean <- sum(grepl("Liberal Democrats", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_mean <- NA
    } else if (country_list[i] == "CN") {
      sample_candidate_1_mean <- NA
      sample_candidate_2_mean <- NA
      sample_candidate_3_mean <- NA
      sample_candidate_4_mean <- NA
    }
    sample_vote <- c(sample_candidate_1_mean, sample_candidate_2_mean, sample_candidate_3_mean, sample_candidate_4_mean)
    if (country_list[i] %in% c("CN")) {
      sample_vote <- rep(NA, 4)
    }
    # Home ownership statistics
    sample_home_ownership <- mean(d(country_list[i])$home_owner)
    # Combine Statistics
    sample <- c(sample_size, sample_male, sample_age_18_24, sample_age_25_34, sample_age_35_49, sample_age_50_64 + sample_age_65_more,
                sample_income_Q1, sample_income_Q2, sample_income_Q3, sample_income_Q4, sample_region_1, sample_region_2,
                sample_region_3, sample_region_4, sample_region_5, sample_urban, sample_college, sample_vote,
                sample_unemployment_rate, sample_home_ownership)
    
    names(sample) <- labels_columns_stats
    sample_rounded <- c(prettyNum(sample[1], big.mark = ","), sprintf("%.2f",round(sample[2:length(sample)], digits = 2)))
    names(sample_rounded) <- labels_columns_stats
    
    
    # Get Population statistics
    pop_size <- NA
    # Gender statistics
    pop_male <- pop_freq[[country_list[i]]]$gender[3]
    # Age statistics
    pop_age_18_24 <- pop_freq[[country_list[i]]]$age[1]
    pop_age_25_34 <- pop_freq[[country_list[i]]]$age[2]
    pop_age_35_49 <- pop_freq[[country_list[i]]]$age[3]
    pop_age_50_64 <- pop_freq[[country_list[i]]]$age[4]
    pop_age_65_more <- pop_freq[[country_list[i]]]$age[5]
    # Income statistics
    pop_income_Q1 <- pop_freq[[country_list[i]]]$income[1]
    pop_income_Q2 <- pop_freq[[country_list[i]]]$income[2]
    pop_income_Q3 <- pop_freq[[country_list[i]]]$income[3]
    pop_income_Q4 <- pop_freq[[country_list[i]]]$income[4]
    # Region statistics
    if (country_list[i] != "FR"){
      pop_region_1 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][1]
      pop_region_2 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][2]
      pop_region_3 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][3]
      pop_region_4 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][4]
      if (!(country_list[i] %in% c("SK", "TR", "US", "UA"))){
        pop_region_5 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][5]
      } else{
        pop_region_5 <- NA
      }
    } else{
      pop_region_1 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][2]
      pop_region_2 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][3]
      pop_region_3 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][4]
      pop_region_4 <- pop_freq[[country_list[i]]][[paste(country_list[i],"region", sep = "_")]][order(levels_quotas[[paste(country_list[i],"region", sep = "_")]])][5]
      pop_region_5 <- NA
    }
    # Urban statistics
    if (!(country_list[i] %in% c("FR", "IT", "UK", "DE", "CN", "MX", "SK"))){
      pop_urban <- pop_freq[[country_list[i]]]$urban[2]
    } else if (country_list[i] == "FR"){
      pop_urban <- pop_freq[[country_list[i]]][[paste(country_list[i],"urban_category", sep = "_")]][1]
    } else if (country_list[i] == "IT"){
      pop_urban <- pop_freq[[country_list[i]]][[paste(country_list[i],"urban_category", sep = "_")]][1] + pop_freq[[country_list[i]]][[paste(country_list[i],"urban_category", sep = "_")]][2]
    } else if (country_list[i] %in% c("UK", "DE", "CN", "SK")){
      pop_urban <- pop_freq[[country_list[i]]][[paste(country_list[i],"urban_category", sep = "_")]][2] + pop_freq[[country_list[i]]][[paste(country_list[i],"urban_category", sep = "_")]][3]
    } else if (country_list[i] == "MX"){
      pop_urban <- pop_freq[[country_list[i]]][[paste(country_list[i],"urban_category", sep = "_")]][3]
    }
    # Education statistics
    if (country_list[i] %in% countries[countries %in% rich_countries]){
      pop_college <- board$College[board$country == country_list[i]]
    } else {
      pop_college <- board$Master[board$country == country_list[i]]
    }
    # Vote statistics
    pop_candidate_1 <- board$candidate_1[board$country == country_list[i]]
    pop_candidate_2 <- board$candidate_2[board$country == country_list[i]]
    pop_candidate_3 <- board$candidate_3[board$country == country_list[i]]
    pop_candidate_4 <- board$candidate_4[board$country == country_list[i]]
    pop_vote <- c(pop_candidate_1, pop_candidate_2, pop_candidate_3, pop_candidate_4)
    # Unemployment statistics
    pop_unemployment_rate <- board$U_rate[board$country == country_list[i]]
    # Combine Statistics
    pop <- c(pop_size, pop_male, pop_age_18_24, pop_age_25_34, pop_age_35_49, pop_age_50_64 + pop_age_65_more,
             pop_income_Q1, pop_income_Q2, pop_income_Q3, pop_income_Q4, pop_region_1, pop_region_2, pop_region_3,
             pop_region_4, pop_region_5, pop_urban, pop_college, pop_vote, pop_unemployment_rate, pop_home_ownership[[country_list[i]]])
    
    pop_rounded <- round(pop, digits = 2)
    names(pop) <- labels_columns_stats
    names(pop_rounded) <- labels_columns_stats
    # Append the two vectors to a common data frame
    stats_table[,(i*2-1)] <- pop_rounded
    names(stats_table)[(i*2-1)] <- paste0(country_list[i],"_pop")
    stats_table[,(i*2)] <- sample_rounded
    names(stats_table)[(i*2)] <- paste0(country_list[i],"_sample")
  }
  
  if (missing(filename)) filename <- paste(country_list, collapse = '_')
  filename <- paste0(filename, "_ageCombined")
  header <- c("", rep("2", length(country_list)))
  names(header) <- c("", Country_Names[country_list])
  # Create the LaTeX table
  line_sep <- c("\\midrule", "\\addlinespace", "", "", "", "\\addlinespace","", "", "",
                "\\addlinespace", "", "", "", "", "\\addlinespace","\\addlinespace", "\\addlinespace","","","","\\addlinespace", "\\addlinespace")
  latex_output <- kbl(stats_table, "latex",
                      col.names = rep(c("Population", "Sample"), length(country_list)), booktabs = TRUE,
                      linesep = line_sep) %>%
    add_header_above(header)
  
  if (return_table) return(stats_table)
  else cat(paste(latex_output, collapse="\n"), file = paste0(folder, filename, ".tex"))
}

reg_appendix <- function(dep_vars, along = NULL, A = T, B = T, C = FALSE, treatment = FALSE, dep.var.labels = dep_vars, filename = dep_vars[1], dep.var.caption = NULL, data = all, indep_labels = NULL, add_linesAB = FALSE) {
  # Even when treatment = FALSE, treatment is a covariate. treatment = TRUE means that we only keep the treatment variables in the display.
  if (!is.null(along) & A & B & !C & !treatment & length(dep_vars) == 1 & exists("setAt") & exists("setB") & exists("high_income")) { 
    B_hi <- same_reg_subsamples(dep.var = dep_vars, include.total = FALSE, covariates = c(setAt, setB), data = data[high_income[data$country],], filename = paste0(filename, "_AtB_hi"))
    B_mi <- same_reg_subsamples(dep.var = dep_vars, include.total = FALSE, covariates = c(setAt, setB), data = data[!high_income[data$country],], filename = paste0(filename, "_AtB_mi"))
    if (length(B_hi) != 73) warning(paste0("Specification with set B may have an issue: length(B_hi) = ", length(B_hi)))
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = setAt, data = data[high_income[data$country],], filename = paste0(filename, "_AtB_hi"), replace_endAB = B_hi[c(45:length(B_hi), 10)], add_lines = c(list(c(45, "Panel B: Energy usage indicators")), list(c(11, "Panel A: Socio-economic indicators"))))
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = setAt, data = data[!high_income[data$country],], filename = paste0(filename, "_AtB_mi"), replace_endAB = B_mi[c(45:length(B_mi), 10)], add_lines = c(list(c(45, "Panel B: Energy usage indicators")), list(c(11, "Panel A: Socio-economic indicators"))))
  } else if (!is.null(along) & A & B & !C & treatment & length(dep_vars) == 1 & exists("setAt") & exists("setC") & exists("high_income")) {
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = c(setAt, setB), keep = "treatment", data = all[high_income[all$country],], filename = paste0(filename, "_AtB_keept_hi")) #, add_lines = c(list(c(46, "Panel C: Rationales")), list(c(10, "Panel A: Socio-economic indicators"))))
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = c(setAt, setB), keep = "treatment",  data = all[!high_income[all$country],], filename = paste0(filename, "_AtB_keept_mi")) #, add_lines = c(list(c(46, "Panel C: Rationales")), list(c(10, "Panel A: Socio-economic indicators"))))
  } else if (!is.null(along) & A & !B & !C & treatment & length(dep_vars) == 1 & exists("setAt") & exists("high_income")) {
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = c(setAt), keep = "treatment", data = all[high_income[all$country],], filename = paste0(filename, "_At_keept_hi"))
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = c(setAt), keep = "treatment", data = all[!high_income[all$country],], filename = paste0(filename, "_At_keept_mi"))
  } else if (!is.null(along) & A & !B & C & !treatment & length(dep_vars) == 1 & exists("setAt") & exists("setC") & exists("high_income")) {
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = c(setAt, setC), keep = setC, data = all[high_income[all$country],], filename = paste0(filename, "_AtC_keepC_hi")) #, add_lines = c(list(c(46, "Panel C: Rationales")), list(c(10, "Panel A: Socio-economic indicators"))))
    same_reg_subsamples(dep_vars, include.total = FALSE, covariates = c(setAt, setC), keep = setC,  data = all[!high_income[all$country],], filename = paste0(filename, "_AtC_keepC_mi")) #, add_lines = c(list(c(46, "Panel C: Rationales")), list(c(10, "Panel A: Socio-economic indicators"))))
  } else if (is.null(along) & A & B & !C & !treatment & add_linesAB) { 
    table_B <- desc_table(dep_vars = dep_vars, dep.var.labels = dep.var.labels, filename = filename, dep.var.caption = dep.var.caption, data = data, indep_vars = c(setAt, setB, "country"), keep = c(setAt, setB), mean_control = T, mean_above = FALSE)
    if (length(table_B) != 72) warning(paste0("Specification with set B may have an issue: length(table_B) = ", length(table_B)))
    desc_table(dep_vars = dep_vars, dep.var.labels = dep.var.labels, filename = filename, dep.var.caption = dep.var.caption, data = data, indep_vars = c(setAt, "country"), keep = setAt, mean_control = T, replace_endAB = table_B[43:length(table_B)], add_lines = c(list(c(49, "Panel B: Energy usage indicators")), list(c(11, "Panel A: Socio-economic indicators"))))
  } else if (is.null(along) & A & !B & C & !treatment & add_linesAB) {
    desc_table(dep_vars = dep_vars, dep.var.labels = dep.var.labels, filename = filename, dep.var.caption = dep.var.caption, data = data, indep_vars = c(setAt, setC, "country"), keep = setC, mean_control = T, add_lines = c(list(c(45, "Panel B: Energy usage indicators")), list(c(11, "Panel A: Socio-economic indicators"))))
  } else if (is.null(along) & A & !B & !C & treatment) {
    desc_table(dep_vars = dep_vars, dep.var.labels = dep.var.labels, filename = filename, dep.var.caption = dep.var.caption, data = all, indep_vars = c(setAt, "country"), keep = "treatment", indep_labels = indep_labels, mean_control = T)
  } else warning("Case not supported")
}

treatment_table_oecd <- function(list_countries = countries[high_income], dep_vars_all, filename = NULL, indep_vars = control_variables, indep_labels = NULL, weight = T, add_lines = NULL, model.numbers = T, #!mean_above,
                                 save_folder = "../tables/", dep.var.labels_all = NULL, dep.var.caption = c(""), digits= 3, mean_control = T, logit = FALSE, atmean = T, robust_SE = F, omit = c("Constant", "Gender: Other", "Economic Leaning: PNR"),
                                 only_mean = F, keep = indep_vars, nolabel = F, indep_vars_included = T, print_regs = FALSE, lee_bounds = F) {
  # Wrapper for stargazer
  # /!\ always run first with nolabel = T to check that the order of indep_labels correspond to the one displayed
  # dep_vars: either a variable name (automatically repeated if needed) or a list of variable names (of length the number of columns)
  # (in)dep_vars accept expressions of type : var_name expression (e.g. "equal_quota %in% 0:1", but not "equal_quota == 0 | equal_quota==1)
  # /!\ There is a bug if the interaction terms are not at the end of indep_vars, also a bug if the unused indep variables in the first regression are not at the end
  # /!\ To appear in the table, they should be written without parentheses and with due space, e.g. "var > 0" and not "(var>0)"
  # indep_vars is the list of potential covariates, they are by default all included by
  # indep_vars_included can be set to a list (of length the number of columns) of booleans or variable names to specify which covariates to include in each column
  # keep is a vector of regular expressions allowing to specify which covariates to display (by default, all except the Constant)
  # mean_above=T displays the mean of the dependant var (for those which treatment=="control" if mean_control = T) at top rather than bottom of Table (only_mean=T only displays that)
  # logit is either a boolean or a boolean vector
  # data can be a list of data frames instead of a single one
  tables_country <- c()
  for(country in list_countries){
    if (country %in% tropical_countries) {
      dep_vars = dep_vars_all[1:10]
      dep.var.labels = dep.var.labels_all[1:10]
    } else {
      dep_vars = dep_vars_all
      dep.var.labels = dep.var.labels_all
    }
    
    indep_vars_included <- T
    logit <- F
    
    data <- d(country)
    weights <- data$weight
    country_name <- countries_names[country]
    if (missing(dep.var.labels) & !(is.character(dep_vars))) dep.var.labels <- dep_vars
    dep.var.labels.include <- ifelse(is.null(dep.var.labels), F, T)
    names(indep_vars) <- indep_vars
    print(country)
    if (class(indep_vars_included)=="list") { if (length(dep_vars)==1) dep_vars <- rep(dep_vars[1], length(indep_vars_included))  }
    else { indep_vars_included <- rep(list(rep(T, length(indep_vars))), length(dep_vars)) }
    if (length(logit) == 1) logit <- rep(logit, length(dep_vars))
    # if (length(indep_labels) > length(indep_vars)) indep_labels <- indep_labels[indep_vars]
    models <- coefs <- SEs <- list()
    means <- c()
    for (i in seq_along(dep_vars)) {
      df <- if (is.data.frame(data)) data else data[[i]]
      formula_i <- as.formula(paste(dep_vars[i], "~", paste("(", indep_vars[indep_vars_included[[i]] & covariates_with_several_values(data = df, covariates = indep_vars)], ")", collapse = ' + ')))
      if (logit[i]) {
        models[[i]] <- glm(formula_i, data = df, family = binomial(link='logit'))
        logit_margin_i <- logitmfx(formula_i, data = df, robust = robust_SE, atmean = atmean)$mfxest # 
        coefs[[i]] <- logit_margin_i[,1]
        SEs[[i]] <- logit_margin_i[,2]
      }
      else {
        models[[i]] <- lm(formula_i, data = df, weights = weights)
        coefs[[i]] <- models[[i]]$coefficients
        if (robust_SE) SEs[[i]] <- coeftest(models[[i]], vcov = vcovHC(models[[i]], "HC1"))[,2]
        else SEs[[i]] <- summary(models[[i]])$coefficients[,2]
      }
      if (print_regs) print(summary(models[[i]]))
      if (mean_control==FALSE){
        means[i] <- round(wtd.mean(eval(parse(text = paste( "df$", parse(text = dep_vars[i]), sep=""))), weights = weights, na.rm = T), d = digits)
        mean_text <- "Mean"
      } else {
        means[i] <- round(wtd.mean(eval(parse(text = paste( "(df$", parse(text = dep_vars[i]), ")[df$treatment=='None']", sep=""))), weights = weights[df$treatment=='None'], na.rm = T), d = digits)
        mean_text <- "Control group mean"
      }
      
      if (lee_bounds) {
        models[[i]] <- return_lee_bounds(models[[i]], country, dep_vars[i])
      }
      
      if (robust_SE) {
        temp_model <- models[[i]] %>%
          modelsummary(output = "modelsummary_list")
        temp_model$tidy$std.error <- SEs[[i]]
        models[[i]] <- temp_model
      }
    }
    
    keep <- gsub("(.*)", "\\\\\\Q\\1\\\\\\E", sub("^\\(", "", sub("\\)$", "", keep)))
    if (exists("regressors_names") & missing(indep_labels)) {
      if (!is.data.frame(data)) data <- data[[1]]
      model_total <- lm(as.formula(paste(dep_vars[1], "~", paste("(", indep_vars[covariates_with_several_values(data = data, covariates = indep_vars)], ")", collapse = ' + '))), data = data)
      indep_labels <- create_covariate_labels(names(model_total$coefficients)[-1], regressors_names = regressors_names, keep = keep, omit = "Constant")
    }
    
    country_column <- rep("", length(indep_labels)*2)
    country_column[round(length(indep_labels)/2)] <- paste0("\\textbf{", country_name, "}")
    cols <- data.frame(country_column)
    names(cols) <- c(" ")
    attr(cols, "position") <- c(1)
    
    if (country == "all") cols <- NULL
    
    if (country != "all") {
      control_row <- c("", mean_text, means)
      empty_row <- rep("", 2 + length(dep_vars))
      rows <- data.frame(rbind(control_row, empty_row))
      attr(rows, "position") <- c(1, 2)
      
      header_table <- c("", "", length(dep_vars))
      names(header_table) <- c("", "", dep.var.caption)
    } else {
      control_row <- c(mean_text, means)
      rows <- data.frame(rbind(control_row))
      attr(rows, "position") <- c(1)
      
      header_table <- c("", length(dep_vars))
      names(header_table) <- c("", dep.var.caption)
    }
    
    
    names(models) <- dep.var.labels
    if (country == "all") align <- paste0("l", paste(rep("c", length(dep_vars)), collapse = "")) else align <- paste0("ll", paste(rep("c", length(dep_vars)), collapse = ""))
    
    table <- modelsummary(models, output = "latex", escape = F,
                          add_columns = cols, add_rows = rows,
                          align = align, # stars = c("*" = .1, "**" = .05, "***" = .001),
                          coef_map = regressors_names[regressors_names %in% indep_labels]) %>%
      add_header_above(header_table)
    if (country == "all") table <- row_spec(table, 1, extra_latex_after = "\\midrule")
    
    table <- str_split(table, "\n")[1][[1]]
    table_header <- table[grep(align, table):grep(dep.var.labels[1], table, fixed = T)]
    table_header <- c(table_header[1:grep("toprule", table_header)], "\\toprule", table_header[(grep("toprule", table_header)+1):length(table_header)])
    table_footer <- c("\\bottomrule", "\\bottomrule", "\\end{tabular}")
    if (country == "all") tables_core_country <- table[(grep("Mean|Control", table)-1):(grep("Num.Obs.", table) + 1)] else tables_core_country <- table[(grep("Mean|Control", table)-1):(grep("Num.Obs.", table)-2)]
    # tables_core_country <- table[(grep("Mean|Control", table)-1):(grep("Num.Obs.", table)-2)]
    tables_country <- c(tables_country, tables_core_country)
  }
  
  table_final <- c(table_header, tables_country, table_footer)
  
  if (missing(filename)) file_path <- NULL
  else file_path <- paste0(save_folder, filename, ".tex")
  
  cat(paste(table_final, collapse="\n"), file = file_path) 
  return(cat(paste(table_final, collapse="\n")))
}

prepare <- function(incl_quality_fail = FALSE, exclude_speeder=TRUE, exclude_screened=TRUE, only_finished=TRUE, only_known_agglo=T, duration_min=0, country = "US", wave = NULL, weighting = TRUE, replace_brackets = FALSE, zscores = T, zscores_dummies = FALSE, remove_id = FALSE, efa = FALSE, combine_age_50 = T) { #(country!="DK") # , exclude_quotas_full=TRUE
  filename <- paste0(c(country, wave), collapse="_")
  file <- paste0("../data_raw/", filename, ".csv")
  if (remove_id) remove_id(filename)
  if (replace_brackets) {
    data <- readLines(file)
    data <- gsub("[Country]", Country_names[country], data, fixed = T)
    data <- gsub("[country]", country_names[country], data, fixed = T)
    writeLines(data, con=file)  }
  e <- read_csv(file)
  
  if (missing(wave)) wave <- "full"
  e <- relabel_and_rename(e, country = country, wave = wave)
  
  if (country == "US" & wave == "compl_regular") e$excluded[e$type =="Complete" & e$excluded == "QuotaMet"] <- NA
  
  print(paste(length(which(e$excluded=="QuotaMet")), "QuotaMet"))
  e$finished[e$excluded=="QuotaMet"] <- "False" 
  # The following line only has an effect on allq, it excludes respondents who were screened out in Qualtrics although they succeeded the attention test (due to a bug in Qualtrics).
  if (exclude_screened) e <- e[!(no.na(e$excluded) == "Screened" & replace_na(e$attention_test) == "A little") & !is.na(e$attention_test) & no.na(e$excluded) != "QuotaMet",] 
  if (exclude_screened & !incl_quality_fail) { e <- e[is.na(e$excluded),] } # Excludes respondents who failed the quality test or whose quota was full.
  if (exclude_speeder) e <- e[as.numeric(as.vector(e$duration)) > duration_min,]  # Excludes respondents who rushed through the survey.
  if (only_finished) e <- e[e$finished==1,] # Excludes respondents who did not complete the survey.
  # Main function to cleanse the data:
  e <- convert(e, country = country, wave = wave, weighting = weighting, zscores = zscores, zscores_dummies = zscores_dummies, efa = efa, combine_age_50 = combine_age_50)
  e <- e[,!duplicated(names(e))]
  if (!incl_quality_fail) e <- e[e$attentive == T, ] # Keep respondents who failed the attention test.
  
  e$valid <- (as.numeric(e$progress) > 1) & (e$attention_test == "A little" | is.na(e$attention_test)) & is.na(e$excluded)
  label(e$valid) <- "valid: Respondents that has not been screened out due to speed or failure to the attention test."
  e$dropout <- (e$attention_test == "A little" | is.na(e$attention_test)) & is.na(e$excluded) & e$finished != "1"
  label(e$dropout) <- "dropout: Respondent who did not complete the survey though was not excluded."
  e$finished_attentive <- (e$valid | (e$duration <= 686 & e$attention_test=="A little")) & e$finished==1
  label(e$finished_attentive) <- "finished_attentive: Respondent completed the survey and did not fail the attention test."
  
  return(e)
}

merge_all_countries <- function(df = lapply(countries, function(c) d(c)), weight_adult = T, weight_oecd = F, weight_no_pop = T) {
  all <- Reduce(function(df1, df2) { merge(df1, df2, all = T) }, df)
  if ("weight" %in% names(all)) {
    all$weight_country <- all$weight
    all$weight_pop <- all$weight * population[all$country]
    all$weight_adult <- all$weight * adult_pop[all$country]
    all$weight_pop_oecd <- all$weight * oecd[all$country] * population[all$country]
    all$weight_adult_oecd <- all$weight * oecd[all$country] * adult_pop[all$country]
    for (w in c("weight_country", "weight_pop", "weight_adult", "weight_pop_oecd", "weight_adult_oecd")) all[[w]] <- nrow(all) * as.numeric(all[[w]] / sum(all[[w]]))
    
    if (weight_adult) {
      if (weight_oecd) all$weight <- all$weight_adult_oecd
      else all$weight <- all$weight_adult
    } else {
      if (weight_oecd) all$weight <- all$weight_pop_oecd
      else all$weight <- all$weight_pop
    }
    if (weight_no_pop) all$weight <- all$weight_country    
  } else warning("No weight defined.")
  
  names_indices <<- c("affected", "knowledge", "knowledge_not_dum", "knowledge_footprint", "net_zero_feasible", "worried", "positive_economy", "policies_effective",
                      "affected_subjective", "lose_policies_subjective", "lose_policies_poor", "lose_policies_rich", "fairness", "trust_govt", "willing_change", "care_poverty", "problem_inequality",
                      "standard_policy", "tax_transfers_policy", "investments_policy", "main_policies", "main_policies_all", "main_policies_all", "beef_policies",
                      "international_policies", "other_policies", "all_policies", "standard_effective",
                      "tax_transfers_effective", "investments_effective", "tax_transfers_positive_economy", "standard_positive_economy", "investments_positive_economy", "lose_standard_poor", "lose_standard_rich", "lose_standard_subjective",
                      "lose_investments_poor", "lose_investments_rich", "lose_investments_subjective", "lose_tax_transfers_poor", "lose_tax_transfers_rich", "lose_tax_transfers_subjective", "policies_emissions", "investments_emissions", "tax_emissions_plus", "investments_emissions_plus", "standard_emissions_plus", 
                      "policies_pollution", "investments_pollution", "tax_transfers_pollution", "standard_pollution", "tax_emissions", "standard_emissions", 
                      "policies_emissions_plus", "fairness_standard", "fairness_tax_transfers", "fairness_investments", "knowledge_fundamentals", "knowledge_gases", "knowledge_impacts", "worried_old", "concerned_about_CC")
  
  for (i in names_indices) {
    tryCatch({ temp <- index_zscore(i, df = all, weight = T, dummies = FALSE, require_all_variables = TRUE, efa = FALSE)
    all[[paste0("index_c_", i)]] <- all[[paste0("index_", i)]]
    all[[paste0("index_", i)]] <- temp # all[[paste0("index_pooled_", i)]]
    }, error = function(cond) { print(paste("Index", i, "could not be created")) } )  }
  
  if ("heating_expenses" %in% names(all)) { # Replace heating expenses for countries where the variable is not defined
    all$heating_expenses_original <- all$heating_expenses
    all$heating_expenses <- as.character(all$heating_expenses)
    all[["heating_expenses"]][all$country  %in% c("MX", "BR", "IA", "ID")] <- "Don't know"
    temp <- 125*(all$heating_expenses == "< 250") + 600*(all$heating_expenses == "251-1,000") + 1250*(all$heating_expenses == "1,001-1,500") +
      2000*(all$heating_expenses == "1,501-2,500") + 3000*(all$heating_expenses == "> 2,500") - 0.1*(all$heating_expenses == "Don't know")
    all$heating_expenses <- as.item(temp, labels = structure(c(-0.1, 125, 600, 1250, 2000, 3000), names = c("Don't know","< 250","251-1,000", "1,001-1,500","1,501-2,500", "> 2,500")), missing.values=-0.1, annotation=Label(all$heating_expenses))
  }
  
  return(all)
}

prepare_all <- function(weighting = T, zscores = T, zscores_dummies = F, efa = FALSE, pilots = FALSE, prepare.countries = T, merge = T, remove_id = F, incl_all = FALSE, incl_quality_fail = FALSE, rm_country_data = T) {
  start <- Sys.time()
  if (prepare.countries) {
    variables_include <- c("finished", "excluded", "duration", "attention_test", "progress", "dropout", "valid", "finished_attentive", "education_original", "college", "gender", "treatment_policy", "treatment_climate", "age", "income", "investments_support", "standard_support", "tax_transfers_support", "standard_fair", "tax_transfers_fair", "investments_fair", "urbanity", "agglo_categ",
                           "standard_public_transport_support", "policy_tax_fuels", "policy_tax_flying", "policy_subsidies", "insulation_mandatory_support_no_priming", "net_zero_feasible", "index_knowledge_gases", "index_trust_govt", "index_fairness", "index_willing_change", "policy_ban_city_centers", "willing_electric_car", "willing_limit_driving", "willing_limit_flying", "willing_limit_beef", "willing_limit_heating", 
                           "availability_transport", "car_dependency", "flights_agg", "polluting_sector", "frequency_beef", "owner", "female", "other", "children", "age_control", "income_factor", "educ_categ", "econ_leaning", "treatment", "petition", "can_trust_govt", "urban_category", "high_gas_expenses", "high_heating_expenses", "region") 
    if (incl_all) for (c in countries) {
      temp <- prepare(country = c, duration_min = 686, incl_quality_fail = T, exclude_speeder = F, only_finished = F, exclude_screened = F, weighting = weighting, zscores = zscores, zscores_dummies = zscores_dummies, efa = efa, remove_id = remove_id)
      eval(str2expression(paste0(tolower(c), "a <<- temp[, intersect(names(temp), variables_include)]")))
      eval(str2expression(paste0(tolower(c), "a$country <<- '", c, "'"))) }
    else if (incl_quality_fail) for (c in countries) eval(str2expression(paste0(tolower(c), "q <<- prepare(country = '", c, "', duration_min = 686, weighting = weighting, zscores = zscores, zscores_dummies = zscores_dummies, efa = efa, remove_id = remove_id, incl_quality_fail = T)")))
    else {
      if (pilots) {
        usp1 <<- prepare(country = "US", wave = "pilot1", duration_min = 0)
        usp2 <<- prepare(country = "US", wave = "pilot2", duration_min = 686)
        usp3 <<- prepare(country = "US", wave = "pilot3", duration_min = 686)
        usp3all <<- prepare(country = "US", wave = "pilot3", duration_min = 686, exclude_screened = F, exclude_speeder = F)
        usp12 <<- merge(usp1, usp2, all = T)
        usp <<- merge(usp3, usp12, all = T) 
        us_all <<- prepare(country = "US", duration_min = 0, only_finished = F, exclude_screened = F, exclude_speeder = F)
      }
      for (c in countries) eval(str2expression(paste0(tolower(c), " <<- prepare(country = '", c, "', duration_min = 686, weighting = weighting, zscores = zscores, zscores_dummies = zscores_dummies, efa = efa, remove_id = remove_id)")))
    }
  }
  if (merge) {
    if (incl_all) { alla <<- merge_all_countries(df = lapply(countries, function(c) eval(str2expression(paste0(tolower(c), "a")))))
    if ("treatment_climate" %in% names(alla)) {
      alla$treatment <<- "None"
      alla$treatment[alla$treatment_climate == 1 & alla$treatment_policy == 0] <<- "Climate impacts"
      alla$treatment[alla$treatment_climate == 0 & alla$treatment_policy == 1] <<- "Climate policy"
      alla$treatment[alla$treatment_climate == 1 & alla$treatment_policy == 1] <<- "Both"
      alla$treatment <<- relevel(relevel(relevel(as.factor(alla$treatment), "Climate policy"), "Climate impacts"), "None")
      label(alla$treatment) <<- "treatment: Treatment received: Climate impacts/Climate policy/Both/None" 
      temp <-  (alla$income %in% text_income_q1) + 2 * (alla$income %in% text_income_q2) + 3 * (alla$income %in% text_income_q3) + 4 * (alla$income %in% text_income_q4) 
      alla$income <<- as.item(temp, labels = structure(c(1:4), names = c("Q1","Q2","Q3","Q4")), annotation=Label(alla$income))
      
      alla$final <<- 1*(alla$finished==1 & is.na(alla$excluded) & no.na(alla$attention_test) == "A little")
      for (v in c("standard_public_transport_support", "tax_transfers_support", "investments_support", "standard_support", "policy_tax_fuels", "policy_ban_city_centers", "policy_tax_flying", "policy_subsidies", "insulation_mandatory_support_no_priming")) alla[[paste0(v, "_binary")]] <<- 1*grepl("support$", alla[[v]])
      alla$net_zero_feasible_binary <<- as.character(alla$net_zero_feasible) %in% c("A great deal", "A lot")
      for (v in c("index_c_knowledge_gases", "index_trust_govt", "index_c_fairness", "index_c_willing_change")) alla[[paste0(v, "_binary")]] <<- alla[[v]] > 0
      alla$treatment_both <<- 1*(alla$treatment == "Both")
      alla$excluded[n(alla$duration) > 686/60 & no.na(alla$attention_test) == "A little" & !is.na(alla$excluded)] <<- "QuotaMet"
    }
    if (rm_country_data) rm(list = paste0(tolower(countries), "a"), envir = .GlobalEnv)
    } else if (incl_quality_fail) {
      allq <<- merge_all_countries(df = lapply(countries, function(c) eval(str2expression(paste0(tolower(c), "q")))))
      if (rm_country_data) rm(list = paste0(tolower(countries), "q"), envir = .GlobalEnv)
    } else {
      all <<- merge_all_countries()
      if (rm_country_data) rm(list = tolower(countries), envir = .GlobalEnv)
    }
    if (!incl_all) {
      e <<- all
      variables_policy_all <<- names(e)[grepl('policy_', names(e)) & !grepl("order_|list_", names(e))]
      variables_tax_all <<- names(e)[grepl('^tax_', names(e)) & !grepl("order_|transfers_|1p", names(e))]
      variables_beef <<- names(e)[grepl('beef_', names(e)) & !grepl("order_|know", names(e))]
      all_policies <<- c(variables_policies_support, "standard_public_transport_support", "tax_transfers_progressive_support", variables_fine_support, variables_policy, variables_tax, "global_quota", variables_global_policies, "insulation_support", variables_beef, variables_policy_additional) # include also should_fight_CC, burden_share, if_other_do_less/more, variables_flight_quota ?
    }
  }
  print(Sys.time()-start)
}


##### Preparation #####
# U.S. complementary surveys
usc_extra <- prepare(country = "US", wave = "compl_extra")
usc_extra$extra_incentive <- T
usc_regular <- prepare(country = "US", wave = "compl_regular")
usc_regular$extra_incentive <- FALSE
usc <- rbind(usc_regular, usc_extra)
# Creates 'allq': the extended dataset. The difference with 'all' is that it does not exclude respondents who failed the attention test.
prepare_all(incl_quality_fail = T) # 32 min
# Creates 'alla': the entire dataset. It keeps all observations, even those whose quota were full (and were then screened out at the beginning, right after sociodemographic questions.)
prepare_all(incl_all = T) # Creates 'alla': the merging of raw samples. 53 min
# Creates 'all': the final dataset. It excludes respondents who rushed (completed the survey in less than 686 seconds), who did not complete the survey, or were screened out for failing the attention test or whose quotas were full.
prepare_all() # 35 min 
us_control <- all[all$treatment == "None" & all$country == "US",]

##### Variable sets and names #####
control_variables <- c("majority_origin", "female", "children", "college", "as.factor(employment_agg)", "income_factor", "age", "left_right <= -1", "left_right >= 1", "left_right == 0")
cov_lab <- c("origin: largest group", "Female", "Children", "No college", "status: Retired" ,"status: Student", "status: Working", "Income Q2", "Income Q3", "Income Q4","age: 25-34", "age: 35-49", "age: 50-64", "age: 65+", "Left or Very left", "Right or Very right", "Center") 
control_variables_w_treatment <- c("majority_origin", "female", "children", "college", "as.factor(employment_agg)", "income_factor", "age", "left_right <= -1", "left_right >= 1", "left_right == 0", "treatment")
cov_lab_w_treatment <- c("race: White only", "Female", "Children", "No college", "status: Retired" ,"status: Student", "status: Working", "Income Q2", "Income Q3", "Income Q4","age: 25-34", "age: 35-49", "age: 50-64", "age: 65+", "Left or Very left", "Right or Very right", "Center", "Climate treatment only", "Policy treatment only", "Both treatments")

# Sets. A: core socio-demos + vote. At: A + treatment. B: energy characteristics. C: mechanisms. D: outcomes. Dpos: binary outcomes (> 0).
setA <- c("female", "other", "children", "age_control", "income_factor", "educ_categ", "econ_leaning") 
setAt <- c(setA, "treatment") 
setB <- c("agglo_categ", "(availability_transport >= 1)", "car_dependency", "high_gas_expenses", "high_heating_expenses", "(flights_agg > 1)", "polluting_sector", "(frequency_beef >= 1)", "owner") 
setC <- c("index_trust_govt", "index_problem_inequality", "index_worried", "index_net_zero_feasible", "index_affected_subjective", "index_knowledge_footprint", "index_knowledge_fundamentals", "index_knowledge_gases", "index_knowledge_impacts", "index_positive_economy", "index_policies_pollution", "index_policies_emissions_plus", "index_lose_policies_subjective", "index_lose_policies_poor", "index_lose_policies_rich")

setC_tax_transfers <- c(setC[1:9], "index_tax_transfers_positive_economy", "index_tax_transfers_pollution", "index_tax_emissions_plus", "index_lose_tax_transfers_subjective", "index_lose_tax_transfers_poor", "index_lose_tax_transfers_rich")
setC_standard <- c(setC[1:9], "index_standard_positive_economy", "index_standard_pollution", "index_standard_emissions_plus", "index_lose_standard_subjective", "index_lose_standard_poor", "index_lose_standard_rich")
setC_investments <- c(setC[1:9], "index_investments_positive_economy", "index_investments_pollution", "index_investments_emissions_plus", "index_lose_investments_subjective", "index_lose_investments_poor", "index_lose_investments_rich")

setC_indiv_main_label <- c(setC[1:9],
                           "Believes the policy would have positive econ. effects", "Believes the policy would reduce pollution", "Believes the policy would reduce emissions",
                           setC[13:15])

setC_label <- c("Trusts the governement", "Believes inequality is an important problem", "Worries about the consequences of CC", "Believes net-zero is technically feasible", "Believes will suffer from climate change",
                "Understands emission across activities/regions", "Knows CC is real \\& caused by humans", "Knows which gases cause CC", "Understands impacts of CC",
                "Believes policies would have positive econ. effects", "Believes policies would reduce pollution", "Believes policies would reduce emissions",
                "Believes own household would lose", "Believes low-income earners will lose", "believes high-income earners will lose")

uncommon_questions <- c(variables_fine_support, variables_fine_prefer, variables_gas_spike, variables_policy_additional, variables_flight_quota, "investments_funding_global_transfer") 
# common_policies <- Reduce(function(vars1, vars2) { intersect(vars1, vars2) }, c(list(all_policies), lapply(lapply(countries, function(c) eval(str2expression(tolower(c)))), names))) 
common_policies <- c("standard_support", "investments_support", "tax_transfers_support", "standard_public_transport_support", "policy_tax_flying", "policy_tax_fuels", "policy_ban_city_centers", "policy_subsidies", "policy_climate_fund", "tax_transfer_constrained_hh", "tax_transfer_poor", "tax_transfer_all", "tax_reduction_personal_tax", "tax_reduction_corporate_tax", "tax_rebates_affected_firms", "tax_investments", "tax_subsidies", "tax_reduction_deficit", "global_assembly_support", "global_tax_support", "tax_1p_support")
variables_policy <- intersect(variables_policy_all, common_policies)
variables_tax <- intersect(variables_tax_all, common_policies)
setD <- c(common_policies, "should_fight_CC")
setDpos <- paste0("(", setD, " >= 1)")

# all$share_common_policies_supported <-  rowMeans(all[, common_policies] > 0, na.rm = T)
# label(all$share_common_policies_supported) <- "share_common_policies_supported: Share of all policies supported (strongly or somewhat) among all policies asked to the respondent that were asked in all countries."


regressors_names <- rev(c("treatment_list_experiment_policyTRUE" = "List contains: Carbon tax with cash transfers", "treatment_list_experiment_behaviorTRUE" = "List contains: Limit beef/meat consumption", "treatment_knowledgeTRUE" = "Incentives for knowledge", "treatment_taxTRUE" = "Incentives for carbon tax with cash transfers", "treatment_banTRUE" = "Incentives for ban on combustion engine cars", "treatment_investmentsTRUE" = "Incentives for green infrastructure program",
                          "extra_incentiveTRUE" = "Treatment: Extra Incentives", "femaleTRUE" = "Gender: Woman", "otherTRUE" = "Gender: Other", "genderMale" = "Gender: Man", "genderFemale" = "Gender: Woman", "childrenTRUE" = "Lives with child(ren) under 14", "age65+" = "Age: 65 or older", "age50-64" = "Age: 50 - 64", "age35-49" = "Age: 35 - 49", "age25-34" = "Age: 25 - 34",  "age_control50+" = "Age: 50 or older", "age_control35-49" = "Age: 35 - 49", "age_control25-34" = "Age: 25 - 34",
                          "income_factorQ4" = "Household income: Q4", "income_factorQ3" = "Household income: Q3", "income_factorQ2" = "Household income: Q2", "wealth" = "Individual wealth", "educ_categCollege degree" = "Highest diploma: College", "educ_categHigh-school non-College" = "Highest diploma: High school",
                          "econ_leaningPNR" = "Economic Leaning: PNR", "econ_leaningVery left" = "Economic Leaning: Very Left", "econ_leaningVery right" = "Economic Leaning: Very Right", "econ_leaningRight" = "Economic Leaning: Right", "econ_leaningCenter" = "Economic Leaning: Center", "econ_leaningLeft" = "Economic Leaning: Left", "as.character(left_right)Left" = "Political leaning: Left", "as.character(left_right)PNR" = "Political leaning: PNR", "as.character(left_right)Right" = "Political leaning: Right", "as.character(left_right)Veryleft" = "Political leaning: Veryleft", "as.character(left_right)Veryright" = "Political leaning: Veryright", 
                          "treatmentNone" = "Treatment: None", "treatmentBoth" = "Treatment: Both", "treatmentPolicy" = "Treatment: Climate policy", "treatmentClimate" = "Treatment: Climate impacts", "treatmentClimate impacts" = "Treatment: Climate Impacts", "treatmentClimate policy" = "Treatment: Climate Policies", "factor(country)" = "Country",
                          
                          "age_control" = "Age", "income_factor" = "Income", "educ_categ" = "Education", "econ_leaning" = "Economic leaning", "treatment" = "Treatment", "agglo_categ" = "Size of agglomeration", "female" = "Gender: Woman", "children" = "Lives with child(ren)", 
                          "availability_transport >= 1" = "Availability of public transport", "car_dependency" = "Car usage", "high_gas_expenses" = "Gas expenses", "high_heating_expenses" = "Heating expenses", "flights_agg > 1" = "Flying frequency", "polluting_sector" = "Sector of activity", "frequency_beef >= 1" = "Beef consumption", "owner" = "Home ownership", "country" = "Country", 
                          "as.factor(wealth)Q5" = "Individual Wealth : Q5", "as.factor(wealth)Q4" = "Individual Wealth : Q4", "as.factor(wealth)Q3" = "Individual Wealth : Q3", "as.factor(wealth)Q2" = "Individual Wealth : Q2",
                          "employment_aggWorking" = "Employment status: Working", "employment_aggStudent" = "Employment status: Student", "employment_aggRetired" = "Employment status: Retired", "collegeNo college" = "Diploma: below college", "collegeCollege Degree" = "College degree",
                          "majority_originTRUE" = "Origin: country's majority one", "vote_agg_factorLeft" = "Vote: Left or Far left", "vote_agg_factorRight" = "Vote: Right or Far right", "vote_agg_factorCenter" = "Vote: Center", "vote_agg_factorPNR or other" = "Vote: Others or PNR",
                          "vote_agg == -0.1TRUE" = "Vote: Others or PNR","vote_agg == 0TRUE" = "Vote: Center", "vote_agg < 0TRUE" = "Vote: Left or Far left", "vote_agg <= -1TRUE" = "Vote: Left or Far left", "vote_agg >= 1TRUE" = "Vote: Right or Far right",
                          "(Intercept)" = "Intercept",
                          "agglo_categLarge agglo" = "Agglomeration size: Large", "agglo_categMedium agglo" = "Agglomeration size: Medium", "agglo_categSmall agglo" = "Agglomeration size: Small", "agglo_categRural" = "Agglomeration size: Rural", "availability_transport >= 1TRUE" = "Public transport available",
                          
                          "car_dependencyTRUE" = "Uses car", "high_gas_expensesTRUE" = "High gas expenses", "high_heating_expensesTRUE" = "High heating expenses", "flights_agg > 1TRUE" = "Flies more than once a year", "polluting_sectorTRUE" = "Works in polluting sector", "frequency_beef >= 1TRUE" = "Eats beef/meat weekly or more", "ownerTRUE" = "Owner or landlord",
                          "income_factorQ1" = "Household income: Q1", "age_control18-24" = "Age: 18 - 24", "other" = "Gender: other", "educ_categBelow high-school" = "Highest diploma: Below high-school",
                          "urbanTRUE" = "Urban", "gas_expenses" = "Gasoline expenses", "heating_expenses" = "Heating expenses", "availability_transport" = "Availability of public transport",
                          "heating_expenses_above_medianTRUE" = "High heating expenses given income", "gas_expenses_above_medianTRUE" = "High gasoline expenses given income", "gas_expenses > 50TRUE" = "High gasoline expenses", "gas_expenses > 100TRUE" = "High gasoline expenses", "heating_expenses > 500TRUE" = "High heating expenses", "heating_expenses > 1000TRUE" = "High heating expenses", 
                          
                          "standard_support >= 1TRUE" = "Ban on thermal cars: Support", "investments_support >= 1TRUE" = "Green infrastructure program: Support", "tax_transfers_support >= 1TRUE" = "Carbon tax with cash transfers: Support", "standard_public_transport_support >= 1TRUE" = "Ban on thermal cars w. alternatives available: Support", 
                          "policy_tax_flying >= 1TRUE" = "Tax on flying: Support", "policy_tax_fuels >= 1TRUE" = "Tax on fossil fuels: Support", "policy_ban_city_centers >= 1TRUE" = "Ban polluting cars from city centers: Support", "policy_subsidies >= 1TRUE" = "Subsidies for low-carbon tech.: Support", "policy_climate_fund >= 1TRUE" = "Climate fund: Support", 
                          "tax_transfer_constrained_hh >= 1TRUE" = "CT \\& Cash transfers for constrained HH: Support", "tax_transfer_poor >= 1TRUE" = "CT \\& Cash transfers to the poorest: Support", "tax_transfer_all >= 1TRUE" = "CT \\& Cash trasnfers to all: Support", "tax_reduction_personal_tax >= 1TRUE" = "CT \\& Reduction in personal tax: Support", "tax_reduction_corporate_tax >= 1TRUE" = "CT \\& Reduction in corporate tax: Support", 
                          "tax_rebates_affected_firms >= 1TRUE" = "CT \\& Tax rebates for affected firms: Support", "tax_investments >= 1TRUE" = "CT \\& Green infrastructure: Support", "tax_subsidies >= 1TRUE" = "CT \\& Low-carbon tech. subsidies: Support", "tax_reduction_deficit >= 1TRUE" = "CT \\& Reduction in the deficit: Support", 
                          "global_assembly_support >= 1TRUE" = "Global assembly on climate: Support", "global_tax_support >= 1TRUE" = "Global tax with cash transfers: Support", "tax_1p_support >= 1TRUE" = "Global tax on millionaires to fund LDC: Support", "should_fight_CC >= 1TRUE" = "Country should fight climate change: Agree", 
                          "CC_problem >= 1TRUE" = "CC is a problem: Agree", "CC_anthropogenic >= 1TRUE" = "CC is anthropogenic", "CC_affects_self >= 1TRUE" = "CC affects self: Agree", "can_trust_govt >= 1TRUE" = "Government can be trusted: Agree", "problem_inequality >= 1TRUE" = "Inequality is a problem: Agree",
                          
                          "index_trust_govt" = "Trusts the governement", "index_problem_inequality" = "Believes inequality is an important problem", "index_worried" = "Worries about the consequences of CC", "index_net_zero_feasible" = "Believes net-zero is technically feasible", "index_affected_subjective" = "Believes will suffer from climate change", "index_knowledge_footprint" = "Understands emission across activities/regions", "index_knowledge_fundamentals" = "Knows CC is real \\& caused by human", "index_knowledge_gases" = "Knows which gases cause CC", "index_knowledge_impacts" = "Understands impacts of CC", "index_positive_economy" = "Believes policies entail positive econ. effects", "index_policies_pollution" = "Believes policies would reduce pollution", "index_policies_emissions_plus" = "Believes policies would reduce emissions", "index_lose_policies_subjective" = "Believes own household would lose", "index_lose_policies_poor" = "Believes low-income earners will lose", "index_lose_policies_rich" = "Believes high-income earners will lose",
                          
                          "index_lose_standard_poor:treatment_banTRUE" = "Believes low-income earners will lose X Incentivized",
                          "index_lose_investments_poor:treatment_investmentsTRUE" = "Believes low-income earners will lose X Incentivized",
                          "index_lose_tax_transfers_poor:treatment_taxTRUE" = "Believes low-income earners will lose X Incentivized",
                          
                          "index_lose_investments_poor_new_rep" = "Believes low-income earners will lose",
                          "index_lose_standard_poor_new_rep" = "Believes low-income earners will lose",
                          "index_lose_tax_transfers_poor_new_rep" = "Believes low-income earners will lose",
                          "index_tax_emissions_plus_new_rep" = "Believes the policy would reduce emissions",
                          "index_standard_emissions_plus_new_rep" = "Believes the policy would reduce emissions",
                          "index_investments_emissions_plus_new_rep" = "Believes the policy would reduce emissions",
                          "index_lose_standard_poor_new_rep:treatment_banTRUE" = "Believes low-income earners will lose X Incentivized",
                          "index_lose_investments_poor_new_rep:treatment_investmentsTRUE" = "Believes low-income earners will lose X Incentivized",
                          "index_lose_tax_transfers_poor_new_rep:treatment_taxTRUE" = "Believes low-income earners will lose X Incentivized",
                          "index_tax_emissions_plus_new_rep:treatment_taxTRUE" = "Believes the policy would reduce emissions X Incentivized",
                          "index_standard_emissions_plus_new_rep:treatment_banTRUE" = "Believes the policy would reduce emissions X Incentivized",
                          "index_investments_emissions_plus_new_rep:treatment_investmentsTRUE" = "Believes the policy would reduce emissions X Incentivized",
                          
                          "index_tax_transfers_pollution:treatment_taxTRUE"= "Believes the policy would reduce pollution X Incentivized",
                          "index_tax_emissions_plus:treatment_taxTRUE" = "Believes the policy would reduce emissions X Incentivized",
                          "index_standard_pollution:treatment_banTRUE"= "Believes the policy would reduce pollution X Incentivized",
                          "index_standard_emissions_plus:treatment_banTRUE" = "Believes the policy would reduce emissions X Incentivized",
                          "index_tax_transfers_positive_economy" = "Believes the policy would have positive econ. effects",
                          "index_investments_pollution:treatment_investmentsTRUE" = "Believes the policy would reduce pollution X Incentivized",
                          "index_investments_emissions_plus:treatment_investmentsTRUE" = "Believes the policy would reduce emissions X Incentivized",
                          
                          "index_tax_transfers_positive" = "Believes the policy would have positive econ. effects", "index_tax_transfers_pollution" = "Believes the policy would reduce pollution", "index_tax_emissions_plus" = "Believes the policy would reduce emissions", "index_lose_tax_transfers_subjective" = "Believes own household would lose", "index_lose_tax_transfers_poor" = "Believes low-income earners will lose", "index_lose_tax_transfers_rich" = "believes high-income earners will lose",
                          
                          "index_standard_positive_economy" = "Believes the policy would have positive econ. effects", "index_standard_pollution" = "Believes the policy would reduce pollution", "index_standard_emissions_plus" = "Believes the policy would reduce emissions", "index_lose_standard_subjective" = "Believes own household would lose", "index_lose_standard_poor" = "Believes low-income earners will lose", "index_lose_standard_rich" = "believes high-income earners will lose",
                          
                          "index_investments_positive_economy" = "Believes the policy would have positive econ. effects", "index_investments_pollution" = "Believes the policy would reduce pollution", "index_investments_emissions_plus" = "Believes the policy would reduce emissions", "index_lose_investments_subjective" = "Believes own household would lose", "index_lose_investments_poor" = "Believes low-income earners will lose", "index_lose_investments_rich" = "believes high-income earners will lose",
                          "CC_field_do_not_knowTRUE" = "Field: don't know", "CC_field_do_not_know" = "Field: don't know", "CC_field_do_not_knowTRUE:treatmentClimate impacts" = "Don't know $\\times$ Treatment: Impacts", "CC_field_do_not_knowTRUE:treatmentClimate policy" = "Don't know $\\times$ Treatment: Policy", "CC_field_do_not_knowTRUE:treatmentBoth" = "Don't know $\\times$ Treatment: Both", 
                          "CC_field_empty" = "Field: empty", "CC_field_contains_waste" = "Field contains: recycl\\textbar waste\\textbar plastic", "CC_field_contains_wasteTRUE" = "Field contains: recycl\\textbar waste\\textbar plastic",
                          "CC\\_field\\_do\\_not\\_knowTRUE" = "Field: don't know", "CC\\_field\\_do\\_not\\_know" = "Field: don't know", "CC\\_field\\_do\\_not\\_knowTRUE:treatmentClimate impacts" = "Don't know $\\times$ Treatment: Impacts", "CC\\_field\\_do\\_not\\_knowTRUE:treatmentClimate policy" = "Don't know $\\times$ Treatment: Policy", "CC\\_field\\_do\\_not\\_knowTRUE:treatmentBoth" = "Don't know $\\times$ Treatment: Both", 
                          "CC\\_field\\_empty" = "Field: empty", "CC\\_field\\_contains\\_waste" = "Field contains: recycl\\textbar waste\\textbar plastic",  "CC_field_land_agri" = "Field: land/agriculture", "CC_field_contains_forest" = "Field contains: forest\\textbar mazon\\textbar tree",
                          "CC\\\\_field\\\\_do\\\\_not\\\\_knowTRUE" = "Field: don't know", "CC\\\\_field\\\\_do\\\\_not\\\\_know" = "Field: don't know", "CC\\\\_field\\\\_do\\\\_not\\\\_knowTRUE:treatmentClimate impacts" = "Don't know $\\times$ Treatment: Impacts", "CC\\\\_field\\\\_do\\\\_not\\\\_knowTRUE:treatmentClimate policy" = "Don't know $\\times$ Treatment: Policy", "CC\\\\_field\\\\_do\\\\_not\\\\_knowTRUE:treatmentBoth" = "Don't know $\\times$ Treatment: Both", 
                          "CC\\\\_field\\\\_empty" = "Field: empty", "CC\\\\_field\\\\_contains\\\\_waste" = "Field contains: recycl\\textbar waste\\textbar plastic", 
                          "countryAU" = "Country: Australia", "countryCA" = "Country: Canada", "countryDK" = "Country: Denmark", "countryFR" = "Country: France", "countryDE" = "Country: Germany", "countryIT" = "Country: Italy", "countryJP" = "Country: Japan", "countryMX" = "Country: Mexico", "countryPL" = "Country: Poland", "countrySK" = "Country: South Korea",
                          "countrySP" = "Country: Spain", "countryTR" = "Country: Turkey", "countryUK" = "Country: United Kingdom", "countryUS" = "Country: United States", "countryBR" = "Country: Brazil", "countryCN" = "Country: China", "countryIA" = "Country: India", "countryID" = "Country: Indonesia", "countrySA" = "Country: South Africa", "countryUA" = "Country: Ukraine",  
                          "CC_field_empty:treatmentClimate impacts" = "Empty $\\times$ Treatment: Impacts", "CC_field_empty:treatmentClimate policy" = "Empty $\\times$ Treatment: Policy", "CC_field_empty:treatmentBoth" = "Empty $\\times$ Treatment: Both", 
                          "CC\\\\_field\\\\_empty:treatmentClimate impacts" = "Empty $\\times$ Treatment: Impacts", "CC\\\\_field\\\\_empty:treatmentClimate policy" = "Empty $\\times$ Treatment: Policy", "CC\\\\_field\\\\_empty:treatmentBoth" = "Empty $\\times$ Treatment: Both", "CC_field_ambiguousTRUE" = "Field: ambiguous", "CC_field_ambiguous" = "Field: ambiguous",
                          
                          "vote_agg" = "Vote", "index_concerned_about_CC" = "Index Concerned about CC", "index_knowledge" = "Knowledge Index", "index_constrained" = "Index Constrained to use fossils", 
                          "index_policies_effective" = "Index Policies effective", "index_care_poverty" = "Index Cares about inequalities", "index_willing_change" = "Index Willing to change", 
                          "policies_self >= 1TRUE" = "Self wins from main policies: Agree", "policies_fair >= 1TRUE" = "Main policies are fair: Agree", "policies_poor >= 1TRUE" = "Poor win from main policies: Agree", "policies_rich >= 1TRUE" = "Rich win from main policies: Agree", 
                          "index_fairness" = "Fairness of main climate policies index", "index_willing_change" = "Willingness to adopt climate-friendly behavior index", "index_main_policies" = "Support for main climate policies index", 
                          "investments_support > 0" = "Supports a green infrastructure program", "tax_transfers_support > 0" = "Supports a carbon tax with cash transfers", "standard_support > 0" = "Supports a ban on combustion-engine cars", "standard_public_transport_support >= 1" = "Supports a ban on combustion-engine cars where alternatives such as public transports are made available", "standard_public_transport_support > 0" = "Ban on cars, with alternatives"))
for (l in names(regressors_names)) if (grepl("TRUE$", l)) {
  regressors_names <- c(regressors_names, regressors_names[l])
  names(regressors_names)[length(regressors_names)] <- paste0("(", sub("TRUE$", ")TRUE", l)) 
} else if (grepl("index_", l)) {
  regressors_names <- c(regressors_names, regressors_names[l])
  names(regressors_names)[length(regressors_names)] <- sub("index_", "index_c_", l)
}
setAB_labels <- unlist(lapply(c(setA, setB), function(x) regressors_names[which(grepl(x, names(regressors_names)) & !grepl(c("No college|Left"), names(regressors_names)))]))

# Labels and variables used in paper_reproduced.R
labels_policy_short <- c("Tax on flying (+20%)", "Tax on fossil fuels ($45/tCO2)", "Ban on polluting cars in city centers", "Subsidies to low-carbon technologies", "Funding clean energy in low-income countries")
labels_tax <- c()
for (v in variables_tax) labels_tax <- c(labels_tax, sub('.* - ', '', sub('.*: ', '', Label(all[[v]]))))
labels_tax[7] <- "Funding environmental infrastructures"
labels_tax[1] <- "Cash transfers to constrained households"
labels_tax[4] <- "Reduction in personal income taxes"
labels_tax[5] <- "Reduction in corporate income taxes"
labels_tax[8] <- " Subsidies to low-carbon technologies"
labels_tax[9] <- "Reduction in the public deficit"
labels_main_policies <- c("A ban on combustion-engine cars", "A green infrastructure program", "A carbon tax with cash transfers")
labels_beef <- c("A high tax on cattle products, doubling beef prices", "Subsidies on organic and local vegetables", "Removal of subsidies for cattle farming", "Ban of intensive cattle farming")
variables_policies <- c("tax_transfers_support", "standard_support", "standard_public_transport_support", "investments_support", variables_beef[1:4], "insulation_mandatory_support_no_priming", "policy_tax_flying", "policy_ban_city_centers", "global_quota", "burden_share_ing_population", "global_tax_support", "global_assembly_support", "tax_1p_support")
labels_policies <<- c("Carbon tax with cash transfers", "Ban on combustion-engine cars", "Ban on combustion-engine cars\nw. alternatives available", "Green infrastructure program", "High tax on cattle products,\nso that the price of beef doubles" , "Subsidies on organic and local\nvegetables, fruits, and nuts", "Removal of subsidies to cattling", "Ban on intensive cattling", "Mandatory insulation of buildings", "A tax on flying (raising price by 20%)", "A ban of polluting vehicles in city centers", "Global carbon budget (+2°C)\ndivided in tradable country shares", "Emission share should be in proportion to population*", "Global tax on GHG financing a global basic income", "Global democratic assembly on climate change", "Global tax on millionaires funding LDC")
variables_policies_main <- variables_policies[-c(5:7)]
labels_policies_main <- labels_policies[-c(5:7)]

main_variables_opinion <- c("CC_anthropogenic", "CC_problem", "should_fight_CC", "willing_limit_driving", "standard_support", "investments_support", "tax_transfers_support", "beef_ban_intensive_support", "insulation_mandatory_support_no_priming", "burden_share_ing_population", "tax_1p_support")
labels_opinion <- c("CC exists, is anthropogenic", "CC is an important problem", "[Country] should fight CC", "A lot willing to limit driving", "Ban on combustion-engine cars", "Green infrastructure program", "Carbon tax with cash transfers", "Ban on intensive cattling", "Mandatory insulation of buildings", "Emission share should be in proportion to population*", "Global tax on millionaires funding LDC")

main_outcomes <- c("standard_support > 0", "investments_support > 0",  "tax_transfers_support > 0", "index_fairness", "index_willing_change", "standard_public_transport_support > 0", "policy_tax_fuels > 0", "policy_ban_city_centers > 0", "policy_tax_flying > 0", "policy_subsidies > 0", "insulation_mandatory_support_no_priming > 0") # index fairness?
labels_main_outcomes <- c("\\makecell{Ban on\\\\combustion-engine\\\\cars\\\\(1)}", "\\makecell{Green\\\\infrastructure\\\\program\\\\(2)}", "\\makecell{Carbon tax\\\\with\\\\cash transfers\\\\(3)}", "\\makecell{Fairness of\\\\main climate\\\\policies index\\\\(4)}", "\\makecell{Willingness to\\\\adopt climate-friendly\\\\behavior index\\\\(5)}", "\\makecell{Ban on\\\\combustion-engine cars\\\\with alternatives\\\\(6)}", "\\makecell{Tax on\\\\fossil\\\\fuels\\\\(7)}", "\\makecell{Ban on\\\\polluting cars\\\\in city centers\\\\(8)}", "\\makecell{Tax\\\\on\\\\flights\\\\(9)}", "\\makecell{Subsidies\\\\to low-carbon\\\\technologies\\\\(10)}", "\\makecell{Mandatory\\\\and subsidized\\\\insulation\\\\(11)}")

labels_investments_win_lose <- c()
for (v in variables_investments_win_lose) labels_investments_win_lose <- c(labels_investments_win_lose, sub('.* - ', '', sub('.*: ', '', Label(all[[v]]))))
labels_investments_win_lose[5] <- "Your household financially"
labels_standard_win_lose <- c()
for (v in variables_standard_win_lose) labels_standard_win_lose <- c(labels_standard_win_lose, sub('.* - ', '', sub('.*: ', '', Label(all[[v]]))))
labels_standard_win_lose[5] <- "Your household financially"
labels_tax_transfers_win_lose <- c()
for (v in variables_tax_transfers_win_lose) labels_tax_transfers_win_lose <- c(labels_tax_transfers_win_lose, sub('.* - ', '', sub('.*: ', '', Label(all[[v]]))))
labels_tax_transfers_win_lose[5] <- "Your household financially"

labels_CC_impacts <- c()
for (v in variables_CC_impacts) labels_CC_impacts <- c(labels_CC_impacts, sub('.* - ', '', sub('.*: ', '', Label(all[[v]]))))

labels_investments_funding <- c() 
for (v in variables_investments_funding) labels_investments_funding <- c(labels_investments_funding, sub('.* - ', '', sub('.*: ', '', Label(all[[v]]))))

variables_future <- c("future_richness", "net_zero_feasible",  "CC_will_end", "CC_affects_self","CC_impacts_extinction", "effect_halt_CC_economy", "effect_halt_CC_lifestyle")
labels_future_signed <- c("World will be \"richer\" or \"much richer\" in 100 years", "Technically possible to stop emissions by 2100: \"a lot\" or \"a great deal\"", "\"Likely\" or \"very likely\" that humans halt CC by 2100", "CC will affect me negatively \"a little\" or \"not at all\"", "\"Unlikely\" or \"very unlikely\" that unmitigated CC causes extinction of humankind", "Ambitious climate policies \"positive\" or \"very positive\" for economy", 'Ambitious policies would affect negatively own lifestyle "a little" or "not at all"')
labels_future <- c("World will be richer in 100 years", "Technically possible to stop emissions by 2100", "Likely that humans halt CC by 2100", "CC will affect me negatively", "Likely that CC causes extinction of humankind", "Ambitious climate policies positive for economy", "Ambitious climate policies negative for my lifestyle")

labels_heatmap_scale <- paste("Level of climate policies needed:", c("global", "federal/continental", "state/national", "local"))

# Create df of correct answers for footprint variables. Used in LDA
footprint_variables <- c("footprint_tr_car",
                         "footprint_tr_coach",
                         "footprint_tr_plane",
                         "footprint_fd_beef",
                         "footprint_fd_pasta",
                         "footprint_fd_chicken",
                         "footprint_el_gas",
                         "footprint_el_nuclear",
                         "footprint_el_coal",
                         "footprint_reg_US",
                         "footprint_reg_EU",
                         "footprint_reg_china",
                         "footprint_reg_india",
                         "footprint_pc_US",
                         "footprint_pc_EU",
                         "footprint_pc_china",
                         "footprint_pc_india")
type <- sub("_(.*)", "",sub("footprint_", "", footprint_variables))
cat <- sub("(.*)_", "",sub("footprint_", "", footprint_variables))
true_rank <- c(2, 3, 1, 1, 3, 2, 2, 3, 1, 2, 3, 1, 4, 1, 2, 3, 4)
correct_answers_df <- data.frame(type, cat, true_rank)


##### Export for Stata #####
export_codebook(data = all, stata = TRUE, dta_file = "../data/all", file = "../data/codebook.csv")
export_codebook(data = alla, stata = TRUE, dta_file = "../data/alla", file = "../data/codebook_alla.csv")

summary_stats_table_sd <- function(){
  # Function to generate summary statistics table
  # Calculates various summary statistics for different variables in the dataset
  # and stores the results in a matrix
  # For Australia, we adjust the income variable using the ratio between the population share of income because the lowest income category (0-36k) we used is the population P45.
  # This stems from the fact that we were originally using LIS income categories which are not well aligned with the Census data, and that the income definition used by the LIS doesn't seem to correspond to respondents' definition of income.
  # The actual quartiles are 0-18k; 18k-42k; 42k-79k; 79k+ (from Census Data)
  # From the Census data we have that 45.06% of the population has an income below 36k; 53.42% has an income below 46k.
  # Note that string values of those variables do not accurately represent the actual values in terms of CU
  # The correspondence is as follows:
  # less than $10,000 -> 0-36k
  # between $10,000 and $20,000-> 36k-46k
  # between $20,000 and $25,000 -> 46k-51k
  # between $25,000 and $30,000 -> 51k-56k
  # between $30,000 and $40,000 -> 56k-67k
  # between $40,000 and $50,000 -> 67k-79k
  # between $50,000 and $60,000 -> 79k-93k
  # between $60,000 and $70,000 -> 93k-112k
  # between $70,000 and $75,000 -> 112k-122k
  # between $75,000 and $80,000 -> 122k-134k
  # between $80,000 and $90,000 -> 134k-174k
  # more than $90,000 -> 174k+
  
  # Vector of column labels for the summary statistics table
  labels_columns_stats <- c("Sample size","Man", "18-24 years old", "25-34 years old", "35-49 years old", "More than 50 years old",
                            "Income Q1", "Income Q2", "Income Q3", "Income Q4", "Region 1", "Region 2", "Region 3", "Region 4", "Region 5",
                            "Urban", "College education (25-64)", "Master's level or higher (25-64)", "Unemployment rate (15-64)",
                            "Home ownership rate", "Candidate 1", "Candidate 2", "Candidate 3", "Candidate 4")
  
  # Create an empty matrix to store the summary statistics
  # nrow corresponds to number of var. in labels_columns_stats
  stats_table <- matrix(nrow = 24, ncol = 92)
  stats_table <- as.data.frame(stats_table)
  rownames(stats_table) <- labels_columns_stats
  # Read statistics from an Excel file
  board <- read.xlsx("../data/stats_employment_college.xlsx", sheet = 1, colNames = T)
  board_comp <- read.xlsx("../data/stats_employment_college_us_2023.xlsx", sheet = 1, colNames = T)
  
  
  countries <- c(countries, "usc_regular", "usc_extra", "usc")
  # Loop through each country in the dataset
  for (i in seq_along(countries)){
    dataset <- d(countries[i])
    
    # Get Sample statistics
    sample_size <- NROW(dataset)
    # Gender statistics
    sample_male_mean <- sum(dataset$gender == "Male", na.rm = T) / sum(!is.na(dataset$gender))
    sample_male_N <- sum(!is.na(dataset$gender))
    sample_male_sd <- sd(dataset$gender == "Male", na.rm = T)
    
    # Age statistics
    sample_age_18_24_mean <- sum(dataset$age == "18-24", na.rm = T) / sum(!is.na(dataset$age))
    sample_age_18_24_N <- sum(!is.na(dataset$age))
    sample_age_18_24_sd <- sd(dataset$age == "18-24", na.rm = T)
    sample_age_25_34_mean <- sum(dataset$age == "25-34", na.rm = T) / sum(!is.na(dataset$age))
    sample_age_25_34_N <- sum(!is.na(dataset$age))
    sample_age_25_34_sd <- sd(dataset$age == "25-34", na.rm = T)
    sample_age_35_49_mean <- sum(dataset$age == "35-49", na.rm = T) / sum(!is.na(dataset$age))
    sample_age_35_49_N <- sum(!is.na(dataset$age))
    sample_age_35_49_sd <- sd(dataset$age == "35-49", na.rm = T)
    sample_age_50_more_mean <- sum(dataset$age %in% c("50-64", "65+"), na.rm = T) / sum(!is.na(dataset$age))
    sample_age_50_more_N <- sum(!is.na(dataset$age))
    sample_age_50_more_sd <- sd(dataset$age %in% c("50-64", "65+"), na.rm = T)
    
    # Income statistics
    if (countries[i] %in% c("AU")) {
      sample_income_Q1_mean <- 25*mean(dataset$income_original == "less than $10,000", na.rm = T)/45.06
      sample_income_Q1_sd <- 25*sd(dataset$income_original == "less than $10,000", na.rm = T)/45.06
      
      sample_income_Q2_mean <- (45.06-25)*mean(dataset$income_original == "less than $10,000", na.rm = T)/45.06 + 50/53.42*mean(dataset$income_original == "between $10,000 and $20,000", na.rm = T)
      sample_income_Q2_sd <- (45.06-25)*sd(dataset$income_original == "less than $10,000", na.rm = T)/45.06 + 50/53.42*sd(dataset$income_original == "between $10,000 and $20,000", na.rm = T)
      
      sample_income_Q3_mean <- (53.42-50)/53.42*mean(dataset$income_original == "between $10,000 and $20,000", na.rm = T)+mean(dataset$income_original %in% c("between $20,000 and $25,000", "between $25,000 and $30,000", "between $30,000 and $40,000", "between $40,000 and $50,000"), na.rm = T)
      sample_income_Q3_sd <- (53.42-50)/53.42*mean(dataset$income_original == "between $10,000 and $20,000", na.rm = T)+mean(dataset$income_original %in% c("between $20,000 and $25,000", "between $25,000 and $30,000", "between $30,000 and $40,000", "between $40,000 and $50,000"), na.rm = T)
      
      sample_income_Q4_mean <-mean(dataset$income_original %in% c("between $50,000 and $60,000", "between $60,000 and $70,000", "between $70,000 and $75,000", "between $75,000 and $80,000", "between $80,000 and $90,000", "more than $90,000"), na.rm = T)
      sample_income_Q4_sd <-sd(dataset$income_original %in% c("between $50,000 and $60,000", "between $60,000 and $70,000", "between $70,000 and $75,000", "between $75,000 and $80,000", "between $80,000 and $90,000", "more than $90,000"), na.rm = T)
    } else {
      sample_income_Q1_mean <- sum(dataset$income == 1, na.rm = T) / sum(!is.na(dataset$income))
      sample_income_Q1_sd <- sd(dataset$income == 1, na.rm = T)
      sample_income_Q2_mean <- sum(dataset$income == 2, na.rm = T) / sum(!is.na(dataset$income))
      sample_income_Q2_sd <- sd(dataset$income == 2, na.rm = T)
      sample_income_Q3_mean <- sum(dataset$income == 3, na.rm = T) / sum(!is.na(dataset$income))
      sample_income_Q3_sd <- sd(dataset$income == 3, na.rm = T)
      sample_income_Q4_mean <- sum(dataset$income == 4, na.rm = T) / sum(!is.na(dataset$income))
      sample_income_Q4_sd <- sd(dataset$income == 4, na.rm = T)
    }
    sample_income_Q1_N <- sum(!is.na(dataset$income))
    sample_income_Q2_N <- sum(!is.na(dataset$income))
    sample_income_Q3_N <- sum(!is.na(dataset$income))
    sample_income_Q4_N <- sum(!is.na(dataset$income))
    
    # Urban statistics
    sample_urban_mean <- mean(dataset$urban == T, na.rm = T)
    sample_urban_N <- sum(!is.na(dataset$urban))
    sample_urban_sd <- sd(dataset$urban == T, na.rm = T)
    sample_college_mean <- sum(dataset$college_OECD == "College Degree", na.rm = T) / sum(!is.na(dataset$college_OECD))
    sample_college_N <- sum(!is.na(dataset$college_OECD))
    sample_college_sd <- sd(dataset$college_OECD == "College Degree", na.rm = T)
    
    # Education statistics
    if (countries[i] %in% c("US", "UA")) {
      sample_master_mean <- sum(dataset$education == 6, na.rm = T) / sum(!is.na(dataset$college_OECD))
      sample_master_N <- sum(!is.na(dataset$college_OECD))
      sample_master_sd <- sd(dataset$education == 6, na.rm = T)
    } else if (countries[i] %in% c("usc_regular", "usc_extra", "usc")) {
      sample_master_mean <- NA
      sample_master_N <- NA
      sample_master_sd <- NA
    }  else {
      sample_master_mean <- sum(dataset$education[dataset$age %in% c("25-34", "35-49", "50-64")] == 6, na.rm = T) / sum(!is.na(dataset$college_OECD))
      sample_master_N <- sum(!is.na(dataset$college_OECD))
      sample_master_sd <- sd(dataset$education[dataset$age %in% c("25-34", "35-49", "50-64")] == 6, na.rm = T)
    }
    
    # Home ownership statistics
    sample_home_ownership_mean <- mean(d(countries[i])$home_owner)
    sample_home_ownership_N <- sum(!is.na(d(countries[i])$home_owner))
    sample_home_ownership_sd <- sd(d(countries[i])$home_owner)
    
    # Region statistics
    if (countries[i] == "FR"){
      sample_region_1_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][2], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_1_N <- sum(!is.na(dataset$region))
      sample_region_1_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][2], na.rm = T)
      sample_region_2_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][3], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_2_N <- sum(!is.na(dataset$region))
      sample_region_2_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][3], na.rm = T)
      sample_region_3_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][4], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_3_N <- sum(!is.na(dataset$region))
      sample_region_3_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][4], na.rm = T)
      sample_region_4_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][5], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_4_N <- sum(!is.na(dataset$region))
      sample_region_4_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][5], na.rm = T)
      sample_region_5_mean <-  NA
      sample_region_5_N <- sum(!is.na(dataset$region))
      sample_region_5_sd <-  NA
    } else if (!(countries[i] %in% c("SK", "TR", "US", "UA"))){
      sample_region_1_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][1], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_1_N <- sum(!is.na(dataset$region))
      sample_region_1_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][1], na.rm = T)
      sample_region_2_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][2], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_2_N <- sum(!is.na(dataset$region))
      sample_region_2_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][2], na.rm = T)
      sample_region_3_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][3], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_3_N <- sum(!is.na(dataset$region))
      sample_region_3_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][3], na.rm = T)
      sample_region_4_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][4], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_4_N <- sum(!is.na(dataset$region))
      sample_region_4_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][4], na.rm = T)
      sample_region_5_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][5], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_5_N <- sum(!is.na(dataset$region))
      sample_region_5_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][5], na.rm = T)
    } else{
      sample_region_1_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][1], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_1_N <- sum(!is.na(dataset$region))
      sample_region_1_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][1], na.rm = T)
      sample_region_2_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][2], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_2_N <- sum(!is.na(dataset$region))
      sample_region_2_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][2], na.rm = T)
      sample_region_3_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][3], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_3_N <- sum(!is.na(dataset$region))
      sample_region_3_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][3], na.rm = T)
      sample_region_4_mean <-  sum(dataset$region == unique(dataset$region)[order(unique(dataset$region))][4], na.rm = T) / sum(!is.na(dataset$region))
      sample_region_4_N <- sum(!is.na(dataset$region))
      sample_region_4_sd <-  sd(dataset$region == unique(dataset$region)[order(unique(dataset$region))][4], na.rm = T)
      sample_region_5_mean <-  NA
      sample_region_5_N <- NA
      sample_region_5_sd <- NA
      
    }
    
    # Vote Statistics
    if (countries[i] == "US" | countries[i] %in% c("usc_regular", "usc_extra", "usc")) {
      sample_candidate_1_mean <- sum(grepl("Biden", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Biden", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Trump", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Trump", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "FR") {  
      sample_candidate_1_mean <- sum(grepl("Macron", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Macron", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Le Pen", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Le Pen", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("Fillon", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("Fillon", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- sum(grepl("Mélenchon", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_4_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_4_sd <- sd(grepl("Mélenchon", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
    } else if (countries[i] == "DK") {
      sample_candidate_1_mean <- sum(grepl("Socialdemokratiet", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Socialdemokratiet", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("^Venstre", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("^Venstre", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "IT") {  
      sample_candidate_1_mean <- sum(grepl("Movimento 5 Stelle", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Movimento 5 Stelle", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Partito Democratico", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Partito Democratico", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("Lega", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("Lega", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "PL") {
      sample_candidate_1_mean <- sum(grepl("Andrzej Duda", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Andrzej Duda", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Trzaskowski", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Trzaskowski", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("Hołownia", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("Hołownia", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "MX") {
      sample_candidate_1_mean <- sum(grepl("MORENA", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("MORENA", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("PAN", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("PAN", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("PRI", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("PRI", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "JP") {
      sample_candidate_1_mean <- sum(grepl("Liberal Democratic Party", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Liberal Democratic Party", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Constitutional Democratic Party of Japan", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Constitutional Democratic Party of Japan", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("Japan Innovation Party", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("Japan Innovation Party", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "SP") { 
      sample_candidate_1_mean <- sum(grepl("PSOE", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("PSOE", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("PP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("PP", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("VOX", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("VOX", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "IA") { 
      sample_candidate_1_mean <- sum(grepl("BJP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("BJP", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("INC", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("INC", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "ID") {
      sample_candidate_1_mean <- sum(grepl("PDI-P", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("PDI-P", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Gerindra", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Gerindra", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("Golkar", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("Golkar", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "SA") {
      sample_candidate_1_mean <- sum(grepl("ANC", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("ANC", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("(DA)", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("(DA)", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "DE") {
      sample_candidate_1_mean <- sum(grepl("CDU/CSU", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("CDU/CSU", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("SPD", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("SPD", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "CA") {
      sample_candidate_1_mean <- sum(grepl("Conservative", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Conservative", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Liberal", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Liberal", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("New Democratic", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("New Democratic", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "AU") {
      sample_candidate_1_mean <- sum(grepl("Liberal/National coalition", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Liberal/National coalition", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Labor", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Labor", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "UA") {
      sample_candidate_1_mean <- sum(grepl("Zelensky", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Zelensky", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Poroshenko", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Poroshenko", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "SK") {
      sample_candidate_1_mean <- sum(grepl("Jae-in", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Jae-in", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Joon-pyo", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Joon-pyo", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("Cheol-soo", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("Cheol-soo", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "TR") {
      sample_candidate_1_mean <- sum(grepl("AKP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("AKP", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("CHP", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("CHP", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "BR") {
      sample_candidate_1_mean <- sum(grepl("Bolsonaro", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Bolsonaro", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Haddad", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Haddad", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "UK") {
      sample_candidate_1_mean <- sum(grepl("Conservative", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_1_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_1_sd <- sd(grepl("Conservative", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_2_mean <- sum(grepl("Labour", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_2_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_2_sd <- sd(grepl("Labour", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_3_mean <- sum(grepl("Liberal Democrats", dataset$vote_voters)) / sum(!is.na(dataset$vote_voters))
      sample_candidate_3_N <- sum(!is.na(dataset$vote_voters))
      sample_candidate_3_sd <- sd(grepl("Liberal Democrats", dataset$vote_voters[!is.na(dataset$vote_voters)]), na.rm = T)
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } else if (countries[i] == "CN") {
      sample_candidate_1_mean <- NA
      sample_candidate_1_N <- NA
      sample_candidate_1_sd <- NA
      sample_candidate_2_mean <- NA
      sample_candidate_2_N <- NA
      sample_candidate_2_sd <- NA
      sample_candidate_3_mean <- NA
      sample_candidate_3_N <- NA
      sample_candidate_3_sd <- NA
      sample_candidate_4_mean <- NA
      sample_candidate_4_N <- NA
      sample_candidate_4_sd <- NA
    } 
    # Unemployment Statistics
    sample_unemployment_rate_mean <- sum(dataset$employment_status[!(dataset$age %in% c("65+"))] %in% c("Unemployed")) / sum(dataset$employment_status[!(dataset$age %in% c("65+"))] %in% c("Unemployed", "Full-time employed", "Part-time employed", "Self-employed"))
    sample_unemployment_rate_N <- sum(dataset$employment_status[!(dataset$age %in% c("65+"))] %in% c("Unemployed", "Full-time employed", "Part-time employed", "Self-employed"))
    sample_unemployment_rate_sd <- sd(dataset$employment_status[!(dataset$age %in% c("65+"))] %in% c("Unemployed"))
    
    # Combine Statistics Together
    sample_mean <- c(sample_size, sample_male_mean, sample_age_18_24_mean, sample_age_25_34_mean, sample_age_35_49_mean, sample_age_50_more_mean,
                     sample_income_Q1_mean, sample_income_Q2_mean, sample_income_Q3_mean, sample_income_Q4_mean, sample_region_1_mean, sample_region_2_mean,
                     sample_region_3_mean, sample_region_4_mean, sample_region_5_mean, sample_urban_mean, sample_college_mean, sample_master_mean,
                     sample_unemployment_rate_mean, sample_home_ownership_mean, sample_candidate_1_mean,
                     sample_candidate_2_mean, sample_candidate_3_mean, sample_candidate_4_mean)
    sample_sd <- c(sample_size, sample_male_sd, sample_age_18_24_sd, sample_age_25_34_sd, sample_age_35_49_sd, sample_age_50_more_sd,
                   sample_income_Q1_sd, sample_income_Q2_sd, sample_income_Q3_sd, sample_income_Q4_sd, sample_region_1_sd, sample_region_2_sd,
                   sample_region_3_sd, sample_region_4_sd, sample_region_5_sd, sample_urban_sd, sample_college_sd, sample_master_sd,
                   sample_unemployment_rate_sd, sample_home_ownership_sd, sample_candidate_1_sd,
                   sample_candidate_2_sd, sample_candidate_3_sd, sample_candidate_4_sd)
    sample_N <- c(sample_size, sample_male_N, sample_age_18_24_N, sample_age_25_34_N, sample_age_35_49_N, sample_age_50_more_N,
                  sample_income_Q1_N, sample_income_Q2_N, sample_income_Q3_N, sample_income_Q4_N, sample_region_1_N, sample_region_2_N,
                  sample_region_3_N, sample_region_4_N, sample_region_5_N, sample_urban_N, sample_college_N, sample_master_N,
                  sample_unemployment_rate_N, sample_home_ownership_N, sample_candidate_1_N,
                  sample_candidate_2_N, sample_candidate_3_N, sample_candidate_4_N)
    
    names(sample_mean) <- labels_columns_stats
    names(sample_N) <- labels_columns_stats
    names(sample_sd) <- labels_columns_stats
    ## Get Population statistics
    pop_size <- NA
    
    if (countries[i] %in% c("usc_regular", "usc_extra", "usc")) {
      # Get Population statistics
      pop_size <- NA
      # Gender statistics
      pop_male <- board_comp$Male
      # Age statistics
      pop_age_18_24 <- board_comp$`18-24`
      pop_age_25_34 <- board_comp$`25-34`
      pop_age_35_49 <- board_comp$`35-49`
      pop_age_50_64 <- board_comp$`50-64`
      pop_age_65_more <- board_comp$`65+`
      # Income statistics
      pop_income_Q1 <- board_comp$Income_1
      pop_income_Q2 <- board_comp$Income_2
      pop_income_Q3 <- board_comp$Income_3
      pop_income_Q4 <- board_comp$Income_4
      
      # Region statistics
      pop_region_1 <- board_comp$Midwest
      pop_region_2 <- board_comp$Northeast
      pop_region_3 <- board_comp$South
      pop_region_4 <- board_comp$West
      pop_region_5 <- NA
      
      # Urban statistics
      pop_urban <- pop_freq[["US"]]$urban[2]
      
      # Education statistics
      pop_college <- board_comp$College
      # Vote statistics
      pop_candidate_1 <- board_comp$Biden
      pop_candidate_2 <- board_comp$Trump
      pop_candidate_3 <- NA
      pop_candidate_4 <- NA
      # Unemployment statistics
      pop_unemployment_rate <- board_comp$U_rate
      # Home ownership
      pop_home_ownership_temp <- pop_home_ownership[["US"]]
    } else {
      # Gender Statistics
      pop_male <- pop_freq[[countries[i]]]$gender[3]
      # Age Statistics
      pop_age_18_24 <- pop_freq[[countries[i]]]$age[1]
      pop_age_25_34 <- pop_freq[[countries[i]]]$age[2]
      pop_age_35_49 <- pop_freq[[countries[i]]]$age[3]
      pop_age_50_64 <- pop_freq[[countries[i]]]$age[4]
      pop_age_65_more <- pop_freq[[countries[i]]]$age[5]
      # Income Statistics
      pop_income_Q1 <- pop_freq[[countries[i]]]$income[1]
      pop_income_Q2 <- pop_freq[[countries[i]]]$income[2]
      pop_income_Q3 <- pop_freq[[countries[i]]]$income[3]
      pop_income_Q4 <- pop_freq[[countries[i]]]$income[4]
      # Region Statistics
      if (countries[i] != "FR") {
        pop_region_1 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][1]
        pop_region_2 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][2]
        pop_region_3 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][3]
        pop_region_4 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][4]
        if (!(countries[i] %in% c("SK", "TR", "US", "UA"))){
          pop_region_5 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][5]
        } else{
          pop_region_5 <- NA
        }
      } else{
        pop_region_1 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][2]
        pop_region_2 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][3]
        pop_region_3 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][4]
        pop_region_4 <- pop_freq[[countries[i]]][[paste(countries[i],"region", sep = "_")]][order(levels_quotas[[paste(countries[i],"region", sep = "_")]])][5]
        pop_region_5 <- NA
      }
      if (!(countries[i] %in% c("FR", "IT", "UK", "DE", "CN", "MX", "SK"))){
        pop_urban <- pop_freq[[countries[i]]]$urban[2]
      } else if (countries[i] == "FR"){
        pop_urban <- pop_freq[[countries[i]]][[paste(countries[i],"urban_category", sep = "_")]][1]
      } else if (countries[i] == "IT"){
        pop_urban <- pop_freq[[countries[i]]][[paste(countries[i],"urban_category", sep = "_")]][1] + pop_freq[[countries[i]]][[paste(countries[i],"urban_category", sep = "_")]][2]
      } else if (countries[i] %in% c("UK", "DE", "CN", "SK")){
        pop_urban <- pop_freq[[countries[i]]][[paste(countries[i],"urban_category", sep = "_")]][2] + pop_freq[[countries[i]]][[paste(countries[i],"urban_category", sep = "_")]][3]
      } else if (countries[i] == "MX"){
        pop_urban <- pop_freq[[countries[i]]][[paste(countries[i],"urban_category", sep = "_")]][3]
      }
      # Education Statistics
      pop_college <- board$College[board$country == countries[i]]
      pop_master <- board$Master[board$country == countries[i]]
      # Voting Statistics
      pop_candidate_1 <- board$candidate_1[board$country == countries[i]]
      pop_candidate_2 <- board$candidate_2[board$country == countries[i]]
      pop_candidate_3 <- board$candidate_3[board$country == countries[i]]
      pop_candidate_4 <- board$candidate_4[board$country == countries[i]]
      # Unemployment Statistics
      pop_unemployment_rate <- board$U_rate[board$country == countries[i]]
      # Home ownership
      pop_home_ownership_temp <- pop_home_ownership[[countries[i]]]
    }
    pop <- c(pop_size, pop_male, pop_age_18_24, pop_age_25_34, pop_age_35_49, pop_age_50_64 + pop_age_65_more,
             pop_income_Q1, pop_income_Q2, pop_income_Q3, pop_income_Q4, pop_region_1, pop_region_2, pop_region_3,
             pop_region_4, pop_region_5, pop_urban, pop_college, pop_master, pop_unemployment_rate,
             pop_home_ownership_temp, pop_candidate_1, pop_candidate_2, pop_candidate_3, pop_candidate_4)
    
    #pop_rounded <- round(pop, digits = 2)
    names(pop) <- labels_columns_stats
    #names(pop_rounded) <- labels_columns_stats
    # Append the two vectors to a common data frame
    stats_table[,(i*4-3)] <- pop
    names(stats_table)[(i*4-3)] <- paste0(countries[i],"_pop")
    stats_table[,(i*4-2)] <- sample_mean
    names(stats_table)[(i*4-2)] <- paste0(countries[i],"_sample_mean")
    stats_table[,(i*4-1)] <- sample_sd
    names(stats_table)[(i*4-1)] <- paste0(countries[i],"_sample_sd")
    stats_table[,(i*4)] <- sample_N
    names(stats_table)[(i*4)] <- paste0(countries[i],"_sample_N")
  }
  return(stats_table)
}

# Create the representativeness table used in Stata
table_sd <- summary_stats_table_sd()
table_sd$variable <- rownames(table_sd)
haven::write_dta(table_sd, "../data/table_sd.dta", )


# Remove large and useless datasets (if they exist)
saveRDS(allq, file = "allq.rds")
rm(e, allq)

# ##### Apply changes to all datasets without re-running preparation #####
# for (country in c(countries, "all")) {
#   if (country == "all") e <- all else e <- eval(str2expression(paste0(tolower(country), "")))
#   # Changes
#   if (country == "all") all <- e else eval(str2expression(paste0(tolower(country), " <- e")))
# }

