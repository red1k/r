library(tidyverse)
library(lubridate)

df <- readxl::read_excel('data/data.xlsx', sheet = 'TripData')

attach(df)
glimpse(df)
summary(df)

df <- df %>%
    select(2:6, 13:18)

colnames(df) <- c(
    'tr',
    'plate_mon',
    'trailer_mon',
    'last_name',
    'first_name',
    'badge',
    'sap',
    'bags',
    'seal',
    'date',
    'convoy'
)

df <- df %>%
    mutate(
        badge = as.integer(badge),
        sap = as.integer(sap),
        bags = as.integer(bags),
        date = ymd(date),
        convoy = factor(convoy)
    )

df <- df %>%
    mutate(
        year = year(date),
        month = month(date),
        day = day(date)
    )

test <- df %>%
    group_by(year, month, convoy) %>%
    tally() %>%
    mutate(
        trip_count = n / 16
    )

test %>%
    ggplot(aes(x = factor(month), y = trip_count)) +
    geom_bar(aes(fill = convoy), stat = 'identity') +
    facet_wrap(~year)

test %>%
    ggplot(aes(x = factor(month), y = trip_count)) +
    geom_bar(aes(fill = convoy), stat = 'identity', position = 'dodge') +
    facet_wrap(~year) +
    theme_minimal()

head(df)
df %>%
    mutate(
        full_name = paste(first_name, last_name),
        year = year(date)
    ) %>%
    group_by(year, full_name) %>%
    summarise(count = n()) %>%
    filter(count > 30) %>%
    ggplot(aes(fct_reorder(full_name, count), count)) +
    geom_bar(stat = 'identity') +
    coord_flip()
    