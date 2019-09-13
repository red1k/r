# each df in a separate object 
# for (i in 1:length(files)) assign(files[i], read_excel(files[i]))

# creating large list
# dfs <- lapply(files, read_excel)

importer <- function(given_url) {
    url = paste(getwd(), given_url, sep = '/')
    files = list.files(path = url, pattern = '*.xlsx')
    files = paste(url, files, sep = '/')
    df = map_df(files, read_excel, .id = 'id')
}

testing <- importer('raw')

mutated <- testing %>%
    gather(
        '43490':'43489',
        key = 'date',
        value = 'status',
        na.rm = TRUE,
    ) %>%
    select(-('...1':'...45')) %>%
    mutate(
        date = as.Date(as.integer(date), origin = '1899-12-30')
    )

write.xlsx(mutated, 'ttt.xlsx')

# SOME SUBSETTING IDEAS
test <- read_excel('raw/test.xlsx', range = cell_limits(c(3, NA), c(NA, NA)))

cleaner <- function(df) {
    names(df) = df[1, ]
    df = df[-(1:3), ]
    return(df)
}