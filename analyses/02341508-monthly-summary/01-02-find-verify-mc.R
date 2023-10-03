# In this script, we use the last 12 months of earthquakes to select a value for mc and verify 
# graphically that above the chosen value observation appears to be complete.

# ----- Packages, Helper functions Needed ------------------------------------------------
library(ggplot2)
library(showtext)
library(here)
source(here("src","helper-functions","find_mc.R"))
# Loading fonts for plots
font_add_google(name = "Montserrat", family = "Montserrat") 
showtext_auto()

#------ Selecting a value for the mc -----------------------------------------------------

# For future reports, please replace the name of the file "2023-02-01_to_2022-02-01_earthquakes.csv"
# to the new file "new-date_to_last-year-date_earthquakes.csv", where the dates should be in
# YYYY-MM-DD format.
data <- read.csv(here("data", "derived","2023-02-01_to_2022-02-01_earthquakes.csv"))
# Please insert the new file name here.
filename <- "2023-02-01_to_2022-02-01_earthquakes.csv"

# We subtract 1 day from the "new_date", i.e. from the date we access the API, as the measurements are
# available from the day before.
new_date <- as.character(ymd(substr(filename, 1, 10))%m-%days(1))
last_year_date <- substr(filename, 15, 24)

mags <- data$mag
mc <- find_mc(mags)

#------ Graphically verifying the value for mc---------------------------------------------

#==========================================================================================
# To validate the value of mc given by the functon "find_mc", we are going to use a 
# histogram and a Q-Q plot. The histogram will show the density of the magnitude values,
# the cutoff point mc from the function, as well as the density curve of the 
# exponential dsitribution that corresponds to the complete data. This means that the
# curve will start from the estimated mc, with rate 1/mean(x) (Maximum Likelihood
# Estimator), where x the completed magnitude measurements, i.e. the magnititudes
# equal to or bigger than mc. We expect this curve to approximately fit the 
# histogram after the cutofff value mc.

# We will also use a Q-Q plot. First, we will plot the sample quantiles of our magnitude
# data against the theoretical quantiles of the exponential distribution that the
# data would follow if it were exponential, i.e. exp(beta) with beta 
# approximated by 1/mean(y), where y all the data. We add a horizontal line corresponding
# to the cutoff point mc to check that it is not too conservative or too small at first 
# glance. 
# Then, to be sure, we plot another QQ plot, where this time the sample & 
# theoretical quantiles are those of the completed magnitudes, meaning we only use 
# magnitudes > mc for the data and the MLE (for the rate of the exponential quantiles). 
# The closer the scatterplot follows the plotted qqline, the better the fit for the 
# distribution. We are interested in examining the fit for small values of magnitude, as 
# we know that for values > 1.5, our observations are surely complete. For this reason
# we add a horizontal line corresponding to the value of 1.5, to examine the values 
# smaller than that easier.
#==========================================================================================

# Create the data frame used for the plots
df <- data.frame(mags = mags, mc = mc)

# Histogram

# By default, plotting histograms from geom_histogram() in ggplot produces different plots
# than hist() due to different binning. So we make sure that the binning is the same with hist(),
# as that's what we used in the find_mc function, and we want the plot to reflect our way of 
# thinking & result.
brs <- pretty(range(mags), n = nclass.scott(mags), min.n = 1)

histg <- ggplot(df, aes(x = mags)) + 
          geom_histogram(aes(y = ..density..), position = "identity", breaks = brs, 
                         color = "darkgrey", 
                         fill = "ivory3", alpha = 0.2) +
          geom_vline(data = df, aes(xintercept = mc, color = paste0("mc = ", mc)), 
                     lwd = 1, linetype = "dotted") +
          stat_function(fun = function(x) dexp(x - mc, rate = 1/mean(mags[mags >= mc])),
                        aes(color = "dexp", linetype = "dexp"),
                        xlim = c(mc, 4),
                        lwd = 0.7,
                        show.legend = FALSE) +
          scale_color_manual(values = c("blue", "#FF3366"), name = NULL) +
          guides(color = guide_legend(override.aes = list(
            linetype = c("solid", "dotted")
          ), nrow = 2, byrow = TRUE)) +
          labs(title = paste0("Histogram plot of the magnitudes from ", last_year_date, "\n to ", new_date), 
               x = "Magnitude (M1)") +
          theme_classic() +
          theme(plot.title = element_text(hjust = 0.5, size = 10), 
                text = element_text(family = "Montserrat"),
                axis.title = element_text(size = 8),
                legend.title = element_text(size = 8),
                legend.text = element_text(size = 8)) +
          theme(legend.position = "right")

