library(tidyverse)
library(tidytext)
library(janeaustenr)
library(gutenbergr)

text <- c("Because I could not stop for Death -",
          "He kindly stopped for me -",
          "The Carriage held but just Ourselves -",
          "and Immortality")

#txt dataset to data frame
text_df <- tibble(line = 1:4, text = text)

# Note:
# toke is a unit of text, tokenization is the 
# process of splitting text into tokens

# word <- specifying output column name
# text <- input column - which column u want to tokenize
text_df %>%
    unnest_tokens(words, text)

original_books <- austen_books() %>%
    group_by(book) %>%
    mutate(
        linenumber = row_number(),
        chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]", ignore_case = TRUE)))
    ) %>%
    ungroup()

tidy_books <- original_books %>%
    unnest_tokens(word, text)

# stop_words <- extremely common words such as the, of, to
# removing stop words using anti_join
tidy_books <- tidy_books %>%
    anti_join(stop_words)

tidy_books %>%
    count(word, sort = TRUE) %>%
    filter(n > 600) %>%
    mutate(word = reorder(word, n)) %>%
    ggplot(aes(word, n)) +
    geom_col() +
    # xlab(NULL) <- removing x axis name
    xlab(NULL) +
    coord_flip()

# WORD FREQUENCY

hgwells <- gutenberg_download(c(35, 36, 5230, 159))
bronte  <- gutenberg_download(c(1260, 769, 969, 9182, 767))

tidy_hgwells <- hgwells %>%
    unnest_tokens(word, text) %>%
    anti_join(stop_words)

tidy_hgwells %>% count(word, sort = TRUE)

tidy_bronte <- bronte %>%
    unnest_tokens(word, text) %>%
    anti_join(stop_words)

tidy_bronte %>% count(word, sort = TRUE)
    

frequency <- bind_rows(
    mutate(tidy_bronte, author = "Brontë Sisters"),
    mutate(tidy_hgwells, author = "H.G. Wells"), 
    mutate(tidy_books, author = "Jane Austen")
    ) %>%
    mutate(word = str_extract(word, "[a-z']+")) %>%
    count(author, word) %>%
    group_by(author) %>%
    mutate(proportion = n / sum(n)) %>%
    select(-n) %>%
    spread(author, proportion) %>%
    gather(author, proportion, `Brontë Sisters`:`H.G. Wells`)

ggplot(frequency, aes(x = proportion,
                      y = `Jane Austen`,
                      color = abs(`Jane Austen` - proportion))) +
    geom_abline(color = 'gray40', lty = 2) +
    geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
    geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
    scale_x_log10() +
    scale_y_log10() +
    scale_color_gradient(limits = c(0, 0.001), low = 'darkslategray4', high = 'gray75') +
    facet_wrap(~author, ncol = 2) +
    theme(legend.position = 'none') +
    labs(y = 'Jane Austen', x = NULL)
