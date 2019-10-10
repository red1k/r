library(tidyverse)
library(lubridate)

setwd('~/git/r/smartcap')

df <- read_csv('data.csv')

glimpse(df)

df <- df %>%
    mutate(
        Timestamp = dmy_hms(Timestamp),
        Date = as.Date(Timestamp)
    ) %>%
    select(
        -c('Headwear ID',
           'Shift Start Date/Time',
           'Shift End Date/Time')
    )

names(df) <- str_replace_all(names(df), ' ', '')

df %>%
    group_by(Date, OperatorFirstName) %>%
    tally() %>%
    filter(n < 50) %>%
    ggplot(aes(x = n, y = Date)) +
    geom_point() +
    facet_wrap(~OperatorFirstName) +
    coord_flip()

test <- df %>%
    group_by(Date, OperatorFirstName) %>%
    summarise(mean = mean(Status), count = n()) %>%
    filter(mean == 0, OperatorFirstName != 'None')

test %>%
    group_by(OperatorFirstName) %>%
    summarise(sum_count = sum(count)) %>%
    ggplot(aes(fct_reorder(OperatorFirstName, sum_count), sum_count)) +
    geom_bar(stat = 'identity') +
    coord_flip()

df %>%
    mutate(Month = factor(month(Date))) %>%
    group_by(Month, PlantName) %>%
    summarise(sum = n()) %>%
    mutate(PlantName = fct_reorder(PlantName, sum)) %>%
    ggplot(aes(PlantName, sum)) +
    geom_bar(stat = 'identity') +
    coord_flip()
