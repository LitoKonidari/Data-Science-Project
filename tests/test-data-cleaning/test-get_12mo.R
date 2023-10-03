# In this script, we are performing tests to ensure the function get_12mo.R
# works as expected. You can find the function in /src/data-cleaning/get_12mo.R.

# ----- Packages & Helper functions Needed ---------------------------------------
library(testthat)
library(lubridate)
library(here)
source(here("src","data-cleaning","get_12mo.R"))

# ----- Tests --------------------------------------------------------------------

# Typical Behaviour
test_that("examples work", {
  expect_equal(
    object = get_12mo("2014-12-04"),
    expected = ymd("2013-12-04"))
  expect_equal(
    object = get_12mo("1980-01-31"),
    expected = ymd("1979-01-31")
  )
})

# Malformed Inputs
test_that("an input that's not a character produces error", {
  expect_error(get_12mo(20120104))
})

test_that("an input of length not 1 produces error", {
  expect_error(get_12mo(c("2012-03-22", "2022-04-30")))
  expect_error(get_12mo(c(2, 3)))
})

test_that("a date not in YYYY-MM-DD format produces error", {
  expect_error(get_12mo("01-23-2014"))
  expect_error(get_12mo("31-1999-01"))
})

# This is a result of the ymd() function from the lubridate package
# that is used in the get_12mo function -no extra input check was added.
test_that("an invalid date produces warning", {
  expect_warning(get_12mo("2020-20-01"))
  expect_warning(get_12mo("2000-20-60"))
})

# Edge Cases
# The earliest date we could be interested in for the project at hand is 1997-01-01; a year after
# the earliest record of earthquake activity in the API used.
test_that("earliest date of interest works", {
  expect_equal(
    object = get_12mo("1997-01-01"),
    expected = ymd("1996-01-01"))
})
