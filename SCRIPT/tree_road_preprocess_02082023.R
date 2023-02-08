#load libraries
library(sf)
library(tmap)
library(terra)
library(tidyverse)

#read in data
focus_counties <- st_read("../../DISS_DATA_SP2023/NCDOT_County_Boundaries/FrenchBroad_MPO_Boundaries.shp")
roads <- st_read("../../DISS_DATA_SP2023/NCRouteCharacteristics_SHP/NCRouteCharacteristics.shp")
TCM <- rast("../../DISS_DATA_SP2023/p45_west_20ft_ch_QL1.tif")

#crop and mask TCM to focus counties
cropped_TCM <- crop(TCM, focus_counties)
masked_TCM <- mask(cropped_TCM, focus_counties)
#export
writeRaster(masked_TCM, "../PROCESSED_DATA/focus_counties_TCM_02082023.tif")

#reproject roads to match focus counties (secondary projection was problematic)
roads_reproj <- st_transform(roads, crs = crs(focus_counties))
#drop zm values
roads_dropped <- st_zm(roads_reproj)

#spatial intersect with focus counties and export
focus_roads <- st_intersection(roads_dropped, focus_counties)
st_write(focus_roads, "../PROCESSED_DATA/focus_roads_02082023.shp")
