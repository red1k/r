library(tidyverse)
library(nycflights13)

# structure of flights dataset
str(flights)

# nicer way to see its str
glimpse(flights)

# summarising with group_by function
flights %>%
    group_by(dest) %>%
    summarise(avg_delay = mean(arr_delay, na.rm = TRUE))

aggregate(arr_delay ~ dest, flights, mean)

# summarise multiple columns
flights %>%
    group_by(carrier) %>%
    summarise_each(funs(mean(., na.rm = TRUE)), air_time, distance) %>%
    mutate(blah = distance / air_time)

# matches() <- all columns named with 'delay'
flights %>%
    group_by(carrier) %>%
    summarise_each(funs(max(., na.rm = TRUE),
                        min(., na.rm = TRUE)),
                   matches('delay'))

# n()                   <- counts the number of rows in a group
# arrange(desc(blah))   <- sort descending order by blah
flights %>%
    group_by(month, day) %>%
    summarise(flight_count = n()) %>%
    arrange(desc(flight_count))
    
# simpler way to calc using tally function
# summarise(blah = n()) is same as tally()
flights %>%
    group_by(month, day) %>%
    tally(sort = TRUE)

# n_distinct(vector)    <- counts unique item in a vector
flights %>%
    group_by(dest) %>%
    summarise(flight_count = n(), plane_count = n_distinct(tailnum))

# dest index column
# origin variable
flights %>%
    group_by(dest) %>%
    select(origin) %>%
    table()
    head()
    
    
# min_rank()    <- rank column values
# lag()         <- take previous row's value
    
flights %>%
    group_by(month) %>%
    summarise(flight_count = n()) %>%
    mutate(change = flight_count - lag(flight_count))

# using tally function
flights %>%
    group_by(month) %>%
    tally() %>%
    mutate(change = n - lag(n))

# randomly sample a fixed number of rows, without replacement
flights %>% sample_n(5)
