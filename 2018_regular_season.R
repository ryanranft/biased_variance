# Install and load necessary libraries
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
if (!requireNamespace("baseballr", quietly = TRUE)) install.packages("baseballr")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")
if (!requireNamespace("readr", quietly = TRUE)) install.packages("readr")
devtools::install_github(repo = "BillPetti/baseballr", force = TRUE)
if (!requireNamespace("DBI", quietly = TRUE)) install.packages("DBI")
if (!requireNamespace("RSQLite", quietly = TRUE)) install.packages("RSQLite")

library(devtools)
library(baseballr)
library(dplyr)
library(lubridate)
library(readr)
library(DBI)
library(RSQLite)

# Set the start and end dates in Central Time Zone
start_date <- as.Date('2018-03-29', tz = "America/Chicago")
end_date <- as.Date('2018-10-01', tz = "America/Chicago")

# Generate a data frame containing all dates from start_date to end_date
date_list <- seq.Date(start_date, end_date, by = "day")
date_df <- data.frame(date = date_list)

# Read the column types file
column_types <- readRDS("/Volumes/files/biased_variance/statcast_column_types.RDS")

# Initialize an empty data frame to store all data
all_data <- tibble()

# Function to scrape data for a given date
scrape_data_for_date <- function(date) {
  tryCatch({
    baseballr::scrape_statcast_savant(start_date = date, end_date = date)
  }, error = function(e) {
    warning(paste("No valid data found or error occurred for date:", date))
    return(NULL)
  })
}

# Loop through each date in the date_df and scrape data
for (i in 1:nrow(date_df)) {
  current_date <- date_df$date[i]
  print(paste("Scraping data for date:", current_date))
  
  # Scrape data and ensure column types match
  daily_data <- scrape_data_for_date(current_date)
  
  # Check if the data frame is not NULL and has rows
  if (!is.null(daily_data) && nrow(daily_data) > 0) {
    all_data <- bind_rows(all_data, daily_data)
  }
}

# Print the final data
print(all_data)

# Define the file paths for saving the CSV and DB files
csv_file_path <- "/Volumes/files/data/mlb/savant/2018/pbp_regular_season_2018.csv"
db_file_path <- "/Volumes/files/data/mlb/savant/2018/pbp_regular_season_2018.db"

# Save the combined data to a CSV file in the specified directory
write_csv(all_data, csv_file_path)

# Save the combined data to a SQLite database in the specified directory
conn <- dbConnect(RSQLite::SQLite(), db_file_path)
dbWriteTable(conn, "all_data", all_data, overwrite = TRUE)
dbDisconnect(conn)

# Save the workspace image
save.image("/Volumes/files/data/mlb/savant/2018/pbp_regular_season_2018.RData")