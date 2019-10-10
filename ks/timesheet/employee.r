library(tidyverse)
library(readxl)
library(openxlsx)
library(purrr)

emp <- read_excel('./ref/roster_group.xlsx')

emp <- emp %>%
    mutate(
        roster = factor(roster),
        full_name = factor(full_name)
    )
