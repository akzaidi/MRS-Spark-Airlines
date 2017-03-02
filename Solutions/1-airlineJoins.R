library(sparklyr)
library(tidyverse)


# Configure cluster (D13v2large 56G 8core 400GBdisk) ----------------------


conf <- spark_config()
conf$'sparklyr.shell.executor-memory' <- "16g"
conf$'sparklyr.shell.driver-memory' <- "16g"
conf$spark.executor.cores <- 4
conf$spark.executor.memory <- "16G"
conf$spark.yarn.am.cores  <- 4
conf$spark.yarn.am.memory <- "16G"
conf$spark.dynamicAllocation.enabled <- "false"
conf$spark.default.parallelism <- 8


# Connect to cluster ------------------------------------------------------


sc <- spark_connect(master = "yarn-client", config = conf)



# Load Data to Spark DataFrames -------------------------------------------


airlineDF <- spark_read_csv(sc = sc, 
                            name = "airline",
                            path = "/FlightData/AirlineSubsetCsv", 
                            header = TRUE, 
                            infer_schema = TRUE, 
                            null_value = "null")

weatherDF <- spark_read_csv(sc = sc, 
                            name = "weather",
                            path = "/FlightData/WeatherSubsetCsv",
                            header = TRUE,
                            infer_schema = TRUE,
                            null_value = "null")



# Rename Airline Columns --------------------------------------------------


library(stringr)

airNames <- colnames(airlineDF)
newNames <- gsub('\\_(\\w?)', '\\U\\1', tolower(airNames), perl=T)

airlineDF <- airlineDF %>% setNames(newNames)




# Join --------------------------------------------------------------------


# Select desired columns from the flight data. 

varsToKeep <- c("arrDel15", "year", "month", "dayOfMonth", 
                "dayOfWeek", "uniqueCarrier", "originAirportId", 
                "destAirportId", "crsDepTime", "crsArrTime",
                "tailNum", "distance", "arrDelayNew")

airlineDF <- select_(airlineDF, .dots = varsToKeep)

airlineDF <- airlineDF %>% mutate(crsDepTime = floor(crsDepTime / 100))

weatherSummary <- weatherDF %>% 
  group_by(AdjustedYear, AdjustedMonth, AdjustedDay, AdjustedHour, AirportID) %>% 
  summarise(Visibility = mean(Visibility),
            DryBulbCelsius = mean(DryBulbCelsius),
            DewPointCelsius = mean(DewPointCelsius),
            RelativeHumidity = mean(RelativeHumidity),
            WindSpeed = mean(WindSpeed),
            Altimeter = mean(Altimeter))

#######################################################
# Join airline data with weather at Origin Airport
#######################################################

originDF <- left_join(x = airlineDF,
                      y = weatherSummary,
                      by = c("originAirportId" = "AirportID",
                             "year" = "AdjustedYear",
                             "month" = "AdjustedMonth",
                             "dayOfMonth"= "AdjustedDay",
                             "crsDepTime" = "AdjustedHour"))



# Remove redundant columns ------------------------------------------------

vars <- colnames(originDF)
varsToDrop <- c('AdjustedYear', 'AdjustedMonth', 'AdjustedDay', 'AdjustedHour', 'AirportID')
varsToKeep <- vars[!(vars %in% varsToDrop)]

originDF <- select_(originDF, .dots = varsToKeep)

originDF <- originDF %>% rename(VisibilityOrigin = Visibility,
                                DryBulbCelsiusOrigin = DryBulbCelsius,
                                DewPointCelsiusOrigin = DewPointCelsius,
                                RelativeHumidityOrigin = RelativeHumidity,
                                WindSpeedOrigin = WindSpeed,
                                AltimeterOrigin = Altimeter)

#######################################################
# Join airline data with weather at Destination Airport
#######################################################

destDF <- left_join(x = originDF,
                    y = weatherSummary,
                    by = c("destAirportId" = "AirportID",
                           "year" = "AdjustedYear",
                           "month" = "AdjustedMonth",
                           "dayOfMonth"= "AdjustedDay",
                           "crsDepTime" = "AdjustedHour"))



# Rename Columns and Drop Reduncies ---------------------------------------

vars <- colnames(destDF)
varsToDrop <- c('AdjustedYear', 'AdjustedMonth', 'AdjustedDay', 'AdjustedHour', 'AirportID')
varsToKeep <- vars[!(vars %in% varsToDrop)]
airWeatherDF <- select_(destDF, .dots = varsToKeep)

airWeatherDF <- rename(airWeatherDF,
                       VisibilityDest = Visibility,
                       DryBulbCelsiusDest = DryBulbCelsius,
                       DewPointCelsiusDest = DewPointCelsius,
                       RelativeHumidityDest = RelativeHumidity,
                       WindSpeedDest = WindSpeed,
                       AltimeterDest = Altimeter)

airWeatherDF <- airWeatherDF %>% sdf_register("flightsweather")

tbl_cache(sc, "flightsweather")
