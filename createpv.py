import pandas as pd

# Load the Excel file
file_path = '/Volumes/files/mlb/savant_daily_data/all/combined_daily_data_frames.xlsx'  # Replace with your file path
data_df = pd.read_excel(file_path)

# Display the first few rows to understand the structure
print(data_df.head())

# Assuming 'pitch_type' and 'value' are columns in your dataframe, 
# calculate the pitch-level value for each pitch
pitch_level_values = data_df.groupby('pitch_type')['value'].mean().reset_index()
pitch_level_values.columns = ['pitch_type', 'pitch_level_value']

# Display the calculated pitch-level values
print(pitch_level_values)

# Normalize the relevant variables
data_sql['release_speed_norm'] = (data_sql['release_speed'] - data_sql['release_speed'].mean()) / data_sql['release_speed'].std()
data_sql['release_spin_norm'] = (data_sql['release_spin'] - data_sql['release_spin'].mean()) / data_sql['release_spin'].std()
data_sql['release_pos_x_norm'] = (data_sql['release_pos_x'] - data_sql['release_pos_x'].mean()) / data_sql['release_pos_x'].std()
data_sql['release_pos_z_norm'] = (data_sql['release_pos_z'] - data_sql['release_pos_z'].mean()) / data_sql['release_pos_z'].std()
data_sql['pfx_x_norm'] = (data_sql['pfx_x'] - data_sql['pfx_x'].mean()) / data_sql['pfx_x'].std()
data_sql['pfx_z_norm'] = (data_sql['pfx_z'] - data_sql['pfx_z'].mean()) / data_sql['pfx_z'].std()
data_sql['plate_x_norm'] = (data_sql['plate_x'] - data_sql['plate_x'].mean()) / data_sql['plate_x'].std()
data_sql['plate_z_norm'] = (data_sql['plate_z'] - data_sql['plate_z'].mean()) / data_sql['plate_z'].std()
data_sql['delta_home_win_exp_norm'] = (data_sql['delta_home_win_exp'] - data_sql['delta_home_win_exp'].mean()) / data_sql['delta_home_win_exp'].std()
data_sql['delta_run_exp_norm'] = (data_sql['delta_run_exp'] - data_sql['delta_run_exp'].mean()) / data_sql['delta_run_exp'].std()

# Assign hypothetical coefficients
a, b, c, d, e, f, g, h, i, j, k = 0.3, 0.25, 0.2, 0.15, 0.1, 0.1, 0.05, 0.05, 0.4, 0.35, 0.1

# Define a function to assign values to event outcomes
def event_outcome_value(event):
    event_dict = {'strikeout': -0.1, 'ball': 0.1, 'hit': 0.2, 'foul': 0.0, 'single': 0.15, 'double': 0.3, 'triple': 0.4, 'home_run': 0.5}
    return event_dict.get(event, 0.0)

# Calculate event outcome values
data_sql['event_outcome_value'] = data_sql['events'].apply(event_outcome_value)

# Calculate the PLV for each pitch
data_sql['PLV'] = (a * data_sql['release_speed_norm'] + 
                   b * data_sql['release_spin_norm'] + 
                   c * data_sql['release_pos_x_norm'] + 
                   d * data_sql['release_pos_z_norm'] + 
                   e * data_sql['pfx_x_norm'] + 
                   f * data_sql['pfx_z_norm'] + 
                   g * data_sql['plate_x_norm'] + 
                   h * data_sql['plate_z_norm'] + 
                   i * data_sql['delta_home_win_exp_norm'] + 
                   j * data_sql['delta_run_exp_norm'] + 
                   k * data_sql['event_outcome_value'])

# Display the first few rows with the calculated PLV
import ace_tools as tools; tools.display_dataframe_to_user(name="Refined Pitch Level Values", dataframe=data_sql[['release_speed', 'release_spin', 'release_pos_x', 'release_pos_z', 'pfx_x', 'pfx_z', 'plate_x', 'plate_z', 'delta_home_win_exp', 'delta_run_exp', 'events', 'PLV']].head())

data_sql[['release_speed', 'release_spin', 'release_pos_x', 'release_pos_z', 'pfx_x', 'pfx_z', 'plate_x', 'plate_z', 'delta_home_win_exp', 'delta_run_exp', 'events', 'PLV']].head()
