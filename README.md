# Earthquake Report

This project attempts to complete two independent tasks, both relating to the earthquake activity in the North-East of the Netherlands. The first is to produce a Monthly report analysing the seismic landscape of the region, and the second is to provide technical guidance on how to store large samples obtained from Markov Chain Monte Carlo (MCMC) methods. This file will provide further details on the two tasks in the following two sections.

## Aim 1: Monthly Report
The aim of this task is to produce a fully reproducible 2-page report, which summarises the earthquake activity in the North-East of the Netherlands. This report should documented so that it can be regenerated each month for new data with minimal effort. The data used is gathered from an API provided by the Royal
Dutch Meteorological Society and accessed on 2023-02-01. It contains all earthquakes recorded in the region since 1996-01-01. 

- The first page of the monthly report uses the last 12 months of earthquakes to select a value for mc (the magnitude of completion) and should verify that above the chosen value observation appears to be complete. For context, not all earthquakes make it into the earthquake record. Any earthquake with a magnitude exceeding the magnitude of completion, mc, is certain to be recorded. Any earthquake with a magnitude less than mc might be missed from the record.

- The second page of the monthly report uses visualisations and simple numerical summaries to compare the earthquake activity in the last month to the average behaviour in the 11 months preceding that, encompassing the earthquake counts, locations and magnitudes.

