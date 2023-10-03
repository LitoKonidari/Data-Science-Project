# In this script, we isolate the last 12 months of data from our file, and save it into a new file.

# ----- Packages & Helper functions Needed ---------------------------------------------------------- 
library(here)
source(here("src","data-cleaning","get_12mo.R"))

# -----Data Loading & Manipulation ------------------------------------------------------------------
# The data provided by the Royal Dutch Meteorological Society API and loaded from the csv file.
# Please put the most recent file here instead of "2023-02-01_induced-earthquakes.csv" for future
# reports. 
data <- read.csv(here("data", "raw","2023-02-01_induced-earthquakes.csv"))
# The name of the file, following the naming convention "YYYY-MM-DD induced-earthquakes.csv".
# Please put the new name of the file for future reports.
file_name <- "2023-02-01_induced-earthquakes.csv"
# The current date, obtained from the file's name.
curr_date <- substr(file_name, 1, 10)
# The date 12 months before the current date.
date_12mo <- get_12mo(curr_date)

# We obtain the dates from our original data and only keep the dates before the curr_date and after (or ewual to) the date_12mo.
# We proceed by saving the data in a new csv file called "2023-02-01_to_2022-02-01_earthquakes.csv" found in data/derived/ 
# in our project. These will be the data used for our monthly report.
dates <- data$date
wanted_dates <- which(curr_date > dates & dates >= date_12mo)
newdata <- data[wanted_dates,]

# For future reports, please change the name of the file from "2023-02-01_to_2022-02-01_earthquakes.csv" to
# "new-date_to_last-year-date_earthquakes.csv", where the dates should be in YYYY-MM-DD format. Specifically, 
# new-date should be the most recent date the API was accessed, and last-year-date the date returned by 
# the get_12mo function, saved in the date_12mo variable.
write.csv(newdata, file = here("data", "derived", "2023-02-01_to_2022-02-01_earthquakes.csv"), row.names = FALSE)

