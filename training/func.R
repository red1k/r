library(tidyverse)
library(readxl)
library(lubridate)
library(RSQLite)

coursera <- function(df) {
    df$Date <- date(df$`Start Date`)
    df$Time <- paste(substr(df$`Start time`, 12, 16), substr(df$`End time`, 12, 16), sep = "-")
    df <- df %>%
        select(-13, -11, -10, -5:-8) %>%
        filter(
            str_detect(Abbreviation, "OPS"),
            `Seats Available` > 0,
            Date >= today()
        ) %>%
        arrange(Date)
    colnames(df) <- c('ID', 'Course', 'Abbr', 'Location', 'Seats', 'Room', 'Date', 'Time')
    return(df)
}

expired <- function(df) {
    filter(df, Expire_Date < today())
}

thismonth <- function(df) {
    filter(df,
        month(Expire_Date) == month(today()),
        year(Expire_Date) == year(today()),
        Expire_Date > today()
    )
}

nextmonth <- function(df) {
    filter(df,
        month(Expire_Date) == if_else(month(today()) == 12, 1, month(today()) + 1),
        year(Expire_Date) == if_else(month(today()) == 12, year(today()) + 1, year(today()))
    )
}

all <- function(df) {
    df1 <- expired(df)
    df2 <- thismonth(df)
    df3 <- nextmonth(df)
    return(rbind(df1, df2, df3))
}

groupByVendor <- function(df, vendor) {
    filter(df, Vendor == vendor)
}

groupByDate <- function(df, date) {
    final <- switch(date,
           'expired' = expired(df),
           'thismonth' = thismonth(df),
           'nextmonth' = nextmonth(df),
           'all' = all(df))
    return(final)
}

whichLocation <- function(df, location) {
    return(filter(df, Location == location))
}

mandatoryCourses <- function(df) {
    return(filter(df, str_detect(Course, "OT Induction|Pretask|CRM for team|Personal Lockholder")))
}

db_data <- function() {
    db <- dbConnect(SQLite(), "tables.db")
    raw <- dbReadTable(db, 'expirydate')

    raw$Expire_Date = as.Date(as.integer(raw$Expire_Date), origin = '1899-12-30')
    raw$Vendor <- str_replace(raw$Vendor, "Not assigned", "Other")
    raw$Vendor <- str_replace(raw$Vendor, "CENTRAL ASIAN MINING LOGI", "Other")
    raw$Vendor <- str_replace(raw$Vendor, "SPECIALIZED CAREER CONSULTING LLC", "Other")

    return(arrange(raw, Expire_Date))
}
