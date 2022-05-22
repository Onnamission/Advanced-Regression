library(tidyverse)
library(janitor)
library(caret)
library(e1071)


# setting path and reading data

print(getwd())
setwd("D:/Projects/Advanced-Regression")
print(getwd())

df = read.csv("dataset/bank-full.csv", sep=";")

View(df)


# data pipeline

data_clean = df %>%
  subset(select = -c(job, marital, education, contact, day, month, poutcome)) %>%
  drop_na() %>%
  janitor::clean_names()

View(data_clean)


# Remaining Columns

colnames(data_clean) = c("age",
                         "credit_default",
                         "balance",
                         "house_loan",
                         "personal_loan",
                         "duration",
                         "campaign",
                         "pdays",
                         "previous",
                         "term_deposit")

View(data_clean)


# changing parameters from yes-no to 1-0

data_clean$term_deposit[data_clean$term_deposit == "yes"] = 1

data_clean$term_deposit[data_clean$term_deposit == "no"] = 0

View(data_clean)


data_clean$credit_default[data_clean$credit_default == "yes"] = 1

data_clean$credit_default[data_clean$credit_default == "no"] = 0

View(data_clean)


data_clean$house_loan[data_clean$house_loan == "yes"] = 1

data_clean$house_loan[data_clean$house_loan == "no"] = 0

View(data_clean)


data_clean$personal_loan[data_clean$personal_loan == "yes"] = 1

data_clean$personal_loan[data_clean$personal_loan == "no"] = 0

View(data_clean)


# converting data type

sapply(data_clean, class)

data_clean$term_deposit = as.numeric(data_clean$term_deposit)

data_clean$balance = as.numeric(data_clean$balance)

data_clean$campaign = as.numeric(data_clean$campaign)

data_clean$credit_default = as.numeric(data_clean$credit_default)

data_clean$house_loan = as.numeric(data_clean$house_loan)

data_clean$personal_loan = as.numeric(data_clean$personal_loan)

data_clean$age = as.numeric(data_clean$age)

data_clean$duration = as.numeric(data_clean$duration)

data_clean$pdays = as.numeric(data_clean$pdays)

data_clean$previous = as.numeric(data_clean$previous)

sapply(data_clean, class)


# splitting the whole dataset

intrain = createDataPartition(y = data_clean$term_deposit, p = 0.7, list = FALSE)

training = data_clean[intrain,]

testing = data_clean[-intrain,]


# defining the model

model = svm(term_deposit ~ ., data = training)

print(model)


# Prediction

prediction = predict(model, newdata = testing)


# calculating MSE

mse = mean((prediction - testing$term_deposit)^2)

print(mse) # 0.08847484


# calculating RMSE

RMSE = mean((prediction - testing$term_deposit)^2) %>% sqrt()

print(RMSE) # 0.2974472


# R2 Score components

rss = sum((prediction - testing$term_deposit) ^ 2)  # residual sum of squares

tss = sum((testing$term_deposit - mean(testing$term_deposit)) ^ 2)  # total sum of squares

rsq = 1 - rss/tss  # R-squared formula

print(rsq) # 0.1551842


# graph

prediction_plot = data.frame(testing$age,
                             testing$credit_default,
                             testing$balance,
                             testing$house_loan,
                             testing$personal_loan,
                             testing$duration,
                             testing$campaign,
                             testing$pdays,
                             testing$previous,
                             testing$term_deposit,
                             predicted = prediction)

colnames(prediction_plot) = c("age", 
                              "credit_defaut", 
                              "balance",
                              "house_loan",
                              "personal_loan",
                              "duration",
                              "campaign",
                              "pdays",
                              "previous",
                              "term_deposit",
                              "prediction")

prediction_plot %>%
  ggplot(aes(pdays, 
             duration, 
             color = prediction, 
             fill = prediction)) + 
  geom_point(size = 2) + 
  labs(x = "Pdays",
       y = "Duration",
       title = "Pdays vs Duration") +
  theme_bw() +
  theme(plot.title = element_text(size = 60),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15))
