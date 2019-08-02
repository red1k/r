library(tidyverse)
library(skimr)

install.packages('skimr')

# guess_max <- maximum number of records to use for guessing column types
df <- read_csv('webinar/data/multipleChoiceResponses.csv',
               guess_max = nrow(df))

glimpse(df)

# return dataframe if u r using map_df
# . 'dot' is telling every column
# write after '~' function
df %>% map_df(~ sum(is.na(.)))

df %>% summarize(number_nas = sum(is.na(Country)))
df %>% count(StudentStatus)

# empty string <- R does not recognize as a NA
# using na_if function you can change empty cell to NAs
df <- df %>% na_if("")

# examining our dataset
colnames(df)

# summarise all numeric columns 'one way to see quickly your df'
df %>%
    select_if(is.numeric) %>%
    skimr::skim()

# get unique values from all columns
df %>%
    map_df(~n_distinct(.)) %>%
    gather(question, num_dist) %>%
    arrange(desc(num_dist))

df %>% 
    count(WorkMethodsSelect, sort = T)

# some of them using multiple work methods <- which separated by ,
work_method <- df %>%
    select(WorkMethodsSelect) %>%
    filter(!is.na(WorkMethodsSelect)) %>%
    mutate(work_method = str_split(WorkMethodsSelect, ",")) %>%
    unnest() %>%
    select(work_method)

# same as above unnest function
df %>%
    select(WorkMethodsSelect) %>%
    filter(!is.na(WorkMethodsSelect)) %>%
    mutate(work_method = str_split(WorkMethodsSelect, ",")) %>%
    separate_rows(WorkMethodsSelect, sep = ',')

method_freq <- work_method %>%
    count(work_method, sort = T)
    
# reorder x axis using fct_reorder
work_method %>% 
    count(work_method) %>%
    ggplot(aes(x = fct_reorder(work_method, n), y = n)) +
    geom_col() +
    coord_flip()

work_challenge <- df %>%
    select(contains('WorkChallengeFrequency')) %>%
    gather(question, response) %>%
    filter(!is.na(response)) %>%
    mutate(question = str_remove(question, 'WorkChallengeFrequency'))

work_challenge

perc_problem <- work_challenge %>%
    mutate(response = if_else(response %in% c('Most of the time', 'Often'), 1, 0)) %>%
    group_by(question) %>%
    summarise(perc_problem = mean(response)) %>%
    arrange(perc_problem)

perc_problem

perc_problem %>%
    ggplot(aes(x = fct_reorder(question, perc_problem), y = perc_problem)) +
    geom_point() +
    coord_flip() +
    scale_y_continuous(labels = scales::percent) +
    labs(
        x = 'Questions',
        y = 'Percentage'
    )

# USED FUNCTIONS:

map_df(dataset, ~ function(.))

na_if(dataset, "")

select_if(dataset, is_numeric)

skim(dataset)

str_split(dataset$somecol, ",")

unnest(dataset)

#fct_reorder(AxisUWantToReorder, bywhatvalue)
fct_reorder(x, y)