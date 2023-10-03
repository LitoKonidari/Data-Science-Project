# ----- Packages & Helper functions Needed -----------------------------------------
library(ggplot2)
library(showtext)
library(here)
library(lubridate)
library(ggrepel)
library(xtable)
library(tidyverse)
# Loading fonts for plots
font_add_google(name = "Montserrat", family = "Montserrat") 
showtext_auto()

# ----- Comparative Data Analysis --------------------------------------------------
# In this analysis, we explore the earthquake activity in the last month of our data compared 
# to the average behaviour in the 11 months preceding that. 

# We will use the cleaned data for the last 12 months of observations, meaning the completed observations
# of magnitudes.

# For future reports, please replace the name of the file "CLEANED_2023-02-01_to_2022-02-01_earthquakes.csv"
# to the new file "CLEANED_new-date_to_last-year-date_earthquakes.csv", where the dates should be in
# YYYY-MM-DD format.
dat <- read.csv(here("data", "derived","CLEANED_2023-02-01_to_2022-02-01_earthquakes.csv"))

# Separate data 

# We find the date 10 months after the earliest date of our data; this is the latest month we have data for.
date_11_months <- min(ymd(dat$date))%m+%months(10)
# We separate our data into the data of the 1 latest month (data_1) and the data of the 11 months preceding that
# (data_11).
data_11 <- dat[dat$date < ymd(date_11_months),]
data_1 <- dat[dat$date >= ymd(date_11_months),]

# ----- Bubble Plots ---------------------------------------------------------------

# We will plot 2 bubble plots for the last month & preceding 11 months respectively, that
# present the earthquake activity and more specifically the earthquake locations, counts
# and magnitudes. For the locations, we use the location names as well as their latitudes and
# londitudes.

# ----- Bubble Plot for the last month ---------------------------------------------

# Counts of earthquakes per place.
counts_per_place1 <- aggregate(mag ~ place, data = data_1, FUN = length)

df1 <- data.frame(Magnitude = data_1$mag, place = data_1$place,
                    lon = data_1$lon, lat = data_1$lat, counts = counts_per_place1$mag)

bubble1 <- ggplot(df1, aes(x = lat,y = lon, size = counts, color = Magnitude)) +
             geom_point(alpha = 0.7) +
             scale_size(range = c(1, 10)) +
             geom_text_repel(aes(label = place), size = 5, nudge_x = -0.03) +
             labs(title = paste0("Bubble plot of the earthquake activity from the last month"), 
                  x = "latitude", y = "longitude") +
             theme(plot.title = element_text(hjust = 0.5, size = 17),
                   text = element_text(family = "Montserrat"),
                   axis.title = element_text(size = 12),
                   legend.title = element_text(size = 12),
                   legend.text = element_text(size = 12)) +
             scale_color_gradient2(high = "blue", mid = "coral", low = "pink") +
             theme_classic()

# Save the plot in /outputs/02341508-monthly-summary/figures.
ggsave(here("outputs", "02341508-monthly-summary", "figures", "02-01-bubble-plot-1.pdf"), plot = bubble1,
       width = 6, height = 5)

# ----- Bubble Plot for the preceding 11 months ------------------------------------
# When dealing with the data from the preceding 11 months, we will investigate the average
# earthquake activity as we have many more observations. This means that we will take the 
# mean longitude & latitude for every place to find the average centre of earthquakes for each place.
# Additionally, we will compute the mean magnitude of the earthquakes happening in each place, as well
# as the counts.

counts_per_place11 <- aggregate(mag ~ place, data = data_11, FUN = length)

# Mean latitude of every place
sum_lat_per_place11 <- aggregate(lat ~ place, data = data_11, FUN = sum)
mean_lat_per_place11 <- sum_lat_per_place11$lat/counts_per_place11$mag

