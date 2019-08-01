library(tidyverse)
library(shiny)

fluidPage(
    sliderInput(inputId = 'num', 
                label = 'Choose number',
                value = 50, min = 1, max = 100),
    plotOutput(outputId = 'hist')
)
