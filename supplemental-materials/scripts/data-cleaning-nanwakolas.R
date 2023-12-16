###############################################################################
#file loading and wrangling
###############################################################################
#Sowder, C., & Steel, E. A. (2012). A note on the collection and cleaning of water temperature data. Water, 4(3), 597-606.
#https://www.fs.usda.gov/rm/pubs_other/rmrs_2014_stamp_j001.pdf#%5B%7B%22num%22%3A145%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C70%2C720%2C0%5D


lapply(c("tidyverse", "lubridate", "reshape", "stringr", "plotly", "roll", "data.table", "knitr", "scales","kableExtra"), library, character.only = TRUE)


# Load data - read headers
fileheaders <- read.csv("heydon-2023-qc.csv",
                        nrows = 1, as.is = TRUE,
                        header = FALSE)
# Read in data, drop redundant header rows
df <- read.csv("heydon-2023-qc.csv",
               header = FALSE,
               skip = 4,
               stringsAsFactors = FALSE)

# Add headers to dataframe
colnames(df) <- fileheaders
names(df)
glimpse(df)

colnames(df)[1] <- "date"
df$date<-as.POSIXct(df$date,format="%Y-%m-%d %H:%M")

#check structure
str(df)


remove unnecessary columns
df1 <- df %>%
  select(matches("flag|avg|level|date")) %>%
  select( -contains("unesco"))

colnames(df1) <- tolower(colnames(df1))
colnames(df1) <- str_replace_all(colnames(df1), "_q_flags", "_qflag_extended")
colnames(df1) <- str_replace_all(colnames(df1), "depth", "depth_")
colnames(df1) <- str_replace_all(colnames(df1), "twtr", "twtr_")
colnames(df1) <- str_replace_all(colnames(df1), "_q_level", "_qlevel")

 
#reorder  columns -- must change per site ie. "heyd2" vs. "lull" etc.
df2 <- df1 %>% 
  select(date, depth_heyd2pt_qlevel, depth_heyd2pt_qflag_extended, depth_heyd2pt_avg, twtr_heyd2pt_qlevel, twtr_heyd2pt_qflag_extended, twtr_heyd2pt_avg, twtr_heyd1_tb1_qlevel, twtr_heyd1_tb1_qflag_extended, twtr_heyd1_tb1_avg)

#split into shortened columns for flags
# Define patterns to match
patterns <- c("AV", "SVC", "SVD", "PV", "MV", "EV")
desired_column_order <- c("date", "depth_heyd2pt_qlevel","depth_heyd2pt_qflag_short", "depth_heyd2pt_qflag_extended", "depth_heyd2pt_avg", "twtr_heyd2pt_qlevel","twtr_heyd2pt_qflag_short", "twtr_heyd2pt_qflag_extended","twtr_heyd2pt_avg", "twtr_heyd1_tb1_qlevel","twtr_heyd1_tb1_qflag_short", "twtr_heyd1_tb1_qflag_extended","twtr_heyd1_tb1_avg")


# Create a new column 'qflag_short' based on above pattern matching
df3 <- df2 %>%
  mutate(depth_heyd2pt_qflag_short = str_extract(depth_heyd2pt_qflag_extended, paste(patterns, collapse = "|")),
         twtr_heyd2pt_qflag_short = str_extract(twtr_heyd2pt_qflag_extended, paste(patterns, collapse = "|")),
         twtr_heyd1_tb1_qflag_short = str_extract(twtr_heyd1_tb1_qflag_extended, paste(patterns, collapse = "|"))) %>% 
  # Reorder columns programmatically
  select(desired_column_order)


# Display the resulting data frame
print(df3)

#write to csv
write.csv(df3,"heydon-2023-cleaned.csv")


####################################################################################################################################################################################################################################################
#the chunks of code below are extra, and  have not been directly used in QC but may be helpful to the user for exploration


#change column names

colnames(df2) <- str_replace_all(colnames(df2), "_Q_flags", "_qflag")
colnames(df2) <- str_replace_all(colnames(df2), "Depth", "depth_")
colnames(df2) <- str_replace_all(colnames(df2), "TWtr", "twtr_")
colnames(df) <- tolower(colnames(df))


