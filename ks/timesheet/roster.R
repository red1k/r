library(tidyverse)
library(readxl)
library(openxlsx)
library(purrr)
library(lubridate)

setwd(getwd())

roster_other <- read_excel('./ref/count_other.xlsx')
roster_ot    <- read_excel('./ref/count_ot.xlsx')


roster_other <- roster_other %>%
    gather(
        names(roster_other[2]):names(roster_other[length(roster_other)]),
        key = 'date',
        value = 'status'
    ) %>%
    mutate(
        Group = as.integer(Group),
        date = as.Date(as.integer(date), origin = '1899-12-30'),
        status = factor(status),
    ) %>%
    rename(
        group = Group
    )

roster_other

roster_other <- roster_other %>%
    mutate(
        MONTH = ifelse(
            day(date) > 25,
            month(date) + 1,
            month(date)
        )
    )

roster_other

grouped_other <- roster_other %>%
    group_by(group, MONTH, status) %>%
    tally() %>%
    spread(
        status, n
    ) %>%
    rename(
        day_on = '1',
        day_off = '0'
    )

write.xlsx(grouped_other, 'roster.xlsx')
