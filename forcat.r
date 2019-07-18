library(tidyverse)
library(forcats)

# CREATING FACTOR

x <- c("Dec", "Apr", "Jam", "Mar")
sort(x)

month_level <- c(
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
    'Aug', 'Sep', 'Nov', 'Dec'
)

# any value not in the set will be silently converted to NA
x1 <- factor(x, levels = month_level)
sort(x1)

# order of the levels match the order of the first appearance in the data
f1 <- factor(x , levels = unique(x))

# similar way
f2 <- x %>% factor() %>% fct_inorder()

names(gss_cat)
glimpse(gss_cat)
summary(gss_cat)

gss_cat %>%
    count(race)

# without levels that have no value
ggplot(gss_cat, aes(race)) + geom_bar()

# see all the levels
ggplot(gss_cat, aes(race)) +
    geom_bar() +
    scale_x_discrete(drop = FALSE)

gss_cat %>%
    count(relig) %>%
    arrange(desc(n))

gss_cat %>%
    count(rincome)

ggplot(gss_cat, aes(rincome)) + geom_bar()

relig <- gss_cat %>%
    group_by(relig) %>%
    summarise(
        age = mean(age, na.rm = TRUE),
        tvhour = mean(tvhours, na.rm = TRUE),
        n = n()
    )

ggplot(relig, aes(tvhour, relig)) + geom_point()

# reordering the levels of relig
ggplot(relig, aes(tvhour, fct_reorder(relig, tvhour))) + geom_point()
