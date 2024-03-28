######
# Program: DC housing analysis PUFS Census Pulse Cleaning
# Author: Elizabeth Burton 
# Created: 1/17/24
# Description: compile, clean, and analyze PUF census data for DC housing assistance analysis
######

## Indicators: 1) rent payment status 2) number of months behind on rent 3) likelihood of eviction
# 3) informal pressure to move

library(tidyverse)
library(readxl)
library(openxlsx)
library(data.table)
library(srvyr)
library(weights)

# read in data
week_63 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_63.csv")
week_62 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_62.csv")
week_61 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_61.csv")
week_60 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_60.csv")
week_59 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_59.csv")
week_58 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_58.csv")
cycle_01 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/hps_04_00_01_puf.csv") %>%
  rename(WEEK = CYCLE)
cycle_02 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/hps_04_00_02_puf.csv") %>%
  rename(WEEK = CYCLE)

# read in replicate weights
weights_58 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_58.csv")
weights_59 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_59.csv")
weights_60 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_60.csv")
weights_61 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_61.csv")
weights_62 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_62.csv")
weights_63 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_63.csv")
weights_01 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/hps_04_00_01_repwgt_puf.csv") %>%
  rename(WEEK = CYCLE)
weights_02 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/hps_04_00_02_repwgt_puf.csv") %>%
  rename(WEEK = CYCLE)

clean_data <- function(data_week, num_period) {
  data_week %>%
    filter(EST_ST == "11") %>%
    mutate(pressured = ifelse(MOVEWHY1 == 1|MOVEWHY2 == 1| MOVEWHY3 == 1|MOVEWHY4 == 1|MOVEWHY5 == 1|MOVEWHY6 == 1|MOVEWHY7 == 1,
                              "Pressure", 
                              ifelse(MOVEWHY8 == 1, "No pressure", "Not reported")),
           increase_rent = case_when(MOVEWHY1 == 1 ~ "Increased rent"), 
           missed_rent = case_when(MOVEWHY2 == 1 ~ "Missed Rent"), 
           repairs_not_made = case_when(MOVEWHY3 == 1 ~ "Repairs not made"),
           eviction_threatened = case_when(MOVEWHY4 == 1 ~ "Eviction threatened"),
           locks_changed = case_when(MOVEWHY5 == 1 ~ "Locks changed"),
           nhbd_danger = case_when(MOVEWHY6 == 1 ~ "Neighborhood dangerous"),
           other_pressure = case_when(MOVEWHY7 == 1 ~ "Other pressure"),
           race = case_when(RRACE == 1 & (RHISPANIC == 1|RHISPANIC == -99|RHISPANIC == -88) ~ "White", 
                            RRACE == 2 & (RHISPANIC == 1|RHISPANIC == -99|RHISPANIC == -88) ~ "Black", 
                            RRACE == 3 & (RHISPANIC == 1|RHISPANIC == -99|RHISPANIC == -88) ~ "Asian", 
                            RRACE == 4 & (RHISPANIC == 1|RHISPANIC == -99|RHISPANIC == -88) ~ "Other race or multiple races",
                            RHISPANIC == 2 ~ "Hispanic/Latino",
                            TRUE ~ "Did not report"),
           moved = case_when(MOVED == 1 ~ "Moved from Pressure", 
                             MOVED == 2 ~ "Did not move from Pressure",
                             MOVED == -99 | MOVED == -88 ~ "Did not report"),
           income = case_when(INCOME == 1 ~ "Less than $25,000",  
                              INCOME == 2 ~ "$25,000 - $34,999",
                              INCOME == 3 ~ "$35,000 - $49,999",
                              INCOME == 4 ~ "$50,000 - $74,999",
                              INCOME == 5 ~ "$75,000 - $99,999",
                              INCOME == 6 ~ "$100,000 - $149,999",
                              INCOME == 7 ~ "$150,000 - $199,999",
                              INCOME == 8 ~ "$200,000 and above",
                              INCOME == -99 | INCOME == -88 ~ "Did not report"),
           rent_change = case_when(RENTCHNG == 1 ~ "My rent did not change",
                                   RENTCHNG == 2 ~ "My rent decreased",
                                   RENTCHNG == 3 ~ "My rent increased by <$100",
                                   RENTCHNG == 4 ~ "My rent increased by $100-$249",
                                   RENTCHNG == 5 ~ "My rent increased by $250-$500",
                                   RENTCHNG == 6 ~ "My rent increased by more than $500",
                                   RENTCHNG == -99 | RENTCHNG == -88 ~ "Did not report"),
           rent_behind = case_when(RENTCUR == 1 ~ "Not behind on rent",
                                   RENTCUR == 2 ~ "Behind on rent",
                                   RENTCUR == -99 | RENTCUR == -88 ~ "Did not report"),
           months_behind = case_when(TMNTHSBHND == 1 | TMNTHSBHND == 2 ~ "1-2 months behind",
                                     TMNTHSBHND == 3 | TMNTHSBHND == 4 ~ "3-4 months behind",
                                     TMNTHSBHND == 5 | TMNTHSBHND == 6 ~ "5-6 months behind",
                                     TMNTHSBHND == 7 | TMNTHSBHND == 8 ~ "7+ months behind",
                                     TMNTHSBHND == -99 | TMNTHSBHND == -88 ~ "Did not report"),
           eviction_two_months = case_when(EVICT == 1 ~ "very likely", 
                                           EVICT == 2 ~ "somewhat likely", 
                                           EVICT == 3 ~ "not very likely", 
                                           EVICT == 4 ~ "not likely at all",
                                           EVICT == -99 | EVICT == -88 ~ "Did not report"),
    ) %>%
    filter(TENURE == 3 | TENURE == 4) %>% # 3 == Rented; 4 == Occupied without payment of rent
    mutate(inc_cat=case_when(
          INCOME == 1 | INCOME == 2 & THHLD_NUMPER==1 ~ "below 40 AMI",
          INCOME == 1 | INCOME == 2 & THHLD_NUMPER==2 ~ "below 40 AMI",
          INCOME == 1 | INCOME == 2 | INCOME == 3 & THHLD_NUMPER==3 ~ "below 40 AMI",
          INCOME == 1 | INCOME == 2 | INCOME == 3 & THHLD_NUMPER==4 ~ "below 40 AMI",
          INCOME == 1 | INCOME == 2 | INCOME == 3 & THHLD_NUMPER==5 ~ "below 40 AMI",
          INCOME == 1 | INCOME == 2 | INCOME == 3 | INCOME == 4 & THHLD_NUMPER==6 ~ "below 40 AMI",
          INCOME == 1 | INCOME == 2 | INCOME == 3 | INCOME == 4 & THHLD_NUMPER==7 ~ "below 40 AMI",
          INCOME == 1 | INCOME == 2 | INCOME == 3 | INCOME == 4 & THHLD_NUMPER>7 ~ "below 40 AMI",
          TRUE ~ "above 40 AMI")) %>%
    select(SCRAM,HWEIGHT,PWEIGHT,WEEK,EST_ST,
           pressured,moved,increase_rent,missed_rent,repairs_not_made,eviction_threatened,
           locks_changed,nhbd_danger,other_pressure,
           rent_change,rent_behind,months_behind,eviction_two_months,
           race, income,inc_cat) %>%
    mutate(period = {{num_period}})
}

