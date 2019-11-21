library(shiny)
library(shinydashboard)
library(tidyverse)
library(rsconnect)
library(readxl)
library(DT)
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
        )
    return(df)
}

expired <- function(df) {
    filter(df, Expire_Date < today()) %>% arrange(Expire_Date)
}

thismonth <- function(df) {
    filter(df,
        month(Expire_Date) == month(today()),
        year(Expire_Date) == year(today()),
        Expire_Date > today()
    ) %>%
    arrange(Expire_Date)
}

nextmonth <- function(df) {
    filter(df,
        month(Expire_Date) == month(today()) + 1,
        year(Expire_Date) == year(today())
    ) %>%
    arrange(Expire_Date)
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


function(input, output, session) {
    
    dataframe   <- reactive({read_excel(input$expiryFile$datapath)})
    result      <- reactive({manipulator(dataframe())})
    vendor      <- reactive({input$company})
    dateType    <- reactive({input$datetype})
    
    output$expiryTable <- renderDataTable(datatable({
        req(input$expiryFile)
        tryCatch(
            {dataframe()},
            error = function(e) {stop(safeError(e))}
        )
        final <- result() %>% 
            groupByVendor(vendor()) %>% 
            groupByDate(dateType()) %>%
            select(1, 2, 4, 5)
        
        return(final)
    }))
    
    totalEmployee <- reactive({
        validate(need(input$expiryFile != "", "Waiting for excel file..."))
        total <- result() %>% 
            groupByVendor(vendor()) %>% 
            group_by(SAP) %>%
            tally()
        return(count(total[2]))
    })
    
    totalTraining <- reactive({
        validate(need(input$expiryFile != "", "Waiting for excel file..."))
        total <- result() %>%
            groupByVendor(vendor()) %>%
            nrow()
        return(total)
    })
    
    totalExpired <- reactive({
        validate(need(input$expiryFile != "", "Waiting for excel file..."))
        total <- result() %>%
            groupByVendor(vendor()) %>%
            groupByDate("expired") %>%
            nrow()
        return(total)
    })
    
    output$totalEmp <- renderInfoBox({
        infoBox(value = totalEmployee(), title = 'Total Employee', icon = icon("user"), color = 'teal')
    })
    
    output$totalTraining <- renderInfoBox({
        infoBox(value = totalTraining(), title = 'Total Training', icon = icon("book-reader"), color = 'teal')
    })
    
    output$expiredPercent <- renderInfoBox({
        percent = round(totalExpired() / totalTraining(), 4)
        infoBox(value = 1 - percent, title = 'Expiration Percentage', icon = icon("chart-line"), color = 'teal')
    })

}
