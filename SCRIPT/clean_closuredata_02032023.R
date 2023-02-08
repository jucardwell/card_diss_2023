##load libraries
library(tidyverse)
library(sf)
library(tmap)
library(lubridate)
library(sp)
library(rgdal)
library(geosphere)
library(purrr)
library(ivs)
library(sfnetworks)
library(sp)
library(igraph)
library(tidygraph)

##read in closure data
TIMS_data <- read_csv("../../DISS_DATA_SP2023/deepsearch_weather_02082022.csv")

TIMS_data_datetime <- TIMS_data %>% mutate(updated_start_time = strptime(`StartTime (EST)`, format = "%m/%d/%Y %I:%M:%S %p", tz ="EST"), 
                                                 updated_end_time = strptime(`EndTime (EST)`, format = "%m/%d/%Y %I:%M:%S %p", tz ="EST"), 
                                                 day = format(updated_start_time, "%Y-%m-%d"), dur = as.numeric(updated_end_time-updated_start_time,"days"))

##get a list of unique clusters
list_events <- unique(TIMS_data_datetime$IncidentID)

##init blank dataframe
closure_events = data.frame()                                     

#filter out events with just lane closure, etc. (aka no full road closure at any time)
for (value in list_events) {
  filtered_obs <- subset(TIMS_data_datetime, IncidentID == value)
  closure = sum(filtered_obs$ConditionName == 'Road Closed' | filtered_obs$ConditionName == 'Road Impassable' | filtered_obs$ConditionName == 'Road Closed with Detour')
  if (closure > 0) {
    closure_events <- rbind(closure_events,filtered_obs)
  }
}

#aggregate events, take the earliest start and the latest end
agg_closure_events <- closure_events %>% group_by(IncidentID) %>% summarise(start = min(updated_start_time), end = max(updated_end_time), RoadName = first(RoadName), 
                                                                            CommonName = first(CommonName), Direction= first(Direction), CrossStreetName = first(CrossStreetName), 
                                                                            CrossStCommonName = first(CrossStCommonName), Latitude= first(Latitude), ConditionName= first(ConditionName), 
                                                                            IncidentType = first(`Incident Type`), Event = first(Event), EventName = first(EventName), Reason= first(Reason), 
                                                                            day= first(day), dur = first(dur) )
#write aggregated events as a .csv
write_csv(agg_closure_events, "../PROCESSED_DATA/aggregated_closures_02082023.csv")

