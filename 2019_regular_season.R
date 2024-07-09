# Install necessary packages
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
library(devtools)
if (!requireNamespace("tidyverse", quietly = TRUE)) install.packages("tidyverse")
library(tidyverse)
install_github("BillPetti/baseballr")
if (!requireNamespace("DBI", quietly = TRUE)) install.packages("DBI")
library(DBI)
if (!requireNamespace("RSQLite", quietly = TRUE)) install.packages("RSQLite")
library(RSQLite)
if (!requireNamespace("git2r", quietly = TRUE)) install.packages("git2r")
library(git2r)
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")
library(lubridate)

# Function to scrape data for a given date range
scrape_data <- function(start_date, end_date) {
  baseballr::scrape_statcast_savant(start_date = start_date, end_date = end_date, player_type = 'batter')
}

# Function to extract column types from sch_label_statcast_imputed_data.R
get_column_types <- function(file_path) {
  lines <- readLines(file_path)
  column_types <- list()
  
  for (line in lines) {
    if (grepl("<-", line)) {
      parts <- strsplit(line, "<-")[[1]]
      column_name <- str_trim(parts[1])
      if (grepl("as\\.numeric", parts[2])) {
        column_types[[column_name]] <- as.numeric
      } else if (grepl("as\\.character", parts[2])) {
        column_types[[column_name]] <- as.character
      } else if (grepl("as\\.Date", parts[2])) {
        column_types[[column_name]] <- as.Date
      } else if (grepl("as\\.integer", parts[2])) {
        column_types[[column_name]] <- as.integer
      } else if (grepl("as\\.logical", parts[2])) {
        column_types[[column_name]] <- as.logical
      }
    }
  }
  return(column_types)
}

# Function to apply the correct data types to a dataframe
apply_column_types <- function(df, column_types) {
  for (col in names(column_types)) {
    if (col %in% colnames(df)) {
      df[[col]] <- column_types[[col]](df[[col]])
    }
  }
  return(df)
}

# Path to sch_label_statcast_imputed_data.R
sch_label_path <- "/Volumes/files/github/baseballr/R/sch_label_statcast_imputed_data.R"

# Extract column types
column_types <- get_column_types(sch_label_path)

# Set the start and end dates in Central Time Zone
start_date <- as.Date('2019-03-28', tz = "America/Chicago")
end_date <- as.Date('2019-09-29', tz = "America/Chicago")  # Adjust the end date as needed

# Initialize an empty list to store the data
all_data <- list()
error_count <- 0

# Loop through each day in the date range and scrape the data
current_date <- start_date
while (current_date <= end_date) {
  print(paste("Scraping data for:", current_date))
  tryCatch({
    daily_data <- scrape_data(current_date, current_date)
    if (!is.null(daily_data) && nrow(daily_data) > 0) {
      daily_data <- apply_column_types(daily_data, column_types)
      all_data[[as.character(current_date)]] <- daily_data
    } else {
      print(paste("No valid data for:", current_date))
    }
  }, error = function(e) {
    print(paste("Error on date:", current_date, "-", e$message))
    error_count <<- error_count + 1
  })
  current_date <- current_date + days(1)
}

# Print number of errors encountered
print(paste("Number of errors encountered:", error_count))

# Combine all the daily data into one dataframe
SavantData19 <- bind_rows(all_data)

# Ensure all columns have correct data types
SavantData19 <- apply_column_types(SavantData19, column_types)

# Verify the structure
print(str(SavantData19))

# Define the file paths for saving the CSV and DB files
csv_file_path <- "/Volumes/files/data/mlb/savant/2019/pbp_regular_season_2019.csv"
db_file_path <- "/Volumes/files/data/mlb/savant/2019/pbp_regular_season_2019.db"

# Save the combined data to a CSV file in the specified directory
write_csv(SavantData19, csv_file_path)

# Save the combined data to a SQLite database in the specified directory
conn <- dbConnect(RSQLite::SQLite(), db_file_path)
dbWriteTable(conn, "SavantData19", SavantData19, overwrite = TRUE)
dbDisconnect(conn)

# Save the workspace image
save.image("regular_season.RData")

# Example query: Display top HR hitters on pitches 95+ MPH
top_hr_hitters <- SavantData19 %>%
  select(player_name, events, launch_speed, release_speed) %>%
  filter(events == "home_run", release_speed >= 95) %>%
  group_by(player_name) %>%
  summarise(HR = n(), AvgEV = mean(launch_speed)) %>%
  arrange(desc(HR))

print(top_hr_hitters)

# Push the script to GitHub
repo_path <- "/path/to/your/local/repo"
repo <- repository(repo_path)
add(repo, "/Volumes/files/biased_variance/2015_regular_season.R")
commit(repo, "Add 2015_regular_season.R script")
credentials <- cred_user_pass("your_username", "your_personal_access_token")
push(repo, credentials = credentials)