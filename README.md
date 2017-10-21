[![Build Status](https://travis-ci.org/MoRudyKim/farsfunc.svg?branch=master)

# farsfunc
Cousera_RDev_FARS_Package

# Fatality Accident Reporting System Functions

*Mastering Software Development with R*, third course provides the functions using data from the US National Highway Traffic Safety Administration's Fatality Analysis Reporting System (FARS), which is a nationwide census providing the American public yearly data regarding fatal injuries suffered in motor vehicle traffic crashes to illustrate **R package** building process. 

## Functions Behind Functions

To this end, there are five functions that work to summarize and map FARS data. Three functions--**make_filename**, **fars_read**, and **fars_read_years**--are involved in reading FARS data for summarization and mapping. The workflow is as follows:

1. make_filename function creates a filename that complies with FARS data files.
2. fars_read function uses the name from make_filename and checks to see if that file exists in the path provided and if the file does exist, it reads the data into the environment. Otherwise, the function will throw an error message.
3. fars_read_years function uses make_filename and fars_read functions and creates a "tibble" from dyplyr package tath represents Month-Value pair for the specified year.

The above workflow completes initial loading of data to be used for summary and mapping.

### Examples
make_filename(2013)

fars_read(make_filename(2013))


## Main Functions for FARS 

The main functions are *fars_summarize_years* and *fars_map_state*. *fars_summarize_years* take in a year or vectors of years and produces a tibble (dplyr) that counts the number of incidents by month for the years specified. With this information *fars_map_state* graphically illustrates those incidents by utilizing additional data from the file (longitudes, lattitudes and state Id).

### Examples
fars_summarize_years(2013)

fars_map_state(2013)
