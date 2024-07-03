# Load the required packages
library(baseballr)
library(tidyverse)

# Function to scrape data for a given date range
scrape_and_combine_2022 <- function(start_date, end_date, player_type) {
  print(paste("Scraping data for", start_date, "to", end_date))
  data <- baseballr::scrape_statcast_savant(start_date = start_date,
                                            end_date = end_date,
                                            player_type = player_type)
  return(data)
}

# Define the start and end dates for the 2022 season
start_date <- as.Date('2022-04-07')
end_date <- as.Date('2022-10-05')

# Generate a sequence of dates from start_date to end_date
date_ranges_2022 <- lapply(seq(start_date, end_date, by = "day"), function(date) {
  list(start_date = as.character(date), end_date = as.character(date))
})

# Initialize list to store data frames for each day
daily_data_frames_2022 <- list()

# Loop through each date range, scrape data, and store in daily data frames
for (date_range in date_ranges_2022) {
  start_date <- date_range$start_date
  end_date <- date_range$end_date
  
  # Scrape data for current date range
  data_2022 <- scrape_and_combine_2022(start_date = start_date,
                                       end_date = end_date,
                                       player_type = 'batter')
  
  # Store data in a data frame
  daily_data_frames_2022[[start_date]] <- data_2022
}

# Print the first few elements of the list to verify
head(daily_data_frames_2022)

#find where the save will be
getwd() #should be /Volumes/files/mlb/savant_daily_data/2022

#if not in proper wd
setwd("/Volumes/files/mlb/savant_daily_data/2022")
getwd()

#save the data
#save.image("regular_season.RData")

