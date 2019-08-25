library(tidyverse)
library(modelr)
library(reshape2)

# our data
glimpse(sim1)
summary(sim1)
ggplot(sim1) + geom_point(aes(x, y))

random_models <- tibble(
   a1 = runif(250, -20, 40),
   a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y)) +
    geom_abline(
        aes(intercept = a1, slope = a2),
        data = random_models, alpha = 1/4
    ) +
    geom_point()

base_model <- function(a, data) {
    a[1] + data$x * a[2]
}

base_model(c(7, 1.5), sim1)

# formula that calculates error
measure_distance <- function(mod, data) {
    diff <- data$y - base_model(mod, data)
    sqrt(mean(diff ^ 2))
}

measure_distance(c(7, 1.5), sim1)

# helper function to compute the distance for all the models
sim1_dist <- function(a1, a2) {
    measure_distance(c(a1, a2), sim1)
}

models <- random_models %>%
    mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

# overlaying 10 best models on to the data
ggplot(sim1, aes(x, y)) +
    geom_point(size = 2, color = 'grey30') +
    geom_abline(
        aes(intercept = a1, slope = a2, color = dist),
        data = filter(models, rank(dist) <= 10)
    )

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

# using optim() function
sim1_optim <- optim(c(0, 0), measure_distance, data = sim1)

ggplot(sim1, aes(x, y)) +
    geom_point(size = 2, color = 'grey30') +
    geom_abline(
        aes(intercept = sim1_optim$par[1], slope = sim1_optim$par[2])
    )

# using linear model lm()
sim1_lm <- lm(y ~ x, data = sim1)

# sim1_optim$par = sim1_lm$coefficents
# coef by optim and coef by lm is exactly the same!


# EXERCISES

sim1a <- tibble(
    x = rep(1:10, each = 3),
    y = x * 1.5 + 3 +rt(length(x), df = 2)
)

sim1a %>%
    ggplot(aes(x, y)) +
    geom_point() +
    geom_smooth(method = 'lm')
    # geom_text(aes(1, 6.374), label = 'blah')


sim1a_lm    <- lm(y ~ x, data = sim1a)
sim1a_optim <- optim(c(0, 0), measure_distance, data = sim1a)

sim1a_optim$par
sim1a_lm$coefficients


# Prediction

# data_grid <- for each subsequent argument it finds the unique variables
#              and then generates all combinations
# arguments <- dataframe, subsequent argument (column name)
grid <- data_grid(sim1, x)

# it adds prediction from the model to a new column in the dataframe
# arguments <- dataframe, model
grid <- grid %>% add_predictions(sim1_lm)

# plotting prediction
ggplot(sim1, aes(x = x)) +
    geom_point(aes(y = y)) +
    geom_line(
        aes(y = pred),
        data = grid,
        color = 'red',
        size = 1
    )

# Residual <- distance between the observed values and predicted values
sim1 <- sim1 %>%
    add_residuals(sim1_lm)

# Visualization
ggplot(sim1, aes(resid)) +
    geom_freqpoly(binwidth = 0.5)

ggplot(sim1, aes(x, resid)) +
    geom_ref_line(h = 0) +
    geom_point()


# Excercise 'Using loess function instead of lm on sim1'

# Model fitting
sim1_loess <- loess(y ~ x, data = sim1)

# Prediction
gridWithLoess <- grid %>% add_predictions(sim1_loess)

# Checking differences between loess pred and lm pred
test <- grid
test <- test %>%
    mutate(LoessPred = gridWithLoess$pred,
           Diff = pred - LoessPred)

# Visualization
ggplot(sim1, aes(x = x)) +
    geom_point(aes(y = y)) +
    geom_line(
        aes(y = pred),
        data = gridWithLoess,
        color = 'red',
        size = 2
    ) +
    geom_smooth(aes(y = y), size = 0.5)

gridWithLoessResidual <- sim1 %>% add_residuals(sim1_loess)

ggplot(gridWithLoessResidual, aes(resid)) +
    geom_freqpoly(binwidth = 0.5)

ggplot(gridWithLoessResidual, aes(x, resid)) +
    geom_ref_line(h = 0) +
    geom_point()

# ggplot tutorial
# https://www.gl-li.com/2017/08/03/a-uniform-way-to-use-ggplot2/
# https://ggplot2.tidyverse.org/reference/geom_text.html
