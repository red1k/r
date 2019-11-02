library(tidyverse)
library(vroom)
library(neiss)

injuries   <- neiss::injuries
products   <- neiss::products
population <- neiss::population

glimpse(injuries)

selected <- injuries %>% filter(prod1 == 1842)
nrow(selected)

selected %>% count(diag, wt = weight, sort = TRUE)
selected %>% count(body_part, wt = weight, sort = TRUE)
selected %>% count(location, wt = weight, sort = TRUE)

summary <- selected %>%
    count(age, sex, wt = weight)

summary %>%
    ggplot(aes(age, n, color = sex)) +
    geom_line() +
    labs(y = "Estimated number of injuries")

# comparing the number of people injured with the total population

selected$age <- ceiling(selected$age)
selected$sex <- tolower(selected$sex)

summary <- selected %>%
    count(age, sex, wt = weight) %>%
    left_join(population, by = c("age", "sex")) %>%
    mutate(rate = n.x / n.y * 1e4)

summary %>%
    ggplot(aes(age, rate, color = sex)) +
    geom_line(na.rm = TRUE) +
    labs(y = "Injuries per 10,000 people")

selected %>%
    sample_n(10) %>%
    pull(narrative)
