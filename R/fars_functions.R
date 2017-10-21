

#' FARS (Fatality Accident Reporting System) Read File
#'
#' \code{fars_read(filename)} checks the existence of the file (based on the filename
#'  supplied in the parameter), reads the file, and loads the file as a data frame
#'  and S3 class "tbl_df" from dplyr package.
#'
#' @param filename String characters used to read the file. This parameter takes the output of
#'  make_filename function. Although the filename can be created as a string input
#'  into the function as a parameter, any mis-spelled component or mis-specified
#'  filename will result in an error.
#'
#' @return output of this function is a dataframe and S3 class tbl_df from
#'  dplyr package.
#'
#' @example
#' \dontrun{
#'  fars_read("accident_2013.csv")
#'  }
#'
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Make File Name
#'
#' \code{make_filename(year)} is a simple function to create file names for the data files. Fatality accident
#'  files come in a compressed format with "accident_YYYY_.csv.bz2" The function preserves
#'  the naming convention but differentiates the file with the "year" of the data.
#'
#' @param year Numerical value which will be used
#'  to name the file.If the parameter is not a numerical value representing a four digit year, the
#'  function will return an error message if non-numeric values entered.
#'
#' @return The function will return a file name with the year value embedded
#'  in the file name to be decompressed.
#'
#' @examples
#' \dontrun{
#'  make_filename(2013)
#'  make_filename(2014)
#'  }
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}


#' Support Function
#'
#' \code{fars_read_years(years)} is a support function that creates list(s) of month-
#'  year based on the parameters passed into the function. This function uses *make_filename*
#'  function as well as mutate and select functions from the dplyr package.
#'
#' @importFrom dplyr mutate select
#' @importFrom magrittr %>%
#'
#' @param years Numerical values which can be a single or multiple years and
#'  this value must be supplied as four digit integer value. This parameter will be used to generate list(s) of month-year. Error will
#'  result if non-numerical parameter is passed into the function
#'
#' @return The function will return a list or lists of month-year (<int><dbl>).
#'
#' @examples
#' \dontrun{
#'  fars_read_years(2013)
#'  fars_read_years(c(2013,2014))
#'  }
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate_(dat, year = year) %>%
                                dplyr::select_(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Count Incidents per Month per Year
#'
#' \code{fars_summarize_years(years)} takes the year or years in as a parameter and
#'  creates a dplyr style table (tibble) that counts the number of incidents
#'  per month for the given year. This function uses fars_read_years function
#'  as well as group_by and summarize functions from *dplyr* package. Additionally,
#'  function requires tidyr pacakge to utilize spread function.
#'
#' @importFrom dplyr group_by summarize
#' @importFrom tidyr spread
#' @importFrom magrittr %>%
#'
#' @param years Numerical values which can be a single year or multiple years.
#'  Error will result if no-numeric value is passed into the function.
#'
#' @return function will return the number of incidents per month for the
#'  given year(s).
#'
#' @examples
#' \dontrun{
#'  fars_summarize_years(2013)
#'  fars_summarize_years(c(2013,2014))
#'  }
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by_(year, MONTH) %>%
                dplyr::summarize_(n = n()) %>%
                tidyr::spread_(year, n)
}

#' Fatality Accident Reporting System--Mapping Function
#'
#' \code{fars_map_state(state.num, year)} takes in the data from the FARS files and maps the
#'  number of incidents for the specified state for the given year. This function uses
#'  make_filename and fars_read functions. It also requires *dplyr*, *maps*, and *graphics*
#'  packages to use filter, map, and points functions, respectively.
#'
#' @importFrom dplyr filter
#' @importFrom maps map
#' @importFrom graphics points
#' @importFrom magrittr %>%
#'
#' @param state.num Numerical values which are integers that represents
#'  a spefic state and the year is the year of interest in mapping the incidents.
#'  state.num value in the FARS range from 1 to 56. Integer value outside this
#'  range will result in an error.
#' @param year Numerical values and they must be four digit year integer value.
#'
#' @return function will return a map in a graphical form with incidents represented
#'  in a particular state based on locational information specified in FARS.
#'
#' @examples
#' \dontrun{
#'  fars_map_state(1, 2013)
#'  fars_map_state(20, 2014)
#'  fars_map_state(50, 2015)
#'  }
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter_(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
