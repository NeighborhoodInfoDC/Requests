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

# Household income bins function
source("C:/Users/eburton/Documents/GitHub/Requests/Prog/Eviction Group/DC-HH-inc-cat.R")

dc_pums_22 <- get_pums(
  variables = c("PUMA10","PUMA20", "TEN", "TYPEHUGQ", "SPORDER", "VALP", "NP", "HINCP", "VACS", "GRNTP","RAC1P", "HISP", "GRPIP","ADJHSG","ADJINC"),
  state="DC", 
  survey="acs5", 
  year = 2022, 
  show_call = TRUE, 
  recode = TRUE)

## NEED TO PUT ALL $ IN 2020 VALUE!

## Filter for only head of occupied households, create rent burden variable, and add 2022 income category bins
clean_pums <- dc_pums_22 %>%
  filter(VACS=="0", # not vacant
         SPORDER == 1) %>% # person 1 in household
  mutate(rent_burden = case_when(
    GRPIP >= 30 ~ "rent burden", 
    HINCP <= 0 & GRNTP > 0 ~ "rent burden", #counting people with zero or negative household income (who pay rent) as cost burden
    GRPIP < 30 ~ "not rent burden")) %>% # GRPIP is gross rent as a percentage of household income past 12 months
  dmv_hh_inc() # to have HH income bins from function

total_hh_dc <- clean_pums %>%
  summarize(total_hh = sum(WGTP)) # total households 315,785 matches ACS 5 year for total households

renters_below_30_AMI <- clean_pums %>%
  filter(TEN == 3 | TEN == 4, 
         inc_cat == "below 30 AMI") %>%
  summarize(total_below_30AMI = sum(WGTP))

renters_30_50 <- clean_pums %>%
  filter(TEN == 3 | TEN == 4,
         rent_burden == "rent burden",
         inc_cat == "30_40AMI" | inc_cat == "40_50AMI") %>%
  group_by(inc_cat) %>%
  summarize(total_rent_burden = sum(WGTP)) 

estimate_voucher_cost <- clean_pums %>%
  filter(TEN == 3 | TEN == 4, 
         inc_cat == "below 30 AMI") %>%
  

# export the totals above
df_list <- list('Total' = total_dc_need, 'By AMI' = need_by_AMI)
write.xlsx(df_list, file = "Initial estimate of overall program need.xlsx")
