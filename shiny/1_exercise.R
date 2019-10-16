library(shiny)

df <- data
ui <- fluidPage(
    textInput("name", "What is your name?"),
    textOutput("greeting"),
    numericInput("age", label = "How old are you?", value = 18),
    textOutput("ager"),
    plotOutput("hist"),
    sliderInput(inputId = "x", label = "Multiplier_x", min = 1, max = 50, value = 18),
    sliderInput(inputId = "y", label = "Multiplier_y", min = 1, max = 50, value = 10),
    textOutput("result")
)

server <- function(input, output, session) {
    
    output$greeting <- renderText({
        paste0("Hello ", input$name)
    })
    
    output$ager <- renderText({
        paste0("You are ", input$age, " years old")
    })
    
    output$hist <- renderPlot({
        if(is.na(input$age)) {
            hist(rnorm(10))
        }
        else {
            hist(rnorm(input$age))
        }
    })
    
    output$result <- renderText({
        result = input$x * input$y
        result
    })
    
}

shinyApp(ui, server)
