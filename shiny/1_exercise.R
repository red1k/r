library(shiny)

ui <- fluidPage(
    textInput("name", "What is your name?"),
    textOutput("greeting"),
    
    numericInput("age", label = "How old are you?", value = 18),
    textOutput("ager"),
    plotOutput("hist"),
    
    sliderInput("x", "If x is", min = 1, max = 50, value = 30),
    sliderInput("y", "and y is", min = 1, max = 50, value = 5),
    "then, (x * y) is", textOutput("product"),
    "and, (x * y) + 5 is", textOutput("product_plus5"),
    "and (x * y) + 10 is", textOutput("product_plus10")
    
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
    
    multiplied <- reactive({
        input$x * input$y
    })
    
    output$product <- renderText({
        multiplied()
    })
    
    output$product_plus5 <- renderText({
        multiplied() + 5
    })
    
    output$product_plus10 <- renderText({
        multiplied() + 10
    })
    
}

shinyApp(ui, server)