clean_week_58 <- clean_data(week_58, "1")
clean_week_59 <- clean_data(week_59, "1")
clean_week_60 <- clean_data(week_60, "2")
clean_week_61 <- clean_data(week_61, "2")
clean_week_62 <- clean_data(week_62, "3")
clean_week_63 <- clean_data(week_63, "3")
clean_cycle_01 <- clean_data(cycle_01, "4") 
clean_cycle_02 <- clean_data(cycle_01, "5") 

all_clean <- clean_week_58 %>%
  rbind(clean_week_59,clean_week_60,clean_week_61,clean_week_62,clean_week_63,clean_cycle_01,clean_cycle_02)

all_weights <- weights_58  %>%
  rbind(weights_59,weights_60,weights_61,weights_62,weights_63,weights_01,weights_02)

all_PUF <- inner_join(all_clean, all_weights, by = c("SCRAM", "WEEK"))

srvy_all <-
  as_survey_rep(
    all_PUF,
    repweights = dplyr::matches("HWEIGHT[0-9]+"),
    weights = HWEIGHT,
    type = "BRR",
    mse = TRUE
  )

## Analysis on PUF since June 2023 when pressure to move added to survey 

# Likelihood of eviction
eviction_behind_rent <-  srvy_all %>%
  group_by(inc_cat, eviction_two_months) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out big p values
  select(-proportion_se) %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(eviction_two_months != "Did not report") %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# 1) Of all households who responded, those who felt pressure to move

total_pressure <- srvy_all %>%
  filter(pressured != "Not reported") %>% # denominator only people who reported if pressured or not
  group_by(inc_cat, pressured) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out obs with large standard errors
  select(-proportion_se) %>%     
  mutate_if(is.numeric, round, digits = 2) %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# 2) Of households that faced pressure, those who had to move in past 6 months due to pressure

total_moved <- srvy_all %>%
  filter(pressured == "Pressure") %>%
  group_by(inc_cat, moved) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out obs with large standard errors
  select(-proportion_se) %>%     
  mutate_if(is.numeric, round, digits = 2) %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# 3) Of households who felt pressured to move, what were the reasons? 

reasons_fun <- function(reason_input) {
  srvy_all %>%
    filter(pressured == "Pressure") %>%
    group_by(inc_cat, {{reason_input}}) %>%
    summarise(proportion = survey_mean()) %>%
    filter(proportion_se < 0.05) %>% # taking out big p values
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

# Rent Payment Status  
total_rent_payment <- srvy_all %>%
  group_by(inc_cat, rent_behind) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out big p values
  select(-proportion_se) %>%     
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(rent_behind == "Behind on rent") %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# Of people behind on rent, the number of months behind on rent
months_behind <- srvy_all %>%
  filter(rent_behind == "Behind on rent") %>% #The survey only asks those who are behind on rent
  group_by(inc_cat, months_behind) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out big p values
  select(-proportion_se) %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(months_behind != "Did not report") %>%
  filter(!is.na(months_behind)) %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# Rent change 
total_rent_change <-  srvy_all %>%
  group_by(inc_cat, rent_change) %>%
  summarise(proportion = survey_mean()) %>%
  filter(proportion_se < 0.05) %>% # taking out big p values
  select(-proportion_se) %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(rent_change != "Did not report") %>%
  pivot_wider(names_from = inc_cat, values_from = proportion)

# Exporting in one xlsx

all_PUF <- list('Eviction Likelihood'=eviction_behind_rent,'Total Pressure'=total_pressure,'Total Moved'=total_moved,'Total Reason'=total_reason,
                'Total Rent Payment'=total_rent_payment, 'Months Behind'=months_behind, 'Total Rent Change'=total_rent_change)
write.xlsx(all_PUF, file="DC PUF Tabulation June 2023-February 2024.xlsx")