# Mean longitude of every place
sum_lon_per_place11 <- aggregate(lon ~ place, data = data_11, FUN = sum)
mean_lon_per_place11 <- sum_lon_per_place11$lon/counts_per_place11$mag

# Mean magnitude of the earthquakes in every place
sum_mag_per_place11 <- aggregate(mag ~ place, data = data_11, FUN = sum)
mean_mag_per_place11 <- sum_mag_per_place11$mag/counts_per_place11$mag

df11 <- data.frame(Magnitude = mean_mag_per_place11, place = counts_per_place11$place,
                  lon = mean_lon_per_place11, lat = mean_lat_per_place11, counts = counts_per_place11$mag)


bubble11 <- ggplot(df11, aes(x = lat,y= lon, size = counts, color = Magnitude)) +
              geom_point(alpha = 0.7) +
              scale_size(range = c(1, 10)) +
              # For future reports, the nudge_x & nudge_y values could potentially need a bit of tuning
              # so that the labels don't overlap; nudge_x controls the movement along the x axis and
              # nudge_y the movement in the y axis.
              geom_text_repel(aes(label = place), size = 5, nudge_y = 0.014) +
              labs(title = "Bubble plot of the average earthquake activity from \nthe preceding 11 months", 
                   x = "latitude", y = "longitude") +
              theme(plot.title = element_text(hjust = 0, size = 17),
                    axis.title = element_text(size = 12),
                    legend.title = element_text(size = 12),
                    legend.text = element_text(size = 12)) +
              scale_color_gradient2(name = "Mean magnitude", high = "blue", mid = "coral", low = "pink") +
              theme_classic()

# Save the plot in /outputs/02341508-monthly-summary/figures.
ggsave(here("outputs", "02341508-monthly-summary", "figures", "02-02-bubble-plot-2.pdf"), plot = bubble11,
       width = 6, height = 5)

# ----- Earthquake Activity per month ----------------------------------------------

# Now, we will make a table that encompasses the earthquake counts and magnitudes for
# each month of the pasrt year. For the magnitudes, we will compute the minimum and maximum
# value as well as the mean, for each month.

mo <- month(ymd(dat$date))

# Earthquake counts per month
counts_per_month <- aggregate(mag ~ mo, data = dat, FUN = length)
# Minimum magnitude per month
min_mag_per_month <- aggregate(mag ~ mo, data = dat, FUN = min)
# Maximum magnitude per month
max_mag_per_month <- aggregate(mag ~ mo, data = dat, FUN = max)
# Mean magnitude per month
mean_mag_per_month <- aggregate(mag ~ mo, data = dat, FUN = mean)

# Before making our table, we will fill in the missing months with zero values.
all_months <- 1:12

complete_counts <- counts_per_month %>%
  complete(mo = all_months, fill = list(mag = 0))

complete_min <- min_mag_per_month %>%
  complete(mo = all_months, fill = list(mag = 0))

complete_max <- max_mag_per_month %>%
  complete(mo = all_months, fill = list(mag = 0))

complete_mean <- mean_mag_per_month %>%
  complete(mo = all_months, fill = list(mag = 0))

# Now, we are ready to make our table.

Months <- month.abb[complete_counts$mo]
counts <- complete_counts$mag
min <- complete_min$mag
max <- complete_max$mag
mean <- complete_mean$mag

data_month <- rbind("counts" = counts, "min mag"= min, "mean mag" = mean, "max mag" = max)
colnames(data_month) <- Months

output_table <- xtable(data_month, caption="Table showing the monthly earthquake activity for the past
                       12 months.", label = "tab1")

# Save this table in /outputs/02341508-monthly-summary/tables.
print(output_table, file = here("outputs", "02341508-monthly-summary", "tables", 
                                "02-01-monthly-table-2023.tex"))

# Some last measurements
length(data_11$mag)
# 35 earthquakes in total in the 11 prior months
length(which(data_11$mag > 3))
# only 1 had a magnitude over 3.


