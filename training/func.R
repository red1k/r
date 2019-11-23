library(tidyverse)
library(readxl)
library(lubridate)

manipulator <- function(df) {
    df <- tail(df, -3)
    names(df) <- c("SAP", "Full_Name", "Vendor", "blah1", "Course", 1:8)
    
    df$Vendor <- str_replace(df$Vendor, "Not assigned", "Other")
    df$Vendor <- str_replace(df$Vendor, "CENTRAL ASIAN MINING LOGI", "Other")
    df$Vendor <- str_replace(df$Vendor, "SPECIALIZED CAREER CONSULTING LLC", "Other")
    
    df <- df %>%
        gather(`1`:`8`, key = 'key', value = 'Expire_Date', na.rm = TRUE) %>%
        select(1, 2, 3, 5, 7) %>%
        mutate(
            SAP = as.integer(SAP),
            Expire_Date = as.Date(as.integer(Expire_Date), origin = '1899-12-30')
        ) %>%
        arrange(Expire_Date)
    return(df)
}

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
        month(Expire_Date) == month(today()) + 1,
        year(Expire_Date) == year(today())
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
