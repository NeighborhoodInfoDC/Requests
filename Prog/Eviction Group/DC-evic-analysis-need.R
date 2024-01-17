##################
# Program: DC-evic-analysis-need
# Library: HAND - HIT
# Author: Elizabeth Burton
# Created: 1/16/2024

# Description: Estimate # households in DC that need housing assistance. For eviction co-leader group 
# housing assistance analysis
##################

# Load libraries and functions
library(tidyverse)
library(tidycensus)
library(skimr)
library(data.table)
library(openxlsx)

# Household income bins macro
source("//sas1/dcdata/Libraries/HAND/Macros/HIT_HH_inc_cat.R")

pums_vars_21 <- pums_variables %>%
  filter(year==2021, survey == "acs5")

dc_pums_21 <- get_pums(
  variables = c("PUMA", "TEN", "TYPEHUGQ", "SPORDER", "VALP", "NP", "HINCP", "VACS", "GRNTP", "RNTP",
                "RAC1P", "HISP", "GRPIP"),
  state="DC", 
  survey="acs5", 
  year = 2021, 
  show_call = TRUE, 
  recode = TRUE)

skim_pums <- skim(dc_pums_21)

## add adjusted income for 2017-2020 after Rodrigo updates HIT pums
clean_pums <- dc_pums_21 %>%
  filter(VACS == "b", # not vacant
         SPORDER == 1) %>% # person 1 in household
  mutate(rent_burden = case_when(
    GRPIP >= 30 ~ "rent burden", 
    HINCP <= 0 & GRNTP > 0 ~ "rent burden", #counting people with zero or negative household income (who pay rent) as cost burden
    GRPIP < 30 ~ "not rent burden")) %>% # GRPIP is gross rent as a percentage of household income past 12 months
  dmv_hh_inc() # to have HH income bins from function

total_hh_dc <- clean_pums %>%
  summarize(total_hh = sum(WGTP)) # total households 310,104 matches ACS 5 year for total households

total_owners_dc <- clean_pums %>%
  filter(TEN == 1 | TEN == 2) %>%
  summarize(total_owner = sum(WGTP))

renters_not_burden <- clean_pums %>%
  filter(TEN == 3 | TEN == 4) %>%
  filter(rent_burden == "not rent burden") %>%
  summarize(total_not_rent_burden = sum(WGTP))

renters_above_80AMI <- clean_pums %>%
  filter(TEN == 3 | TEN == 4,
         rent_burden == "rent burden", 
         inc_cat == "80_120MFI" | inc_cat == "120_200MFI") %>%
  summarize(total_above_80_AMI = sum(WGTP))

total_dc_need <- total_hh_dc %>%
  cbind(total_owners_dc, renters_not_burden, renters_above_80AMI) %>%
  mutate(total_need = total_hh-total_owner-total_not_rent_burden-total_above_80_AMI)

need_by_AMI <- clean_pums %>%
  filter(TEN == 3 | TEN == 4,
         rent_burden == "rent burden", 
         inc_cat == "below 30 MFI" | inc_cat == "30_50MFI" | inc_cat == "50_80MFI") %>%
  group_by(inc_cat) %>%
  summarize(hh_AMI = sum(WGTP))

# export the totals above
df_list <- list('Total' = total_dc_need, 'By AMI' = need_by_AMI)
write.xlsx(df_list, file = "Initial estimate of overall program need.xlsx")
