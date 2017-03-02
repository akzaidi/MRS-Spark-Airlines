
# EDA ---------------------------------------------------------------------

delay <- airWeatherDF %>% 
  group_by(tailNum) %>%
  summarise(count = n(), 
            dist = mean(distance), 
            delay = mean(as.numeric(arrDelayNew))) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect

# plot delays
library(ggplot2)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area(max_size = 2)


ave_delay_carrier <- airWeatherDF %>% group_by(dayOfWeek, uniqueCarrier) %>% 
  summarise(aveDelay = mean(as.numeric(arrDelayNew))) %>% 
  collect


library(forcats)

ave_delay_carrier <- ave_delay_carrier %>% ungroup() %>% 
  mutate(dayOfWeek = fct_recode(factor(dayOfWeek), 
                                "Monday" = "1",
                                "Tuesday" = "2",
                                "Wednesday" = "3",
                                "Thursday" = "4",
                                "Friday" = "5",
                                "Saturday" = "6",
                                "Sunday" = "7"))

ggplot(ave_delay_carrier) + 
  geom_bar(aes(x = dayOfWeek, 
               y = aveDelay,
               fill = uniqueCarrier),
           stat = 'identity') +
  facet_wrap(~uniqueCarrier) + 
  coord_flip() + theme_minimal() + guides(fill = FALSE) +
  labs(title = "Average Delay by Carrier and Day of Week",
       subtitle = "(minutes)",
       xlab = "Minutes",
       ylab = "Carrier")



# WebGL Routes Visualization ----------------------------------------------

system("wget https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat")

airports <- read.table("airports.dat", header = F, sep = ",")

airportsDF <- copy_to(sc, airports, "airports")
airportsDF <- rename(airportsDF,
                     airportID = V1,
                     airportName = V2,
                     City = V3,
                     Country = V4, 
                     airportIATA = V5, 
                     airportICAO = V6, 
                     latitude = V7,
                     longitude = V8,
                     altitude = V9,
                     timezone = V10,
                     DST = V11,
                     TZdb = V12,
                     Type = V13,
                     Source = V14)

origins <- left_join(airWeatherDF %>% select(originAirportId),
                     airportsDF %>% select(airportID, airportName, longitude, latitude),
                     by = c("originAirportId" = "airportID"))

dest <- left_join(airWeatherDF %>% select(destAirportId), 
                  airportsDF %>% select(airportID, airportName, longitude, latitude),
                  by = c("destAirportId" = "airportID"))

origin_tbl <- origins  %>% collect
dest_tbl <- dest  %>% collect
codes <- bind_cols(origin_tbl, dest_tbl) %>% repair_names
codes <- codes %>% filter(!is.na(airportID), !is.na(airportID1))

flights <- codes %>% select(latitude, longitude, latitude1, longitude1)

library(threejs)

earth <- system.file("images/world.jpg",  package="threejs")

globejs(img=earth, arcs=flights,
        arcsHeight=0.3, arcsLwd=2, arcsColor="#ffff00", arcsOpacity=0.15,
        atmosphere=TRUE)