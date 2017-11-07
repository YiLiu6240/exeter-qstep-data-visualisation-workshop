library("tidyverse")
library("titanic")
library("cowplot")

df <- titanic_train %>% as_tibble() %>%
  # Relabel categorical values
  mutate(Survived = ifelse(Survived == 0,
                           "Did not survive", "Survived") %>%
           as.factor(),
         Embarked = case_when(Embarked == "C" ~ "Cherbourg",
                              Embarked == "Q" ~ "Queenstown",
                              Embarked == "S" ~ "Southhampton",
                              TRUE ~ "") %>%
           as.factor())

p_categorical <- df %>%
  # Reshape dataframe into: ..., Survived, ..., Variable, Category
  gather(
    # Variable names for key and value
    Variable, Category,
    # Categorical variables to be included in the transformation
    Sex, Embarked, Pclass,
    # Preseve the order of variables we supply
    factor_key = TRUE) %>%
  # Add a variable "n" which is the number of observations in
  # each category
  count(Survived, Variable, Category) %>%
  ggplot(aes(x = Variable, y = n, group = Category)) +
  facet_wrap(~ Survived, ncol = 2) +
  geom_col(aes(fill = Category), alpha = 0.9, colour = "black") +
  geom_text(aes(label = Category), colour = "white",
            size = 2, fontface = "bold",
            position = position_stack(vjust = 0.5)) +
  labs(x = "") +
  theme_bw() + theme(legend.position = "none")

p_numerical <- df %>%
  gather(Variable, Value,
         Age, Fare, SibSp, Parch,
         factor_key = TRUE) %>%
  ggplot(aes(x = Survived, y = Value)) +
  facet_wrap(~ Variable, scale = "free", ncol = 1) +
  geom_boxplot(aes(color = Survived)) +
  labs(x = "") +
  theme_bw() + theme(legend.position = "none")

p_dot <- df %>%
  mutate(Pclass = Pclass %>% as.factor()) %>%
  ggplot(aes(x = Fare, y = Pclass)) +
  geom_jitter(aes(fill = Survived),
              shape = 21, size = 2, alpha = 0.7) +
  theme_bw() +
  theme(legend.position = c(0.85, 0.75),
        legend.background = element_rect(fill = alpha("gray", 0.1)))

p_line <- df %>%
  mutate(Pclass = sprintf("Pclass %s", Pclass) %>% as.factor()) %>%
  group_by(Survived, Age, Pclass) %>%
  summarise_at(vars(Fare),
               mean, na.rm = TRUE) %>%
  ggplot(aes(x = Age, y = Fare, group = Survived)) +
  facet_wrap(~ Pclass, ncol = 1, scale = "free") +
  geom_point(aes(fill = Survived),
             shape = 21, size = 2, alpha = 0.7) +
  geom_smooth(aes(colour = Survived),
              linetype = 2, alpha = 0.4) +
  theme_bw() +
  theme(legend.position = "none")

p <- ggdraw() +
  draw_plot(p_numerical, 0.00, 0.00, 0.25, 1.00) +
  draw_plot(p_categorical, 0.25, 0.40, 0.50, 0.60) +
  draw_plot(p_dot, 0.25, 0.00, 0.50, 0.40) +
  draw_plot(p_line, 0.75, 0.00, 0.25, 1.00)


p %>%
  ggsave(filename = "titanic-data.png",
         height = 5.5, width = 10)
