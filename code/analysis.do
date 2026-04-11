/* =====================================================================
Project: QCEW & Population Data Analysis Exercise
Author: Airui Meng
Date: March 16, 2026
======================================================================*/


***** Install required packages (uncomment if needed)
***** ssc install estout, replace


clear all

* === USER: Change this path to your project folder ===
global root "/Users/ray/Desktop/QCEW_Population_Analysis"

* ----------------------------------------------------------------------
* 0. Environment Setup
* ----------------------------------------------------------------------
cd "$root"

capture mkdir "$root/cleaned_data"
capture mkdir "$root/output"


capture log close _all

log using "$root/output/analysis_log.txt", name(analysis_log) text replace
version 19.5

set more off


* ======================================================================
* PART 1: CENTRALIZED DATA PREPARATION
* ======================================================================



* ----------------------------------------------------------------------
* 1.1 Prepare Base Dataset: QCEW Annual 2012
* ----------------------------------------------------------------------
import excel "raw_data/2012_all_county_high_level/allhlcn12.xlsx", sheet("US_St_Cn_MSA") firstrow clear

* Clean variable names
rename AreaCode                         area_code
rename St                               state_code
rename Cnty                             county_code
rename Own                              own_code
rename NAICS                            naics_code
rename Year                             year
rename Qtr                              quarter
rename AreaType                         area_type
rename StName                           state_name
rename Area                             area_name
rename Ownership                        ownership
rename Industry                         industry
rename AnnualAverageStatusCode          avg_status_code
rename AnnualAverageEstablishmentCou    avg_estab_count
rename AnnualAverageEmployment          avg_employment
rename AnnualTotalWages                 annual_wages
rename AnnualAverageWeeklyWage          avg_weekly_wage
rename AnnualAveragePay                 avg_annual_pay
rename EmploymentLocationQuotientRel    emp_lq_rel
rename TotalWageLocationQuotientRel     wage_lq_rel

* Save clean base annual dataset
save "cleaned_data/base_qcew_annual.dta", replace


* ----------------------------------------------------------------------
* 1.2 Prepare Base Dataset: Census Population 2012
* ----------------------------------------------------------------------
import excel "raw_data/nst-est2018-01.xlsx", sheet("NST01") cellrange(A10:F60) clear

rename A state_name_raw
rename F pop2012

keep state_name_raw pop2012

* Remove leading dots from state names
gen state_name = state_name_raw
replace state_name = substr(state_name, 2, .) if substr(state_name, 1, 1) == "."
drop state_name_raw

* Check uniqueness before merge
isid state_name

* Save clean base population dataset
save "cleaned_data/base_population.dta", replace


* ----------------------------------------------------------------------
* 1.3 Prepare Base Dataset: QCEW Q1 2012 (Massachusetts Only)
* ----------------------------------------------------------------------
import excel "raw_data/2012_all_county_high_level/allhlcn121.xlsx", sheet("US_St_Cn_MSA") firstrow clear

rename AreaCode              area_code
rename AreaType              area_type
rename StName                state_name
rename Area                  area_name
rename Ownership             ownership
rename Industry              industry
rename TotalQuarterlyWages   q1_wages

* Keep Massachusetts county-level totals
keep if state_name == "Massachusetts"
keep if area_type == "County"
keep if ownership == "Total Covered"
keep if industry == "Total, all industries"
drop if area_name == "Unknown Or Undefined, Massachusetts"

* Annualize Q1 wages
gen q1_wages_annualized = 4 * q1_wages
keep area_code area_name q1_wages q1_wages_annualized

* Save clean base Q1 dataset
save "cleaned_data/base_qcew_q1.dta", replace






* ======================================================================
* PART 2: TASK ANALYSIS
* ======================================================================




**************
* Question 3 *
**************
use "cleaned_data/base_qcew_annual.dta", clear

* 1. Filter for State-level data and aggregate "Total employment, all industries"
keep if area_type == "State" & naics_code == 10
* naics_code == 10 corresponding to "Total, all industries"

* 2. Exclude the District of Columbia
drop if area_name == "District of Columbia"

* 3. Keep only the "Total Covered" and "Federal Government" rows
keep if ownership == "Total Covered" | ownership == "Federal Government"


* 4. Rename ownership categories to make reshaping simpler
replace ownership = "Total" if ownership == "Total Covered"
replace ownership = "Federal" if ownership == "Federal Government"

keep area_code area_name state_code state_name ownership avg_employment

* 5. Reshape and calculate share
reshape wide avg_employment, i(area_code) j(ownership) string
gen federal_share = avg_employmentFederal / avg_employmentTotal

