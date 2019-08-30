library(tidyverse)
library(lubridate)

df <- readxl::read_excel('data.xlsx', sheet = 'FuelData')
glimpse(df)

# deselecting redundant columns
df <- df %>%
    select(-c(1, 11:13))
    

# renaming columns
colnames(df) <- c(
    'con',
    'tr',
    'plate',
    'trailer',
    'last_name',
    'first_name',
    'odo_meter',
    'litre',
    'date',
    'convoy'
)


df <- df[1:3119, ]

plate_letters <- str_sub(df$plate, -3, -1)
table(plate_letters) 

# does not work!
# df$plate <- str_replace_all(df$plate, c("УБР" = "UBR",
#                                         "УНД" = "UND",
#                                         "УНЭ" = "UNE",
#                                         "ӨМА" = "UMA",
#                                         "ӨМӨ" = "UMU"))

df$trailer <- str_replace(df$trailer, 'ГЧ', 'GCH')

df$plate   <- str_replace(df$plate, 'УБР', 'UBR')
df$plate   <- str_replace(df$plate, 'УНД', 'UND')
df$plate   <- str_replace(df$plate, 'УНЭ', 'UNE')
df$plate   <- str_replace(df$plate, 'ӨМА', 'UMA')
df$plate   <- str_replace(df$plate, 'ӨМӨ', 'UMU')

df$con     <- str_to_upper(str_replace(df$con, '-', ''))
df$con     <- str_replace(df$con, 'KSУБ1', 'UB1')
df$con[df$con == '2'] <- 'KS2'

df <- df %>% mutate(
    con = factor(con),
    tr = factor(tr),
    plate = factor(plate),
    trailer = factor(trailer),
    odo_meter = as.integer(odo_meter),
    litre = as.integer(litre),
    date = ymd(date),
    convoy = factor(convoy)
)

df <- df %>%
    filter(!is.na(litre))

boxplot(df$litre)

ggplot(df) +
    geom_boxplot(aes(x = fct_reorder(plate, litre, fun = mean), y = litre)) +
    coord_flip() +
    theme_minimal()

ggplot(df) +
    geom_boxplot(aes(x = convoy, y = litre)) +
    theme_minimal()

df %>% 
    filter(convoy != '0') %>%
    group_by(convoy, plate) %>%
    summarise(sum = sum(litre)) %>%
    ggplot(aes(x = fct_reorder(plate, sum, fun = sum), y = sum, color = convoy)) +
    geom_point() +
    coord_flip() +
    theme_minimal()
    

ggplot(df, aes(x = plate, y = litre)) +
    geom_point() +
    coord_flip() +
    theme_minimal()

glimpse(df)
summary(df)
