# In this script, we are performing tests to ensure the helper function find_mc.R
# works as expected. You can find the function in /src/helper-functions/find_mc.R.

# ----- Packages & Helper functions Needed ---------------------------------------

library(testthat)
library(here)
source(here("src","helper-functions","find_mc.R"))

# ----- Tests --------------------------------------------------------------------

# We expect that, when using a sample from an exponential distribution, our function
# will return a value of mc (at least very close if not equal to) zero. We also expect that 
# for a normal distribution of mean mu, the estimated mc will be very close to mu; the mean 
# is also the mode when it comes to normal distributions, and our function is designed to estimate 
# mc as the value which gives the maximum height of the histogram.

# We simulate a sample from an exponential and standard normal distribution to test the above
# claim and also confirm that our examples work.

set.seed(123)
exp_sample <- rexp(100)
normal_sample <- rnorm(100)

test_that("examples work", {
  expect_equal(
    object = find_mc(exp_sample),
    expected = 0)
  expect_equal(
    object = find_mc(normal_sample),
    expected = -0.5
  )
})

# We want to test for additional exponential distributions with varying sample sizes and rates to 
# confirm our results where not due to randomness and our function works as expected, i.e. when data 
# are already exponential mc is approximately 0.

set.seed(158)
exp_sample2 <- rexp(100, rate = 3)
exp_sample3 <- rexp(50, rate = 1/2)
exp_sample4 <- rexp(500)

test_that("testing luck", {
  expect_equal(
    object = find_mc(exp_sample2),
    expected = 0)
  expect_equal(
    object = find_mc(exp_sample3),
    expected = 0)
  expect_equal(
    object = find_mc(exp_sample4),
    expected = 0)
})

# Malformed Inputs
test_that("an input that's not numeric/integer or has NAs produces error", {
  expect_error(find_mc(c("12", "32")))
  expect_error(find_mc(c(NA, 35, 42)))
  expect_error(find_mc(c(NaN, 35, 42)))
})

test_that("an input that has length equal to 1 produces error", {
  expect_error(find_mc(2))
})

# Edge Cases
# We check there's not problem with negative values (as our data can take such values) or a zero vector.
test_that("edge cases and negative values", {
  expect_equal(
    object = find_mc(c(-2, -1, -3, -5, -6)),
    expected = -6)
  expect_equal(
    object = find_mc(rep(0, times = 10)),
    expected = -1)
  expect_equal(
    object = find_mc(c(-2, 1, 1, 1, 2, 3)),
    expected = 0)
})

# Adaptability
# Lastly, since this function is to be used every month on new data, it is important to test whether it can
# adapt to different data and still give correct results. We will do this in a separate file called 
# "test-adapt-find_mc.R", in the tests folder.