library(shiny)
library(shinydashboard)
library(tidyverse)
library(rsconnect)
library(readxl)
library(DT)
library(rdrop2)
library(openxlsx)

# dropbox folder name
outputDir <- "training"

saveData <- function(df) {
    df <- read_excel(df)
    fileName <- "data.csv"
    filePath <- file.path(tempdir(), fileName)
    write_csv(df, filePath)
    drop_upload(filePath, path = outputDir)
}


loadData <- function() {
    fileInfo <- drop_dir(outputDir)
    filePath <- fileInfo$path_display
    data <- drop_read_csv(filePath)
    data
}

function(input, output, session) {
    
    output$mainTable <- renderDataTable(datatable({
        req(input$datafile)
        tryCatch(
            {
                df <- read_excel(input$datafile$datapath)
                # saveData(input$datafile$datapath)
            },
            error = function(e) {
                stop(safeError(e))
            }
        )
        # manipulate raw excel data here
        return(df)
        # return(loadData())
    }))
    
}