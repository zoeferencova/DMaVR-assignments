## Data source: https://opendata.chmi.cz/meteorology/climate/historical_csv/data/1hour/precipitation/2025/

# Get the current working directory (where R is currently operating)
getwd()

## Define the main path where downloaded CSV files are stored
pth <- "~/Desktop/DMaVR-assignments/assignment_01/data/"

## List all CSV files in the downloads folder
## recursive = TRUE: search in subfolders too
## pattern = ".csv": only find files ending in .csv
## full.names = TRUE: gives the complete file path
fls <- list.files(path = pth,
                  recursive = TRUE,
                  pattern = ".csv",
                  full.names = TRUE)

# Display the list of found files
fls

## Read the first CSV file into a data frame
## header = TRUE: the first row contains column names
## sep = ",": values are separated by commas
dta <- read.table(file = fls[1], 
                  header = TRUE, 
                  sep = ",")

# Show the first few rows
head(x = dta)

# Show dimensions
dim(x = dta)

# Show structure: data types of each column, first few values
str(object = dta)

# Check how much memory df uses
object.size(x = dta)

## Convert STATION column from character to factor
## Factors are more memory-efficient for categorical data with repeated values
## (like station IDs that appear many times)
dta$STATION <- as.factor(x = dta$STATION)

# Check structure again - STATION should now show as Factor
str(object = dta)

# Check memory size - should be smaller now
object.size(x = dta)

## Convert ELEMENT column to factor as well
dta$ELEMENT <- as.factor(x = dta$ELEMENT)

# Check memory size again - smaller
object.size(x = dta)

## Try converting the first date entry as a simple date
## Doesn't work because the data includes time (hours and minutes)
as.Date(x = dta$DT[1])

## Try converting to POSIXlt (datetime format)
## format = "%Y-%m-%dT%H:%M" tells R how to parse the string
## %Y = 4-digit year, %m = month, %d = day, %H = hour, %M = minute
as.POSIXlt(x = dta$DT[1],
           format = "%Y-%m-%dT%H:%M")

## Test removing the "T" and "Z" characters from the date string
## The data comes in format like "2025-03-12T14:30Z"
## gsub replaces patterns: T and Z with spaces
gsub(pattern = "T|Z",
     replacement = " ",
     x = dta$DT[1])

## Convert all date-time values to POSIXct format
## POSIXct is better for data frames than POSIXlt (more efficient)
## First: gsub removes "T" and "Z" characters
## Second: as.POSIXct converts the cleaned string to a date-time object
dta$DT <- as.POSIXct(x = gsub(pattern = "T|Z",
                              replacement = " ",
                              x = dta$DT),
                     format = "%Y-%m-%d %H:%M ")

# Check structure - DT should now be POSIXct type
str(object = dta)

## Save the processed data as RDS file
## RDS files preserve R object types and are faster to read than CSV
saveRDS(object = dta,
        file = paste(pth, "data_prec_1h.rds"))

## Read the RDS file back into memory (testing that save worked)
x <- readRDS(file = paste(pth, "data_prec_1h.rds"))

# Verify the structure matches what we saved
str(object = x)

# Get summary statistics for each column
summary(object = dta)

## Create a plot of precipitation values over time
## type = "h" creates a histogram-like vertical lines plot
## x-axis: date-time, y-axis: precipitation value
plot(x = dta$DT,
     y = dta$VALUE, 
     type = "h")

## IQR = Interquartile Range, a measure of spread
## ACF = Autocorrelation Function, shows patterns over time
## Distribution/quantile/density functions help understand data patterns

# Help page about probability distributions
?distribution

# Calculate mean of all precipitation values (including zeros)
mean(x = dta$VALUE)

# Calculate mean of only non-zero precipitation values
# (more meaningful for precipitation data)
mean(x = dta$VALUE[dta$VALUE > 0])

# Calculate standard deviation of precipitation values
sd(x = dta$VALUE)

