# Bass model: Netgear Nighthawk M3 (5G hotspot), look-alike = 4G/LTE

Author: Hamlet Khachatryan | Course: DS 223 Marketing Analytics, AUA

The project forecasts the worldwide diffusion of portable 5G hotspots (Netgear Nighthawk M3, TIME Best Inventions 2025). The Bass parameters p and q are estimated from a look-alike, 4G/LTE mobile broadband (Ericsson data via Statista), and the market size m comes from a Fermi estimate.

## Directory Details

- **report/**: This directory contains the project report.
  - `report.pdf`: Final report in PDF format (all seven steps: chosen innovation, look-alike, data, Bass parameters, prediction, scope, adopters by year, and the references).
  - `report_source.Rmd`: Source R Markdown file used to generate the report.
- **/**: The root directory holds the code and documentation files for the project.
  - `bass_5g_hotspot.R`: The report's code as a plain R script. It loads the data, estimates the Bass parameters with `nls()` and the `diffusion` package, checks the model on 5G subscriptions, and calculates the hotspot adopters by year.
  - `references.md`: Reference list (lecture slides, the two Statista/Ericsson datasets, the TIME article, and the `diffusion` R package).
  - `README.md`: This file, with an overview of the project and instructions to reproduce it.
- **data/**: This directory holds the datasets used for the analysis. All values are in millions of subscriptions. Source: Ericsson Mobility Visualizer via Statista, retrieved 14 October 2026.
  - `4g_lte_global.csv`: Global 4G/LTE subscriptions, 2012 to 2031. Columns: `year`, `subscriptions` (total, the sum of the eight regions) and `sales` (new subscriptions in that year, the yearly change). The analysis uses 2012 to 2022 only, the growth phase.
  - `4g_lte_by_region.csv`: 4G/LTE subscriptions by region, 2012 to 2031, one column for each of the eight Ericsson regions. Used in Step 6 to show how demand is spread across regions.
  - `5g_subscriptions_global.csv`: Global 5G subscriptions, 2018 to 2030. Columns: `year`, `subscriptions` and `forecast` (TRUE for years that are Ericsson forecasts). Used to check the model on 5G and to estimate the market size m.
  - `original_statista_excel/`: The two Excel files as downloaded from Statista (4G/LTE by region, Statistic ID 521572; 5G subscriptions, Statistic ID 1199693). The CSV files above were made from them.
- **img/**: This directory contains all the images used in the report.
  - `4g_new_subscriptions.png`: Bar chart of new global 4G/LTE subscriptions per year, 2012 to 2022 (the data used to estimate the Bass model).
  - `4g_bass_fit.png`: The same bars with the fitted Bass model shown as red dots, to check how well the model matches the 4G/LTE data.
  - `5g_check_bass_vs_data.png`: New 5G subscriptions per year, 2019 to 2030 (dark bars are actual data, light bars are Ericsson forecasts), with the Bass curve using the 4G values of p and q as red dots. This is the check that the look-alike works for the next network generation.
  - `hotspot_forecast.png`: Two charts for the 5G hotspot forecast, 2019 to 2035: cumulative adopters (left) and new adopters per year (right), for the low, base and high market-size cases.

## Reproduction Instructions

1. Clone or download this repository into RStudio.
2. Install required R packages: `install.packages(c("ggplot2", "ggpubr", "knitr", "diffusion"))`
3. Open `report/report_source.Rmd` and click **Knit to PDF**.
4. To run only the code, open `bass_5g_hotspot.R` in RStudio.