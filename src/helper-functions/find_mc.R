#' Select a value for mc
#'
#' @description
#' This function is used to estimate the value for mc, i.e. the magnitude of completion, for a set 
#' of earthquake magnitude measurements. Above the mc, all observations of magnitude are complete.
#' To assess the completeness of observations, we use the modelling assumption that earthquake magnitudes
#' follow an Exponential(beta) distribution, where beta > 0 is an unknown parameter. Deviations from this 
#' model (at low magnitudes) are then attributed to incomplete observation.
#'
#' This function was built to estimate the mc for datasets of earthquake activity in the North-East 
#' of the Netherlands, provided by the Royal Dutch Meteorological Society API. Thus, it utilises
#' the assumptions that characterise this particular dataset. More specifically, we know that a 
#' conservative value for mc in this study region for the entire time period (earliest record 1996-01-01)
#' is 1.5M1. 
#' 
#' The method used to estimate mc is the following: first, we divide the data in k bins using the hist()
#' function. The number k is calculated according to Scott's rule, which provided a better representation 
#' for exponential data, as the built in hist() function in R chooses a default value k based on Sturges' 
#' rule that assumes normal data. Scott's rule claims that bind width should be equal to 3.5*sd(x)/(n^(1/3)),
#' where n is the sample size and sd(x) the standard deviation of the data x. We use R's built in function 
#' nclass.scott(x) to determine the "breaks" argument in hist() in our function. After that, we find the 
#' left border of the bin that has the maximum number of counts. That will be our estimated mc value.
#' This is because the pdf of an exponential distribution begins at its maximum value and is decreasing.
#'
#' @param magnit magnit A vector of the magnitudes used to find the value of mc.
#'
#' @return The estimated value of mc.
#'
#' @examples
#' find_mc(rexp(100))
#' find_mc(rnorm(100))
#' 
find_mc <- function(magnit) {
  # Input checks
  stopifnot(class(magnit) %in% c("integer", "numeric"))
  # Because we use Scott's rule, which involves calculating sd(magnit), we want at least 2
  # observations in magnit, and not NA/NaN values.
  stopifnot(length(magnit) > 1)
  stopifnot(any(!is.na(magnit)))
  stopifnot(any(!is.nan(magnit)))
  
  # Function body
  histogram <- hist(magnit, plot = FALSE, breaks = nclass.scott(magnit))
  # Find the bin of the histogram with the maximum counts.
  max_height <- max(histogram$counts)
  # Get its index.
  max_height_index <- which(histogram$counts == max_height)
  # Determine left border of histogram:
  # We choose the minimum value of the left borders that correspond to the 
  # bins with the maximum height, to minimise the loss of complete magnitudes
  # that we can include in our dataset
  left_border <-  min(histogram$breaks[max_height_index])
  
  if (left_border < 1.5) {
    # the left border of the max_bin will be the cutoff point
    mc <- left_border
  } else {
    mc <- 1.5
  }
  return(mc)
}

