library(tidyverse)
library(vroom)
library(shiny)

injuries   <- neiss::injuries
products   <- neiss::products
population <- neiss::population

injuries$age <- ceiling(injuries$age)
injuries$sex <- tolower(injuries$sex)

# keeping only products appears in injuries table
# avoiding ugly NA tables in dashboard
onlyProducts <- products %>%
    inner_join(injuries, by = c("code" = "prod1")) %>%
    select(1:2) %>%
    unique()


# Shiny app

ui <- fluidPage(
    
    fluidRow(
        column(6,
           # setNames function <- shows product name in the UI
           # returns product code to the server
           selectInput(
                "code", "Product",
                choices = setNames(onlyProducts$code, onlyProducts$title),
                width = "100%"
           )
        ),
        column(3,
            selectInput("y", "Y axis", c("rate", "count"))
        ),
        column(3,
            numericInput("row", "How many rows?", value = 4)
        )
    ),
    
    fluidRow(
        column(4, tableOutput("diag")),
        column(4, tableOutput("body_part")),
        column(4, tableOutput("location"))
    ),
    
    fluidRow(
        column(12, plotOutput("age_sex"))
    ),

    fluidRow(
        column(2, actionButton("story", "Tell me a story!")),
        column(10, textOutput("narrative"))
    )
    
)


server <- function(input, output, session) {
    
    selected <- reactive(injuries %>% filter(prod1 == input$code))
    
    count_top <- function(df, var, n = input$row) {
        df %>%
            mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
            group_by({{ var }}) %>%
            summarise(n = as.integer(sum(weight)))
    }
    
    output$diag      <- renderTable(count_top(selected(), diag), width = "100%")
    output$body_part <- renderTable(count_top(selected(), body_part), width = "100%")
    output$location  <- renderTable(count_top(selected(), location), width = "100%")
    
    sumly <- reactive({
        selected() %>%
            count(age, sex, wt = weight) %>%
            left_join(population, by = c("age", "sex")) %>%
            mutate(rate = n.x / n.y * 1e4)
    })
    
    output$age_sex <- renderPlot({

        if (input$y == "count") {
            sumly() %>%
                ggplot(aes(age, n.x, color = sex)) +
                geom_line(na.rm = TRUE) +
                labs(y = "Estimated number of injuries")
        } else {
            sumly() %>%
                ggplot(aes(age, rate, color = sex)) +
                geom_line() +
                labs(y = "Injuries per 10,000 people")
        }

    })

    output$narrative <- renderText({
        input$story
        selected() %>% pull(narrative) %>% sample(1)
    })
  
}

shinyApp(ui, server)
