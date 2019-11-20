library(shiny)
library(shinydashboard)
library(tidyverse)
library(rsconnect)
library(readxl)
library(DT)
library(lubridate)

dashboardPage(
    dashboardHeader(title = 'SGC Training'),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Expiration Date", tabName = "expiry"),
            menuItem("Course Table", tabName = "course"),
            menuItem("About", tabName = "about")
        )
    ),
    
    dashboardBody(
        tabItems(
            # expiry information
            tabItem(tabName = "expiry",
                fluidRow(
                    column(width = 1),
                    column(width = 10,
                        # info boxes
                        infoBoxOutput("totalEmp"),
                        infoBox("Expired Percentage", '98%', icon = icon("calendar")),
                        infoBox("Another Useful Info", '?'),

                        # main table box
                        box(title = "Expiry Table", status = "primary", solidHeader = TRUE, width = 12, height = '600px',
                            sidebarPanel(
                                radioButtons("datetype", "Choose:",
                                    c("Expired" = "expired",
                                      "This Month" = "thismonth",
                                      "Next Month" = "nextmonth",
                                      "All" = "all"
                                    )
                                ),
                                width = 2
                            ),
                            mainPanel(
                                dataTableOutput("expiryTable"),
                                width = 10
                            )
                        )
                    )
                ),
                fluidRow(
                    column(width = 1),
                    column(width = 4,
                        fileInput(
                            inputId = "expiryFile", label = "Upload the latest course data file",
                            multiple = FALSE, accept = c(".xlsx")
                        )
                    )
                )
            ),
            # course information
            tabItem(tabName = "course",
                fluidRow(
                    column(width = 1),
                    column(width = 10,
                        box(title = "Course Information", status = "primary", solidHeader = TRUE, width = 12, height = '600px',
                            dataTableOutput("courseTable")
                        )
                    )
                ),
                fluidRow(
                    column(width = 1),
                    column(width = 4,
                        fileInput(
                            inputId = "courseFile", label = "Upload the latest course data file",
                            multiple = FALSE, accept = c(".xlsx")
                        )
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
