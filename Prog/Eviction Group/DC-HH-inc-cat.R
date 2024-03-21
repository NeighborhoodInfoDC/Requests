######
# Program: HH Income bins for DC Eviction Housing Assistance Analysis
# Library: Requests
# Project: DC Eviction Prevention Co-leaders Group
# Author:  Elizabeth Burton 
# Created: 2/20/24

# Description: Create a macro/function for household income bins to use for housing assistance analysis programs. 
######

## Incomes based on 2022 HUD income limits for DMV metro area 

dmv_hh_inc <- function(dataset) {
  dataset %>% 
  mutate(inc_cat=case_when(
    HINCP<29900 & NP==1 ~ "below 30 AMI",
    HINCP>=29900 & HINCP<39880 & NP==1 ~ "30_40AMI",
    HINCP>=39880 & HINCP<49850 & NP==1 ~ "40_50AMI",
    HINCP>=49850 & HINCP<63000 & NP==1~ "50_80AMI",
    HINCP>=63000 & HINCP<119640 & NP==1 ~ "80_120AMI",
    HINCP>=119640 & HINCP<199400 & NP==1 ~ "120_200AMI",
    HINCP>=199400 & NP==1 ~ "200plusAMI",
    HINCP<34200 & NP==2 ~ "below 30 AMI",
    HINCP>=34200 & HINCP<45560 & NP==2 ~ "30_40AMI",
    HINCP>=45560 & HINCP<56950 & NP==2 ~ "40_50AMI",
    HINCP>=56950 & HINCP<72000 & NP==2~ "50_80AMI",
    HINCP>=72000 & HINCP<136680 & NP==2 ~ "80_120AMI",
    HINCP>=136680 & HINCP<227800 & NP==2 ~"120_200AMI",
    HINCP>=227800 & NP==2 ~ "200plusAMI",
    HINCP<38450 & NP==3 ~ "below 30 AMI",
    HINCP>=38450 & HINCP<51240 & NP==3 ~ "30_40AMI",
    HINCP>=51240 & HINCP<64050 & NP==3 ~ "40_50AMI",
    HINCP>=64050 & HINCP<81000 & NP==3~ "50_80AMI",
    HINCP>=81000 & HINCP<153720 & NP==3 ~ "80_120AMI",
    HINCP>=153720 & HINCP<256200 & NP==3 ~ "120_200AMI",
    HINCP>=256200 & NP==3 ~ "200plusAMI",
    HINCP<42700 & NP==4 ~ "below 30 AMI",
    HINCP>=42700 & HINCP<56920 & NP==4 ~ "30_40AMI",
    HINCP>=56920 & HINCP<71150 & NP==4 ~ "40_50AMI",
    HINCP>=71150 & HINCP<90000 & NP==4~ "50_80AMI",
    HINCP>=90000 & HINCP<170760 & NP==4 ~ "80_120AMI",
    HINCP>=170760 & HINCP<284600 & NP==4 ~ "120_200AMI",
    HINCP>=284600 & NP==4 ~ "200plusAMI",
    HINCP<46150  & NP==5 ~ "below 30 AMI",
    HINCP>=46150  & HINCP<61480 & NP==5 ~ "30_40AMI",
    HINCP>=61480 & HINCP<76850 & NP==5 ~ "40_50AMI",
    HINCP>=76850 & HINCP<97200 & NP==5~ "50_80AMI",
    HINCP>=97200 & HINCP<184440 & NP==5 ~ "80_120AMI",
    HINCP>=184440 & HINCP<307400 & NP==5 ~ "120_200AMI",
    HINCP>=307400 & NP==5 ~ "200plusAMI",
    HINCP<49550  & NP==6 ~ "below 30 AMI",
    HINCP>=49550  & HINCP<66040 & NP==6 ~ "30_40AMI",
    HINCP>=66040  & HINCP<82550 & NP==6 ~ "40_50AMI",
    HINCP>=82550 & HINCP<104400 & NP==6~ "50_80AMI",
    HINCP>=104400 & HINCP<198120 & NP==6 ~ "80_120AMI",
    HINCP>=198120 & HINCP<330200 & NP==6 ~ "120_200AMI",
    HINCP>=330200 & NP==6 ~ "200plusAMI",
    HINCP<52950  & NP==7 ~ "below 30 AMI",
    HINCP>=52950  & HINCP<70600 & NP==7 ~ "30_40AMI",
    HINCP>=70600  & HINCP<88250 & NP==7 ~ "40_50AMI",
    HINCP>=88250 & HINCP<111600 & NP==7~ "50_80AMI",
    HINCP>=111600 & HINCP<211800 & NP==7 ~ "80_120AMI",
    HINCP>=211800 & HINCP<353000 & NP==7 ~ "120_200AMI",
    HINCP>=353000 & NP==7 ~ "200plusAMI",
    HINCP<56400  & NP>7 ~ "below 30 AMI",
    HINCP>=56400  & HINCP<75160 & NP>7 ~ "30_40AMI",
    HINCP>=75160  & HINCP<93950 & NP>7 ~ "40_50AMI",
    HINCP>=93950 & HINCP<118800 & NP>7~ "50_80AMI",
    HINCP>=118800 & HINCP<225480 & NP>7 ~ "80_120AMI",
    HINCP>=225480 & HINCP<375800 & NP>7 ~ "120_200AMI",
    HINCP>=375800 & NP>7 ~ "200plusAMI",
    TRUE ~ "Not available")) 
}