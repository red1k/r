library(shiny)
library(shinydashboard)
library(tidyverse)
library(rsconnect)
library(readxl)
library(DT)
library(lubridate)

dashboardPage(
    dashboardHeader(title = 'Training Dashboard'),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Expiration Date", tabName = "expiry", icon = icon("chart-bar")),
            menuItem("Course Table", tabName = "course", icon = icon("calendar")),
            menuItem("About", tabName = "about", icon = icon("info"))
        )
    ),
    
    dashboardBody(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
        ),
        tabItems(
            # expiry information
            tabItem(tabName = "expiry",
                fluidRow(
                    column(width = 1),
                    column(width = 10,
                        # info boxes
                        infoBoxOutput("totalEmp"),
                        infoBoxOutput("totalTraining"),
                        infoBoxOutput("expiredPercent"),

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
                                width = 2,
                                br(),
                                radioButtons("company", "Which company:",
                                    c("SGC" = "UMNUGOVI TEEWRIIN NEGDEL LLC",
                                      "TERRA" = "TERRA EXPRESS LLC",
                                      "KBTL" = "KHANBOGD TEEVER LOGISTIC LLC",
                                      "OLT" = "Other"
                                    )
                                )
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
                column(width = 4),
                column(width = 8,
                    h3("Used R shiny, shinydashboard packages")
                )
            )
        )
    )
)
