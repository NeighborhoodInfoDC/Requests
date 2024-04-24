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

# Read in data and replicate weights
data <- list.files(path="//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/", pattern = "[.]csv$", full.names=TRUE ) %>% 
  map_dfr(read_csv)

rep_weights <- list.files(path="//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/weights/", full.names=TRUE ) %>% 
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
                             MOVED == -99 | MOVED == -88 ~ "Did not report"),
           income = case_when(INCOME == 1 ~ "$25,000 below",  
                            INCOME == 2 | INCOME == 3 ~ "$25,000-$49,999",
                            INCOME == 4 ~ "$50,000-$74,999",
                            INCOME == 5 ~ "$75,000-$99,999",
                            INCOME == 6 | INCOME == 7 | INCOME == 8 ~ "$100,000 above",
                            INCOME == -99 | INCOME == -88 ~ "Not reported"),
           rent_behind = case_when(RENTCUR == 1 ~ "Not behind on rent",
                                   RENTCUR == 2 ~ "Behind on rent",
                                   RENTCUR == -99 | RENTCUR == -88 ~ "Did not report"),
           eviction_two_months = case_when(EVICT == 1 ~ "very likely", 
                                           EVICT == 2 ~ "somewhat likely", 
                                           EVICT == 3 ~ "not very likely", 
                                           EVICT == 4 ~ "not likely at all",
                                           EVICT == -99 | EVICT == -88 ~ "Did not report"),
           inc_cat=case_when(INCOME == 1 | INCOME == 2 & THHLD_NUMPER==1 ~ "below 40 AMI", #based on HUD incomes limits for income & household size 
                             INCOME == 1 | INCOME == 2 & THHLD_NUMPER==2 ~ "below 40 AMI",
                             INCOME == 1 | INCOME == 2 | INCOME == 3 & THHLD_NUMPER==3 ~ "below 40 AMI",
                             INCOME == 1 | INCOME == 2 | INCOME == 3 & THHLD_NUMPER==4 ~ "below 40 AMI",
                             INCOME == 1 | INCOME == 2 | INCOME == 3 & THHLD_NUMPER==5 ~ "below 40 AMI",
                             INCOME == 1 | INCOME == 2 | INCOME == 3 | INCOME == 4 & THHLD_NUMPER==6 ~ "below 40 AMI",
                             INCOME == 1 | INCOME == 2 | INCOME == 3 | INCOME == 4 & THHLD_NUMPER==7 ~ "below 40 AMI",
                             INCOME == 1 | INCOME == 2 | INCOME == 3 | INCOME == 4 & THHLD_NUMPER>7 ~ "below 40 AMI",
                             TRUE ~ "above 40 AMI")) %>%
  select(SCRAM,HWEIGHT,PWEIGHT,WEEK,CYCLE,EST_ST,
         pressured,moved,increase_rent,missed_rent,repairs_not_made,eviction_threatened,
         locks_changed,nhbd_danger,other_pressure,
         rent_behind,eviction_two_months,income,inc_cat,THHLD_NUMPER) 

all_PUF <- inner_join(clean_data, rep_weights, by = c("SCRAM", "WEEK", "CYCLE")) # need to join by week/cycle for replicate weights

srvy_all <- 
  as_survey_rep(
    all_PUF,
    repweights = dplyr::matches("HWEIGHT[0-9]+"),
    weights = HWEIGHT,
    type = "BRR",
    mse = TRUE
  )

# 1) Households who think they are likely to face an eviction in the next two months
eviction_behind_rent <-  srvy_all %>%
  group_by(inc_cat, eviction_two_months) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out obs with large standard errors
  select(-proportion_se) %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(eviction_two_months != "Did not report") %>%
  pivot_wider(names_from = inc_cat, values_from = proportion) 

# 2) Households who felt pressure to move
total_pressure <- srvy_all %>%
  group_by(inc_cat, pressured) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out obs with large standard errors
  select(-proportion_se) %>%     
  mutate_if(is.numeric, round, digits = 2) %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# 3) Households who physically moved from pressure they felt in the past 6 months
total_moved <- srvy_all %>%
  group_by(inc_cat, moved) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out obs with large standard errors
  select(-proportion_se) %>%     
  mutate_if(is.numeric, round, digits = 2) %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# 4) Reasons households felt pressured to move 
reasons_fun <- function(reason_input) { # respondents can choose multiple reasons 
  srvy_all %>%
    group_by(inc_cat, {{reason_input}}) %>%
    summarise(proportion = survey_mean()) %>%
    filter(proportion_se < 0.05) %>% # taking out obs with large standard errors
    select(-proportion_se) %>%     
    mutate_if(is.numeric, round, digits = 2) %>%
    rename(reason={{reason_input}})
}

rent_increase <- reasons_fun(increase_rent)
miss_rent <- reasons_fun(missed_rent)
repairs <- reasons_fun(repairs_not_made)
evictions_threat <- reasons_fun(eviction_threatened)
locks_change <- reasons_fun(locks_changed)
nhbd_danger <- reasons_fun(nhbd_danger)
other_pressure <- reasons_fun(other_pressure)

total_reason <- rent_increase %>%
  rbind(miss_rent, repairs,evictions_threat,locks_change,nhbd_danger,other_pressure) %>%
  drop_na() %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# 5) Households behind in rent payments
total_rent_payment <- srvy_all %>%
  group_by(inc_cat, rent_behind) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out obs with large standard errors
  select(-proportion_se) %>%     
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(rent_behind == "Behind on rent") %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# Exporting in one xlsx
all_PUF <- list('Eviction Likelihood'=eviction_behind_rent,'Total Pressure'=total_pressure,'Total Moved'=total_moved,'Total Reason'=total_reason,
                'Total Rent Payment'=total_rent_payment)
write.xlsx(all_PUF, file="//sas1/dcdata/Libraries/Requests/Prog/Eviction Group/DC PUF Tabulation June 2023-February 2024.xlsx")