## Define a direct URL to a specific CSV file on the CHMI server
fls_url <- "https://opendata.chmi.cz/meteorology/climate/historical_csv/data/1hour/precipitation/2025/1h-0-20000-0-11414-SRA1H-202503.csv"

## Read the CSV directly from the internet
dta <- read.table(file = fls_url[1], 
                  header = TRUE, 
                  sep = ",")

## Apply the same data processing as before:
## Convert STATION to factor for memory efficiency
dta$STATION <- as.factor(x = dta$STATION)

## Convert ELEMENT to factor
dta$ELEMENT <- as.factor(x = dta$ELEMENT)

## Convert date-time strings to POSIXct format
dta$DT <- as.POSIXct(x = gsub(pattern = "T|Z",
                              replacement = " ",
                              x = dta$DT),
                     format = "%Y-%m-%d %H:%M ")

## Base URL for the precipitation data directory (for web scraping)
base_url <- "https://opendata.chmi.cz/meteorology/climate/historical_csv/data/1hour/precipitation/"

# Set the year we want to explore
yr <- 2025

## Try to scan the directory (this won't work for HTML)
## scan(file = paste0(base_url, yr, "/"))

## Read the HTML content of the directory listing page
## paste0 concatenates strings without spaces
readLines(con = paste0(base_url, yr, "/"))

## Store the HTML content in a variable
res <- readLines(con = paste0(base_url, yr, "/"))

# Look at the first few lines of HTML
head(x = res)

## Filter to only keep lines that contain ".csv"
## grep finds which lines match the pattern
res <- res[grep(pattern = "\\.csv",
                x = res)]

## Test: split the first line by quotation marks
## strsplit breaks a string into pieces based on a delimiter
test <- strsplit(x = res[1], 
                 split = '"')

## Extract the second element (which contains the filename)
test[[1]][2]

## Split all lines by quotation marks
res_l <- strsplit(x = res, 
                  split = '"')

## Extract the 2nd element from each split line
## sapply applies a function to each element of a list
## "[[" to extract a list element
## index = 2 to get the second element
fls <- sapply(X = res_l, 
              FUN = "[[",
              index = 2)

# Show the components to build URLs
base_url
yr
fls[42]  # Example: the 42nd file

## Test reading one of the discovered CSV files
read.table(file = paste0(base_url, yr, "/", fls[42]),
           sep = ",",
           header = TRUE)

## Download ALL precipitation data from ALL years
## Import all precipitation data for all available years and save it as a single 
## RDS file

# Base URL
base_url <- "https://opendata.chmi.cz/meteorology/climate/historical_csv/data/1hour/precipitation/"

## Create an empty list to store data from each year
dta_all <- list()

base_url <- "https://opendata.chmi.cz/meteorology/climate/historical_csv/data/1hour/precipitation/"
dta_all <- list()

# Process years one at a time with visible progress
for (yr in 2000:2026) {
  
  cat("\n========================================\n")
  cat("YEAR:", yr, "\n")
  cat("========================================\n")
  
  # Try to get directory listing
  res <- try(readLines(con = paste0(base_url, yr, "/")), silent = TRUE)
  
  if (inherits(res, "try-error")) {
    cat("Year", yr, "not available - skipping\n")
    next
  }
  
  # Extract filenames
  fls <- sapply(X = strsplit(x = res[grep(pattern = "\\.csv", x = res)], 
                             split = '"'), 
                FUN = "[[", index = 2)
  cat("Found", length(fls), "files\n")
  
  # Download each file with progress
  dta_yr_list <- list()
  for (i in seq_along(fls)) {
    cat("  File", i, "of", length(fls), "...")
    
    dta_month <- try(
      read.table(file = paste0(base_url, yr, "/", fls[i]), 
                 header = TRUE, 
                 sep = ","),
      silent = TRUE
    )
    
    if (!inherits(dta_month, "try-error")) {
      dta_month$STATION <- as.factor(dta_month$STATION)
      dta_month$ELEMENT <- as.factor(dta_month$ELEMENT)
      dta_month$DT <- as.POSIXct(gsub(pattern = "T|Z", replacement = " ", x = dta_month$DT),
                                 format = "%Y-%m-%d %H:%M ")
      dta_yr_list[[i]] <- dta_month
      cat(" OK\n")
    } else {
      cat(" FAILED\n")
    }
  }
  
  # Combine this year's data
  if (length(dta_yr_list) > 0) {
    dta_all[[as.character(yr)]] <- do.call(rbind, dta_yr_list)
    cat("Year", yr, "complete:", nrow(dta_all[[as.character(yr)]]), "total rows\n")
  }
}

