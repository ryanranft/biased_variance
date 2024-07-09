# Load the required packages
library(baseballr)
library(tidyverse)

# Function to scrape data for a given date range
scrape_and_combine_2015 <- function(start_date, end_date, player_type) {
  print(paste("Scraping data for", start_date, "to", end_date))
  data <- baseballr::scrape_statcast_savant(start_date = start_date,
                                            end_date = end_date,
                                            player_type = player_type)
  return(data)
}

# Define the start and end dates for the 2015 season
start_date <- as.Date('2015-04-05')
end_date <- as.Date('2015-10-04')

# Generate a sequence of dates from start_date to end_date
date_ranges_2015 <- lapply(seq(start_date, end_date, by = "day"), function(date) {
  list(start_date = as.character(date), end_date = as.character(date))
})

# Initialize list to store data frames for each day
daily_data_frames_2015 <- list()

# Loop through each date range, scrape data, and store in daily data frames
for (date_range in date_ranges_2015) {
  start_date <- date_range$start_date
  end_date <- date_range$end_date
  
  # Scrape data for current date range
  data_2015 <- scrape_and_combine_2015(start_date = start_date,
                                       end_date = end_date,
                                       player_type = 'batter')
  
  # Store data in a data frame
  daily_data_frames_2015[[start_date]] <- data_2015
}

# Print the first few elements of the list to verify
head(daily_data_frames_2015)

#save the data
#save.image("regular_season.RData")

#find where the save will be
getwd() #should be /Volumes/files/mlb/savant_daily_data/2015
setwd('/Volumes/files/mlb/savant_daily_data/2015')
getwd()


# Load the RData file
load("regular_season.RData")

# Verify the loaded objects
print(ls())

# Inspect the structure of daily_data_frames_2015
print(str(daily_data_frames_2015))

# Function to standardize list items to a consistent structure
standardize_list_item <- function(item) {
  # Ensure item is a dataframe
  item <- as.data.frame(item)
  
  # Add missing columns with NA values
  all_columns <- unique(unlist(lapply(daily_data_frames_2015, names)))
  missing_columns <- setdiff(all_columns, names(item))
  for (col in missing_columns) {
    item[[col]] <- NA
  }
  
  # Reorder columns to match the overall structure
  item <- item[all_columns]
  
  return(item)
}

# Standardize each list item
daily_data_frames_2015 <- lapply(daily_data_frames_2015, standardize_list_item)

# Combine the standardized list items into a single dataframe
daily_data_frames_2015 <- do.call(rbind, daily_data_frames_2015)

# Verify the structure
print(str(daily_data_frames_2015))

# Load necessary libraries
library(DBI)
library(RSQLite)

# Create a connection to a new SQLite database
conn <- dbConnect(RSQLite::SQLite(), "daily_data_frames_2015.db")

# Write the dataframe to the database
dbWriteTable(conn, "daily_data_frames_2015", daily_data_frames_2015)

# List the tables in the database to confirm the operation
print(dbListTables(conn))

# Disconnect from the database
dbDisconnect(conn)

