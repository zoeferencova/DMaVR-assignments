## Read the previously saved RDS file containing all precipitation data
## This file was created in the previous assignment
dta <- readRDS(file = "~/Desktop/DMaVR-assignments/assignment_01/data/prec_data.rds")

## Assignment goal: Calculate mean, sd, iqr, min, max for precipitation
## for each station and each year using data.table package

## Install data.table package (only needed once)
# install.packages("data.table")

## Load the data.table library to access its functions
library(data.table)

## Check the current class of the data object
## Should return "data.frame"
class(x = dta)

## Convert the data.frame to a data.table object
## data.table is much faster for large datasets and has powerful syntax
dta_t <- as.data.table(x = dta)

## Verify it's now a data.table (should show "data.table" "data.frame")
class(dta_t)

## Display first 6 rows of original data.frame (traditional output)
head(x = dta)

## Display the data.table (shows first and last rows by default)
## data.table has a more informative print method
dta_t

## Compare memory usage between data.frame and data.table
object.size(x = dta_t)  # Memory used by data.table
object.size(x = dta)    # Memory used by data.frame (usually same or slightly larger)

## The data.table syntax is: DT[i, j, by]
## i = which rows (like WHERE in SQL)
## j = what to do with columns (like SELECT in SQL)
## by = grouping (like GROUP BY in SQL)

# dta_t[i, j, by]

## EXAMPLE 1: Subset rows (i parameter)
## Get rows 1 through 20
dta_t[1:20,]

## EXAMPLE 2: Select a single column (j parameter)
## Returns the DT column as a vector
dta_t[, DT]

## EXAMPLE 3: Select multiple columns (j parameter with .() syntax)
## .() is data.table's shorthand for list()
## Returns a data.table with only DT and VALUE columns
dta_t[, .(DT, VALUE)]

## EXAMPLE 4: Filter rows AND select columns (i and j together)
## Get only rows where precipitation VALUE is greater than 0
## Select only STATION, DT, and VALUE columns
dta_t[VALUE > 0, .(STATION, DT, VALUE)]

## Note: .() is exactly the same as list() in data.table

## Create a new data.table with only non-zero precipitation values
## This is stored as 'nz' (short for "non-zero")
nz <- dta_t[VALUE > 0, .(STATION, DT, VALUE)]

## Calculate summary statistics grouped by STATION
## by = STATION means: calculate these stats separately for each station
nz[, .(mean = mean(x = VALUE),     # Average precipitation
       sd = sd(x = VALUE),         # Standard deviation
       iqr = IQR(x = VALUE),       # Interquartile range (75th - 25th percentile)
       min = min(x = VALUE),       # Minimum value
       max = max(x = VALUE)),      # Maximum value
   by = STATION]

## Calculate the same statistics, but grouped by both STATION and YEAR
## by = .(STATION, year(DT)) means: group by station AND year
## year() is a data.table function that extracts the year from a date
nz[, .(mean = mean(x = VALUE), 
       sd = sd(x = VALUE), 
       iqr = IQR(x = VALUE), 
       min = min(x = VALUE), 
       max = max(x = VALUE)),
   by = .(STATION, year(x = DT))]

## This does the exact same calculation as above, but in one step
## Instead of creating 'nz' first, it filters and aggregates in one command
dta_t[VALUE > 0, .(mean = mean(x = VALUE), 
                   sd = sd(x = VALUE), 
                   iqr = IQR(x = VALUE), 
                   min = min(x = VALUE), 
                   max = max(x = VALUE)),
      by = .(STATION, year(x = DT))]

## Add a new column to the data.table using := (modify by reference)
## This creates a column called "new_col" with value TRUE for all rows
## := modifies the data.table in place
nz[, new_col := TRUE]

## Display the data.table to see the new column
nz

## Rename columns in the data.table
## setnames() modifies the data.table directly (by reference)
## old = vector of current column names to rename
## new = vector of new names (must be same length as old)
## skip_absent = TRUE means don't throw error if a column doesn't exist
setnames(x = nz,
         old = c("new_col", "not_exists"), # "not_exists" doesn't exist
         new = c("RENAME", "something"),
         skip_absent = TRUE)  # Skip "not_exists" without error

## Delete a column by setting it to NULL
## This removes the RENAME column from the data.table
nz[, RENAME := NULL]

## Create a row ID column that restarts at 1 for each STATION
## .N is a special data.table symbol meaning "number of rows in this group"
## 1:.N creates a sequence from 1 to the number of rows
## by = STATION means the sequence restarts for each station
nz[, id := 1:.N,
   by = STATION]

## These examples show dcast (wide format) and melt (long format)
## They are commented out because they would create very large datasets

## dcast converts from long to wide format
## Each station becomes its own column, with DT as rows
# dta_wide <- dcast(data = nz,
#                   formula = id + DT ~ STATION,
#                   value.var = "VALUE")

## Alternative dcast version (also commented out)
# dta_wide <- dcast(data = dta_t[, .(STATION, DT, VALUE)],
#                   formula = DT ~ STATION,
#                   value.var = "VALUE")

## melt converts from wide back to long format
## id.vars are the columns to keep as identifiers
## All other columns become variable-value pairs
# dta_long <- melt(data = dta_wide,
#                  id.vars = c("id", "DT"))

## Show original data (just for reference)
# dta

## Task: Merge the non-zero values (nz) back with zero values
## WITHOUT using the original dataset
## Goal: Recreate the complete time series including hours with 0 precipitation

## Look up the merge function documentation
?data.table::merge

## Create a data.table with zero values for every hour in the date range
## This creates a complete hourly time series from 2018 to 2026
dt <- data.table(VALUE = 0,                          # All values are 0
                 DT = seq(from = as.POSIXct(x = "2018-01-01 00:00:00"),  # Start date
                          to = as.POSIXct(x = "2026-01-01 00:00:00"),    # End date
                          by = "hour"))               # Create one row per hour

## fread() - Fast file reading, much faster than read.table/read.csv
?fread()

## fwrite() - Fast file writing, much faster than write.table/write.csv
?fwrite()

## frollapply() - Fast rolling window calculations (moving averages, etc.)
?frollapply()

## merge() - Join/merge data.tables together (like SQL JOIN)
?data.table::merge