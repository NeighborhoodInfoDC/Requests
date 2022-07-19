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

# Use tidycensus to get a tract dataset with geography
dctracts <- get_acs("tract", table = "B01003", cache_table = TRUE, geometry = TRUE,
                   state = "11", county = "001", year = 2019, output = "tidy",
                   key = "5f7c478f7a433ac442443ad30a9096305d84224d") %>%
  rename(Geo2010=GEOID) 

# Read in affordability data
salsaff <- read_csv("D:/dcdata/Libraries/Requests/Prog/2022/Sales_affordability_allgeo.csv") %>%
  mutate(Geo2010=as.character(Geo2010))

# Function to create each map by race
makemap <- function(maprace){

salesaff_race <- salsaff %>%
  filter(!is.na(Geo2010)) %>%
  filter(race == maprace)

salesaff_race_tacts <- left_join(dctracts,salesaff_race,by="Geo2010") %>% 
  st_set_geometry(value = "geometry") %>%
  mutate(ratebucket = case_when(
    PctAffordFirst_dec < .5 ~ "Less than 50%",
    PctAffordFirst_dec >= .5 ~ "50% or greater",
    is.na(PctAffordFirst_dec) ~ "No data"))

set_urbn_defaults(style = "print")

urban_colors8 <- c("#cfe8f3", "#a2d4ec", "#73bfe2", "#46abdb","#1696d2", "#12719e", "#0a4c6a", "#d2d2d2")

ggplot() +
  geom_sf(data = salesaff_race_tacts, aes( fill = ratebucket))+
  scale_fill_manual(name="`Bucket`", values = urban_colors8, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                            shape = NA)))+ 
  #geom_sf(salesaff_wht_tacts, mapping = aes(), fill=NA,lwd =  1, color="#fdbf11",show.legend = "line")+
   geom_sf(cog_all, mapping = aes(), fill=NA,lwd =  1, color="#ec008b",show.legend = "line")+
  scale_color_manual(values = 'transparent', guide = guide_legend(override.aes = list(linetype = "solid"))) +
  coord_sf(datum = NA)+
 
  theme(
    panel.grid.major = element_line(colour = "transparent", size = 0),
    axis.title = element_blank(),
    axis.line.y = element_blank(),
    plot.caption = element_text(hjust = 0, size = 16),
    plot.title = element_text(size = 20),
    legend.text = element_text(size = 16)
    
  )+
  guides(color = guide_legend(override.aes = list(size=5)))+
  labs(title = paste0("Poverty rates by census tract in \n", countyname, ", ", statename),
       subtitle= "Racially or Ethnically Concentrated Areas of Poverty highlighted in yellow",
       caption = "Source: American Community Survey, 2019") 

}

makemap(maprace = "White")
makemap(maprace = "Black")
makemap(maprace = "Hispanic")