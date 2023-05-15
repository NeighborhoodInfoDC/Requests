##############################################################################
# Program:  Affordability_maps.R
# Library:  Requests
# Project:  Homeownership Strikeforce
# Author:   Rob Pitingolo
# Created:  07/18/2022
# Version:  R version 4.2.1
# Environment:  Windows 10

# Description:  Create tract-based maps from the affordability tabulations
#               for homeowners by race.

# Modifications: 
##############################################################################

# load necessary packages
library(tidyverse)
library(tidycensus)
library(forcats)
library(gridExtra)
library(sp)
library(rgdal)
library(broom)
library(tigris)
library(urbnmapr)
library(urbnthemes)
library(sf)

set_urbn_defaults(style="map")

# Use tidycensus to get a tract dataset with geography
dctracts <- get_acs("tract", table = "B01003", cache_table = TRUE, geometry = TRUE,
                   state = "11", county = "001", year = 2021, output = "tidy",
                   key = "5f7c478f7a433ac442443ad30a9096305d84224d") %>%
  rename(Geo2020=GEOID) 

# Read in affordability data
salsaff <- read_csv("D:/dcdata/Libraries/Requests/Prog/2023/Sales_affordability_allgeo_2022.csv") %>%
  mutate(Geo2020=as.character(Geo2020))

# Function to create each map by race
makemap <- function(maprace, affvar, status){

salesaff_race <- salsaff %>%
  filter(!is.na(Geo2020)) %>%
  filter(race == maprace)

salesaff_race_tacts <- left_join(dctracts,salesaff_race,by="Geo2020") %>% 
  st_set_geometry(value = "geometry") %>%
  mutate(ratebucket = case_when(
    {{affvar}} < .15 ~ "0% to up to 15%",
    {{affvar}} < .30 ~ "15% to up to 30%",
    {{affvar}} < .45 ~ "30% to up to 45%",
    {{affvar}} < .60 ~ "45% to up to 60%",
    {{affvar}} < .75 ~ "60% to up to 75%",
    {{affvar}} >= .75 ~ "75% or greater",
    is.na({{affvar}}) ~ "No data"))

set_urbn_defaults(style = "print")

aff_colors <- c("#cfe8f3", "#a2d4ec", "#73bfe2", "#46abdb","#1696d2", "#12719e", "#bcbcbc")

ggplot() +
  geom_sf(data = salesaff_race_tacts, aes(fill = ratebucket)) +
  scale_fill_manual(name = "`Bucket`", guide = guide_legend(override.aes = list(linetype = "blank", shape = NA))) +
  scale_color_manual(values = "transparent", guide = guide_legend(override.aes = list(linetype = "solid"))) +
  coord_sf(datum = NA) +
  scale_fill_manual(
    values = c(`0% to up to 15%` = "#cfe8f3", `15% to up to 30%` = "#a2d4ec", `30% to up to 45%` = "#73bfe2", 
               `45% to up to 60%` = "#46abdb", `60% to up to 75%` = "#1696d2", `75% or greater` = "#12719e", 
               `No data` = "#bcbcbc"), 
    drop = TRUE
  ) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    axis.line = element_blank(),
    axis.text = element_text(),
    axis.title = element_text(),
    plot.caption = element_text(hjust = 0.5, size = 10),
    plot.title = element_text(size = 16, hjust = 0.5),
    legend.text = element_text(size = 14),
    legend.title = element_blank(),
    legend.background = element_blank(),
    legend.key = element_blank(),
    legend.key.size = unit(0.5, "lines"),
    legend.key.width = unit(0.5, "lines")
  ) +
  guides(color = guide_legend(override.aes = list(size = 3))) +
  labs(
    title = paste0("Pct. of SF/Condo Sales 2016-22 Affordable to \n",
                   status, " Buyer at Avg. Household Income - ", maprace),
    caption = "Source: American Community Survey 2017-21 and \n DC Office of Tax and Revenue, Tabulated by Urban-Greater DC"
  )

ggsave(paste0("D:/dcdata/Libraries/Requests/Prog/2023/map/", maprace, " ", status, " affordable 2022.png"),
       device = "png",
       width = 8.5,
       height = 8.5)

}

makemap(maprace = "White", affvar=PctAffordFirst_dec, status="First-time")
makemap(maprace = "Black", affvar=PctAffordFirst_dec, status="First-time")
makemap(maprace = "Hispanic", affvar=PctAffordFirst_dec, status="First-time")

makemap(maprace = "White", affvar=PctAffordRepeat_dec, status="Repeat")
makemap(maprace = "Black", affvar=PctAffordRepeat_dec, status="Repeat")
makemap(maprace = "Hispanic", affvar=PctAffordRepeat_dec, status="Repeat")

# End of program