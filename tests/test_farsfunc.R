library(testthat)
library(farsfunc)

expect_error(make_filename(yyyy),"object 'yyyy' not found")

expect_error(fars_read(coursera),"object 'coursera' not found")

expect_equal(make_filename(2013), "accident_2013.csv.bz2")
