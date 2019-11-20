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
    df <- df %>%
        gather(`1`:`8`, key = 'key', value = 'Expire_Date', na.rm = TRUE) %>%
        filter(Vendor == 'UMNUGOVI TEEWRIIN NEGDEL LLC') %>%
        select(1, 2, 5, 7) %>%
        mutate(
            SAP = as.integer(SAP),
            Expire_Date = as.Date(as.integer(Expire_Date), origin = '1899-12-30')
        )
    return(df)
}

expired <- function() {
    filter(df, Expire_Date < today()) %>%
    arrange(Expire_Date)
}

thismonth <- function() {
    filter(df,
        month(Expire_Date) == month(today()),
        year(Expire_Date) == year(today()),
        Expire_Date > today()
    ) %>%
    arrange(Expire_Date)
}

nextmonth <- function() {
    filter(df,
        month(Expire_Date) == month(today()) + 1,
        year(Expire_Date) == year(today())
    ) %>%
    arrange(Expire_Date)
}

all <- function() {
    df1 <- expired()
    df2 <- thismonth()
    df3 <- nextmonth()
    df_combined <- rbind(df1, df2, df3)
    return(df_combined)
}

df <- read_excel("data.xlsx")
df <- manipulator(df)

function(input, output, session) {
    
    df <- reactive({
        read_excel(input$expiryFile$datapath)
    })

    tableType <- reactive({
        switch(input$datetype,
               expired = expired(),
               thismonth = thismonth(),
               nextmonth = nextmonth(),
               all = all())
    })

    output$expiryTable <- renderDataTable(datatable({
        req(input$expiryFile)
        tryCatch(
            {df()},
            error = function(e) {stop(safeError(e))}
        )
        result <- manipulator(df())
        result <- tableType()

        return(result)
    }))
    
    output$totalEmp <- renderInfoBox({
        infoBox(value = 100, title = 'Total Employee')
    })

}
