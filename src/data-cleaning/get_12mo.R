#' Get the date 12 months before the input date
#' 
#' This function returns the date 12 months before the input date. The input date is turned from a 
#' character string of the form "YYYY-MM-DD" into a Date class object by using the ymd() function 
#' from the lubridate package.
#'
#' @param input_date The date from which we count 12 months backwards to the output date, as a character
#' string in "YYYY-MM-DD" format.
#'
#' @return The date 12 months from the input date, as a Date object in "YYYY-MM-DD" format.
#'
#' @examples
#' get_12mo("2014-12-04")
#' get_12mo("1980-01-31")
#' 
library(lubridate)

get_12mo <- function(input_date) {
  # Input checks
  # We do not need to put a check for invalid dates as ymd() produces a warning for this already. 
  # (See test-get_12mo.R in tests/ folder.)
  
  # This function takes as input one date at a time.
  stopifnot(length(input_date)==1)
  # Check whether date is in the correct format, i.e. "YYYY-MM-DD".
  pattern <- "^\\d{4}-\\d{2}-\\d{2}$"
  if (grepl(pattern, input_date) == FALSE) {
    stop("Input date is not in YYYY-MM-DD format.")
  }
  stopifnot(class(input_date) == "character")
  
  # Function body
  input <- ymd(input_date)
  date <- input%m-%months(12)
  return(date)
}