library(tidyverse)
library(modelr)

nlevels(sales$ID)
table(sales$ID)
table(sales$Insp) / nrow(sales) * 100

glimpse(sim1)
summary(sim1)

ggplot(sim1) + geom_point(aes(x, y))

models <- tibble(
   a1 = runif(250, -20, 40),
   a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y)) +
    geom_abline(
        aes(intercept = a1, slope = a2),
        data = models, alpha = 1/4
    ) +
    geom_point()

model1 <- function(a, data) {
    a[1] + data$x * a[2]
}

model1(c(7, 1.5), sim1)

# calculating error
measure_distance <- function(mod, data) {
    diff <- data$y - model1(mod, data)
    sqrt(mean(diff ^ 2))
}

measure_distance(c(7, 1.5), sim1)

# helper function to compute the distance for all the models
sim1_dist <-function(a1, a2) {
    measure_distance(c(a1, a2), sim1)
}

models <- models %>%
    mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))


# overlaying 10 best models on to the data
ggplot(sim1, aes(x, y)) +
    geom_point(size = 2, color = 'grey30') +
    geom_abline(
        aes(intercept = a1, slope = a2, color = dist),
        data = filter(models, rank(dist) <= 10)
    )
models

# seeing all the models at once, highlighted best 10 models in red
ggplot(models, aes(a1, a2)) +
    geom_point(
        data = filter(models, rank(dist) <= 10),
        size = 4, color = 'red'
    ) +
    geom_point(
        aes(color = dist)
    )

# grid search
# expand.grid()
# create data frame from all combinations of the 
# supplied vectors or factor
grid <- expand.grid(
    a1 = seq(-5, 20, length = 25),
    a2 = seq(1, 3, length = 25)
) %>%
    mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))


grid %>% 
    ggplot(aes(a1, a2)) +
    geom_point(
        data = filter(grid, rank(dist) <= 10),
        size = 4, color = 'red'
    ) +
    geom_point(
        aes(color = dist)
    )

ggplot(sim1, aes(x, y)) +
    geom_point(size = 2, color = 'grey30') +
    geom_abline(
        aes(intercept = a1, slope = a2, color = dist),
        data = filter(grid, rank(dist) <= 10)
    )

best <- optim(c(0, 0), measure_distance, data = sim1)
best
best$par

ggplot(sim1, aes(x, y)) +
    geom_point(size = 2, color = 'grey30') +
    geom_abline(
        aes(intercept = best$par[1], slope = best$par[2])
    )