* After filtering Q3 data:
assert _N == 50  // 50 states (excluding DC)

* 6. Display highest and lowest share
gsort -federal_share
list area_code area_name state_code state_name federal_share in 1

gsort federal_share
list area_code area_name state_code state_name federal_share in 1

* 7. Descriptive statistics
summarize federal_share, detail

* 8.Save the complete dataset after cleaning
order area_code area_name state_code state_name avg_employmentFederal avg_employmentTotal federal_share
save "cleaned_data/Q3_State_Federal_Employment_Share_2012.dta", replace
export excel using "cleaned_data/Q3_State_Federal_Employment_Share_2012.xlsx", firstrow(variables) replace

* 9. Export Q3 Report (to the "output" folder)

* Obtain the states with the highest proportion and their corresponding values
gsort -federal_share
local highest_a_code = area_code[1]
local highest_a_area = area_name[1]
local highest_s_code = state_code[1]
local highest_s_area = state_name[1]
local highest_share = federal_share[1]

* Obtain the states with the lowest proportion and their corresponding values
gsort federal_share
local lowest_a_code = area_code[1]
local lowest_a_area = area_name[1]
local lowest_s_code = state_code[1]
local lowest_s_area = state_name[1]
local lowest_share = federal_share[1]


summarize federal_share, detail
local mean_val = r(mean)
local median_val = r(p50)    // 50th percentile
local sd_val = r(sd)

putexcel set "output/Q3_Analysis_Report_2012.xlsx", replace

putexcel A1 = "Metric", bold
putexcel B1 = "Federal Share Value", bold
putexcel C1 = "Area Name", bold
putexcel D1 = "Area Code", bold
putexcel E1 = "State Name", bold
putexcel F1 = "State Code", bold

putexcel A2 = "Highest Federal Share"
putexcel B2 = `highest_share'
putexcel C2 = "`highest_a_area'"
putexcel D2 = "`highest_a_code'"
putexcel E2 = "`highest_s_area'"
putexcel F2 = "`highest_s_code'"

putexcel A3 = "Lowest Federal Share"
putexcel B3 = `lowest_share'
putexcel C3 = "`lowest_a_area'"
putexcel D3 = "`lowest_a_code'"
putexcel E3 = "`lowest_s_area'"
putexcel F3 = "`lowest_s_code'"

putexcel A4 = "Mean"
putexcel B4 = `mean_val'

putexcel A5 = "Median"
putexcel B5 = `median_val'

