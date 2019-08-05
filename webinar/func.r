library(tidyverse)
library(gapminder)
library(purrr)


# for atomic vectors:
# Logical -> integer -> double -> character

gapminder

# IMPORTANT -> nest() function

?nest()

gapminder <- gapminder %>% mutate(year1950 = year - 1950)

by_country <- gapminder %>%
    group_by(continent, country) %>%
    nest()

# see the dataframe for better understanding
by_country

# not great idea
str(by_country)

# bit better
glimpse(by_country)
names(by_country)

# subset nested dataframes
by_country$data[[1]]


# MODEL
country_model <- function(df) {
    lm(lifeExp ~ year1950, data = df)
}

# use above function on our nested dataframe - first subset!
country_model(by_country$data[[2]])

# another way to calc lm of given country
lm(lifeExp ~ year1950, data = by_country$data[[2]])

# adding mod column which have all country's lm 
# map(data, country_model) -> 'data' column deer country_model function-g bodoh
models <- by_country %>%
    mutate(
        mod = map(data, country_model)
    )

mtcars
# for loops
# all for loops must started with allocated output

means <- vector("double", ncol(mtcars))

for (i in seq_along(mtcars)) {
    means[[i]] <- mean(mtcars[[i]], na.rm = TRUE)
}

medians <- vector("double", ncol(mtcars))

for (i in seq_along(mtcars)) {
    medians[[i]] <- median(mtcars[[i]], na.rm = TRUE)
}

medians

# loop using map function
means   <- map_dbl(mtcars, mean)
medians <- map_dbl(mtcars, median)

typeof(means)
typeof(medians)

funs <- list(mean, median, sd)
funs

blah <- funs %>%
    map(~ mtcars %>% map_dbl(.x))

blah[[2]]
