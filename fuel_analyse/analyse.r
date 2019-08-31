library(tidyverse)
library(lubridate)

df     <- readxl::read_excel('data/data.xlsx', sheet = 'FuelData')
info   <- readxl::read_excel('data/trucks.xls')
info_2 <- readxl::read_excel('data/2nd convoy.xlsx')


# MAIN DATA CLEANING

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

df$con[df$con == '2'] <- 'KS2'

df$con     <- str_to_upper(str_replace(df$con, '-', ''))
df$con     <- str_replace(df$con, 'KSУБ1', 'UB1')

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


# TRUCK INFO CLEANING

info <- info %>%
    select(c(1:3, 7, 9))
    
colnames(info) <- c(
    'tr',
    'plate',
    'plate_mon',
    'badge',
    'model'
)

info <- info %>% mutate(
    tr = factor(tr),
    plate = factor(plate),
    plate_mon = factor(plate_mon),
    badge = factor(badge),
    model = factor(model)
)


# SECOND CONVOY

colnames(info_2) <- c(
    'tr',
    'plate_mon'
)

info_2$plate_mon <- str_replace(info_2$plate_mon, " ", "")

info_2 <- info_2 %>% mutate(
    tr = factor(tr),
    plate_mon = factor(plate_mon)
)

# adding convoy number
info_2$convoy <- 2


# JOINING THREE DATAFRAMES

info <- full_join(info_2, info)
rm(info_2)

# adding convoy number to NAs
info$convoy[is.na(info$convoy)] <- 1
info$convoy[str_detect(info$plate, '0773')] <- 2
info$convoy[str_detect(info$tr, 'LV')] <- 0

# rearrange columns for better construction
info <- info %>%
    select(tr, plate, everything())


# TR, ulsiin dugaar 2 zarim tulshnii huudas deer zuruutei baigaa tul 
# shuud info-s medeelliig avaad df-ruu hiih heregtei

final <- left_join(df, info, by = 'tr', suffix = c('_df', '_info'))
final <- final %>%
    select(
        tr,
        plate_df,
        plate_info,
        convoy_info,
        trailer,
        last_name,
        first_name,
        odo_meter,
        litre,
        date,
        model
    )

final <- final %>% mutate(
    tr = factor(tr),
    convoy_info = factor(convoy_info),
)

# NA utgatai buh muruud
nan <- final %>% filter_all(any_vars(is.na(.)))


# VISUALIZATION

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

View(final)

# USING FINAL DATAFRAME

plot(final$litre)

final %>%
    drop_na() %>%
    group_by(plate_df) %>%
    summarise(sum = sum(litre)) %>%
    ggplot() +
    geom_point(aes(x = fct_reorder(plate_df, sum, fun = sum), y = sum)) +
    coord_flip()

final %>%
    drop_na() %>%
    mutate(month = month(date), year = year(date)) %>%
    group_by(year, month, convoy_info, model) %>%
    summarise(sum = sum(litre)) %>%
    ggplot() +
    geom_col(aes(factor(month), sum, fill = convoy_info)) +
    facet_wrap(~ year)
