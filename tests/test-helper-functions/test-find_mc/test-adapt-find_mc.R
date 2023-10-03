# Testing Adaptability of the find_mc.R helper function

#===================================================================================
# In this file, we will test whether the function find_mc.R can adapt to different 
# data and still give correct results. To test this, we will use the data we already
# have, i.e. the magnitudes from the file "2023-02-01_induced-earthquakes.csv". More 
# specifically, we will first use all the magnitudes, and also choose two different 
# years' worth of observations available. To test if the function gives a satisfying 
# estimate for the mc value, we will use two graphical methods to validate the result
# of the function; a histogram and a qqplot.
#===================================================================================

# ----- Packages & Helper functions Needed -----------------------------------------
library(ggplot2)
library(showtext)
library(here)
source(here("src","helper-functions","find_mc.R"))
source(here("src","data-cleaning","get_12mo.R"))

# ----- Getting the data -----------------------------------------------------------
dat <- read.csv(here("data", "raw","2023-02-01_induced-earthquakes.csv"))
date <- dat$date
# First, we obtain all the magnitudes the file contains
all_mag <- dat$mag
# Then, we obtain the magnitudes measured for 12 months before the date 2015-12-03 (1)
# and 2005-05-31 (2).

# (1)
date_12mo_1 <- get_12mo("2015-12-03")
# Due to the > sign in "> date", we take the date immediately before ""2015-12-03", i.e.
# we start counting from "2015-12-02".
wanted_dates1 <- which("2015-12-03" > date & date >= date_12mo_1)
mag1 <- dat[wanted_dates1,]$mag

# (2)
date_12mo_2 <- get_12mo("2005-05-31")
wanted_dates2 <- which("2005-05-31" > date & date >= date_12mo_2)
mag2 <- dat[wanted_dates2,]$mag

# ----- Getting the mc values estimated from the find_mc function ------------------
mc_all <- find_mc(all_mag)
mc1 <- find_mc(mag1)
mc2 <- find_mc(mag2)

# ----- Graphically validating the results -----------------------------------------

#===================================================================================
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
# glance. Then, to be sure, we plot another QQ plot, where this time the sample & 
# theoretical quantiles are those of the completed magnitudes, meaning we only use 
# mangitudes > mc for the data and the MLE (for the rate of the exponential quantiles). 
# The closer the scatterplot follows the plotted qqline, the better the fit for the 
# distribution. We are interested in examining the fit for small values of magnitude, as 
# we know that for values > 1.5, our observations are surely complete.

# For all 3 datasets, we observe satisfactory results; after the value mc all
# distributions seem to approximately follow an exponential distribution, i.e.
# all observations appear to be complete. As expected, for the dataset (2) the resulting mc is
# larger than that of (1), as it uses older data and we know that the true value of mc increases
# as we go back in time. The mc for all magnitudes is between these two; mc2 < mc_all < mc1,
# which makes sense considering it uses the oldest & newest data available.

# The code for the plots that validate these results can be found below.
#===================================================================================

# Loading fonts for plots
font_add_google(name = "Montserrat", family = "Montserrat") 
showtext_auto()

# ----- All Magnitudes -------------------------------------------------------------

# Histogram
# By default, plotting histograms from geom_histogram() in ggplot produces different plots
# than hist() due to different binning. So we make sure that the binning is the same with hist(),
# as that's what we used in the find_mc function, and we want the plot to reflect our way of 
# thinking & result.
brsall <- pretty(range(all_mag), n = nclass.scott(all_mag), min.n = 1)

df_all <- data.frame(all_mag = all_mag, mc = mc_all)
ggplot(df_all, aes(x = all_mag)) + 
  geom_histogram(aes(y = ..density..), breaks = brsall, color = "#F85700", 
                 fill = "#F85700", alpha = 0.2) +
  geom_vline(data = df_all, aes(xintercept = mc, color = "mc"), linetype = "dotted", lwd = 1) +
  stat_function(fun = function(x) dexp(x - mc_all, rate = 1/mean(all_mag[all_mag >= mc_all])),
    xlim = c(mc_all, 4),
    lwd = 0.7,
    col = 'red') +
  scale_color_manual(values = c("blue"), name = NULL) +
  labs(title="Histogram plot of all the magnitudes from 1996-01-01\n to 2023-01-31", x = "Magnitude (M1)")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat")) +
  theme(legend.position = "right")

# Q-Q Plot

ggplot(df_all, aes(sample = all_mag)) +
  stat_qq(distribution = qexp, 
          dparams = list(rate = 1/mean(all_mag))) +
  stat_qq_line(distribution = qexp,
               dparams = list(rate = 1/mean(all_mag))) +
  labs(x = "Theoretical Quantiles (Exponential)",
       y = "Sample Quantiles") +
  geom_vline(data = df_all, aes(xintercept = mc, color = "mc"), linetype = "dotted", lwd = 1) +
  scale_color_manual(values = c("purple"), name = NULL) +
  labs(title="Q-Q Plot for all the magnitudes from 1996-01-01\n to 2023-01-31")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat"))

