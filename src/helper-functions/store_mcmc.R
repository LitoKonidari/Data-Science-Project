#' Different mcmc storage approaches
#'
#' The following 4 functions demonstrate the 4 different approaches proposed by the team of R programmers. 
#' The goal is to find the fastest approach to sequentially obtain and store large numbers of samples 
#' computed with MCMC algorithms. Due to the lack of more information about the algorithms performed, 
#' a minimal example is created; a sample from a standard Normal distribution is drawn at each iteration 
#' to fill the corresponding row or column. Before this simulation, a seed is set to make the results 
#' reproducible and to ensure that each approach returns the same matrix for a fair comparison.
#'
#' @param m The number of samples of the parameter of interest acquired from the MCMC algorithm
#' @param p The dimensions of the parameter of interest
#'
#' @return The matrix or data frame filled with the simulated sample.
#'
library(data.table)
library(plyr)

# data frame row-wise: Create a m×p data frame of NA values; fill each row sequentially.
df_row_wise <- function(m, p) {
  # Inpute checks
  stopifnot(length(m)== 1)
  stopifnot(length(p)==1)
  stopifnot(class(m) == "integer")
  stopifnot(class(p) == "integer")
  
  # Function body
  df <- data.table(matrix(as.numeric(NA), nrow = m, ncol = p))
  set.seed(123)
  for (i in 1:m) {
    set(df, i, names(df), as.list(rnorm(p)))
  }
  return(df)
}

# data frame column-wise: Create a p × m data frame of NA values; fill each column
# sequentially and transpose the resulting data frame.
df_col_wise <- function(m, p) {
  # Inpute checks
  stopifnot(length(m)== 1)
  stopifnot(length(p)==1)
  stopifnot(class(m) == "integer")
  stopifnot(class(p) == "integer")
  
  # Function body
  df <- data.table(matrix(as.numeric(NA), nrow = p, ncol = m))
  set.seed(123)
  for (i in 1:m) {
    set(df, 1:p, i, rnorm(p))
  }
  df <- as.data.table(t(df))
  return(df)
}

#matrix row-wise: Create a m × p matrix of NA values; fill each row sequentially and
# then convert to a data frame.
mat_row_wise <- function(m, p) {
  # Inpute checks
  stopifnot(length(m)== 1)
  stopifnot(length(p)==1)
  stopifnot(class(m) == "integer")
  stopifnot(class(p) == "integer")
  
  # Function body
  mat <- matrix(NA, nrow = m, ncol = p)
  set.seed(123)
  for (i in 1:m) {
    mat[i,] <- rnorm(p)
  }
  mat <- as.data.table(mat)
  return(mat)
}

# matrix column-wise: Create a p×m matrix of NA values; fill each column sequentially
# then transpose the matrix and convert to a data frame.
mat_col_wise <- function(m, p) {
  # Inpute checks
  stopifnot(length(m)== 1)
  stopifnot(length(p)==1)
  stopifnot(class(m) == "integer")
  stopifnot(class(p) == "integer")
  
  # Function body
  mat <- matrix(NA, nrow = p, ncol = m)
  set.seed(123)
  for (i in 1:m) {
    mat[,i] <- rnorm(p)
  }
  mat <- as.data.table(t(mat))
  return(mat)
}
