# QCEW & Population Data Analysis (2012)

Analysis of 2012 Quarterly Census of Employment and Wages (QCEW) county-level data combined with U.S. Census Bureau state population estimates. Produced as a data exercise using Stata 19.5 and LaTeX.

**Author:** Airui Meng
**Date:** March 2026

## Project Overview

This project transforms raw administrative employment and wage data into a coherent set of descriptive and regression-based findings at the state and county levels. It covers:

- **Q3** — State-level federal employment shares (50 states, excluding DC)
- **Q4** — County-level mean weekly wage in Financial Activities and Professional & Business Services
- **Q5** — State-level relationship between Education & Health Services employment share and annual pay (scatterplot with dual fit lines)
- **Q6** — Regression analysis of sector pay on employment share and log population, with interaction terms and a DC-outlier robustness check
- **Q7** — Massachusetts counties where annualized Q1 wages exceed full-year annual wages

## Key Findings

- **Maryland** has the highest federal employment share (5.83%); **Wisconsin** the lowest (1.08%).
- **San Mateo County, CA** has the highest constructed mean weekly wage across Financial Activities and Professional & Business Services ($3,599).
- Education & Health Services employment share and annual pay are positively associated, but the relationship is sensitive to DC as an extreme outlier: simple-model R² drops from 0.205 to 0.057 when DC is excluded.
- **Middlesex** and **Suffolk** counties in Massachusetts had annualized Q1 wages exceeding annual wages in 2012.

See `report/Results_Report_Data_Exercise_2026.pdf` for the full written report with tables and figures.

## Repository Structure

```
QCEW_Population_Analysis/
├── code/
│   └── analysis.do              # Main Stata do-file (Part 1: data prep, Part 2: Q3–Q7)
├── raw_data/
│   ├── 2012_all_county_high_level/   # QCEW 2012 annual + quarterly files
│   └── nst-est2018-01.xlsx           # Census state population estimates
├── cleaned_data/                # Intermediate and analytic datasets (.dta / .xlsx)
├── output/
│   ├── analysis_log.txt         # Full Stata execution log
│   ├── Q3_Analysis_Report_2012.xlsx
│   ├── Q4_Top5_Counties_Report_2012.xlsx
│   ├── Q5_state_edhealth_pay_popshare_2012.png
│   ├── Q6_Regression_Results.rtf
│   ├── Q6_Robustness_ExclDC.rtf
│   └── Q7_MA_Counties_Report_2012.xlsx
├── report/
│   └── Results_Report_Data_Exercise_2026.pdf
└── README.md                    # This file
```

## How to Replicate

1. Install Stata 19 or later.
2. Install the `estout` package (uncomment line 9 in `code/analysis.do` on first run):
   ```stata
   ssc install estout, replace
   ```
3. Open `code/analysis.do` and update the `global root` path on line 15 to your local project folder.
4. Run the do-file end-to-end. All cleaned datasets and output files will be regenerated into `cleaned_data/` and `output/`.

## Data Sources

- **QCEW 2012 High-Level County Files** — U.S. Bureau of Labor Statistics, [bls.gov/cew](https://www.bls.gov/cew/)
- **State Population Estimates (2012)** — U.S. Census Bureau, file `nst-est2018-01.xlsx`

## Tools Used

- **Stata 19.5** — data cleaning, merging, regression, visualization
- **LaTeX** — results report typesetting
- **Excel** — structured output reports via `putexcel`

## Notes and Limitations

- In the QCEW high-level files, supersectors (Education & Health Services, Financial Activities, Professional & Business Services) are reported only under **private ownership**, not total covered. The employment share used in Q5 and Q6 therefore reflects private-sector employment relative to total state population.
- The county mean wage in Q4 is a **constructed** arithmetic mean of two industries, not an officially published measure.
- Regression results in Q6 are **descriptive**, not causal. Small-sample sensitivity to outliers (notably DC) is documented in the robustness check.
