## Set-up
#### Load libraries and functions

library(tidyverse)
library(DescTools)
library(purrr)


#### Create directory for data exports on local computer

if (!dir.exists("../Data")) {
  dir.create("../Data")
}

jdir <- "D:/DCData/Libraries/Requests/Prog/2019/"

library(dplyr)

#### Load in region shapefile
library(rgdal)

library(sf)
shp= "L:/Libraries/General/Maps/DCMetroArea2015_tr10.shp"
Metro_sf <- read_sf(dsn=shp,layer= basename(strsplit(shp, "\\.")[[1]])[1])

countyshp= "L:/Libraries/General/Maps/DMVCounties.shp"

county_sf <- read_sf(dsn= countyshp, layer= "DMVCounties")


# load in typology dataset output from SAS program

InternetAccess <- read.csv(paste0(jdir,"Internet_access_tract.csv")) 

Access_df <- InternetAccess  %>% 
         mutate(GEOID=as.character(geoid))

  

#spatial join
Accessmap <- left_join (Metro_sf, Access_df, by = c("GEOID"="GEOID")) 
  
Typologymap$neighborhoodtypeHH[Typologymap$neighborhoodtypeHH==""] <- "NA"
Typologymap$neighborhoodtypeFAM[Typologymap$neighborhoodtypeFAM==""] <- "NA"
Typologymap$neighborhoodtypeHH[Typologymap$neighborhoodtypeHHcode==""] <- "NA"
Typologymap$neighborhoodtypeFAM[Typologymap$neighborhoodtypeFAMcode==""] <- "NA"

#You need to install these if the library after these don't exist'
#install.packages("colorspace")
#install.packages("devtools")
#devtools::install_github("UI-Research/urbnthemes")

library(colorspace)
library(ggplot2)
library(urbnthemes)

boundary <- ggplot()+
  geom_sf(county_sf, mapping=aes(), fill=NA, color="#0a4c6a", size=0.5)+
  theme_urbn_map() +
  coord_sf(crs = 4269, datum = NA)


#overall internet access
ggplot() +
  geom_sf(Accessmap,  mapping = aes(),
          fill = NA, color = "white", size = .05) +
  geom_sf(Accessmap, mapping=aes(fill=pctbroadband)) +
  theme_urbn_map() +
  scale_colour_gradient (limits=c(0,10), low = "red", high = "blue", na.value = "grey50", aesthetics = "colour")+
  scale_fill_gradientn(labels = scales::percent) +
  labs(fill = "Access to Internet and broadband", color = NULL) +
  labs(title = "Percentage have access to broadband internet") + 
  theme(legend.position ="bottom", legend.direction = "vertical", legend.text = element_text(size=8)) +
  coord_sf(crs = 4269, datum = NA)

  # geom_sf(COGcounty_sf, mapping=aes(), fill=NA, color="#12719e", size=0.3, alpha=0.5)+
  # coord_sf(crs = 4269, datum = NA)

#overall internet access
ggplot() +
  geom_sf(Accessmap,  mapping = aes(),
          fill = NA, color = "white", size = .05) +
  geom_sf(Accessmap, mapping=aes(fill=pctbroadband, size = .05)) +
  theme_urbn_map() +
  scale_colour_gradient (limits=c(0,10), low = "red", high = "blue", na.value = "grey50", aesthetics = "colour")+
  scale_fill_gradientn(labels = scales::percent) +
  labs(fill = "Access to Internet and broadband", color = NULL) +
  labs(title = "Percentage have access to broadband internet") + 
  theme(legend.position ="bottom", legend.direction = "vertical", legend.text = element_text(size=8)) +
  coord_sf(crs = 4269, datum = NA)

# geom_sf(COGcounty_sf, mapping=aes(), fill=NA, color="#12719e", size=0.3, alpha=0.5)+
# coord_sf(crs = 4269, datum = NA)


#internet access by race
ggplot() +
  geom_sf(Accessmap,  mapping = aes(),
          fill = NA, color = "white", size = .01) +
  geom_sf(Accessmap, mapping=aes(fill=pctbroadbandw), size = .05) +
  theme_urbn_map() +
  scale_colour_gradient (limits=c(0,10), low = "red", high = "blue", na.value = "grey50", aesthetics = "colour")+
  scale_fill_gradientn(labels = scales::percent) +
  labs(fill = "Access to Internet and broadband", color = NULL) +
  labs(title = "Percentage of white population have access to broadband internet") + 
  theme(legend.position ="bottom", legend.direction = "vertical", legend.text = element_text(size=8)) +
  coord_sf(crs = 4269, datum = NA)+
  ggsave("D:/DCData/Libraries/Requests/Prog/2019/Broadbandaccess_white.pdf", device = cairo_pdf)

ggplot() +
  geom_sf(Accessmap,  mapping = aes(),
          fill = NA, color = "white", size = .01) +
  geom_sf(Accessmap, mapping=aes(fill=pctbroadbandb), size = .05) +
  theme_urbn_map() +
  scale_colour_gradient (limits=c(0,10), low = "red", high = "blue", na.value = "grey50", aesthetics = "colour")+
  scale_fill_gradientn(labels = scales::percent) +
  labs(fill = "Access to Internet and broadband", color = NULL) +
  labs(title = "Percentage of black population have access to broadband internet") + 
  theme(legend.position ="bottom", legend.direction = "vertical", legend.text = element_text(size=8)) +
  coord_sf(crs = 4269, datum = NA)+
  ggsave("D:/DCData/Libraries/Requests/Prog/2019/Broadbandaccess_black.pdf", device = cairo_pdf)


Accessmap_long <- Accessmap %>%
  select(GEOID, Jurisdiction, metro15, geometry, pctbroadband, pctbroadbanda, 
         pctbroadbandb, pctbroadbandh, pctbroadbandw, pctbroadbandiom) %>% 
  gather(key, value, -GEOID, -Jurisdiction, -metro15, -geometry)

#facet by race
ggplot() +
  geom_sf(Accessmap, mapping=aes(fill=value), size = .05) +
  scale_fill_gradientn(labels = scales::percent) +
  coord_sf(crs = 4269, datum = NA)+
  facet_wrap(~ key) 



