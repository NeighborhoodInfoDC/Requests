######
# Program: DC housing analysis PUFS Census Pulse Cleaning
# Author: Elizabeth Burton 
# Created: 1/17/24
# Description: compile, clean, and analyze PUF census data for DC housing assistance analysis
######

library(tidyverse)
library(readxl)
library(openxlsx)
library(data.table)
library(srvyr)
library(weights)

# Read in data and replicate weights: using week 57-week 63 surveys (May 2023-Oct 2023) and cycle 01 (Jan-Feb 2024)
## list.files() extracts the names of all .csv files at the specified path. 
## map_dfr() and read_csv read in each .csv file and combine them all into a single dataset, called data. 
## Resulting data has 629,582 rows and 283 columns, and rep_weights has 823,537 rows and 163 columns.
data <- list.files(path="//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/", pattern = "[.]csv$", full.names=TRUE ) %>% 
  map_dfr(read_csv)

# Create categorical variables 
clean_data <- data %>%
  filter(EST_ST == "11", # DC only
         TENURE == 3 | TENURE == 4 ) %>% # renters only 3 == Rented; 4 == Occupied without payment of rent
  mutate(pressured = ifelse(MOVEWHY1 == 1|MOVEWHY2 == 1| MOVEWHY3 == 1|MOVEWHY4 == 1|MOVEWHY5 == 1|MOVEWHY6 == 1|MOVEWHY7 == 1,
                              "Pressure", # Respondents can choose multiple reasons
                              ifelse(MOVEWHY8 == 1, "No pressure", "Not reported")),
           increase_rent = case_when(MOVEWHY1 == 1 ~ "Increased rent"), 
           missed_rent = case_when(MOVEWHY2 == 1 ~ "Missed Rent"), 
           repairs_not_made = case_when(MOVEWHY3 == 1 ~ "Repairs not made"),
           eviction_threatened = case_when(MOVEWHY4 == 1 ~ "Eviction threatened"),
           locks_changed = case_when(MOVEWHY5 == 1 ~ "Locks changed"),
           nhbd_danger = case_when(MOVEWHY6 == 1 ~ "Neighborhood dangerous"),
           other_pressure = case_when(MOVEWHY7 == 1 ~ "Other pressure"),
           moved = case_when(MOVED == 1 ~ "Moved from Pressure", 
                             MOVED == 2 ~ "Did not move from Pressure",
                             MOVED == -99 | MOVED == -88 ~ "not reported"),
           income = case_when(INCOME == 1 ~ "$25,000 below",  
                            INCOME == 2 | INCOME == 3 ~ "$25,000-$49,999",
                            INCOME == 4 ~ "$50,000-$74,999",
                            INCOME == 5 ~ "$75,000-$99,999",
                            INCOME == 6 | INCOME == 7 | INCOME == 8 ~ "$100,000 above",
                            INCOME == -99 | INCOME == -88 ~ "not reported"),
           rent_behind = case_when(RENTCUR == 1 ~ "Not behind on rent",
                                   RENTCUR == 2 ~ "Behind on rent",
                                   RENTCUR == -99 | RENTCUR == -88 ~ "not reported"),
           behind_two_months = case_when(TMNTHSBHND >= 2 ~ "Behind 2+ months rent", 
                                         EVICT == 1 | EVICT == 2 ~ "Behind 2+ months rent", 
                                         TMNTHSBHND == -99 | TMNTHSBHND == -88 ~ "not reported",
                                         TRUE ~ "Not 2+ months behind on rent"),
           eviction_two_months = case_when(EVICT == 1 ~ "very likely", 
                                           EVICT == 2 ~ "somewhat likely", 
                                           EVICT == 3 ~ "not very likely", 
                                           EVICT == 4 ~ "not likely at all",
                                           EVICT == -99 | EVICT == -88 ~ "not reported"),
           income_bins = case_when(THHLD_NUMPER == 4 & INCOME == 4 ~ "household_four", 
                                   THHLD_NUMPER == 5 & INCOME == 4 ~ "household_five", 
                                   THHLD_NUMPER == 6 & INCOME == 4 ~ "household_six", 
                                   THHLD_NUMPER == 8 & INCOME == 5 ~ "household_eight", 
                                   TRUE ~ "No")) %>%
  select(SCRAM,HWEIGHT,PWEIGHT,WEEK,CYCLE,EST_ST,
         pressured,moved,increase_rent,missed_rent,repairs_not_made,eviction_threatened,
         locks_changed,nhbd_danger,other_pressure,
         rent_behind,behind_two_months,eviction_two_months,income,income_bins,THHLD_NUMPER,TMNTHSBHND,INCOME) 

# Taking random samples based on the proportion provided in sample_frac (using Pulse income bins to create share of population that would be below that)
# to select below 40% AMI sample
HH_four <- clean_data %>%
  filter(income_bins == "household_four") %>%
  sample_frac(.48) %>%
  mutate(inc_cat = case_when(income_bins == "household_four" ~ "below 40 AMI"))

HH_five <- clean_data %>%
  filter(income_bins == "household_five") %>%
  sample_frac(.67) %>%
  mutate(inc_cat = case_when(income_bins == "household_five" ~ "below 40 AMI"))

HH_six <- clean_data %>%
  filter(income_bins == "household_six") %>%
  sample_frac(.87) %>%
  mutate(inc_cat = case_when(income_bins == "household_six" ~ "below 40 AMI"))