# Save the plot in /outputs/02341508-monthly-summary/figures.
ggsave(here("outputs", "02341508-monthly-summary", "figures", "01-01-hist-mc.pdf"), plot = histg,
       width = 6, height = 5)

# Q-Q Plot

# Q-Q Plot for all the magnitude observations

qqplot1 <- ggplot(df, aes(sample = mags)) +
              stat_qq(distribution = qexp, 
                      dparams = list(rate = 1/mean(mags)), size = 0.5) +
              stat_qq_line(distribution = qexp,
                           dparams = list(rate = 1/mean(mags)), size = 0.5) +
              labs(x = "Theoretical Quantiles (Exponential)",
                   y = "Sample Quantiles") +
              geom_hline(aes(yintercept = mc, color = paste0("mc = ", mc)), linetype = "solid", lwd = 1) +
              geom_hline(aes(yintercept = 1.5, color = "1.5"), linetype = "dotted", lwd = 1) +
              scale_color_manual(values = c("dodgerblue", "#FF3366"), name ="Magnitude") +
              labs(title = paste0("Q-Q Plot for the magnitudes \nfrom ", last_year_date, " to ", new_date)) +
              theme_classic() +
              guides(color = guide_legend(override.aes = list(
                linetype = c("dotted", "solid")
              ), nrow = 2, byrow = TRUE)) +
              theme(plot.title = element_text(hjust = 0.5, size = 10), text = element_text(family = "Montserrat"),
                    axis.title = element_text(size = 8),
                    legend.title = element_text(size = 8),
                    legend.text = element_text(size = 8))

# Save the plot in /outputs/02341508-monthly-summary/figures.
ggsave(here("outputs", "02341508-monthly-summary", "figures", "01-02-qqplot-1.pdf"), plot = qqplot1,
       width = 6, height = 5)

# Q-Q Plot for the complete magnitude observations (>mc)

# We subtract the value mc from all the completed magnitudes for the plot to begin at 0 again,
# as we also want to examine how closely the scatterplot resembles the line y = x.

df_complete <- data.frame(mags = mags[mags> mc] - mc)
qqplot2 <- ggplot(df_complete, aes(sample = mags)) +
              stat_qq(distribution = qexp, 
                      dparams = list(rate = 1/mean(mags)), size = 0.5) +
              stat_qq_line(distribution = qexp, 
                           dparams = list(rate = 1/mean(mags)), size = 0.5) +
              geom_hline(aes(yintercept = 1.5-mc, color = paste0("1.5 - mc = ", 1.5 - mc)), 
                         linetype = "dotted", lwd = 1) +
              labs(x = "Theoretical Quantiles (Exponential)",
                   y = "Sample Quantiles") +
              scale_color_manual(values = c("dodgerblue"), name = "Magnitude") +
              labs(title = paste0("Q-Q Plot for the completed magnitudes \n from ", last_year_date,
                                  " to ", new_date)) +
              theme_classic() +
              theme(plot.title = element_text(hjust = 0.5, size = 10), text = element_text(family = "Montserrat"),
                    axis.title = element_text(size = 8),
                    legend.title = element_text(size = 8),
                    legend.text = element_text(size = 8))

# Save the plot in /outputs/02341508-monthly-summary/figures.
ggsave(here("outputs", "02341508-monthly-summary", "figures", "01-03-qqplot-2.pdf"), plot = qqplot2,
       width = 6, height = 5)
