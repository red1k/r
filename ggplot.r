library('tidyverse')

# dataset:
mpg

# aes stands for aesthetic 
ggplot(data=mpg) + geom_point(mapping=aes(x=displ, y=hwy, color=class))
ggplot(data=mpg) + geom_point(mapping=aes(x=displ, y=hwy, alpha=class))
ggplot(data=mpg) + geom_point(mapping=aes(x=displ, y=hwy, shape=class))

# class-n utgaar tus burd ni graph baiguulj baina
ggplot(data=mpg) + geom_point(mapping=aes(x=displ, y=hwy, color=class)) + facet_wrap(~ class, nrow=3)

# facet_grid function secondary axis-g zaaj baina drv ~ cyl
ggplot(data=mpg) + geom_point(mapping=aes(x=displ, y=hwy, color=class)) + facet_grid(drv ~ cyl)
ggplot(data=mpg, mapping=aes(x=displ, y=hwy)) + geom_point() + geom_smooth()
ggplot(data=mpg, mapping=aes(x=displ, y=hwy)) + geom_point(mapping=aes(color=class)) + geom_smooth()
