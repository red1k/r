library(shiny)
library(shinydashboard)
library(tidyverse)
library(rsconnect)
library(readxl)
library(DT)
library(lubridate)

manipulator <- function(df, company, date) {
    df <- tail(df, -3)
    names(df) <- c("SAP", "Full_Name", "Vendor", "blah1", "Course", 1:8)
    df$Vendor <- str_replace(df$Vendor, "Not assigned", "Other")
    df$Vendor <- str_replace(df$Vendor, "CENTRAL ASIAN MINING LOGI", "Other")
    df$Vendor <- str_replace(df$Vendor, "SPECIALIZED CAREER CONSULTING LLC", "Other")
    df <- df %>%
        gather(`1`:`8`, key = 'key', value = 'Expire_Date', na.rm = TRUE) %>%
        filter(Vendor == company) %>%
        select(1, 2, 5, 7) %>%
        mutate(
            SAP = as.integer(SAP),
            Expire_Date = as.Date(as.integer(Expire_Date), origin = '1899-12-30')
        )

    final <- switch(date,
           'expired' = expired(df),
           'thismonth' = thismonth(df),
           'nextmonth' = nextmonth(df),
           'all' = all(df))

    return(final)
}

expired <- function(df) {
    filter(df, Expire_Date < today()) %>%
    arrange(Expire_Date)
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
    df_combined <- rbind(df1, df2, df3)
    return(df_combined)
}

df <- read_excel("data.xlsx")
df <- manipulator(df, company = "UMNUGOVI TEEWRIIN NEGDEL LLC", date = "expired")

function(input, output, session) {
    
    df <- reactive({
        read_excel(input$expiryFile$datapath)
    })

    tableType <- reactive({input$datetype})
    vendor <- reactive({input$company})

    output$expiryTable <- renderDataTable(datatable({
        req(input$expiryFile)
        tryCatch(
            {df()},
            error = function(e) {stop(safeError(e))}
        )
        result <- manipulator(df(), company = vendor(), date = tableType())
        return(result)
    }))
    
    output$totalEmp <- renderInfoBox({
        infoBox(value = 100, title = 'Total Employee')
    })

}
