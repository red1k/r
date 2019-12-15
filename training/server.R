library(shiny)
library(shinydashboard)
library(DT)
library(rsconnect)
source('func.R')


function(input, output, session) {
    
    expiryDateRaw    <- reactive({read_excel(input$expiryFile$datapath)})
    expiryDateClean  <- reactive({manipulator(expiryDateRaw())})
    vendor           <- reactive({input$company})
    dateType         <- reactive({input$datetype})

    courseDataRaw    <- reactive({read_excel(input$courseFile$datapath, sheet = 'Course')})
    courseDataClean  <- reactive({coursera(courseDataRaw())})
    location         <- reactive({input$location})
    whichCourse      <- reactive({input$courseChoice})
    
    # EXPIRY TABLE ####################################
    output$expiryTable <- renderDT(
        datatable({
			req(input$expiryFile)
			tryCatch(
				{expiryDateRaw()},
				error = function(e) {stop(safeError(e))}
			)
			final <- expiryDateClean() %>%
				groupByVendor(vendor()) %>%
				groupByDate(dateType()) %>%
				select(1, 2, 4, 5)

			return(final)
		}),
        extensions = c("Buttons", "Responsive"),
        options = list(
            dom = 'Bfrtip',
            buttons = c('print', 'excel', 'pdf', 'csv')
        ),
        selection = 'single',
        server = FALSE
    )
    
    # COURSE TABLE ####################################
    output$courseTable <- renderDataTable(
        datatable({
			req(input$courseFile)
			tryCatch(
				{courseDataRaw()},
				error = function(e) {stop(safeError(e))}
			)
			final <- courseDataClean() %>%
				whichLocation(location = location())

			if (whichCourse() == 'mandatory') {
				final <- mandatoryCourses(final)
			}

			return(select(final, 1:2, 5:8))
        }),
        extensions = c("Buttons", "Responsive"),
        options = list(
            dom = 'Bfrtip',
            buttons = c('print', 'excel', 'pdf', 'csv')
        ),
        selection = 'single',
        server = FALSE
    )

    # INFO BOXES ######################################
    totalEmployee <- reactive({
        validate(need(input$expiryFile != "", "Waiting for excel file..."))
        total <- expiryDateClean() %>%
            groupByVendor(vendor()) %>% 
            group_by(SAP) %>%
            tally()
        return(count(total[2]))
    })
    
    totalTraining <- reactive({
        validate(need(input$expiryFile != "", "Waiting for excel file..."))
        total <- expiryDateClean() %>%
            groupByVendor(vendor()) %>%
            nrow()
        return(total)
    })
    
    totalExpired <- reactive({
        validate(need(input$expiryFile != "", "Waiting for excel file..."))
        total <- expiryDateClean() %>%
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
        percent = paste(round(totalExpired() / totalTraining(), 4) * 100, "%", sep = "")
        infoBox(value = percent, title = 'Expiration Percentage', icon = icon("chart-line"), color = 'teal')
    })

}
