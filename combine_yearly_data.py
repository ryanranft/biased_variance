import sqlite3
import pandas as pd
import time

# List of database file paths and their respective years (from 2015 to 2024)
database_info = {
    2015: "/Volumes/files/mlb/savant_daily_data/2015/daily_data_frames_2015.db",
    2016: "/Volumes/files/mlb/savant_daily_data/2016/daily_data_frames_2016.db",
    2017: "/Volumes/files/mlb/savant_daily_data/2017/daily_data_frames_2017.db",
    2018: "/Volumes/files/mlb/savant_daily_data/2018/daily_data_frames_2018.db",
    2019: "/Volumes/files/mlb/savant_daily_data/2019/daily_data_frames_2019.db",
    2020: "/Volumes/files/mlb/savant_daily_data/2020/daily_data_frames_2020.db",
    2021: "/Volumes/files/mlb/savant_daily_data/2021/daily_data_frames_2021.db",
    2022: "/Volumes/files/mlb/savant_daily_data/2022/daily_data_frames_2022.db",
    2023: "/Volumes/files/mlb/savant_daily_data/2023/daily_data_frames_2023.db",
    2024: "/Volumes/files/mlb/savant_daily_data/2024/daily_data_frames_2024.db"
}

# Initialize an empty dataframe to hold all data
combined_df = pd.DataFrame()

# Load data from each database and append to the combined dataframe
for year, db_path in database_info.items():
    try:
        print(f"Processing data for year: {year} from database: {db_path}")
        conn = sqlite3.connect(db_path)
        table_name = f"daily_data_frames_{year}"
        df = pd.read_sql_query(f"SELECT * FROM {table_name}", conn)
        combined_df = pd.concat([combined_df, df], ignore_index=True)
        conn.close()
        print(f"Data for year {year} has been added to the combined dataframe. Current combined dataframe shape: {combined_df.shape}")
    except Exception as e:
        print(f"Error processing data for year {year} from database {db_path}: {e}")

# Save the combined data to a new SQLite database with retry logic
combined_db_path = "/Volumes/files/mlb/savant_daily_data/all/combined_daily_data_frames.db"
retries = 5

while retries > 0:
    try:
        conn_combined = sqlite3.connect(combined_db_path)
        combined_df.to_sql("daily_data_frames", conn_combined, if_exists="replace", index=False)
        conn_combined.close()
        print("Data from all yearly databases has been combined and saved to combined_daily_data_frames.db")
        break
    except sqlite3.OperationalError as e:
        retries -= 1
        print(f"Retrying due to database lock. Retries left: {retries}. Error: {e}")
        time.sleep(5)  # Wait for 5 seconds before retrying
    except Exception as e:
        print(f"Error saving combined dataframe to database: {e}")
        break
