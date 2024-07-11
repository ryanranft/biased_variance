# Read the content of the file
file_path <- "/Volumes/files/github/baseballr/R/sc_statcast_search.R"
file_content <- readLines(file_path)

# Find the line that contains the table header separator
header_line <- which(grepl("^#'   \\|:-------------------------------\\|:---------\\|", file_content))[1]

# Set the start line to be the line following the header separator
start_line <- header_line + 1

# Find the line that contains the table footer separator
footer_line <- which(grepl("^#'\\s*$", file_content[(start_line + 1):length(file_content)]))[1] + start_line

#Set the end line to be the line preceding the footer separator
end_line <- footer_line - 1

# Extract the relevant lines containing column names and types
column_lines <- file_content[start_line:end_line]

# Parse the column names and types
columns <- do.call(rbind, lapply(column_lines, function(line) {
  parts <- strsplit(line, "\\|")[[1]]
  col_name <- trimws(parts[2])
  col_type <- trimws(parts[3])
  return(c(col_name, col_type))
}))

# Create a data frame
column_info_df <- data.frame(
  col_name = columns[, 1],
  data_types = columns[, 2],
  stringsAsFactors = FALSE
)

# Print the data frame
print(column_info_df)

# Save the data frame to an RDS file
saveRDS(column_info_df, "/Volumes/files/biased_variance/statcast_column_types.RDS")