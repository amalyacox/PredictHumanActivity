---
title: "KaggleFinal"
output: html_document
---
#Loading the data \
#```{r}
train = read.csv('/Users/amalyajohnson/Downloads/stats-202-fa21/train.csv')
test = read.csv('/Users/amalyajohnson/Downloads/stats-202-fa21/test.csv')
#```

#Installing packages\
#```{r}

library('class')
install.packages('crossval')
library('crossval')
install.packages('caret')
library(caret)
library(e1071)
#```

#70/30 Train test split cross validation \
#```{r}
set = sample(length(labels), 0.7*length(labels))

labels <- as.factor(train$Activity)

train.data <- train[,2:562]

svm.lin <- svm(labels[set] ~., data=train.data[set,], kernel="linear", cost=10)

train_err_rate = 1 - sum(diag(table(labels[set], predict(svm.lin, train.data[set,]))))/length(labels[set])

test_err_rate = 1 - sum(diag(table(labels[-set], predict(svm.lin, train.data[-set,]))))/length(labels[-set])

print(paste('training err rate:', train_err_rate, 'test err rate:', test_err_rate))
#```

#10-Fold Cross validation to tune cost parameter \
#```{r}
train.data <- train[,2:562]

labels <- as.factor(train$Activity)

err_rate <- function(x) {1-sum(diag(x)/(sum(rowSums(x))))}
err_arr <- c()
for (i in seq(-2, 1, by = 0.25)) {
  cv_err <- c()
  fold <- createFolds(labels, 10) #create 10 folds 
  for (j in fold) {
    svm.out <- svm(labels[-j] ~., data= train.data[-j,], kernel="linear", cost=10^i)
    prediction <- predict(svm.out, train.data[j,])
    tab <- table(prediction, labels[j])
    cv_err<- append(cv_err, err_rate(tab))
  }
  err_arr <- append(err_arr, mean(cv_err))
}
plot(seq(-2, 1, by = 0.25), err_arr, xlab='cost', ylab='error rate')
#```

#Using the best cost parameter and training on all the training data \ 
#```{r}
cv_cost <- seq(-2, 1, by = 0.25)[which.min(err_arr)]
svm.best <- svm(labels ~., data=train.data, kernel="linear", cost=10^cv_cost)

train_err_rate = 1 - sum(diag(table(labels, predict(svm.best, train.data))))/length(labels)
train_err_rate
#```

#Predicting the unlabeled data \
#```{r}
prediction <- predict(svm.best, test)
pred_df <- data.frame('Id' = test$Id, 'Activity' = prediction)
write.csv(pred_df, file='/Users/amalyajohnson/Desktop/Data Science/STATS 202/sv_lin.csv',row.names = FALSE)
#```

