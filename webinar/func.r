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
      # model = data %>% map(country_model)
        model = map(data, country_model)
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

# each of this functions computed for each elements in dataframe
blah <- funs %>%
    map(~ mtcars %>% map_dbl(.x))

blah
blah[[2]]

models <- models %>%
    mutate(
        glance  = model %>% map(broom::glance),
        rsq     = glance %>% map_dbl("r.squared"),
        tidy    = model %>% map(broom::tidy),
        augment = model %>% map(broom::augment)
    )

models
models$glance[[1]]
models$rsq
models$tidy[[1]]
models$augment[[1]]

models %>% arrange(desc(rsq))
models %>% filter(continent == 'Africa')

models %>%
    ggplot(aes(rsq, reorder(country, rsq))) +
    geom_point(aes(color = continent))
    
models %>%
    filter(continent == 'Africa') %>%
    ggplot(aes(rsq, reorder(country, rsq))) +
    geom_point()

# unnest function will extract nested column 'data' 
# nest hiigeegui df rsq baganiin utgatai hamt
models %>% unnest(data)
models %>% unnest(glance, .drop = TRUE) %>% View()
models %>% unnest(tidy)

models %>%
    unnest(tidy) %>%
    select(continent, country, term, estimate, rsq) %>%
    spread(term, estimate) %>% 
    ggplot(aes(`(Intercept)`, year1950)) +
    geom_point(aes(color = continent, size = rsq)) +
    geom_smooth(se = FALSE) +
    xlab("Life Expectancy (1950)") +
    ylab("Yearly Improvement") +
    scale_size_area()

models %>%
    unnest(augment) %>%
    ggplot(aes(year1950, .resid)) +
    geom_line(aes(group = country), alpha = 1/3) +
    geom_smooth(se = FALSE) +
    geom_hline(yintercept = 0, color = 'white') +
    facet_wrap(~continent)

# CONCLUSION
# 1. Store related objects in list-columns
# 2. Learn FP so you can focus on verbs, not objects (FP <- functional programming)
# 3. Use broom to convert models to tidy data
