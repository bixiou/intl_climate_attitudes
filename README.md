# Reproduction code for "Fighting Climate Change: International Attitudes Toward Climate Policies" 

DOI: http://doi.org/10.3886/E208254V1

## Authors
- Antoine Dechezleprêtre, LSE and OECD.
- Adrien Fabre, CNRS and CIRED, adrien.fabre@cnrs.fr (corresponding author).
- Tobias Kruse, LSE and OECD.
- Bluebery Planterose, PSE.
- Ana Sanchez Chico, Analysis Group.
- Stefanie Stantcheva, Harvard, CEPR, and NBER.


## Summary
- The code is in R (data preparation, Tables) and Stata (most Figures), with all files in `code_intl_climate/`. It requires RStudio (for the graphical environment) and Python to be run.
- Instructions to replicate the code are provided in Instructions to Replicators below.
- Questionnaire in each language (both in Qualtrics in MS Word formats) can be found in `questionnaire/`.
- The codebook of variables (with their name in R, in Stata, and their description - including the question text) is `data/codebook.csv`.
- All files in `figures/` (in .pdf or .png), `xlsx/` (data of figures in .xlsx), and `tables/` (LaTeX tables) can be reproduced using the code and `data_raw/`.

## Data Availability and Provenance Statements

- Raw Survey Data: Openly available (License: GNU AGPL3). \
Raw data for [country] directly exported from Qualtrics is `data/[country].csv`.
- All sources are provided in `sources.xlsx` and reported in Appendix A-11 of the paper. For example, data from the [Global Carbon Project (2019)](https://www.icos-cp.eu/GCP/2019) (free to re-use non-comercially), re-used on [Wikipedia](https://en.wikipedia.org/wiki/List_of_countries_by_carbon_dioxide_emissions_per_capita), is used and cited in the paper. 

### Statement about Rights

- [x] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript. 
- [x] I certify that the author(s) of the manuscript have documented permission to redistribute/publish the data contained within this replication package. Appropriate permission are documented in the [LICENSE.md](LICENSE.md) file.


### License for Data

The survey data are licensed under a GNU AGPL3 license. See LICENSE.md for details.


### Summary of Availability

- [x] All data **are** publicly available.

### Details on each Data Source

Many data sources have been used, e.g. to define the survey quotas. All data sources are listed in Appendix A-11 and in the file `sources.xlsx` in the repository root folder.


## Dataset list

| Data file | Source | Notes    |Provided |
|-----------|--------|----------|---------|
| `data_raw/[Country].csv` | Original survey |  | Yes |
| `data/fields/[Country].xlsm` | Original survey | Open-ended fields | Yes |
| `data/equivalised_income_deciles.tsv` | Luxembourg Income Study (LIS) Database, lisdatacenter.org (multiple countries; 2011-2017). Luxembourg: LIS. | LIS survey data. One has to create a free LISSY account, wait some days for validation, and export quantiles from microdata. Data free to re-use for non-commercial purposes. | Yes |
| `data/zipcodes/US_elec.csv` | eia.gov/electricity/state/ U.S. Energy Information Administration, https://www.eia.gov/electricity/state/archive/2019/ (all States, 2019). | 2_preparation.R, l. 3154. Data free to use on the website, was copy/pasted. | Yes |
| `data/zipcodes/US_zipcode_state.xlsx` | Economic Research Service of the U.S. Department of Agriculture, ers.usda.gov/data-products/rural-urban-commuting-area-codes (2010 Rural-Urban Commuting Area Codes, ZIP code file). | 2_preparation.R, l. 3150, .csv can be downloaded on the website and is free to re-use for non-commercial purposes. | Yes |
| `data/stats_employment_college.xlsx` | sources.xlsx |  | Yes |
| `data/stats_employment_college_us_2023.xlsx` | sources.xlsx |  | Yes |


## Computational requirements

### Software Requirements

- [x] The replication package contains one or more programs to install all dependencies and set up the necessary directory structure.

- Stata 17
    - `outreg2`(as of 2024-31-10)
    - `gr0034` from http://www.stata-journal.com/software/sj8-2 (as of 2024-31-10)
    - `heatplot` (as of 2024-31-10)
    - `palettes` (as of 2024-31-10)
    - `colrspace` (as of 2024-31-10)
    - `splitvallabels` (as of 2024-31-10)
    - `sxpose` (as of 2024-31-10)
    - `grc1leg` from http://www.stata.com/users/vwiggins/ (as of 2024-31-10)
    - `wrap` from https://aarondwolf.github.io/wrap" (as of 2024-31-10)
    - `coefplot` (as of 2024-31-10)
    - `blindschemes` (as of 2024-31-10)
    - the program "`code_intl_climate/required_packages.do`" will install all dependencies locally, and should be run once.

- R 4.3.1
  - A particular version (0.99.22) of the R package `memisc` is needed. Similarly, a patched version of the R package `stargazer` is required. If another version of `memisc` or `stargazer` is installed, `code_intl_climate/0_setup.R` will automatically uninstall it and install the appropriate version.
  - the file `0_setup.R` will install all dependencies (latest version), and should be run once prior to running other programs. Here are the packages required:
  - `memisc` (0.99.22)
  - `plotly`
  - `stargazer` (patched version, installed in `0_setup.R`)
  - `utils`
  - `devtools`
  - `tidyverse`
  - `xtable`
  - `gdata`
  - `Hmisc`
  - `readstata13`
  - `ergm`
  - `RColorBrewer`
  - `corrplot`
  - `dplyr`
  - `openxlsx`
  - `quanteda`
  - `topicmodels`
  - `broom`
  - `tidytext`
  - `modelsummary` (1.4.1)
  - `dplR`
  - `relaimpo`
  - `kableExtra`
  - `descr`
  - `knitr`
  - `mfx`
  - `data.table`
  - `RMallow`
  - `boot`
  - `pbapply`
- RStudio 2024.04.1 748 in administrator mode (plotly required a graphical environment)
- Rtools 4.3
- Python 3.6
- Packages `kaleido` and `orca`, which can be installed from Anaconda (see instructions in Summary above). 

### Controlled Randomness

- [x] No Pseudo random generator is used in the analysis described here.

### Memory, Runtime, Storage Requirements


#### Summary

Approximate time needed to reproduce the analyses on a standard (CURRENT YEAR) desktop machine:

- [x] 1-3 days

Approximate storage space needed:

- [x] 2 GB - 25 GB

#### Details
Characteristics of machine  used: Laptop, OS: Windows 11, Processor: 12th Gen Intel(R) Core(TM) i5-12500H 2.50 GHz, RAM: 32 GB
Duration necessary to install all packages: 20 min.\
Duration of data preparation: 1.5 hour.\
Duration of paper reproduction (reverse IV excluded): 30 min.\
Duration of reverse IV: 38 hours.


## Description of programs/code

`sources.xlsx`: File synthesizing all figures used in the questionnaires and their sources: income thresholds, wealth tax estimates, etc.\

`code_intl_climate/`: All code, in R and Stata.\
R files:\
`code_intl_climate/after_preparation.RData`: Cleaned R datasets.\
`code_intl_climate/after_paper_produced.RData`: All R objects created.\
`code_intl_climate/0_setup.R`: First file to run in R: loads packages and defines custom functions.\
`code_intl_climate/1_relabel_rename.R`: Called in preparation.R, defines the variable names.\
`code_intl_climate/2_preparation.R`: Cleanses and prepares the dataset.\
`code_intl_climate/3_paper_reproduced.R`: Reproduces the paper.\
`code_intl_climate/reverse_IV_bootstrap.R`: Called in paper_reproduced.R, computes the reverse IV bootstrap, country by country.\
`code_intl_climate/reverse_IV_bootstrap_all.R`: Called in paper_reproduced.R, computes the reverse IV bootstrap, for the whole sample.\
`code_intl_climate/country_appendices.R`: Computes the online country appendices.
Stata files:\
`code_intl_climate/0_OECD_Climate_Master_Paper.do`: Generates all Stata figures.\
`code_intl_climate/OECD_Climate_SetUp.do`: Creates the variables and macros for the figures.\
`code_intl_climate/OECD_Climate_Coeflabels.do`: Creates macros for the figures aesthetics.\
`code_intl_climate/OECD_Climate_Coefplots_all.do`: Program to generate figures (for the entire sample).\
`code_intl_climate/OECD_Climate_Coefplots_het.do`: Program to generate figures (comparison of countries).\
`code_intl_climate/OECD_Climate_Coefplots_all_multi.do`: Program to generate figures (with several outcomes).\
`code_intl_climate/OECD_Climate_CC_should_fight.do`: Program for Figure 1.\
`code_intl_climate/OECD_graph_desc_stat_het.do`: Generates representativeness figures.\
`code_intl_climate/OECD_Climate_CoefPlots_all_support_willing_indices_multi.do`: Program for Figure 4.\
`code_intl_climate/OECD_Climate_Heatplots.do`: Generates the heatmaps.\
`code_intl_climate/OECD_Climate_Variance.do`: Generates variance decomposition Figures.\
`code_intl_climate/OECD_Climate_Coefplots_all_treat_multi.do`: Program for treatment effect Figures.\
`code_intl_climate/OECD_Climate_CorrelationIndicators - Update.do`: Generates vulnerability correlation Figures.\
`code_intl_climate/OECD_Climate_Means_1.do`: Generates Figures plotting averages by group.\
`code_intl_climate/OECD_Climate_Means_2.do`: Generates Figures plotting averages by group.\
`code_intl_climate/OECD_Climate_Means_3.do`: Generates Figures plotting averages by group.\
`code_intl_climate/OECD_taxrevenues_graphs.do`: Generates Figure on treatment effects and use of carbon tax revenues.\
`code_intl_climate/OECD_reverseIV_graph_all.do`: Generates Figures on reverse IV (for the entire sample).\
`code_intl_climate/OECD_reverseIV_graph_het.do`: Generates Figures on reverse IV (at the country-level).\

`data/`: All non-raw data files, including codebooks.\
`data/fields/`: Data of open-ended fields converted to .xlsx and classified, with translations.

`data_raw/`: All raw data files, directly exported from Qualtrics.
`data_raw/[country].csv`: Raw data from survey in [country].\

`figures/`: Figures generated. 
`figures/all/`: Figures on the merged sample.\
`figures/country_comparison/`: Figures comparing the results by country.
`figures/CC_fields/`: Figures concerning the open-ended field.
`figures/mi/`, `figures/hi/`: Figures concerning middle- or high-income countries.

`questionnaire/`: Questionnaire files, both in Qualtrics and MS Word format.\
`questionnaire/quotas.xlsx`: File synthesizing the sociodemographic quotas used.

`tables/`: LaTeX tables exported from paper_reproduced.R.

`xlsx/`: Export of the data underlying each figure.

### License for Code

The code is licensed under a GNU AGPL3 license. See [LICENSE.md](LICENSE.md) for details.

## Instructions to Replicators

In order to reproduce the paper's results, one needs to:
- (0) install `RTools`, `kaleido` and `orca`. 
- (1) Edit line 25 of `code_intl_climate/0_OECD_Climate_Master_Paper.do` with the path to the repository folder. Create an R Project within the `/code_intl_climate` folder or define `setwd("[path]/code_intl_climate/")` at the beginning of `3_paper_reproduced.R`.
- (2) run the master R file: `3_paper_reproduced.R`, and then 
- (3) run the master Stata file: `0_OECD_Climate_Master_Paper.do`


### Details

- In (0), follow these steps:
    - Install `RTools` from [https://cran.r-project.org/bin/windows/Rtools/](cran.r-project.org/bin/windows/Rtools)
    - To plot figures in R we use `plotly`. To install this R package, `kaleido` and `orca` need to be installed. They can be installed from Anaconda: \
    Run Anaconda in administrator mode and run:\
    `pip install kaleido; conda install -c plotly plotly-orca`\
    Then `orca` should be set in the `PATH`, which is done in ``code_intl_climate/0_setup.R``.
    - If `orca` cannot be installed, set `use_plotly` to `FALSE` in `3_paper_reproduced.R`, line 28.
- In (2), R starts by calling `0_setup.R` and then the user has two options: 
    - (A) reproduce the data preparation (this will call `1_relabel_rename.R` and `2_preparation.R`, and take ~2 hours), or 
    - (B) load the prepared R data: `after_preparation.RData`. 
    - We recommend users to create an R Project within this folder (`code_intl_climate/`). Alternatively, the user can define `setwd("[path]/code_intl_climate/")` at the beginning of `3_paper_reproduced.R`.
    - The plot display pane of RStudio should be as wide and tall as possible for proper rendering.
    - /!\ RStudio may need to be run in administrator mode to avoid permission issues during the package install. If it is not possible to run RStudio in administrator mode, set `use_plotly` to `FALSE` in `3_paper_reproduced.R`, line 28.
- In (3), the master Stata file calls in turn various Stata files. The data of figures requires data exported from R in step (1) into `../data/` and `../xlsx/`.
    - Macro for folder can be edited in `0_OECD_Climate_Master_Paper.do` (line 25)
    - The file `theme_climate.scheme` can be installed to reproduce the aesthetics of the figures. `0_OECD_Climate_Master_Paper.do` automatically installs it.
    - In some cases, bold labels in graphs may appear white when exported to PDF, even though they display correctly in the Stata graph window. To work around this issue, you can export the figures as JPG instead. To do so, edit the `0_OECD_Climate_Master_Paper.do` file by replacing `pdf` with `jpg` in the relevant export line

## List of figures/tables and programs


- [x] All numbers provided in text in the paper
- [x] All tables and figures in the paper


| Figure/Table #    | Program                  | Line Number | Output file                      | Note                            |
|-------------------|--------------------------|-------------|----------------------------------|---------------------------------|
| Figure 1           | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  93           | figures/FINAL_FIGURES/Figure1.pdf                ||
| Figure 2           | n.a. (no data)    |             | figures/FINAL_FIGURES/Figure2.tex                ||
| Figure 3           | n.a. (no data)    |             | figures/FINAL_FIGURES/Figure3.png                ||
| Figure 4a           | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  98           | figures/FINAL_FIGURES/Figure4a.pdf                ||
| Figure 4b           | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  98           | figures/FINAL_FIGURES/Figure4b.pdf                ||
| Figure 5          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  106           | figures/FINAL_FIGURES/Figure5.pdf                ||
| Figure 6          | n.a. (no data)    |             | figures/FINAL_FIGURES/Figure6.pdf                ||
| Figure 7          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/Figure7.pdf                ||
| Figure 8a          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  118           | figures/FINAL_FIGURES/Figure8a.pdf                ||
| Figure 8b          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  126           | figures/FINAL_FIGURES/Figure8b.pdf                ||
| Figure 9          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/Figure9.pdf                ||
| Figure 10          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/Figure10.pdf                ||
| Figure 11a          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  135          | figures/FINAL_FIGURES/Figure11a.pdf                ||
| Figure 11b          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  144          | figures/FINAL_FIGURES/Figure11b.pdf                ||
| Figure 12          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110          | figures/FINAL_FIGURES/Figure12.pdf                ||
| Figure 13          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  154          | figures/FINAL_FIGURES/Figure13.pdf                ||
| Figure 14a          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  173          | figures/FINAL_FIGURES/Figure14a.pdf                ||
| Figure 14b          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  178          | figures/FINAL_FIGURES/Figure14b.pdf                ||
| Figure 15a_bottom          |  n.a. (no data)   |            | figures/FINAL_FIGURES/Figure15a_bottom.pdf                ||
| Figure 15a_middle          |  n.a. (no data)   |            | figures/FINAL_FIGURES/Figure15a_middle.pdf                ||
| Figure 15a_top          |  n.a. (no data)   |            | figures/FINAL_FIGURES/Figure15a_top.pdf                ||
| Figure 15b_bottom          |  n.a. (no data)   |            | figures/FINAL_FIGURES/Figure15b_bottom.pdf                ||
| Figure 15b_middle          |  n.a. (no data)   |            | figures/FINAL_FIGURES/Figure15b_middle.pdf                ||
| Figure 15b_top          |  n.a. (no data)   |            | figures/FINAL_FIGURES/Figure15b_top.pdf                ||
| Figure 16          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  186          | figures/FINAL_FIGURES/Figure16.pdf                ||
| Figure 17a          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  194          | figures/FINAL_FIGURES/Figure17a.pdf                ||
| Figure 17b          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  194          | figures/FINAL_FIGURES/Figure17b.pdf                ||
| Figure A1          | code_intl_climate/3_paper_reproduced.R    |  372         | figures/FINAL_FIGURES/FigureA1.pdf                ||
| Figure A2          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  204          | figures/FINAL_FIGURES/FigureA2.pdf                ||
| Figure A3          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  212          | figures/FINAL_FIGURES/FigureA3.pdf                ||
| Figure A4a          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/FigureA4a.pdf                ||
| Figure A4b          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  222          | figures/FINAL_FIGURES/FigureA4b.pdf                ||
| Figure A5          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/FigureA5.pdf                ||
| Figure A6          | code_intl_climate/3_paper_reproduced.R    |  411          | figures/FINAL_FIGURES/FigureA6.pdf                ||
| Figure A7          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/FigureA7.pdf                ||
| Figure A8a          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  173          | figures/FINAL_FIGURES/FigureA8a.pdf                ||
| Figure A8b          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  231          | figures/FINAL_FIGURES/FigureA8b.pdf                ||
| Figure A9          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  236          | figures/FINAL_FIGURES/FigureA9.pdf                ||
| Figure A10          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  236          | figures/FINAL_FIGURES/FigureA10.pdf                ||
| Figure A11          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  248          | figures/FINAL_FIGURES/FigureA11.pdf                ||
| Figure A12          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  257          | figures/FINAL_FIGURES/FigureA12.pdf                ||
| Figure A13          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/FigureA13.pdf                ||
| Figure A14          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/FigureA14.pdf                ||
| Figure A15          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  110           | figures/FINAL_FIGURES/FigureA15.pdf                ||
| Figure A16          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  237          | figures/FINAL_FIGURES/FigureA16.pdf                ||
| Figure A17          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  237          | figures/FINAL_FIGURES/FigureA17.pdf                ||
| Figure A18a          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  266          | figures/FINAL_FIGURES/FigureA18a.pdf                ||
| Figure A18b          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  178          | figures/FINAL_FIGURES/FigureA18b.pdf                ||
| Figure A19          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  238          | figures/FINAL_FIGURES/FigureA19.pdf                ||
| Figure A20          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  271          | figures/FINAL_FIGURES/FigureA20.pdf                ||
| Figure A21          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  276          | figures/FINAL_FIGURES/FigureA21.pdf                ||
| Figure A22          | code_intl_climate/0_OECD_Climate_Master_Paper.do    |  281          | figures/FINAL_FIGURES/FigureA22.pdf                ||


## References

Dechezleprêtre et al. (2022). Public Acceptability of Climate Change Mitigation Policies. AEA RCT Registry. https://www.socialscienceregistry.org/trials/7300.

Economic Research Service of the U.S. Department of Agriculture, ers.usda.gov/data-products/rural-urban-commuting-area-codes (2010 Rural-Urban Commuting Area Codes, ZIP code file).

Global Carbon Project (2019). Supplemental data of Global Carbon Project 2019. DOI: [10.18160/gcp-2019](https://www.icos-cp.eu/science-and-impact/global-carbon-budget/2019)

Luxembourg Income Study (LIS) Database, lisdatacenter.org (multiple countries; 2011-2017). Luxembourg: LIS.

U.S. Energy Information Administration, https://www.eia.gov/electricity/state/archive/2019/ (all States, 2019).