cat("\n========================================\n")
cat("FINISHED! Processing", length(dta_all), "years\n")
cat("========================================\n")

# Continue with the rest of the original script...
dta_all <- dta_all[which(x = !sapply(X = dta_asll, FUN = is.null))]

dta_out <- do.call(what = rbind,
                   args = dta_all[sapply(X = dta_all, FUN = is.list)])

saveRDS(object = dta_out,
        file = paste0(pth, "prec_data.rds"))

cat("SAVED to:", paste0(pth, "prec_data.rds"), "\n")

## Notes on statistical functions

## iqr, mean, sd, boxplot
## homework -> do some reading about ACF & distribution function|quantile function|density

# ===== BASIC SUMMARY STATISTICS =====

# IQR (Interquartile Range)
# IQR(x, na.rm = FALSE)
# - Measures spread: difference between 75th and 25th percentiles (Q3 - Q1)
# - na.rm = TRUE to ignore missing values
# Example: IQR(c(1, 3, 5, 7, 9)) returns 4

# MEAN (Arithmetic Average)
# mean(x, trim = 0, na.rm = FALSE)
# - Sum of values divided by count
# - trim: fraction of observations to remove from each end (0 to 0.5)
# - na.rm = TRUE to handle NAs
# Example: mean(c(1, 2, 3, 4, 5)) returns 3

# SD (Standard Deviation)
# sd(x, na.rm = FALSE)
# - Measures variability around the mean
# - Square root of variance
# - na.rm = TRUE to ignore missing values
# Example: sd(c(2, 4, 6, 8)) 

# BOXPLOT
# boxplot(x, ..., range = 1.5, names, col, main, xlab, ylab)
# - Visual summary: shows median, quartiles, and outliers
# - range: multiplier for IQR to determine outliers (1.5 default)
# - Can compare multiple groups: boxplot(value ~ group, data = df)
# Example: boxplot(mtcars$mpg, main = "MPG Distribution")


# ===== TIME SERIES & DISTRIBUTIONS =====

# ACF (Autocorrelation Function)
# acf(x, lag.max = NULL, type = "correlation", plot = TRUE, na.action)
# - Measures correlation of series with lagged versions of itself
# - lag.max: max number of lags (default is ~10*log10(n))
# - type: "correlation", "covariance", or "partial"
# - Useful for identifying patterns in time series data
# Example: acf(AirPassengers, lag.max = 20)

# DISTRIBUTION FUNCTIONS (d/p/q/r prefix pattern)
# For each distribution (norm, binom, pois, etc.):

# d____ - DENSITY function (PDF for continuous, PMF for discrete)
# dnorm(x, mean = 0, sd = 1) - height of normal curve at x
# dbinom(x, size, prob) - probability of exactly x successes

# p____ - DISTRIBUTION function (CDF - cumulative probability)
# pnorm(q, mean = 0, sd = 1) - P(X <= q) for normal distribution
# pbinom(q, size, prob) - P(X <= q) for binomial

# q____ - QUANTILE function (inverse CDF)
# qnorm(p, mean = 0, sd = 1) - value where P(X <= x) = p
# qbinom(p, size, prob) - the pth quantile
# Example: qnorm(0.975) gives 1.96 (95% CI cutoff)

# r____ - RANDOM generation
# rnorm(n, mean = 0, sd = 1) - generate n random normal values
# rbinom(n, size, prob) - generate n random binomial values
# Example: rnorm(100, mean = 50, sd = 10)

# Common distributions: norm, binom, pois, t, chisq, f, unif, exp
