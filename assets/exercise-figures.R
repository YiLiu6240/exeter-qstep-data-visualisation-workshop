library("tidyverse")
library("titanic")
library("cowplot")

df <- titanic_train %>% as_tibble() %>%
  mutate_at(vars(PassengerId, Survived, Pclass), as.factor)

p_barchart <- df %>%
  group_by(Pclass, Survived, Sex) %>%
  summarise(AverageAge = mean(Age, na.rm = TRUE)) %>%
  ggplot(aes(x = Pclass, y = AverageAge,
             fill = Survived)) +
  geom_col(position = "dodge") +
  facet_wrap(~ Sex) +
  labs(title = "A bar chart")

p_linechart <- df %>%
  filter(Embarked != "") %>%
  mutate(Embarked = Embarked %>% factor(levels = c("S", "C", "Q"))) %>%
  group_by(Survived, Sex, Embarked) %>%
  summarise(AverageAge = mean(Age, na.rm = TRUE)) %>%
  ggplot(aes(x = Embarked, y = AverageAge,
             colour = Survived, group = Survived)) +
  geom_point() + geom_line(linetype = 2) +
  facet_wrap(~ Sex, ncol = 1) +
  labs(title = "A line chart")

p_scatterplot <- df %>%
  ggplot(aes(x = Pclass, y = Age)) +
  facet_wrap(~ Sex, nrow = 1) +
  geom_jitter(aes(colour = Survived)) +
  labs(title = "A scatter plot")


p_density <- df %>%
  ggplot(aes(x = Fare)) +
  geom_density(aes(fill = Survived), alpha = 0.5) +
  labs(title = "A density plot") +
  theme(legend.position = "bottom")


p <- ggdraw() +
  draw_plot(p_barchart, 0.00, 0.50, 0.50, 0.50) +
  draw_plot(p_linechart, 0.50, 0.50, 0.50, 0.50) +
  draw_plot(p_scatterplot, 0.00, 0.00, 0.50, 0.50) +
  draw_plot(p_density, 0.50, 0.00, 0.50, 0.50)


p %>%
  ggsave(filename = "exercise-figures.png",
         height = 5.5, width = 10)
