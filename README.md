# QCEW & Population Data Analysis (2012)

Analysis of 2012 Quarterly Census of Employment and Wages (QCEW) county-level data combined with U.S. Census Bureau state population estimates. Produced as a data exercise using Stata 19.5 and LaTeX.

**Author:** Airui Meng
**Date:** March 2026

## Project Overview

This project transforms raw administrative employment and wage data into a coherent set of descriptive and regression-based findings at the state and county levels. It was completed as a take-home data exercise to demonstrate the ability to **find, clean, and analyze raw public data** and communicate findings clearly.

## Task Description

The exercise consists of seven tasks. The original prompt is not redistributed in this repository for academic integrity reasons (see note below). A paraphrased summary:

1. **Task 1** — Locate and download the 2012 QCEW NAICS-based county high-level data files from the U.S. Bureau of Labor Statistics. Describe the structure of the annual file (`allhlcn12`) in plain language.
2. **Task 2** — Locate and download the U.S. Census Bureau resident population estimates (2010–2018) covering states and national totals.
3. **Task 3** — Report the states with the highest and lowest share of total annual average employment in the federal government, along with the mean, median, and standard deviation. Exclude the District of Columbia.
4. **Task 4** — Construct a county-level dataset with the mean of average weekly wage in "Financial Activities" and "Professional and Business Services" industries, restricted to counties with non-zero wages in both. Report the top 5 counties.
5. **Task 5** — Create a graph showing the state-level relationship between the share of population employed in "Education and Health Services" and annual average pay in that sector.
6. **Task 6** — Use a regression-based approach to describe the relationship between annual average pay, sector employment share, and state population size, using the data from Task 5.
7. **Task 7** — Identify Massachusetts counties where total wages paid in Q1 2012, on an annualized basis (Q1 × 4), exceed annual total wages. Exclude "Unknown Or Undefined, Massachusetts" and use all industries under Total Covered ownership.

> **Note on the original prompt.** The original `data_exercise_2026.docx` file distributed by the hiring institution is intentionally **not** included in this public repository. The summary above is a paraphrased description of what was asked. This is to respect the confidentiality of the exercise and to avoid exposing the exact prompt to future applicants. If you are an authorized reviewer and would like to see the unredacted submission including the original prompt, please contact me directly.

## Analysis Summary

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

Note: `data_exercise_2026.docx` (the original task prompt) is intentionally excluded from this repository.

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
