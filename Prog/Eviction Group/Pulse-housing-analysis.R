######
# Program: DC housing analysis PUFS Census Pulse Cleaning
# Author: Elizabeth Burton 
# Created: 1/17/24
# Description: compile, clean, and analyze PUF census data for DC housing assistance analysis
######

## Indicators: 1) rent payment status 2) number of months behind on rent 3) likelihood of evction
# 3) informal pressure to move

library(tidyverse)
library(readxl)
library(openxlsx)
library(data.table)
library(srvyr)
library(weights)

# read in data
week_62 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_62.csv")
week_61 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_61.csv")
week_60 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_60.csv")
week_59 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_59.csv")
week_58 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_puf_58.csv")

# read in replicate weights
weights_58 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_58.csv")
weights_59 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_59.csv")
weights_60 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_60.csv")
weights_61 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_61.csv")
weights_62 <- read_csv("//sas1/dcdata/Libraries/Requests/Raw/Eviction Group/pulse2023_repwgt_puf_62.csv")

clean_data <- function(data_week) {
  data_week %>%
    filter(EST_ST == "11") %>%
    mutate(pressured = ifelse(MOVEWHY1 == 1|MOVEWHY2 == 1| MOVEWHY3 == 1|MOVEWHY4 == 1|MOVEWHY5 == 1|MOVEWHY6 == 1|MOVEWHY7 == 1,
                              "Pressure to Move", 
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
    rename(total_HH = THHLD_NUMPER,) %>%
    select(SCRAM,HWEIGHT,PWEIGHT,WEEK,EST_ST,
           pressured,moved,increase_rent,missed_rent,repairs_not_made,eviction_threatened,
           locks_changed,nhbd_danger,other_pressure,
           rent_change,rent_behind,months_behind,eviction_two_months,
           race, income,total_HH)
}

clean_week_58 <- clean_data(week_58)
clean_week_59 <- clean_data(week_59)
clean_week_60 <- clean_data(week_60)
clean_week_61 <- clean_data(week_61)
clean_week_62 <- clean_data(week_62)

all_clean_week_58_62 <- clean_week_58 %>%
  rbind(clean_week_59,clean_week_60,clean_week_61,clean_week_62)

all_weights_58_62 <- weights_58  %>%
  rbind(weights_59,weights_60,weights_61,weights_62)

all_weeks_w_weights <- inner_join(all_clean_week_58_62, all_weights_58_62, by = c("SCRAM", "WEEK"))

srvy_all <-
  as_survey_rep(
    all_weeks_w_weights,
    repweights = dplyr::matches("HWEIGHT[0-9]+"),
    weights = HWEIGHT,
    type = "BRR",
    mse = TRUE
  )

## Weeks 58-62 cross tabs analysis

# 1) Of all households who responded, those who felt pressure to move

total_pressure <- srvy_all %>%
  group_by(pressured) %>%
  summarise(proportion = survey_mean()) %>%
  mutate_if(is.numeric, round, digits = 2)

# 2) Of households that faced pressure, those who had to move in past 6 months due to pressure

total_moved <- srvy_all %>%
  filter(pressured == "Pressure to Move") %>%
  group_by(moved) %>%
  summarise(proportion = survey_mean()) %>%
  mutate_if(is.numeric, round, digits = 2)

# 3) Of households who felt pressured to move, what were the reasons? 

reasons_fun <- function(reason_input) {
  srvy_all %>%
    filter(pressured == "Pressure to Move") %>%
    group_by({{reason_input}}) %>%
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
  drop_na()

# rent payment status 
rent_payment <- srvy_all %>%
  group_by(rent_behind) %>%
  summarise(total = survey_total()) %>%
  mutate_if(is.numeric, round, digits = 2)

# number of months behind on rent 
# likelihood of evction

# 4) Cross tabs 1-3 with race/ethnicity 

# Race/Ethnicity pressured total

race_pressured <- srvy_all %>%
  group_by(race, pressured) %>%
  summarise(proportion = survey_mean()) %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(proportion_se < 0.05) %>% # taking out big p values
  select(-proportion_se) %>%     
  pivot_wider(names_from=pressured, values_from=proportion)

# Race/Ethnicity moved

race_moved <- srvy_all %>%
  filter(pressured == "Pressure to Move") %>%
  group_by(race, moved) %>%
  summarise(proportion = survey_mean()) %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(proportion_se < 0.05) %>% # taking out big p values
  select(-proportion_se) %>%     
  pivot_wider(names_from=moved, values_from=proportion)

# Race/Ethnicity by Reason

race_reason_fun <- function(race_ethnic, reason_input) {
  srvy_all %>%
    filter(pressured == "Pressure to Move") %>%
    group_by({{race_ethnic}}, {{reason_input}}) %>%
    summarise(proportion = survey_mean()) %>%
    filter(proportion_se < 0.05) %>% # taking out big p values
    select(-proportion_se) %>% 
    pivot_wider(names_from={{reason_input}}, values_from=proportion) %>%
    mutate_if(is.numeric, round, digits = 2) 
  # rename(reason={{reason_input}}) 
}

increase_reason_race <- race_reason_fun(race, increase_rent) %>%
  select(-`NA`) 

missed_reason_race <- race_reason_fun(race, missed_rent) %>%
  select(-`NA`) 

repairs_reason_race <- race_reason_fun(race, repairs_not_made) %>%
  select(-`NA`)  

threat_reason_race <- race_reason_fun(race, eviction_threatened) %>%
  select(-`NA`) 

locks_reason_race <- race_reason_fun(race, locks_changed) %>%
  select(-`NA`) 

nhbd_reason_race <- race_reason_fun(race, nhbd_danger) %>%
  select(-`NA`) 

other_reason_race <- race_reason_fun(race, other_pressure) %>%
  select(-`NA`) 

race_reason <- increase_reason_race %>%
  left_join(missed_reason_race, by="race") %>%
  left_join(repairs_reason_race, by="race") %>%
  left_join(threat_reason_race, by="race") %>%
  left_join(locks_reason_race, by="race") %>%
  left_join(nhbd_reason_race, by="race") %>%
  left_join(other_reason_race, by="race")

# 6) Pressure cross tabs 

pressure_crosstab <- function(var_cross) {
  srvy_all %>%
    group_by({{var_cross}}, pressured) %>%
    summarise(proportion = survey_mean()) %>%
    filter(proportion_se < 0.05) %>% # taking out big p values
    select(-proportion_se) %>% 
    pivot_wider(names_from=pressured, values_from=proportion) %>%
    mutate_if(is.numeric, round, digits = 2)
}

income_pressured <- pressure_crosstab(income) 
rent_change_pressure <- pressure_crosstab(rent_change)

# 7) Moved cross tabs 

moved_crosstab <- function(var_cross) {
  srvy_all %>%
    filter(pressured == "Pressure to Move") %>%
    group_by({{var_cross}}, moved) %>%
    summarise(proportion = survey_mean()) %>%
    filter(proportion_se < 0.05) %>% # taking out big p values
    select(-proportion_se) %>% 
    pivot_wider(names_from=moved, values_from=proportion) %>%
    mutate_if(is.numeric, round, digits = 2)
}

income_moved <- moved_crosstab(income)
rent_change_moved <- moved_crosstab(rent_change)

# 8) Reason cross tabs 

reason_crosstab <- function(var_cross, reason_input) {
  srvy_all %>%
    filter(pressured == "Pressure to Move") %>%
    group_by({{var_cross}}, {{reason_input}}) %>%
    summarise(proportion = survey_mean()) %>%
    filter(proportion_se < 0.05) %>% # taking out big p values
    select(-proportion_se) %>% 
    pivot_wider(names_from={{reason_input}}, values_from=proportion) %>%
    mutate_if(is.numeric, round, digits = 2) %>%
    select(-`NA`)
}

income_rent_inc <- reason_crosstab(income, increase_rent)
income_miss_rent <- reason_crosstab(income, missed_rent)
income_repairs <- reason_crosstab(income, repairs_not_made)
income_evict_threat <- reason_crosstab(income, eviction_threatened)
income_locks_change <- reason_crosstab(income, locks_changed)
income_nhbd_danger <- reason_crosstab(income, nhbd_danger)
income_other_press <- reason_crosstab(income, other_pressure)

income_reason <- income_rent_inc %>%
  left_join(income_miss_rent, by="income") %>%
  left_join(income_repairs, by="income") %>%
  left_join(income_evict_threat, by="income") %>%
  left_join(income_locks_change, by="income") %>%
  left_join(income_nhbd_danger, by="income") %>%
  left_join(income_other_press, by="income")

rent_change_rent_inc <- reason_crosstab(rent_change, increase_rent)
rent_change_miss_rent <- reason_crosstab(rent_change, missed_rent)
rent_change_repairs <- reason_crosstab(rent_change, repairs_not_made)
rent_change_evict_threat <- reason_crosstab(rent_change, eviction_threatened)
rent_change_locks_change <- reason_crosstab(rent_change, locks_changed)
rent_change_nhbd_danger <- reason_crosstab(rent_change, nhbd_danger)
rent_change_other_press <- reason_crosstab(rent_change, other_pressure)

rent_change_reason <- rent_change_rent_inc %>%
  left_join(rent_change_miss_rent, by="rent_change") %>%
  left_join(rent_change_repairs, by="rent_change") %>%
  left_join(rent_change_evict_threat, by="rent_change") %>%
  left_join(rent_change_locks_change, by="rent_change") %>%
  left_join(rent_change_nhbd_danger, by="rent_change") %>%
  left_join(rent_change_other_press, by="rent_change")

# Of survey respondents who felt pressured for X reason, those who moved

moved_reason_fun <- function(reason_input, reason_string) {
  srvy_all %>%
    filter(pressured == "Pressure to Move") %>%
    filter({{reason_input}} == {{reason_string}}) %>%
    group_by(moved) %>%
    summarise(proportion = survey_mean()) %>%
    filter(proportion_se < 0.05) %>% # taking out big p values
    select(-proportion_se) %>% 
    mutate_if(is.numeric, round, digits = 2)
}

moved_rent_increase <- moved_reason_fun(increase_rent, "Increased rent") %>%
  rename(`Increased rent` = proportion)
moved_miss_rent <- moved_reason_fun(missed_rent, "Missed Rent") %>%
  rename(`Missed Rent` = proportion)
moved_repairs <- moved_reason_fun(repairs_not_made, "Repairs not made") %>%
  rename(`Repairs not made` = proportion)
moved_evictions_threat <- moved_reason_fun(eviction_threatened, "Eviction threatened") %>%
  rename(`Eviction threatened` = proportion)
moved_locks_change <- moved_reason_fun(locks_changed, "Locks changed") %>%
  rename(`Locks changed` = proportion)
moved_nhbd_danger <- moved_reason_fun(nhbd_danger, "Neighborhood dangerous") %>%
  rename(`Neighborhood dangerous` = proportion)
moved_other_pressure <- moved_reason_fun(other_pressure, "Other pressure") %>%
  rename(`Other pressure` = proportion)

moved_reason <- moved_rent_increase %>%
  left_join(moved_miss_rent, by="moved") %>%
  left_join(moved_repairs, by="moved") %>%
  left_join(moved_evictions_threat, by="moved") %>%
  left_join(moved_locks_change, by="moved") %>%
  left_join(moved_nhbd_danger, by="moved") %>%
  left_join(moved_other_pressure, by="moved")

# Exporting in one xlsx

all_PUF <- list('Total Pressure'=total_pressure,'Total Moved'=total_moved,'Total Reason'=total_reason, 'Reason Moved'=moved_reason,
                'Race Pressure'=race_pressured,'Race Moved'=race_moved,'Race Reason'=race_reason,
                'Has Children by Race Pressure'=race_child_pressure,'Has Children by Race Reason'=race_child_reason,
                'Has Children by Race Moved'=race_child_moved,
                'Income Pressure'=income_pressured,'Income Moved'=income_moved,'Income Reason'=income_reason,
                'Has Children Pressure'=children_pressured,'Has Children Moved'=children_moved,'Has Children Reason'=children_reason,
                'Sufficient Food Pressure'=food_pressured,'Sufficient Food Moved'=food_moved,'Sufficient Food Reason'=food_reason,
                'SNAP Pressure'=SNAP_pressured,'SNAP Moved'=SNAP_moved,'SNAP Reason'=SNAP_reason,
                'Natural Disaster Pressure'=ND_displace_pressure,'Natural Disaster Reason'=ND_displace_reason,'Natural Disaster Moved'=ND_displace_moved,
                'ND by Type Moved'=ND_type_moved, 'ND by Type Pressured'=ND_type_pressured,
                'Rent change Pressure'=rent_change_pressure,'Rent change Moved'=rent_change_moved,'Rent change Reason'=rent_change_reason)
write.xlsx(all_PUF, file="PUF Cross Tabs Week 58-62.xlsx")