The code and analysis are structured as follows:
(The file .Rproj.user/ is automatically added after zipping the files with the online tool [zip](https://www.ezyzip.com/zip-folder-online.html#)).

### data/

This directory contains all raw and derived datasets. Further information can be found in [metadata.txt](./data/raw/metadata.txt). 

### src/
This directory contains the source code for the project. For this task, the functions get_12mo.R (data-cleaning/) and find_mc.R (helper-functions/) are relevant. The first function was built to obtain the last 12 months' worth of data, and the second to find the value of mc (magnitude of completion).

### tests/
This directory contains the tests for the functions in the previous directory. Its aim is to make sure functions work as expected -for the function find_mc.R, a folder containing to test filescan be found. The folder contains the standard tests for the function, as well as an additional R file that tests the adaptability of the function to different datasets.

### analyses/02341508-monthly-summary
This directory contains the analyses conducted for the report. The files with names starting with 01 correspond to analyses relevant to the first page of the report, while names starting with 02 correspond to the second page. The second pair of numbers correspond to the order in which the analyses are executed, e.g. 02-01 corresponds to the first analysis conducted for the second page of the report. However, the analyses of the second page are not independent of the first and thus the files should be executed in the naming order 01-01, 01-02, 02-01, 02-02.

### outputs/02341508-monthly-summary
This directory contains the plots and tables used for the report. The same naming system as above is adopted.

### reports/02341508-monthly-summary
This directory contains the final report (in PDF format), as well as the source file, references file (bib), images and table contained in the report. More information can be found in [README.md](./reports/02341508-monthly-summary/README.md).

## Aim 2: Technical guidance on MCMC
The aim of this task is to design and perform a reproducible simulation study to assess the computational efficiency of four different approaches concerning the storage of large MCMC samples.

The code and analysis are structured as follows:
(The file .Rproj.user/ is automatically added after zipping the files with the online tool [zip](https://www.ezyzip.com/zip-folder-online.html#)).

### data/

This analysis does not require any data. 

### src/
This directory contains the source code for the project. For this task, the function store_mcmc.R is relevant. It contains the 4 functions that correspon to the 4 different storage approaches.

### tests/
This directory contains the tests for the function in the previous directory. Its aim is to make sure functions work as expected.

### analyses/02341508-mcmc-storage-guide
This directory contains the analysis conducted for the report. This includes the simulation study and the code for one visualisation plot that demonstrates some of its results.

### outputs/02341508-mcmc-storage-guide
This directory contains the visualisation plot used for the report.

### reports/02341508-mcmc-storage-guide
This directory contains the final report (in PDF format), as well as the source file and image contained in the report. More information can be found in [README.md](./reports/02341508-mcmc-storage-guide/README.md).

## Installation
To install and set up this project, please follow these steps:

1. Install R: This project was built using the R programming language (R version 4.0.3). To download and install R, please refer to the instructions that apply to your operating system from the official R Project website: [R Project](https://www.r-project.org).

2. Install required packages: Open RStudio and run the following command to install the required packages:
```
install.packages("name_of_package1")
install.packages("name_of_package2")
```
Replace "name_of_package1" and "name_of_package2" with the names of the specific R packages required for this project. The required packages can be found at the top of each R Script of the project. After installing the packages, please run these commands first to be able to use the corresponding package or function. For example, these might look like this:
```
library(name_of_package)
source(path-to-function)
```

3. Open the R project named 'earthquake-report'.

4. Set Working Directory: In R, set the working directory to the project directory by running the following command:
```
setwd("path/to/earthquake-report")
```
You are now ready to use the project! You can open any file inside the R Project and run the commands inside to reprocude the results in the reports, or change the contents as indicated by the code comments to conduct the analyses for a different set of data (applicable for the Monthly report).

## Usage
To effectively use this earthquake analysis project, follow the steps below:

For the Monthly report, run the R scripts in [02341508-monthly-summary](./analyses/02341508-monthly-summary/) with the following order: 
(1) 01-01-get-last-12mo-data.R: from the data containing all the earthquakes recorded, only the last 12 months of observations are extracted and saved in a different file, as that is the time period of interest.
(2) 01-02-find-verify-mc: the mc value is estimated for the last 12 months of observations, and then verified graphically.
(3) 02-01-yearly-data-cleaning: the 12 months of observations are cleaned to only contain the complete observations accordingto the estimated value mc.
(3) 02-02-comparative-earthquake-analysis: the earthquake activity of the last month is compared to the average activity of the preceding 11 months, using visualisations and numerical summaries.

Running these scripts will yield all the plots necessary for the Monthly report. The rest of its content can be found in the source file [source](./reports/02341508-monthly-summary/02341508-monthly-summary.tex).
To recreate this report for future months, the file names in these scripts need to be updated as indicated by the code comments.

For the Technical guidance on MCMC, run the R script in [02341508-mcmc-storage-guide](./analyses/02341508-mcmc-storage-guide/). Running these script will yield the plot necessary for the MCMC storage guide report. The rest of its content can be found in the source file [source](./reports/02341508-mcmc-storage-guide/02341508-mcmc-storage-guide.tex).

Some examples of usage include: 
(1) Finding the magnitude of completion mc for some data:
```
# load the function that finds mc
library(here)
source(here("src","helper-functions","find_mc.R"))

# load the data
data <- read.csv(here("data"))
# extract the magnitudes
mags <- data$mag
# use the function to find mc
mc <- find_mc(mags)
```
(2) A bubble plot can be used to visualise the earthquake counts and magnitudes at different places for a specific time frame (specific dataset) using the code snippet:
```
library(ggplot2)
library(showtext)
library(ggrepel)
library(here)

# The data frame encompasses the earthquake magnitudes, counts, places' names and longitudes & latitudes
data <- read.csv(here("data"))

counts_per_place <- aggregate(mag ~ place, data = data, FUN = length)

df <- data.frame(Magnitude = data$mag, place = data$place,
                    lon = data$lon, lat = data$lat, counts = counts_per_place$mag)

bubble <- ggplot(df1, aes(x = lat,y = lon, size = counts, color = Magnitude)) +
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
```
This code was run for last month's data in [comparative analysis](./analyses/02341508-monthly-summary/02-02-comparative-earthquake-analysis.R), with output 
[bubble plot](./outputs/02341508-monthly-summary/02-01-bubbleplot-1.pdf).

(3) Conducting the simulation study for the MCMC storage guide with dimensions of the resulting sample's data frame equal to 10 times 10^7:
```
library(here)
source(here("src","helper-functions","store_mcmc.R"))

m <- as.integer(10)
p <- as.integer(10^7)

output1 <- system.time({df1 <- df_row_wise(p, m)})
rm(df1)
output2 <- system.time({df2 <- df_col_wise(p, m)})
rm(df2)
output3 <- system.time({mat1 <- mat_row_wise(p, m)})
rm(mat1)
output4 <- system.time({mat2 <- mat_col_wise(p, m)})
rm(mat2)
```

