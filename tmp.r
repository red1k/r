library(tidyverse)
library(stringr)

rule <- function(..., pad = '-') {
    title <- paste0(...)
    width <- getOption('width') - nchar(title) - 3
    cat(title, " ", str_dup(pad, width/nchar(pad)), "\n", sep = "")
}

rule('Hello World', pad = '-+')

commas <- function(...) str_c(..., collapse = '- ')
str_c(LETTERS, sep = '----', collapse = 2)
?str_c
commas(letters[1:10])

str_c("Letter: ", letters)
str_c("Letter", letters, sep = ": ")
str_c(letters, " is for", "...")
str_c(letters[-26], " comes before ", letters[-1])
letters[-26]


width <- getOption('width')
getOption('h', 'a')
width
paste0()
paste("1st", "2nd", "3rd")
paste(1:10)
nth <- paste0(1:12, c('st', 'nd', 'rd', rep('th', 9)))
nth
paste(month.abb, 'is the', nth, 'month of the year.')

str_dup('balah', 2)

1:8 %% 2 == 0

1L

typeof(c(letters))
typeof(letters)

is.vector(1L)


aaaa <- c(1, 2, 3, 4)
bbbb <- c('one', 'two', 'three', 'four')

names(aaaa) <- bbbb
bbbb
aaaa

vec <- c('one' = 1, 'two' = 2, 'three' = 3)
vecc <- c(one = 1, two = 2, three = 3)
vecc

test <- c(1, T, 3, F, NA)
class(test)
sample(5, 10, replace = T)

a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))

str(a)
a[1] + 1

library(nycflights13)
glimpse(flights)
flights$hour[1] + 1

b <- list(1:3)
b
b <- list(list(list(b)))

qwqe <- ncol(1:10)
ncol(mtcars)

output <- vector('double', ncol(mtcars))
output
seq_along(mtcars)
mtcars[1]
?seq_along

for (i in seq_along(mtcars)) {
    output[[i]] <- mean(mtcars[[i]])
}

x <- 1:10

range(100)
