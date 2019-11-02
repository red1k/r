library(tidyverse)
library(vroom)
library(shiny)

injuries   <- neiss::injuries
products   <- neiss::products
population <- neiss::population

selected <- injuries %>% filter(prod1 == 1842)
selected$age <- ceiling(selected$age)
selected$sex <- tolower(selected$sex)

summary <- selected %>%
    count(age, sex, wt = weight) %>%
    left_join(population, by = c("age", "sex")) %>%
    mutate(rate = n.x / n.y * 1e4)

count_top <- function(df, var, n = 5) {
    df %>%
        mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
        group_by({{ var }}) %>%
        summarise(n = as.integer(sum(weight)))
}

# Shiny app

ui <- fluidPage(
    
    fluidRow(
        column(6,
               # setNames function <- shows product name in the UI
               # returns product code to the server
               selectInput("code", "Product", setNames(products$code, products$title))
        )
    ),
    
    fluidRow(
        column(4, tableOutput("diag")),
        column(4, tableOutput("body_part")),
        column(4, tableOutput("location"))
    ),
    
    fluidRow(
        column(12, plotOutput("age_sex"))
    )
    
)

server <- function(input, output, session) {
    
    selected <- reactive(injuries %>% filter(prod1 == input$code))
    
    output$diag <- renderTable(
        count_top(selected(), diag), width = "100%"
    )
    
    output$body_part <- renderTable(
        count_top(selected(), body_part), width = "100%"
    )
    
    output$location <- renderTable(
        count_top(selected(), location), width = "100%"
    )
    
    summary <- reactive({
        selected() %>%
            count(age, sex, wt = weight) %>%
            left_join(population, by = c("age", "sex")) %>%
            mutate(rate = n.x / n.y * 1e4)
    })
    
    output$age_sex <- renderPlot({
        summary() %>%
            ggplot(aes(age, n.x, color = sex)) +
            geom_line(na.rm = TRUE) +
            labs(y = "Estimated number of injuries")
    })
  
}

shinyApp(ui, server)
