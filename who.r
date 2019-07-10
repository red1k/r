library(tidyverse)
library(stringr)

# dataset is about tuberculosis
who

df <- who

df <- df %>%
    gather(
        new_sp_m014:newrel_f65, key = 'key',
        value = 'cases',
        na.rm = TRUE
    )

df %>%
    count(key)


# Brief intro  to dataset
# 'cases' column:
#       rel     <- relapse
#       ep      <- extrapulmonary 
#       sn      <- smear negative
#       sp      <- smear positive

# Sixth letter is sex of TB patient:
#       f       <- female
#       m       <- male

# Remaining number:
#       014     <- 0-14 years old
#       1525    <- 15-24 years old ...
#       ...
#       5564    <- 55-64 years old
#       65      <- 65 or older

# some key value is written without underscore, replacing it:

df <- df %>%
    mutate(key = str_replace(key, 'newrel', 'new_rel'))

# regex in R
blah <- grep("^new_rel", df$key, value = TRUE)
filter(df, key == blah)

# spliting key value into new, type and sexage

df <- df %>%
    separate(key, c('new', 'type', 'sexage'), sep = "_")

# removing redundant columns

df <- df %>%
    select(-iso2, -iso3, -new)

# spliting sexage to sex and age:

df <- df %>%
    separate(sexage, c('sex', 'age'), sep = 1)

# final tidy data
df

# executing above codes in one line using complex pipeline

test <- who %>%
    gather(key, cases, new_sp_m014:newrel_f65) %>%
    mutate(key = str_replace(key, 'newrel', 'new_rel')) %>%
    separate(key, c('new', 'type', 'sexage'), sep = "_") %>%
    select(-iso2, -iso3, -new) %>%
    separate(sexage, c('sex', 'age'), sep = 1)

# check test and df is equal

all.equal(test, df)
