##################################################################################################
#File loading
#################################################################################################
#load packages -- these are ones used commonly for wx QC
lapply(c("tidyverse", "lubridate", "reshape", "stringr", "plotly", "roll", "data.table", 
         "htmlwidgets"), library, character.only = TRUE)

#set working directory
setwd("/YOUR/FILE/LOCATIONS")

# check your working directory is in the right spot
getwd()

# Load data - read headers
fileheaders <- read.csv("hourly-nanwakolas-all.csv",
                        nrows = 1, as.is = TRUE,
                        header = FALSE)
# Read in data, drop redundant header rows
df <- read.csv("hourly-nanwakolas-all.csv",
               header = FALSE,
               skip = 4,
               stringsAsFactors = FALSE)

# Add headers to dataframe
colnames(df) <- fileheaders
names(df)
glimpse(df)

##############################################################################
#data wrangling
##############################################################################

# Select columns containing "Depth"
depth_columns <- df[grep("Depth", names(df))]
# Create a data frame for Depth
depth_df <- cbind(df["Date"], depth_columns)
# Filter columns containing "Avg" and "Date" for the Depth data
depth_data <- depth_df %>% select(Date, contains("Avg"))


# Define a function to extract the site from column names
extract_site <- function(col_name) {
  gsub(".*(FULL|TUNA|GLEN|HEYD|LULL).*", "\\1", col_name)
}

# Melt the depth data frame to long format
depth_data_long <- gather(depth_data, key = "site_value", value = "Depth", -Date)


# Extract the "Site" from the "site_value" column and create a "Site" column
depth_data_long <- depth_data_long %>%
  mutate(Site = str_extract(site_value, "FULL|TUNA|GLEN|HEYD|LULL")) %>%
  select(-site_value)

depth_data_long$Date <- as.Date(depth_data_long$Date, format = "%Y-%m-%d")


# Select columns containing "TWtr"
twtr_columns <- df[grep("TWtr", names(df))]
# Create a data frame for TWtr
twtr_df <- cbind(df["Date"], twtr_columns)
# Filter columns containing "Avg" and "Date" for the TWtr data
twtr_data <- twtr_df %>% select(Date, contains("Avg"))

# Melt the temp data frame to long format
twtr_data_long <- gather(twtr_data, key = "site_value", value = "Twtr", -Date)


# Extract the "Site" from the "site_value" column and create a "Site" column
twtr_data_long <- twtr_data_long %>%
  mutate(Site = str_extract(site_value, "FULL|TUNA|GLEN|HEYD|LULL")) %>%
  select(-site_value)

twtr_data_long$Date <- as.Date(twtr_data_long$Date, format = "%Y-%m-%d")

# View the resulting data frames
head(depth_data_long)
head(twtr_data_long)

str(twtr_data_long)
glimpse(twtr_data_long)

##############################################################################
#depth fig prep
#############################################################################

# Extract the year from the date
depth_data_long$Year <- format(depth_data_long$Date, "%Y")

# Get unique years
years <- unique(depth_data_long$Year)

# Create a list to store the plots
plots_list_depth <- list()

################################################################################
#depth-plots
################################################################################

# Loop through each year
for (year in years) {
  subset_depth_data_long <- depth_data_long[depth_data_long$Year == year, ]  # Subset the data for the current year
  
  # Create a time series plot for each site in the current year
  plot <- ggplot(subset_depth_data_long, aes(x = Date, y = Depth, color = Site)) +
    geom_line() +
    labs(title = paste("Year:", year)) +
    theme_minimal()
  
  # Convert the ggplot to an interactive plot using plotly
  interactive_plot <- ggplotly(plot)
  
  # Store the interactive plot in the list
  plots_list_depth[[year]] <- interactive_plot
}

# Save the interactive plots as HTML files
for (year in years) {
  saveWidget(plots_list_depth[[year]], file = paste0("water_depth_", year, ".html"))
}

##############################################################################
#twtr fig prep
#############################################################################

# Extract the year from the date
twtr_data_long$Year <- format(twtr_data_long$Date, "%Y")

# Get unique years
years <- unique(twtr_data_long$Year)

# Create a list to store the plots
plots_list_twtr <- list()

################################################################################
#temp-plots
################################################################################

# Loop through each year
for (year in years) {
  subset_twtr <- twtr_data_long[twtr_data_long$Year == year, ]  # Subset the data for the current year
  
  # Create a time series plot for each site in the current year
  plot <- ggplot(subset_twtr, aes(x = Date, y = Twtr, color = Site)) +
    geom_line() +
    labs(title = paste("Year:", year)) +
    theme_minimal()
  
  # Convert the ggplot to an interactive plot using plotly
  interactive_plot <- ggplotly(plot)
  
  # Store the interactive plot in the list
  plots_list_twtr[[year]] <- interactive_plot
}

# Save the interactive plots as HTML files
for (year in years) {
  saveWidget(plots_list_twtr[[year]], file = paste0("water_temperature_", year, ".html"))
}
