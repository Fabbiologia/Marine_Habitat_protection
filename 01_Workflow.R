# Joy Kumagai and Fabio Favoretto 
# Date: March 2021
# Final Workflow specifying inputs 
# Marine Habitat Protection Indicator

###### All packages used ##### 
# library(tidyverse) # to easily load and use the "tidyverse"
# library(sf) # For handling spatial vector data
library(raster) # For handling spatial raster data
# library(fasterize) # For a faster function to rasterize the habitat data
# library(tools) 
# library(stringr) # to easily sort some datasets 
# library(janitor) # to clean some datasetes
# require(future.apply)

### packages for parallel processing
# library(doParallel)
# library(parallel)
# library(snow)

source("Functions/R_custom_functions.R")

## SELECT NUMBER OF CORES FOR PARALLEL PROCESSING
cores <- 10 # Please Change 

### Regions of interest (Union of EEZ and Land polygons from marineregions.org version 3)

behrmann.crs <- CRS('+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs')
behrmann <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'

### ocean is the file we create the reference grid from (Ocean 110m from https://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-ocean/)
ocean <- read_sf("Data_original/ocean/ne_110m_ocean.shp") #  version 4.1.0

### MPAS February 2021 Protected Planet Public Download
mpa_files <- list.files("Data_original/mpas/", pattern = "\\.shp$", recursive = T, full.names = T)


#### Workflow ####
# Step 1: Cleaning the protected areas, buffering points, and separating into three levels, all, managed, and no-take
source("Scripts/01_ChangingProtectedAreasToPolygons.R")
source("Scripts/02_CleaningProtectedAreas_v1.R")

# Step 2: Rasterizing Polygon Habitats 
source("Scripts/03_RasterizingPolygonHabitats_v2.R")

# Step 3: Raster intersections with protected areas
source("Scripts/04_CombiningHabitatsandMPAs.R")

# Step 4: Summarizing habitat information per boundary 
source("Scripts/05_SummaryStatistics.R")

# Step 5: Summarizing Final Outputs 
source("Scripts/06_PercentageProtectionWorld.R")

source("Scripts/07_PercentageProtectionBoundary.R")

source("Scripts/07_PercentageProtection_HighSeas.R")
       
#### END OF SCRIPT ####

