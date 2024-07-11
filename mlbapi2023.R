if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
if (!requireNamespace("baseballr", quietly = TRUE)) install.packages("baseballr")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("purrr", quietly = TRUE)) install.packages("purrr")
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")

library(devtools)
library(baseballr)
library(dplyr)
library(purrr)
library(lubridate)

# Create a sequence of dates from 2023-03-30 to 2023-10-01
start_date <- as.Date("2023-03-30")
end_date <- as.Date("2023-10-01")

#Start a data df containing all dates from start_date to end_date
date_list <- seq.Date(start_date, end_date, by = "day")
date_df <- data.frame(date = date_list)

# Function to retrieve game data for a given date
get_games_for_date <- function(date = start_date, date = end_date) {
  game_pks <- get_game_pks_mlb(date)
  if (is.null(game_pks)) {
    return(NULL)
  }
  game_pks
}

# Create a sequence of dates from 2023-03-30 to 2023-10-01
start_date <- as.Date("2023-03-30")
end_date <- as.Date("2023-10-01")
dates <- seq.Date(start_date, end_date, by = "day")

# Retrieve game data for all dates
all_games_2023 <- dates %>%
  map_df(~get_games_for_date(.x))

# Optionally, save the data to a CSV file
write.csv(all_games_2023, "mlb_games_2023.csv", row.names = FALSE)

# Display the first few rows of the data
head(all_games_2023)

