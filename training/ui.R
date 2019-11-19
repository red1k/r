library(shiny)
library(shinydashboard)
library(tidyverse)
library(rsconnect)
library(readxl)
library(DT)
library(rdrop2)
library(openxlsx)

dashboardPage(
    dashboardHeader(title = 'SGC Training'),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard"),
            menuItem("File Upload", tabName = "file"),
            menuItem("About", tabName = "about")
        )
    ),
    
    dashboardBody(
        tabItems(
            # MAIN PAGE
            tabItem(tabName = "dashboard",
                column(width = 1),
                column(width = 10,
                    # info boxes
                    infoBox("Total Employee", 103),
                    infoBox("Expired Percentage", '98%', icon = icon("calendar")),
                    infoBox("Another Useful Info", '?'),
                    
                    # main table box
                    box(title = "Training Table", status = "primary", solidHeader = TRUE, width = 12, height = '700px',
                        dataTableOutput("mainTable")
                    )
                )
            ),
            # FILE UPLOADING PAGE
            tabItem(tabName = "file",
                column(width = 1),
                column(width = 8,
                    fileInput(
                        inputId = "datafile", label = "Upload the latest course data file",
                        multiple = FALSE, accept = c(".xlsx")
                    )
                )
            ),
            # ABOUT PAGE
            tabItem(tabName = "about",
                column(width = 1),
                column(width = 8,
                    p("SGC training dashboard"),
                    p("Used R shiny, shinydashboard packages")
                )
            )
        )
    )
)
