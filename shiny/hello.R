library(tidyverse)
library(shiny)

# inputs:
# actionButton()
# submitButton()
# radioButtons()

# checkboxInput()
# checkboxGroupInput()

# dateInput()
# dateRangeInput()

# fileInput()
# selectInput()

# numericInput()
# textInput()
# sliderInput()
# passwordInput()

# SYNTAX - *Input
# inputId = 'num'  <- input name
# label = 'Choose' <- label to display

# SYNTAX - *Output
# outputId = 'hist'

ui <- fluidPage(
    sliderInput(inputId = 'num', 
                label = 'Choose number',
                value = 50, min = 1, max = 100),
    plotOutput(outputId = 'hist')
)

server <- function(input, output) {
   output$hist <- renderPlot({
       #ggplot(input, aes(x=rnorm(input$num))) + 
       #geom_histogram()
       hist(rnorm(input$num))
   }) 
}

shinyApp(ui = ui, server = server)