#add back in quality level
df_old <- df_old %>%
  mutate(quality_level = case_when(
    grepl("ev", quality_flag) ~ 3,
    !grepl("ev", quality_flag) & !is.na(quality_flag) ~ 2,
    is.na(quality_flag) ~ 1,
    TRUE ~ NA_real_
  ))

# Use lapply to split the data by year
yearly_data <- lapply(split(df, format(df$Date, "%Y")), function(x) x)

# Now, yearly_data is a list where each element is a dataframe for a specific year
# Access a specific year's dataframe, for example, 2020
#year_2020 <- yearly_data$`2020`

# If you want to store each year's dataframe as a separate variable (optional)
#list2env(yearly_data, envir = .GlobalEnv)


###############################
# Function to calculate percentiles and apply quality control
calculate_and_qc <- function(df, year) {
  # Calculate lower and upper 5th percentiles
  lower_5th_percentile <- quantile(df$TWtr2SSN626US_Avg, 0.05, na.rm = TRUE)
  upper_5th_percentile <- quantile(df$TWtr2SSN626US_Avg, 0.95, na.rm = TRUE)
  
  # Store percentiles for the current year
  percentiles <- data.frame(year = year,
                            lower_5th = lower_5th_percentile,
                            upper_5th = upper_5th_percentile)
  
  # Print the results
  print(paste("Lower 5th Percentile:", lower_5th_percentile))
  print(paste("Upper 5th Percentile:", upper_5th_percentile))
  
  # Quality control
  df_qc <- df %>% 
    mutate(qflag = case_when(
      is.na(TWtr2SSN626US_Avg) ~ "MV: QC'd by EH",
      TWtr2SSN626US_Avg >= 30 ~ "SVC: Max temp: QC'd by EH",
      TWtr2SSN626US_Avg < 0 ~ "SVC: Min temp: QC'd by EH",
      WtrLvl2SN626US_Avg < 0.03 ~ "SVC: Dewatering potential, WtrLvl < 0.03 m: QC'd by EH",
      TWtr2SSN626US_Avg == TAirSSN626_Avg ~ "SVC: Dewatering potential, TAir = Twtr: QC'd by EH",
      TWtr2SSN626US_Avg >= upper_5th_percentile ~ "SVC: Exceeds upper 5th percentile: QC'd by EH",
      TWtr2SSN626US_Avg <= lower_5th_percentile ~ "SVC: Less than lowest 5th percentile: QC'd by EH",
      abs(TWtr2SSN626US_Avg - lag(TWtr2SSN626US_Avg)) < 0.01 & abs(lead(TWtr2SSN626US_Avg, 30) - TWtr2SSN626US_Avg) < 0.01 ~ "PV: QC'd by EH",
      TRUE ~ "AV: QC'd by EH"
    ))
  
  df_long_qc <- df_qc %>% 
    select(Date, qflag, contains("TWtr2") & contains("Avg")) 
  

  # Count occurrences of AV, SVD, SVC, MV, and PV
  counts <- df_long_qc %>%
    group_by(qflag) %>%
    summarise(count = n())
  
  # Add the year to the counts data frame
  counts$year <- year
  
  print("Counts:")
  print(counts)
  
  # Convert Date column to character format with specified date and time format
  df_long_qc$Date <- format(df_long_qc$Date, "%Y-%m-%d %H:%M:%S")
  
  # Writing each dataframe to a separate CSV file
  write_csv(df_long_qc, paste("SSN626-twtr-", year, "-qc.csv", sep=""),
            col_names = TRUE, na = "")
  
 
   # Writing each dataframe to a separate CSV file with specified date format
  write_csv(df_long_qc, paste("SSN626-twtr-", year, "-qc.csv", sep=""))
  
  
  
  # Return the counts for the current year
  return(counts)
}

# Apply the function to each yearly dataframe
counts_list <- lapply(names(yearly_data), function(year) calculate_and_qc(yearly_data[[year]], year))

# Convert the list of counts to a dataframe
counts_df <- do.call(rbind, counts_list)

# Print or save the counts dataframe
print(counts_df)

# Save the counts dataframe to a CSV file
write_csv(counts_df, "counts_by_year.csv")

# Create a summary table
summary_df <- counts_df %>%
  group_by(year) %>%
  summarize(total_flags = sum(count)) %>%
  left_join(counts_df, by = "year") %>%
  mutate(percent_proportion = (count / total_flags) * 100) 


write_csv(summary_df,"summary_df.csv")

