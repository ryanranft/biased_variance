# Load necessary libraries
library(readxl)
library()
library(RSQLite)
library(dplyr)
library(ggplot2)

# Define the database file path
db_file_path <- "/Volumes/files/mlb/savant_daily_data/all/combined_daily_data_frames.db"

# Connect to the SQLite database
con <- dbConnect(SQLite(), dbname = db_file_path)

# List all tables in the database (optional, to check the table names)
tables <- dbListTables(con)
print(tables)

# Retrieve data from 2017 and beyond
query <- "SELECT * FROM daily_data_frames WHERE game_year >= 2017"
data <- dbGetQuery(con, query)

# Create the new variables
data <- data %>%
  mutate(
    x0 = release_pos_x,
    y0 = 60.5 - release_extension,
    z0 = release_pos_z,
    yf = 17/12,
    vyR = -sqrt(vy0^2 + 2 * ay * (y0 - 50)),
    tR = (vyR - vy0) / ay,
    vxR = vx0 + ax * tR,
    vzR = vz0 + az * tR,
    release_speed = sqrt(vxR^2 + vyR^2 + vzR^2) * 0.6818,
    release_angle = atan(vzR / sqrt(vxR^2 + vyR^2)) * 57.3,
    release_direction = atan(-vxR / vyR) * 57.3,
    vy_f = -sqrt(vy0^2 - (2 * ay * (50 - yf))),
    t = (vy_f - vy0) / ay,
    vz_f = vz0 + (az * t),
    VAA = -atan(vz_f / vy_f) * (180 / pi)
  )

#x0 =	Horizontal Release Position of the ball measured in feet from the catcher's perspective. The variable release_point_x is how far the pitcher’s hand is laterally from the center of the rubber with values to the pitcher’s left being positive. Sidearm pitchers like Chris Sale will have a greater average release_point_x (3.3 feet in 2018) than more over-the-top pitchers like San Diego’s Joey Lucchessi (2.1 feet in 2018).
#release_extension = Release extension of pitch in feet as tracked by Statcast. This tells us how far the pitcher was in feet from the pitchers mound in the direction of home plate when he released the ball.
#y0 = distance in feet from home plate the pitcher was when he released the ball
#z0 =  the height of a pitcher’s release in feet above the ground. A submarine pitcher will obviously have a lower average value here than a conventional pitcher. For fun, let’s look at the extreme low (Cimber, 2.1 feet on average in 2018) and the extreme high (Josh Collmenter, 7 feet on average in 2017).
#More info on the above and animated pictures detailing variables read https://medium.com/something-tangible/do-release-points-change-for-different-pitch-types-cb2b0588ef0a
#vy0 = The velocity of the pitch, in feet per second, in y-dimension, determined at y=50 feet.
#ay = The acceleration of the pitch, in feet per second per second, in y-dimension, determined at y=50 feet.
#vyR = The velocity of the pitch, in feet per second, in y-dimension, determined at release point in feet.


# Create the scatter plot with corrected color aesthetic
ggplot(data, aes(x = VAA, y = release_pos_z)) +
  geom_point(aes(color = factor(pitch_type)), alpha = 0.5) +
  geom_hline(yintercept = c(1.5, 3.5), linetype = "solid", color = "black") +
  theme_minimal() +
  labs(title = "Vertical Approach Angle (VAA) vs. Pitch Height",
       x = "VAA (degrees)",
       y = "Pitch Height (feet)") +
  scale_color_viridis_d()  # Use the viridis palette that can handle multiple colors

# Save the plot
ggsave("VAA_vs_Pitch_Height.png")

# Save the processed data to a CSV file
write.csv(data, "processed_pitch_data.csv", row.names = FALSE)