df_after <- data.frame(all_mag = all_mag[all_mag> mc_all] - mc_all)
ggplot(df_after, aes(sample = all_mag)) +
  stat_qq(distribution = qexp, 
          dparams = list(rate = 1/mean(all_mag))) +
  stat_qq_line(distribution = qexp, 
               dparams = list(rate = 1/mean(all_mag))) +
  labs(x = "Theoretical Quantiles (Exponential)",
       y = "Sample Quantiles") +
  scale_color_manual(values = c("purple"), name = NULL) +
  labs(title="Q-Q Plot for the completed magnitudes from 1996-01-01\n to 2023-01-31") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat"))

# ----- Magnitudes (1) -------------------------------------------------------------

# Histogram
brs1 <- pretty(range(mag1), n = nclass.scott(mag1), min.n = 1)

df1 <- data.frame(mag1 = mag1, mc = mc1)
ggplot(df1, aes(x = mag1)) + 
  geom_histogram(aes(y = ..density..), breaks = brs1, color = "#F85700", fill = "#F85700", 
                 alpha = 0.2) +
  geom_vline(data = df1, aes(xintercept = mc, color = "mc"), linetype = "dotted", lwd = 1) +
  stat_function(fun = function(x) dexp(x - mc1, rate = 1/mean(mag1[mag1 >= mc1])),
                xlim = c(mc1, 4),
                lwd = 0.7,
                col = 'red') +
  scale_color_manual(values = c("blue"), name = NULL) +
  labs(title="Histogram plot of all the magnitudes from 2014-12-03\n to 2015-12-02", x = "Magnitude (M1)")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat")) +
  theme(legend.position = "right")

# Q-Q Plot

ggplot(df1, aes(sample = mag1)) +
  stat_qq(distribution = qexp, 
          dparams = list(rate = 1/mean(mag1))) +
  stat_qq_line(distribution = qexp,
               dparams = list(rate = 1/mean(mag1))) +
  labs(x = "Theoretical Quantiles (Exponential)",
       y = "Sample Quantiles") +
  geom_hline(aes(yintercept = mc1, color = "mc"), linetype = "dotted", lwd = 1) +
  scale_color_manual(values = c("purple"), name = NULL) +
  labs(title="Q-Q Plot for all the magnitudes from 2014-12-03\n to 2015-12-02", x = "Magnitude (M1)")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat"))


df_after1 <- data.frame(mag1 = mag1[mag1> mc1] - mc1)
ggplot(df_after1, aes(sample = mag1)) +
  stat_qq(distribution = qexp, 
          dparams = list(rate = 1/mean(mag1))) +
  stat_qq_line(distribution = qexp, 
               dparams = list(rate = 1/mean(mag1))) +
  labs(x = "Theoretical Quantiles (Exponential)",
       y = "Sample Quantiles") +
  scale_color_manual(values = c("purple"), name = NULL) +
  labs(title="Q-Q Plot for the completed magnitudes from 2014-12-03\n to 2015-12-02") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat"))

# ----- Magnitudes (2) -------------------------------------------------------------

# Histogram
brs2 <- pretty(range(mag2), n = nclass.scott(mag2), min.n = 1)

df2 <- data.frame(mag2 = mag2, mc = mc2)
ggplot(df2, aes(x = mag2)) + 
  geom_histogram(aes(y = ..density..), breaks = brs2, color = "#F85700", fill = "#F85700", alpha = 0.2) +
  geom_vline(aes(xintercept = mc, color = "mc"), linetype = "dotted", lwd = 1) +
  stat_function(fun = function(x) dexp(x - mc2, rate = 1/mean(mag2[mag2 >= mc2])),
                xlim = c(mc2, 4),
                lwd = 0.7,
                col = 'red') +
  scale_color_manual(values = c("blue"), name = NULL) +
  labs(title="Histogram plot of all the magnitudes from 2004-05-31\n to 2005-05-30", x = "Magnitude (M1)")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat")) +
  theme(legend.position = "right")

# Q-Q Plot
ggplot(df2, aes(sample = mag2)) +
  stat_qq(distribution = qexp, 
          dparams = list(rate = 1/mean(mag2))) +
  stat_qq_line(distribution = qexp, 
          dparams = list(rate = 1/mean(mag2))) +
  labs(x = "Theoretical Quantiles (Exponential)",
       y = "Sample Quantiles") +
  geom_hline(data = df_all, aes(yintercept = mc2, color = "mc"), linetype = "dotted", lwd = 1) +
  scale_color_manual(values = c("purple"), name = NULL) +
  labs(title="Q-Q Plot for all the magnitudes from 2004-05-31\n to 2005-05-30")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat"))

df_after2 <- data.frame(mag2 = mag2[mag2> mc2] - mc2)
ggplot(df_after2, aes(sample = mag2)) +
  stat_qq(distribution = qexp, 
          dparams = list(rate = 1/mean(mag2))) +
  stat_qq_line(distribution = qexp, 
          dparams = list(rate = 1/mean(mag2[mag2 > mc2]))) +
  labs(x = "Theoretical Quantiles (Exponential)",
       y = "Sample Quantiles") +
  scale_color_manual(values = c("purple"), name = NULL) +
  labs(title="Q-Q Plot for the completed magnitudes from 2004-05-31\n to 2005-05-30")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), text=element_text(family = "Montserrat"))

