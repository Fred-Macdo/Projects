# Load and plot the scanned map
setwd("C:/Users/Frederick/Documents/Data_Science_Certificate_Program/IntroMachineLearning/ResearchProjects")
require(raster)
require(e1071)
require(rasclass)
miramar2008 <- brick("Miramar2008.tif")

plotRGB(miramar2008)

# training and non training
training.panels.img <- brick("Solar.tif")
training.nonpanels.img <- brick("nonSolarPanels.jpg")

# Put background data into data frame
training.panels.df <- data.frame(getValues(training.panels.img))
names(training.panels.df) <- c("r", "g", "b")
# Remove black and white background pixels
training.panels.df <- training.panels.df[(training.panels.df$r > 1 & training.panels.df$g > 1 & training.panels.df$b > 1),]
training.panels.df <- training.panels.df[(training.panels.df$r < 254 & training.panels.df$g < 254 & training.panels.df$b < 254),]
# Create new variable indicating pipeline pixels
training.panels.df$Panel <- "1"

# Put training data into data frame
training.nonpanels.df <- data.frame(getValues(training.nonpanels.img))
names(training.nonpanels.df) <- c("r", "g", "b")
# Remove white background pixels
training.nonpanels.df <- training.nonpanels.df[(training.nonpanels.df$r > 1 & training.nonpanels.df$g > 1 & training.nonpanels.df$b > 1),]
training.nonpanels.df <- training.nonpanels.df[(training.nonpanels.df$r < 254 & training.nonpanels.df$g < 254 & training.nonpanels.df$b < 254),]
# Create new variable indicating non solar panel pixels
training.nonpanels.df$Panel <- "0"

#remove NA row 
training.panels.df<- training.panels.df[, c(1:3,5)]

# Combine data frames and subset only 10000 random values from the non-pipeline training data
training.df <- rbind(training.panels.df, training.nonpanels.df[sample(nrow(training.nonpanels.df), 10000),])
# Turn classification variable into factor
training.df$Panel <- as.factor(training.df$Panel)

attach(training.df)
# Divide training data into a train-subset and a test-subset
train <- sample(nrow(training.df), round((nrow(training.df) - 1) / 2, 0))
test <- c(1:nrow(training.df))[!(c(1:nrow(training.df)) %in% train)]
trainset.df <- training.df[train,]
testset.df <- training.df[test,]

# Fit best SVM using tuning
require(e1071)
svm.fit <-  svm(Panel~., data = trainset.df, cost = 10)
# Fit predictions and print error matrix
svm.pred <- predict(svm.fit, testset.df[,1:3])
svm.tab <- table(pred = svm.pred, true = testset.df[,4])
print(svm.tab)
require(caret)
confusionMatrix(svm.tab) 

# Fit tuned SVM to entire training set
svm.fit2 <- best.svm(Panel~., data = training.df, cost = 100)

# Prepare map for predictions
miramar.df <- data.frame(getValues(miramar2008))
names(miramar.df) <- c("r", "g", "b")
# Assign predicted values to target map

miramar.pred <- predict(svm.fit, miramar.df)

miramar.pred1 <- predict(svm.fit2, miramar.df)
miramar.class <- ifelse(miramar.pred == "1", 1, 0)

classified.img <- miramar2008[[1:3]]
values(classified.img) <- miramar.class

plot(miramar.pred)
miramar2008
miramar.pred
