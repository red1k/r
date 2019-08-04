library(tidyverse)
library(gapminder)

glimpse(gapminder)
unique(gapminder$year)

gapminder %>%
    filter(year == 2002) ->
    gapminder02

glimpse(gapminder02)

range(gapminder$lifeExp)
range(gapminder$pop)
range(gapminder$gdpPercap)

gapminder02 %>%
    ggplot(aes(gdpPercap, lifeExp)) +
    geom_point(aes(color = continent, size = pop, alpha = 0.5)) +
    scale_size(
        limits = c(1800, 1420000000),
        range = c(1, 40),
        guide = FALSE
    ) +
    labs(
        x = 'Income',
        y = 'Life Expectancy (year)'
    )


gap_plot <- function(data) {
    data %>%
        arrange(desc(pop)) %>%
        ggplot(aes(gdpPercap, lifeExp)) +
        geom_point(aes(color = continent, size = pop)) +
        scale_y_continuous(
            limits = c(20, 85)
        ) +
        scale_x_continuous(
            limits = c(200, 60000)
        ) +
        labs(
            x = 'Income',
            y = 'Life Expectancy (year)'
        )
}

# you can replace scale_y_con... and sclae_x_con... to xlim and ylim
# ylim(20, 85) +
# xlim(200, 60000) +

gapminder %>%
    filter(country == 'New Zealand') %>%
    gap_plot()

gapminder3 <- gapminder %>%
    group_by(year)

by_year <- gapminder3 %>%
    group_split(year)

#year <- gapminder3 %>% group_keys() %>% pull()
year  <- gapminder3 %>% group_keys() %>% pull(year)
title <- paste0('Year: ', year)
plots <- map2(by_year, title, ~gap_plot(.x))
paths <- paste0(year, '.png')

# exporting png files
walk2(paths, plots, ggsave, width = 9, height = 6)
