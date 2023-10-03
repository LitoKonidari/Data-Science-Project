# In this script, we are performing tests to ensure the helper function store_mcmc.R
# works as expected. You can find the function in /src/helper-functions/store_mcmc.R.

# ----- Packages & Helper functions Needed ---------------------------------------
library(testthat)
library(here)
source(here("src","helper-functions","store_mcmc.R"))

# ----- Tests --------------------------------------------------------------------

# Malformed Inputs
# The four functions have the same input checks and so it suffices to check for one of them.
test_that("an input that's not an integer produces error", {
  expect_error(df_row_wise("r", "b"))
})

test_that("an input of length not 1 produces error", {
  expect_error(mat_col_wise(c(3.5, 5)))
})

# Check that the functions do give the same output, if the dimensions (inputs) m, p are the same
test_that("4 functions return the same numbers", {
  expect_equal(object = df_row_wise(as.integer(4), as.integer(5)),
               expected = df_col_wise(as.integer(4), as.integer(5)))
})

test_that("4 functions return the same numbers", {
  expect_equal(object = mat_row_wise(as.integer(4), as.integer(5)),
               expected = mat_col_wise(as.integer(4), as.integer(5)))
})

test_that("4 functions return the same numbers", {
  expect_equal(object = mat_row_wise(as.integer(4), as.integer(5)),
               expected = df_col_wise(as.integer(4), as.integer(5)))
})