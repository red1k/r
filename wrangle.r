library('tidyverse')
library('nycflights13')

# R table
as_tibble(iris)

blah <- tibble(
	   x = 1:5,
	   y = 1,
	   z = x^2 + y
)

# you can name columns in nonsyntactic way using ``: backticks

tb <- tibble(
			 `:)` 	= 'smile',
			 ` ` 	= 'space',
			 `200` 	= 'number'
			 )

# does not work!
tb <- tb %>% rename(tb, '`200`', 'renamed')

flights %>%
	View()

# SUBSETTING

df <- tibble(
			 x = runif(5),
			 y = rnorm(5)
			 )

# UNIFORM DISTRIBUTION:		every outcome is equally likely, like a dice

# runif(n, min=0, max=1) 	arguments
# runif(n)					distribute n random numbers between 0 and 1
# runif(n, -5, 5)			distribute n random numbers between -5 and 5

df$x			# extract by name
df[['x']]		# extract by name
df[[1]]			# extract by position

# when piping use . operator!
df %>% .$x

# READR

read_csv('a, b, c
		 1, 2, 3
		 4, 5, 6')

read_csv('The first line of metadata
		  The scond line of metadata
		  x, y, z
		  1, 2, 3',
		  skip = 2)

read_csv('# Comment i want to skip
		  x, y, z
		  1, 2, 3',
		  comment = '#')

# useful arguments

# col_names = FALSE 			<- when data not have column names
# col_names = c('x', 'y', 'z')	<- pass char vector
# na = "."						<- specifies the value that are used
#									to represent missing values

# PARSING
parse_logical()
parse_integer()

parse_double('1.23')
parse_double('1,23', locale = locale(decimal_mark = ','))

parse_number('$100')			<- returns 100
parse_number('20%')				<- returns 20
parse_number('it costs 20.45$')	<- returns 20 'extract numbers embedded in text'

# grouping_mark default is , comma
parse_number('$123,456,789')	<- returns 1.23e+08
parse_number('$123.456.789', locale = locale(grouping_mark = "."))

# default encoding is UTF-8, u can specify by encoding argument
parse_character(x)
parse_character(x, locale = locale(encoding = 'Latin1'))

# when u don't know the encoding use guess_encoding() function
guess_encoding(charToRaw(x))

parse_factor()
parse_datetime()
parse_time()
parse_date()


# tweaking the type of the x and y columns 
# you use col_xyz() when you want to tell readr how to load the data
challenge <- read_csv(readr_example('challenge.csv'),
					  col_types = cols(
									   x = col_double(),
									   y = col_date()
									   ))

challenge1 <- read_csv(readr_example('challenge.csv'),
					   guess_max = 1001)

# first read as character vector and change column type using 'type_convert' function!
challenge2 <- read_csv(readr_example('challenge.csv'),
					   col_types = cols(.default = col_character()))

type_convert(challenge2)

#table4a <- tribble(
#				  ~country, ~`1999`, ~`2000`,
#				  'Afghan', 1, 3,
#				  'Brazil', 2, 4,
#				  'China', 3, 5
#				  )

table4a
table4b

# Gather

tidy4a <- table4a %>%
	gather(`1999`, `2000`, key = 'year', value = 'cases')

tidy4b <- table4b %>%
	gather(`1999`, `2000`, key = 'year', value = 'popul')

left_join(tidy4a, tidy4b)

table2

spread(table2, key=type, value=count)

people <- tribble(
	~name, 				 ~key, 		~value,
	#-----------------|--------|------
	"Phillip Woods",	 "age", 	45,
	"Phillip Woods",	 "height", 	186,
	"Phillip Woods",	 "age", 	50,
	"Jessica Cordero",	 "age", 	37,
	"Jessica Cordero",	 "height",  156
)

people

# gives error because of 1st and 3rd row (must be unique)
spread(people, key, value)

preg <- tribble(
	~pregnant, ~male, ~female,
	"yes", 		NA, 	10,
	"no", 		20, 	12
)

preg %>%
	gather(male, female, key = sex, value='male')

# pulls apart one column into multiple columns
# default -> it sees non alphanumeric characters (not letter and not number)
table3 %>% separate(rate, into = c('cases', 'population'))
table3 %>% separate(rate, into = c('cases', 'population'), sep = '/')
table3 %>% separate(rate, into = c('cases', 'population'), sep = '/', convert=TRUE)

# will interpret integer as position to split at. 1 left, -1 right

table3 <- table3 %>% separate(year, into = c('century', 'year'), sep = 2)

# combines multiple columns to one column
# 1st argument is which column
# columns to combine

blah <- table3 %>% unite(new, century, year, sep="")

parse_integer(blah$new)
blah
type_convert(blah$new)
