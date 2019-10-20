library(shiny)

ui <- fluidPage(
    
    theme = shinythemes::shinytheme("united"),
    
    headerPanel("First Shiny App"),
    
    sidebarLayout(
        sidebarPanel(
            textInput(
                inputId = "name", label = "Text Input",
                placeholder = "Your name"
            ),
            selectInput(
                inputId = "subheader",
                label = "Selectize",
                choices = list(
                    number = c(1, 2, 3),
                    names  = c('one', 'two', 'three')
                )
            ),
            sliderInput(
                inputId = 'animate',
                label = 'Slider with animation',
                min = 0, max = 100,
                value = 5, step = 5,
                animate = animationOptions(interval = 500, loop = TRUE)
            )
        ),
        mainPanel(
            verbatimTextOutput(outputId = "user"),
            verbatimTextOutput(outputId = "subHeader"),
            dataTableOutput("table")
        )
    ),
    
    # another way to split multiple outputs
    # splitLayout(
    #     cellWidths = c("33%", "67%"),
    #     verbatimTextOutput("just sitting here, nobody sees me"),
    # ),
    
    verbatimTextOutput(outputId = "summary"),
    verbatimTextOutput(outputId = "animation"), # need to replace
    
    fluidRow(
        column(4,
            plotOutput(outputId = "ploty", height = "230px")        
        ),
        column(8,
            plotOutput(outputId = "plot", height = "230px")        
        )
    )
    
)

server <- function(input, output, session) {
    
    output$user <- renderText(
        if(input$name == "") {"Name appears here"}
        else {input$name}
    ) 
    
    output$subHeader <- renderText(input$subheader) 
    
    output$table <- renderDataTable(
        mtcars,
        options = list(
            scrollY = "160px", searching = FALSE,
            ordering = FALSE, paging = FALSE, info = FALSE
        )
    )
    
    output$ploty <- renderPlot(plot(1:10))
    output$plot  <- renderPlot(plot(1:input$animate))
    
    output$summary   <- renderText("Summary") # need to replace
    output$animation <- renderPrint(summary(1:input$animate))
    
}

shinyApp(ui, server)
