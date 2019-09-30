library(rvest)
library(tidyverse)

# EXAMPLE
lego_movie <- read_html('http://www.imdb.com/title/tt1490017/')

rating <- lego_movie %>%
    html_nodes('strong span') %>%
    html_text() %>%
    as.numeric()
rating

cast <- lego_movie %>%
    html_nodes('#titleCast .primary_photo img') %>%
    html_attr('alt')
cast

poster <- lego_movie %>%
    html_nodes('.poster img') %>%
    html_attr('src')
poster

cast_red <- lego_movie %>%
    html_nodes('.primary_photo+ td a') %>%
    html_text(trim = TRUE)
cast_red


# TASK - extract imdb top 100 with their title, score

# without score (i was fool!)
imdb_top_url <- read_html('https://www.imdb.com/chart/top?ref_=nv_mv_250')

imdb_top <- imdb_top_url %>%
    html_nodes('.titleColumn') %>%
    html_text(trim = TRUE) %>%
    str_split('\n', simplify = TRUE) %>%
    as_tibble()

names(imdb_top) <- c('rank', 'title', 'year')

imdb_top <- imdb_top %>%
    mutate(
        rank = as.integer(rank),
        title = trimws(title) %>% as.character(),
        year = trimws(year) %>% substr(2, 5) %>% as.integer()
    )

imdb_top

# with score
score <- imdb_top_url %>%
    html_nodes('.imdbRating') %>%
    html_text(trim = TRUE)

top <- imdb_top %>%
    cbind(score) %>%
    as_tibble() %>%
    mutate(
        # converting factor to double
        # score = as.numeric(as.character(score)) <- less efficient
        score = as.numeric(levels(score))[score]
    )

View(top)