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
  mutate(across(-c(SERIALNO), as.numeric), # all numeric vars besides SERIALNO
    year=substr(SERIALNO, 1, 4),
    GRNTP = GRNTP*(ADJHSG/1000000), # adjusting to match years prior to 2022 to 2022 $ value for gross rent and household income 
    HINCP = HINCP*(ADJINC),
    inc_month_30 = (HINCP*0.30)/12, # 30% of monthly income 
    rent_burden = case_when(
      inc_month_30 <= GRNTP ~ "Rent Burden", # If 30% of monthly income less than or equal to gross monthly rent cost, HH is rent burden 
      HINCP <= 0 & GRNTP > 0 ~ "Rent Burden", # If HH income is less than or equal to 0 and the HH pays rent, HH is rent burden
      TRUE ~ "Not Rent Burden")) %>% # All else households not rent burden 
  dmv_hh_inc() # to have HH income bins from function in DC-HH-inc-cat.R

total_hh_dc <- clean_pums %>% # testing weights to ensure match to ACS 5 year data for total renter, occupied households 
  summarize(total_hh = sum(WGTP)) # 184,459 matches ACS 5 year (184,920) 

rentburden_inccat <- clean_pums %>% # low income renters by AMI levels and rent burden 
  filter(inc_cat == "below 30 AMI" | inc_cat == "30_40AMI" | inc_cat == "40_50AMI") %>% 
  group_by(inc_cat, rent_burden) %>%
  summarize(Total = sum(WGTP)) %>% #summing by HH weight
  pivot_wider(names_from = inc_cat, values_from = Total) %>%
  bind_rows(summarise(., across(where(is.numeric), sum), 
                      across(where(is.character), ~'Total'))) %>% #creating total row 
  select(rent_burden, `below 30 AMI`, `30_40AMI`, `40_50AMI`) %>% #rearranging columns
  mutate_if(is.numeric, round, -2)

estimate_voucher_cost <- clean_pums %>% # estimating cost of voucher if HH's paid 30% of their income 
  filter(inc_cat == "below 30 AMI",
         rent_burden == "Rent Burden") %>%
  mutate(voucher_cost = GRNTP - inc_month_30) %>% # estimating voucher cost if current rent minus 30% of HH monthly income (inc_month_30 created in clean_pums)
  summarize(across(c(voucher_cost), 
                   list(weighted_avg = ~weighted.mean(., w = WGTP), #calculating weighted avg of voucher_cost var
                        weighted_sum = ~ sum(. * WGTP)))) %>% #calculating weighted sum of voucher_cost var 
  mutate(voucher_total_cost_year = voucher_cost_weighted_sum*12,
         voucher_avg_year = voucher_cost_weighted_avg*12) %>%
  mutate_if(is.numeric, round, -2)

estimate_shallow <- clean_pums %>% # estimating the number of HH who would not be rent burden if received DC Flex ($8,400 a year) and spent towards rent 
  filter(rent_burden == "Rent Burden",
         inc_cat == "30_40AMI" | inc_cat == "40_50AMI") %>% #only looking at HH from 30-50 AMI (30 and below would be voucher)
  mutate(rent_w_subsidy = GRNTP - (8400/12), # Flex recipients receive $8,400
         new_rent_burden = case_when(
           inc_month_30 <= rent_w_subsidy ~ "Still Rent Burden", 
           HINCP <= 0 & GRNTP > 0 ~ "Still Rent Burden", 
           TRUE ~ "Now Not Rent Burden")) %>% #creating new rent burden categories after receiving subsidy 
  group_by(new_rent_burden, inc_cat) %>%
  summarize(Total = sum(WGTP)) %>%
  pivot_wider(names_from = inc_cat, values_from = Total) %>%
  mutate(Total = `30_40AMI` + `40_50AMI`) %>%
  mutate_if(is.numeric, round, -2)

# export the totals above
df_list <- list('Rent Burden by AMI' = rentburden_inccat, 'Voucher Cost Estimate' = estimate_voucher_cost, 'Shallow Subsidy Estimate' = estimate_shallow)
write.xlsx(df_list, file = "Eviction Housing Analysis PUMS Estimates.xlsx")
