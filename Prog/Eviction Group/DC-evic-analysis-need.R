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

## Filter for only head of occupied households, create rent burden variable, and add 2022 income category bins
clean_pums <- dc_pums_22 %>%
  filter(VACS=="0", # not vacant
         SPORDER == 1, # person 1 in household
         TEN == 3 | TEN == 4) %>% #renter
  mutate(across(-c(SERIALNO), as.numeric),
    year=substr(SERIALNO, 1, 4),
    GRNTP = GRNTP*(ADJHSG/1000000), #adjusting to match years prior to 2022 to 2022 $ value
    HINCP = HINCP*(ADJINC),
    inc_month_30 = (HINCP*0.30)/12, 
    rent_burden = case_when(
      inc_month_30 <= GRNTP ~ "rent_burden", 
      HINCP <= 0 & GRNTP > 0 ~ "rent_burden", 
      TRUE ~ "not_rent_burden")) %>%
  dmv_hh_inc() # to have HH income bins from function

total_hh_dc <- clean_pums %>%
  summarize(total_hh = sum(WGTP)) # total households 315,785 matches ACS 5 year for total households

renters_below_30_AMI <- clean_pums %>%
  filter(inc_cat == "below 30 AMI") %>%
  summarize(total_below_30AMI = sum(WGTP))

renters_30_50 <- clean_pums %>%
  filter(rent_burden == "rent_burden",
         inc_cat == "30_40AMI" | inc_cat == "40_50AMI") %>%
  group_by(inc_cat) %>%
  summarize(total_rent_burden = sum(WGTP)) 

estimate_voucher_cost <- clean_pums %>%
  filter(inc_cat == "below 30 AMI",
         rent_burden == "rent_burden") %>%
  mutate(income_30 = (HINCP*0.30)/12, 
         voucher_cost = GRNTP - income_30) %>% # how to sum up the difference with the HH weight?
  summarize(total_voucher_cost = sum(voucher_cost))
  # summarize(total_voucher_cost=weighted.mean(voucher_cost, WGTP))

# Also I can only make this estimate with people who are rent burden not all HH below 30% AMI
  
estimate_shallow <- clean_pums %>%
  filter(rent_burden == "rent_burden",
         inc_cat == "30_40AMI" | inc_cat == "40_50AMI") %>%
  mutate(rent_subsidy_cost = GRNTP - 600, 
         new_rent_burden = case_when(
           inc_month_30 <= rent_subsidy_cost ~ "rent_burden", 
           HINCP <= 0 & GRNTP > 0 ~ "rent_burden", 
           TRUE ~ "not_rent_burden")) %>%
  group_by(new_rent_burden) %>%
  summarize(estimate_shallow = sum(WGTP)) 

# export the totals above
df_list <- list('Total' = total_dc_need, 'By AMI' = need_by_AMI)
write.xlsx(df_list, file = "Initial estimate of overall program need.xlsx")
