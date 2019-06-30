# dyplr package data wrangling

library('tidyverse')
library('nycflights13')

# our dataset
flights

# return all column names
names(flights)


# FILTER() 

feb 	<- 	filter(flights, month==2, day==8)
winter 	<- 	filter(flights, month==1 | month==2 | month==3)

# De Morgan's law
# 	!(x & y) is same as !x | !y
#   !(x | y) is same as !x & !y

filter(flights, !(arr_delay>120 | dep_delay>120))


# ARRANGE() - reorder
# missing values always sorted at the end!

arrange(flights, year, month, day)

# descending order
arrange(flights, desc(arr_delay))

# get missing values at the start
arrange(flights, desc(is.na(arr_delay)))


# SELECT() 

select(flights, year, month, day)

# select all columns between year and day
select(flights, year:day)

# select all columns except those from year to day
select(flights, -(year:day))

# move a columns to the start of the df
select(flights, time_hour, air_time, everything())

# helper functions:
# starts_with('abc')
# ends_with('abc')
# contains('ijk')
select(flights, year:day, ends_with('delay'), distance, air_time)

# rename columns
rename(flights, tail_num = tailnum)


# MUTATE()

# add new columns at the end of the datasets
mutate(flights,
	   gain = arr_delay - dep_delay,
	   speed = distance / air_time * 60)
view(flights)

# you can refer to columns that you've just created!
# keep the new variables
transmute(flights,
		  gain = arr_delay - dep_delay,
		  hours = air_time / 60,
		  gain_per_hour = gain / hours)


# SUMMARIZE() with group_by

# collapses a df to a single row
# na.rm arguments -> exclude NA values remove na's
summarize(flights, delay=mean(dep_delay, na.rm=TRUE))

blah <- flights %>%
	group_by(year, month, day) %>%
	summarize(delay = mean(dep_delay, na.rm=TRUE))

delays <- flights %>%
	group_by(dest) %>%
	summarize(count = n(),
			  dist  = mean(distance, na.rm=TRUE),
			  delay = mean(arr_delay, na.rm=TRUE)
			 ) %>%
	filter(count > 20, dest != 'HNL')


ggplot(delays, aes(x=dist, y=delay)) +
	geom_point(aes(size=count), alpha=1/3) +
	geom_smooth(se=FALSE)
