library(testthat)

expect_error(make_filename(yyyy), "*yyyy*")

expect_error(fars_read(coursera), "*coursera*")

expect_equal(make_filename(2013), "accident_2013.csv.bz2")
