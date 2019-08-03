library(tidyverse)

data("airquality")

# Our dataset
# Solar.R solar radiation
glimpse(airquality)
summary(airquality)
names  (airquality)

# plotting

# base R
plot(Ozone~Solar.R, airquality)
abline(h = mean_ozone)

# ggplot
ggplot(airquality, aes(x = Solar.R, y = Ozone)) +
    geom_point(aes(color = Month))


# calculation
mean_ozone <- mean(airquality$Ozone, na.rm = T)
mean_ozone

# plot with mean of ozone ( using base R plotting function)
plot(Ozone~Solar.R, airquality)
abline(h = mean_ozone, col = 'green')

# using ggplot package
ggplot(airquality, aes(x = Solar.R, y = Ozone)) +
    geom_point(aes(color = Month)) +
    geom_hline(yintercept = mean_ozone, color = 'green')

model <- lm(Ozone~Solar.R, data = airquality)
summary(model)

# adding regression line

# base R
plot(Ozone~Solar.R, airquality)
abline(h = mean_ozone, col = 'green')
abline(model, col = 'red')
plot(model)

# ggplot
ggplot(airquality, aes(x = Solar.R, y = Ozone)) +
    geom_point(aes(color = Month)) +
    geom_smooth(method = 'lm', se = FALSE, color = 'red') +
    geom_hline(yintercept = mean_ozone, color = 'green')

# some cool plot i do not understand yet
coplot(Ozone~Solar.R | Wind, panel = panel.smooth, airquality)
