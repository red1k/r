library(tidyverse)
library(readxl)
library(openxlsx)
library(purrr)

# gather function
gatherer <- function(df, rangefrom, rangeto) {
    df %>%
        gather(
            rangefrom:rangeto,
            key = 'date',
            value = 'status',
            na.rm = TRUE
        ) %>%
        mutate(
            date = as.Date(as.integer(date), origin = '1899-12-30'),
            id = as.integer(id)
        )
}

left = function(text, num_char) {
  substr(text, 1, num_char)
}
 
mid = function(text, start_num, num_char) {
  substr(text, start_num, start_num + num_char - 1)
}
 
right = function(text, num_char) {
  substr(text, nchar(text) - (num_char-1), nchar(text))
}

# ONLY ONE SHEET

files_ot <- list.files(path = 'C:/Users/User/Documents/timesheet/raw_ot', pattern = '*.xlsx')
files_ot <- paste('C:/Users/User/Documents/timesheet/raw_ot', files_ot, sep = '/')

# one big dataframe
df_ot <- map_df(files_ot, read_excel, .id = 'id')

# gathering all variable columns
final_ot <- df_ot %>%
    gather(
        `43490`:`43489`,
        key = 'date',
        value = 'status',
        na.rm = TRUE
    ) %>%
    mutate(
        date = as.Date(as.integer(date), origin = '1899-12-30'),
        id = as.integer(id)
    )


final_ot <- final_ot %>%
    select(1, 3:7) %>%
    mutate(
        id = ifelse(id != 8, id + 1, 1),
        sap = as.integer(sap),
        position = factor(position),
        status = factor(status)
    ) %>%
    arrange(id)

write.xlsx(final_ot, 'ot.xlsx')


# MULTIPLE SHEETS

files_other <- list.files(path = 'C:/Users/User/Documents/timesheet/raw_other', pattern = '*.xlsx')
files_other <- paste('C:/Users/User/Documents/timesheet/raw_other', files_other, sep = '/')

df_other_ub <- map_df(files_other, read_excel, .id = 'id', sheet = 'УБ')
df_other_nuurs <- map_df(files_other, read_excel, .id = 'id', sheet = 'НҮҮРС')
df_other_ab <- map_df(files_other, read_excel, .id = 'id', sheet = 'АБ')

df_other_all <- bind_rows(list(df_other_ub, df_other_nuurs, df_other_ab))

final_other <- gatherer(df_other_all, rangefrom = "43580", rangeto = "43701")

final_other <- final_other %>%
    select(id, full_name, date, status) %>%
    rename(month = id) %>%
    mutate(
        full_name = str_trim(full_name),
        full_name = ifelse(
            str_detect(full_name, " "),
            paste(
                left(full_name, 1),
                right(full_name, str_length(full_name) - str_locate(full_name, ' ')),
                sep = '.'
            ),
            full_name
        ),
        status = factor(status),
        month = month + 4
    )


write.xlsx(final_other, 'other.xlsx')

grouped_by_month <- final_other %>%
  group_by(month, full_name, status) %>%
  tally() %>%
  spread(status, n)

lookup_group  <- read_excel('./ref/group_other.xlsx')
lookup_roster <- read_excel('./ref/roster.xlsx')

lookup_roster

lookup_roster <- lookup_roster %>%
  rename(
    roster = group,
    month = MONTH
  )

lookup_roster
lookup_group
grouped_by_month

blah <- merge(grouped_by_month, lookup_group, by = 'full_name')
blah <- merge(blah, lookup_roster, by = c('roster', 'month'))

names(blah) <- c(
  'roster',
  'month',
  'full_name',
  'ub',
  'a',
  'ot',
  't',
  'to',
  'te',
  'khb',
  'tsts',
  'ch',
  'u',
  'day_off',
  'day_on'
)

blah <- blah %>%
  mutate(
    diff = day_on - tsts
  ) %>%
  arrange(desc(diff))

write.xlsx(merged_other, 'merged_other.xlsx')
write.xlsx(blah, 'blah.xlsx')