putexcel A6 = "Standard Deviation"
putexcel B6 = `sd_val'

putexcel B2:B6, nformat("0.0000")






**************
* Question 4 *
**************
use "cleaned_data/base_qcew_annual.dta", clear

* 1. Keep county-level and target industries
keep if area_type == "County"
keep if industry == "Financial activities" | industry == "Professional and business services"
keep if ownership == "Private"

keep state_code state_name county_code area_code area_name industry avg_weekly_wage

* 2. Filter out missing/zero wages and ensure counties have both industries
gen zero_flag = (avg_weekly_wage == 0 | missing(avg_weekly_wage))

* Grouping by state (state_code) + county (county_code).
* Treat all observations (here observations are two) from the same county as a group.
bysort state_code county_code: egen has_zero = max(zero_flag)
* Mark every row in this county with the following:
* has_zero = 1 -> This county has industries with a wage of 0 or missing values
* has_zero = 0 -> This county has no industries with a salary of 0 or missing values

drop if has_zero == 1
drop zero_flag has_zero

bysort area_code: gen n_industries = _N
drop if n_industries != 2
drop n_industries

* 3. Reshape and calculate mean
replace industry = "fin" if industry == "Financial activities"
replace industry = "pbs" if industry == "Professional and business services"

reshape wide avg_weekly_wage, i(area_code) j(industry) string
gen mean_wage = (avg_weekly_wagefin + avg_weekly_wagepbs) / 2

* After Q4 reshape:
assert avg_weekly_wagefin > 0 & avg_weekly_wagepbs > 0

* 4. Display top 5 and export
order county_code area_code area_name state_code state_name avg_weekly_wagefin avg_weekly_wagepbs mean_wage
gsort -mean_wage
list county_code area_code area_name state_code state_name mean_wage in 1/5

save "cleaned_data/Q4_county_mean_wage_fin_pbs_2012.dta", replace
export excel using "cleaned_data/Q4_county_mean_wage_fin_pbs_2012.xlsx", firstrow(variables) replace

* 5. Export Q4 Report (to the "output" folder)

* the data in descending order of average wage by the previous step's gsort -mean_wage.
* Create a new Excel report file
putexcel set "output/Q4_Top5_Counties_Report_2012.xlsx", replace

putexcel A1 = "Rank", bold
putexcel B1 = "County Code", bold
putexcel C1 = "Area Code", bold
putexcel D1 = "County (Area Name)", bold
putexcel E1 = "State Code", bold
putexcel F1 = "State Name", bold
putexcel G1 = "Mean Weekly Wage ($)", bold

* Use the forvalues loop to accurately extract the first 5 rows of data and write them into Excel.
forvalues i = 1/5 {
	local current_county_code = county_code[`i']
	local current_area_code = area_code[`i']
    local current_county = area_name[`i']
    local current_state_code = state_code[`i']
    local current_state = state_name[`i']
    local current_wage = mean_wage[`i']

    * The first row is the header, so the data starts from the (i + 1)th row.
    local row = `i' + 1

    putexcel A`row' = `i'
	putexcel B`row' = "`current_county_code'"
	putexcel C`row' = "`current_area_code'"
    putexcel D`row' = "`current_county'"
    putexcel E`row' = "`current_state_code'"
    putexcel F`row' = "`current_state'"
    putexcel G`row' = `current_wage', nformat("#,##0.00")
}








**************
* Question 5 *
**************
use "cleaned_data/base_qcew_annual.dta", clear

* 1. Keep relevant state-level industry rows
keep if area_type == "State"
keep if industry == "Education and health services"

keep year area_code area_name state_code state_name avg_employment avg_annual_pay

rename avg_employment edhealth_emp
rename avg_annual_pay edhealth_pay

isid state_name

* 2. Merge with base population data
merge 1:1 state_name using "cleaned_data/base_population.dta"
tab _merge
assert _merge == 3

keep if _merge == 3
drop _merge


* 3. Create employment share
gen edhealth_pop_share = edhealth_emp / pop2012
gen edhealth_pop_share_pct = 100 * edhealth_pop_share
summarize edhealth_emp edhealth_pay pop2012 edhealth_pop_share edhealth_pop_share_pct

* 4. Create Graph

* Flag DC for separate plotting
gen is_dc = (area_name == "District of Columbia")

* Generate label positioning variable to reduce overlap:
* Place labels to the right by default (3 = right),
* adjust specific crowded points to other clock positions.
gen mlabpos = 3
replace mlabpos = 9  if state_name == "California"
replace mlabpos = 3 if state_name == "Nevada"
replace mlabpos = 6  if state_name == "Idaho"
replace mlabpos = 12 if state_name == "Massachusetts"
replace mlabpos = 6  if state_name == "Arkansas"
replace mlabpos = 9  if state_name == "Hawaii"
replace mlabpos = 1  if state_name == "New Hampshire"
replace mlabpos = 6  if state_name == "South Carolina"
replace mlabpos = 12 if state_name == "Connecticut"
replace mlabpos = 12  if state_name == "Montana"
replace mlabpos = 12 if state_name == "Delaware"
replace mlabpos = 6  if state_name == "Wyoming"
replace mlabpos = 9  if state_name == "Mississippi"
replace mlabpos = 12 if state_name == "New York"
replace mlabpos = 6 if state_name == "New Mexico"
replace mlabpos = 8 if state_name == "Colorado"
replace mlabpos = 10 if state_name == "Kansas"
replace mlabpos = 2 if state_name == "Oklahoma"
replace mlabpos = 6 if state_name == "Oregon"

twoway ///
    (scatter edhealth_pay edhealth_pop_share_pct if is_dc == 0, ///
        msymbol(circle) mcolor(navy) msize(tiny) ///
        mlabel(state_name) mlabsize(tiny) mlabcolor(gs6) ///
        mlabvposition(mlabpos)) ///
    (scatter edhealth_pay edhealth_pop_share_pct if is_dc == 1, ///
        msymbol(diamond) mcolor(cranberry) msize(small) ///
        mlabel(state_name) mlabsize(tiny) mlabcolor(cranberry) ///
        mlabposition(9)) ///
    (lfit edhealth_pay edhealth_pop_share_pct if is_dc == 0, ///
        lcolor(navy) lpattern(solid) lwidth(medthin)) ///
    (lfit edhealth_pay edhealth_pop_share_pct, ///
        lcolor(cranberry) lpattern(dash) lwidth(medthin)), ///
    xtitle("Share of population employed in Education and health services (%)", size(small)) ///
    ytitle("Annual average pay in Education and health services ($)", size(small)) ///
    title("State-level relationship: Education & health services", size(medium)) ///
    subtitle("2012", size(small)) ///
    legend(order(1 "States" 2 "District of Columbia" 3 "Fit: excl. DC" 4 "Fit: all obs.") ///
        size(vsmall) rows(1) position(6)) ///
    graphregion(color(white) margin(r=13)) ///
    plotregion(color(white)) ///
    note("Note: DC is highlighted as an outlier due to its exceptionally high employment share in Education and health services (private sector only).", ///
         size(vsmall) color(gs6)) ///
    name(edhealth_scatter, replace)

	* 5. Export Q5 Graph (to the "output" folder)
graph export "output/Q5_state_edhealth_pay_popshare_2012.png", replace width(2000)

* 6. Export Q5 Cleaned_data (to the "output" folder)
drop is_dc mlabpos
order year area_code area_name state_code state_name edhealth_emp edhealth_pay pop2012 edhealth_pop_share edhealth_pop_share_pct
save "cleaned_data/Q5_state_edhealth_pay_popshare_2012.dta", replace
export excel using "cleaned_data/Q5_state_edhealth_pay_popshare_2012.xlsx", firstrow(variables) replace



**************
* Question 6 *
**************


* Continuously running from Q5 data
* (Before running the code for Question 6, please run the code for Problem 5 first)
use "cleaned_data/Q5_state_edhealth_pay_popshare_2012.dta", clear

gen ln_pop2012 = ln(pop2012)

* 1. Simple regression
reg edhealth_pay edhealth_pop_share_pct, vce(robust)

* 2. Multiple regression
* Dependent variable: Annual average pay in the Education and Health Services industry
* Core independent variable: Proportion of employment in this industry to the state's population
* Control variable: State population size
reg edhealth_pay edhealth_pop_share_pct ln_pop2012, vce(robust)

* 3. Interaction effect (add share_x_lnpop)
gen pct_x_lnpop = edhealth_pop_share_pct * ln_pop2012
reg edhealth_pay edhealth_pop_share_pct ln_pop2012 pct_x_lnpop, vce(robust)

** 3.1
* The interaction term will be highly correlated with the original variable.
* First, center the variable, then calculate the interaction term.
summ edhealth_pop_share_pct
gen c_edhealth_pop_pct = edhealth_pop_share_pct - r(mean)

summ ln_pop2012
gen c_lnpop2012 = ln_pop2012 - r(mean)

gen cpct_x_clnpop2012 = c_edhealth_pop_pct * c_lnpop2012
reg edhealth_pay c_edhealth_pop_pct c_lnpop2012 cpct_x_clnpop2012, vce(robust)

* 4. Robustness check: Exclude DC
* DC is an extreme outlier (employment share ~16% vs. next highest ~10%).
* Re-estimate the simple and multiple models excluding DC to verify
* that results are not driven by this single observation.

preserve
drop if area_name == "District of Columbia"

display as text _newline "--- Simple regression (excl. DC, N=50) ---"
reg edhealth_pay edhealth_pop_share_pct, vce(robust)

display as text _newline "--- Multiple regression (excl. DC, N=50) ---"
reg edhealth_pay edhealth_pop_share_pct ln_pop2012, vce(robust)

restore

* 5. Export Q6 Regression Results (to the "output" folder)
eststo clear

* Store main models (all 51 observations)
quietly reg edhealth_pay edhealth_pop_share_pct, vce(robust)
eststo M1

quietly reg edhealth_pay edhealth_pop_share_pct ln_pop2012, vce(robust)
eststo M2

quietly reg edhealth_pay edhealth_pop_share_pct ln_pop2012 pct_x_lnpop, vce(robust)
eststo M3

quietly reg edhealth_pay c_edhealth_pop_pct c_lnpop2012 cpct_x_clnpop2012, vce(robust)
eststo M4

* Store robustness models (excluding DC, 50 observations) [NEW]
preserve
drop if area_name == "District of Columbia"

quietly reg edhealth_pay edhealth_pop_share_pct, vce(robust)
eststo M5

quietly reg edhealth_pay edhealth_pop_share_pct ln_pop2012, vce(robust)
eststo M6

restore

* Panel A: Main results (same as original)
esttab M1 M2 M3 M4 using "output/Q6_Regression_Results.rtf", replace ///
    title("Table A: Regression Results -- All States plus DC (N=51)") ///
    mtitles("Simple" "Multiple" "Interaction" "Centered Interaction") ///
    b(2) se(2) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    r2(3) ///
    compress ///
    addnotes("Robust standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.1")

* Panel B: Robustness check excluding DC [NEW]
esttab M5 M6 using "output/Q6_Robustness_ExclDC.rtf", replace ///
    title("Table B: Robustness Check -- Excluding DC (N=50)") ///
    mtitles("Simple (excl. DC)" "Multiple (excl. DC)") ///
    b(2) se(2) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    r2(3) ///
    compress ///
    addnotes("Robust standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.1" ///
             "DC excluded as an extreme outlier (employment share ~16%).")







**************
* Question 7 *
**************

use "cleaned_data/base_qcew_annual.dta", clear

* 1. Prepare Annual Massachusetts Data
keep if state_name == "Massachusetts"
keep if area_type == "County"
keep if ownership == "Total Covered"
keep if industry == "Total, all industries"
drop if area_name == "Unknown Or Undefined, Massachusetts"
keep county_code area_code year quarter area_name state_name annual_wages

* 2. Merge with base Q1 data
* (Q1 wages was annualized in dataset preparation 1.3)
merge 1:1 area_code area_name using "cleaned_data/base_qcew_q1.dta"
tab _merge
assert _merge == 3

keep if _merge == 3
drop _merge

* 3. Compare and output
gen q1_gt_annual = (q1_wages_annualized > annual_wages) & !missing(q1_wages_annualized) & !missing(annual_wages)
list county_code area_code area_name q1_wages_annualized annual_wages if q1_gt_annual == 1, noobs clean

* 4. Export Q7 Cleaned_data (to the "output" folder)
order year quarter county_code area_code area_name state_name annual_wages  q1_wages q1_wages_annualized q1_gt_annual
save "cleaned_data/Q7_Massachusetts_Q1_vs_Annual_Wages_2012.dta", replace
export excel using "cleaned_data/Q7_Massachusetts_Q1_vs_Annual_Wages_2012.xlsx", firstrow(variables) replace

* 5. Export Q7 Report (to the "output" folder)
* Count the number of counties that meet the condition of "annualized Q1 > full year"


**************************** Important Note: ***********************************

* This section(Q7-5)of code must be selected and run as a whole!
* Reason: The local macro (num_counties) is only valid within the same execution.
* If run in segments, the second code block will not be able to read the value of num_counties,
* resulting in an error (invalid name) for the if `num_counties' > 0 statement.

count if q1_gt_annual == 1
local num_counties = r(N)

putexcel set "output/Q7_MA_Counties_Report_2012.xlsx", replace

putexcel A1 = "Year", bold
putexcel B1 = "Quarter", bold
putexcel C1 = "County Code", bold
putexcel D1 = "Area Code", bold
putexcel E1 = "County (Area Name)", bold
putexcel F1 = "Q1 Wages ($)", bold
putexcel G1 = "Annualized Q1 Wages ($)", bold
putexcel H1 = "Annual Total Wages ($)", bold

if `num_counties' > 0 {
    * Arrange the counties that meet the conditions (with a value of 1) at top and sort them in descending order of salary.
    gsort -q1_gt_annual -q1_wages_annualized

    * Using a loop, only extract the first few counties that meet the criteria.
    forvalues i = 1/`num_counties' {
		local current_year = year[`i']
		local current_quarter = quarter[`i']
		local current_c_code = county_code[`i']
        local current_a_code = area_code[`i']
        local current_county = area_name[`i']
        local q1_wage_val = q1_wages[`i']
        local ann_q1_val = q1_wages_annualized[`i']
        local ann_total_val = annual_wages[`i']

        * Start writing data from the second row (the first row is the header)
        local row = `i' + 1

		putexcel A`row' = "`current_year'"
		putexcel B`row' = "`current_quarter'"
        putexcel C`row' = "`current_c_code'"
		putexcel D`row' = "`current_a_code'"
        putexcel E`row' = "`current_county'"

        * With thousands separator, no decimal retention
        putexcel F`row' = `q1_wage_val', nformat("#,##0")
        putexcel G`row' = `ann_q1_val', nformat("#,##0")
        putexcel H`row' = `ann_total_val', nformat("#,##0")
    }
}
else {
    * If no counties that meet the criteria are found, write a prompt message.
    putexcel A2 = "None of the counties meet the criteria."
}

********************************************************************************






* Data Structure Notes
* These are observations about the data that affect code interpretation:


* In the QCEW high-level county files, supersectors like "Education and health services", "Financial activities", and "Professional and business services" are only reported under Own=5 (Private), not under Own=0 (Total Covered). This means Q4 and Q5 do not need an explicit ownership filter -- there is only one row per area per supersector. However, this also means Q5's "share of population employed" calculation uses only private employment, not total employment in the sector.

* County name uniqueness: QCEW area_name values for counties include the state name (e.g., "Franklin County, Massachusetts"), making them unique across the dataset. This is why bysort area_name works in Q4 despite not being best practice.