HH_eight <- clean_data %>%
  filter(income_bins == "household_five") %>%
  sample_frac(.27) %>%
  mutate(inc_cat = case_when(income_bins == "household_eight" ~ "below 40 AMI"))

HH_AMI <- rbind(HH_four, HH_five, HH_six, HH_eight) %>%
  select(SCRAM, inc_cat)

final_clean_data <- clean_data %>%
  left_join(HH_AMI, by = "SCRAM") %>%
  mutate(inc_cat_new = case_when( #assigning the rest of the below 40% AMI
    INCOME == 1 | INCOME == 2 | INCOME == 3 ~ "below 40 AMI", # all households 0-$49,999; #based on HUD 2024 incomes limits for income & household size
    INCOME == 4 & THHLD_NUMPER >= 7 ~ "below 40 AMI", #7 person HH & income 50-75,000 is 40% AMI
    inc_cat == "below 40 AMI" ~ "below 40 AMI", # coding above random samples as below 40% AMI
    TRUE ~ "above 40 AMI"))

# 1) Households who think they are likely to face an eviction in the next two months
total_eviction <- final_clean_data %>% # 5% of renter pop report somewhat likely or very likely to be evicted
  filter(rent_behind != "not reported") %>% # remove respondents who did not answer rent_behind question (which indicates if eviction question shown)
  group_by(WEEK, eviction_two_months) %>% # eviction question only showed to respondents behind on rent but we want % of all renters for analysis so keeping denominator all renters
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>%
  mutate(proportion = count / sum(count)) %>%
  group_by(eviction_two_months) %>%
  summarise(average = mean(proportion),
            sum = sum(count)) %>%
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

eviction_AMI <- final_clean_data %>% ## 3% of the renter population is HH at 40% ami and below who report facing eviction in next two months.
  filter(rent_behind != "not reported") %>% 
  group_by(WEEK, inc_cat_new, eviction_two_months) %>%
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>%
  mutate(proportion = count / sum(count)) %>%
  group_by(inc_cat_new, eviction_two_months) %>%
  summarise(sum = sum(count),
            average = mean(proportion)) %>%
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

# 2) Households behind in rent payments
total_behind_rent <- final_clean_data %>% # 14% of renter population report behind in rent
  group_by(WEEK, rent_behind) %>% 
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>%
  mutate(proportion = count / sum(count)) %>%
  group_by(rent_behind) %>%
  summarise(average = mean(proportion),
            sum = sum(count)) %>%
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

behind_rent_AMI <- final_clean_data %>% ## 11% of the renter population is HH at 40% ami and below and report behind in rent
  group_by(WEEK, inc_cat_new, rent_behind) %>%
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>% 
  mutate(proportion = count / sum(count)) %>% #share per survey
  group_by(inc_cat_new,rent_behind) %>%
  summarise(sum = sum(count), #summing across surveys
            average = mean(proportion)) %>% #average across surveys
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

# 3) Households 2+ months behind in rent payments 
total_behind_2_months <- final_clean_data %>% # 14% of renter population report behind in rent
  group_by(WEEK, behind_two_months) %>% 
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>%
  mutate(proportion = count / sum(count)) %>%
  group_by(behind_two_months) %>%
  summarise(average = mean(proportion),
            sum = sum(count)) %>%
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

behind_2_months_AMI <- final_clean_data %>% ## 11% of the renter population is HH at 40% ami and below and report behind in rent
  group_by(WEEK, inc_cat_new, behind_two_months) %>%
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>% 
  mutate(proportion = count / sum(count)) %>% #share per survey
  group_by(inc_cat_new,behind_two_months) %>%
  summarise(sum = sum(count), #summing across surveys
            average = mean(proportion)) %>% #average across surveys
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

# 4) Households who felt pressure to move
total_pressure <- final_clean_data %>% #13% of renter HH who have 40% AMI or below, reported pressure to move
  filter(WEEK != 57) %>% # pressure question started week 58, so removing 57
  group_by(WEEK,inc_cat_new, pressured) %>%
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>%
  mutate(proportion = count / sum(count)) %>%
  group_by(inc_cat_new,pressured) %>%
  summarise(average = mean(proportion)) %>% #averaging across the surveys 
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

# 5) Households who physically moved from pressure they felt in the past 6 months
total_moved <- final_clean_data %>%
  filter(WEEK != 57) %>% # pressure question started week 58, so removing 57
  group_by(WEEK,inc_cat_new, moved) %>%
  summarise(count = sum(HWEIGHT)) %>%
  group_by(WEEK) %>%
  mutate(proportion = count / sum(count)) %>%
  group_by(inc_cat_new, moved) %>%
  summarise(average = mean(proportion)) %>% #averaging across the surveys 
  mutate_if(is.numeric, round, digits = 2) # rounding to two decimal places 

# Exporting in one xlsx
all_PUF <- list('Total Eviction Likelihood'=total_eviction,
                'AMI Eviction Likelihood'=eviction_AMI,
                'Total Behind Rent'=total_behind_rent,
                'AMI Behind Rent'=behind_rent_AMI,
                'Total 2+ Months Behind'=total_behind_2_months,
                'AMI 2+ Months Behind'=behind_2_months_AMI,
                'AMI Pressure'=total_pressure,
                'AMI Moved'=total_moved)
write.xlsx(all_PUF, file="//sas1/dcdata/Libraries/Requests/Prog/Eviction Group/DC PUF Tabulation April 2023-April 2024.xlsx")

