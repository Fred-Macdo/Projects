library(randomForest)

s <- sample(150,100)
iris_train <- iris[s,]
iris_test  <- iris[-s,]

rfm <- randomForest(Species ~ ., iris_train)
p   <- predict(rfm, iris_test)

table(iris_test[,5], p)

mean(iris_test[,5]==p)
importance(rfm)
getTree(rfm, 500, labelVar = T)
