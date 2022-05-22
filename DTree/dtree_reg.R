library(tidyverse)
library(janitor)
library(rpart)
library(rpart.plot)
library(caret)


# setting path and reading data

print(getwd())
setwd("D:/Projects/Advanced-Regression")
print(getwd())

df = read.csv("Dataset/bank-full.csv", sep=";")

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

model = rpart(term_deposit ~ ., 
              method = "anova", 
              data = training)

print(model)

printcp(model)


# getting the best CP value with minimum error

bestcp = model$cptable[which.min(model$cptable[,"xerror"]),"CP"]

prunetree = prune(model, cp = bestcp)


# comparing variables on the basis of importance

print(prunetree$variable.importance)

imp = data.frame(parameter = c("duration", "pdays", "house_loan", "previous", "age", "campaign", "balance", "personal_loan"), 
                 score = c(prunetree$variable.importance))

View(imp)

imp %>%
  ggplot(aes(parameter, score,fill = parameter)) + 
  geom_bar(stat = "identity") + 
  geom_text(aes(label = round(prunetree$variable.importance)), vjust = 2) +
  labs(x = "Parameter",
       y = "Score",
       title = "Parameter Importance") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 60),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15))


# plotting the tree

rpart.plot(prunetree)


# Prediction

prediction = predict(prunetree, testing)


# calculating MSE

mse = mean((prediction - testing$term_deposit)^2)

print(mse) # 0.08094377


# calculating RMSE

RMSE = mean((prediction - testing$term_deposit)^2) %>% sqrt()

print(RMSE) # 0.2845062


# R2 Score components

rss = sum((prediction - testing$term_deposit) ^ 2)  # residual sum of squares

tss = sum((testing$term_deposit - mean(testing$term_deposit)) ^ 2)  # total sum of squares

rsq = 1 - rss/tss  # R-squared formula

print(rsq) # 0.2270958
