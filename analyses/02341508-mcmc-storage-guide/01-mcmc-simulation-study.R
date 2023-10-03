# In this script, we compare the different storage approaches proposed by the team of experienced
# R programmers through a simulation study. Namely, the approaches are:
# (1) data frame row-wise: Create a m×p data frame of NA values; fill each row sequentially.
#
# (2) data frame column-wise: Create a p × m data frame of NA values; fill each column
# sequentially and transpose the resulting data frame.
#
# (3) matrix row-wise: Create a m × p matrix of NA values; fill each row sequentially and
# then convert to a data frame.
#
# (4) matrix column-wise: Create a p×m matrix of NA values; fill each column sequentially
# then transpose the matrix and convert to a data frame

# ----- Packages, Helper functions Needed ------------------------------------------
library(ggplot2)
library(here)
source(here("src","helper-functions","store_mcmc.R"))
library(showtext)
font_add_google(name = "Montserrat", family = "Montserrat") 
showtext_auto()

# ----- Simulation Study -----------------------------------------------------------
# A simulation study is performed for each of the approaches above for m = 10, 
# where the rows or columns respectively are filled sequentially with randomly generated samples 
# from the standard Normal distribution, after pre-allocating a data frame or matrix with the 
# appropriate dimensions, filled with NA values. 
#

# for p = 10^7
m <- as.integer(10)
p <- as.integer(10^7)

output1 <- system.time({df1 <- df_row_wise(p, m)})
# To save memory & speed, we remove the large data frame/matrix after every
# output for the sake of the simulation study.
rm(df1)
output2 <- system.time({df2 <- df_col_wise(p, m)})
rm(df2)
output3 <- system.time({mat1 <- mat_row_wise(p, m)})
rm(mat1)
output4 <- system.time({mat2 <- mat_col_wise(p, m)})
rm(mat2)

# for p = 10^8
# The simulation study for p = 10^8 is run only for the matrice-focused approaches
# That's because we already established these two are much faster than the corresponding
# data frame methods, even with the use of the package 'data.table' which optimises large data frames,
# in terms of computation time as well as memory. However the matrix methods are very close in computation 
# time, so we compare them further for higher p = 10^8 (the value we are interested in).
p <- as.integer(10^8)
output3_2 <- system.time({mat1 <- mat_row_wise(p, m)})
rm(mat1)
output4_2 <- system.time({mat2 <- mat_col_wise(p, m)})
rm(mat2)

# Find the computational time for the matrices and convert to minutes by dividing by 60.
mat_row <- as.numeric(output3_2[3])/60
mat_col <- as.numeric(output4_2[3])/60

# ----- Bar plot for p = 10^7 ------------------------------------------------------
# We will now create a barplot with the computation time of every method for p = 10^7.

mcmcdf <- data.frame(comp_time = c(as.numeric(output4[3]), as.numeric(output4[3]),
                                   as.numeric(output4[3]), as.numeric(output4[3])), 
                     method = c("Data frame row-wise", "Data frame col-wise",
                                "Matrix row-wise", "Matrix col-wise"))

p <- ggplot(mcmcdf, aes(comp_time, method)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        labs(title = "Barplot of the computational time of every method", 
             x = "computational time (sec)", y = "") +
        theme(plot.title = element_text(size = 10), text = element_text(family = "Montserrat"),
              axis.title = element_text(size = 8),
              legend.title = element_text(size = 8),
              legend.text = element_text(size = 8)) +
        xlim(0, max(mcmc$comp_time)) +
        theme_minimal()

# Save the plot in /outputs/02341508-mcmc-storage-guide/figures.
ggsave(here("outputs", "02341508-mcmc-storage-guide", "figures","01-01-barplot.pdf"), plot = p,
       width = 6, height = 5)

# Find the computational times in minutes.
comp_minutes <- c(as.numeric(output4[3]), as.numeric(output4[3]),
              as.numeric(output4[3]), as.numeric(output4[3]))/60