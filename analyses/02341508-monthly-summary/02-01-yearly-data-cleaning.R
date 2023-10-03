# In this script, we clean the last 12 months of observations, to then use the cleaned
# data for the comparative earthquake analysis.

# ----- Packages & Helper functions Needed -----------------------------------------
library(here)
source(here("src","helper-functions","find_mc.R"))

# ----- Data Cleaning --------------------------------------------------------------
# For the data of the past 12 months, we will remove any data that correspond to incomplete 
# observation by keeping only magnitudes bigger than the estimated mc.

# For future reports, please replace the name of the file "2023-02-01_to_2022-02-01_earthquakes.csv"
# to the new file "new-date_to_last-year-date_earthquakes.csv", where the dates should be in
# YYYY-MM-DD format. Specifically, new-date should be the most recent date the API was accessed, and
# last-year-date the date returned by the get_12mo function, saved in the date_12mo variable.
dat <- read.csv(here("data", "derived","2023-02-01_to_2022-02-01_earthquakes.csv"))

# Find the estimated mc for the data.
mc <- find_mc(dat$mag)
complete_mag <- dat$mag[dat$mag > mc]
indcs <- which(dat$mag > mc)
# Keep only the data corresponding to complete observations & save the file for future use.
data <- dat[indcs,]

# For future reports, please change the name of the file from "CLEANED_2023-02-01_to_2022-02-01_earthquakes.csv" to
# "CLEANED_new-date_to_last-year-date_earthquakes.csv", where the dates should be in YYYY-MM-DD format.
write.csv(data, file = here("data", "derived", "CLEANED_2023-02-01_to_2022-02-01_earthquakes.csv"), 
          row.names = FALSE)
