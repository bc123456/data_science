# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"

# AGN vs PSR classification using Neural Network(NN) model
# Load workspace from previous step
load(".RData")

# Load pROC package
library(pROC)

# Normalize the dataset
FGL3_AGNPSR <- rbind(FGL3_train, FGL3_test)

FGL3_AGNPSR_attr <- FGL3_AGNPSR[,1:9]

maxs <- apply(FGL3_AGNPSR_attr, 2, max)
mins <- apply(FGL3_AGNPSR_attr, 2, min)

scaled_attr <- as.data.frame(scale(FGL3_AGNPSR_attr, center = mins, scale = maxs - mins))
scaled <- cbind(scaled_attr, FGL3_AGNPSR[10])
scaled$pulsarness <- as.numeric(scaled$pulsarness) - 1 # convert factor to numeric

# Seperate into train set and cross validation set


FGL3_train_ <- scaled[1:(nrow(FGL3_train)-380),]
FGL3_CV_ <- scaled[(nrow(FGL3_train)-379):(nrow(FGL3_train)),]
FGL3_test_ <- scaled[-(1:nrow(FGL3_train)),]


# Load neural network package
library(neuralnet)

# Start training

n <- names(FGL3_train_)
f <- as.formula(paste("pulsarness ~", paste(n[!n %in% "pulsarness"], collapse = " + ")))
nn <- neuralnet(f,data=FGL3_train_,hidden=c(3,3,3),linear.output=TRUE)


pr.nn_train <- neuralnet::compute(nn, FGL3_train_[,1:9])
predictions_FGL3_train <- pr.nn_train$net.result

# Predictions on cross validation

pr.nn_CV <- neuralnet::compute(nn, FGL3_CV_[,1:9])    # add neuralnet:: to avoid namespace colision with ggplot2 and dplyr
predictions_FGL3_CV <- pr.nn_CV$net.result

# Get Training Set threshold, generate ROC plots, and print contingency tables
Best_threshold_train <- ROC_threshold_plots_tables(FGL3_train_$pulsarness, 
                                                   predictions_FGL3_train, 
                                                   FGL3_CV_$pulsarness, 
                                                   predictions_FGL3_CV)
# Prediction on the test data set
pr.nn_test <- neuralnet::compute(nn, FGL3_test_[,1:9])
predictions_FGL3_test <- pr.nn_test$net.result

# Get Training Set threshold, generate ROC plots, and print contingency tables
#Best_threshold_train <- ROC_threshold_plots_tables(FGL3_train_$pulsarness, 
#                                                   predictions_FGL3_train, 
#                                                   FGL3_test_$pulsarness, 
#                                                   predictions_FGL3_test)
pred <-  ifelse(predictions_FGL3_test > Best_threshold_train[1],
                "PSR", "AGN")
truth <- ifelse(FGL3_test_[10]==1, "PSR", "AGN")

table(pred, truth)

#########
# results adjusting on nodes
##########
# Nodes    AUC    Sensitivity
# c(9,4)   0.957    0.935
# c(9,3)   0.990    0.968
# c(8,3)   0.988    0.968
# c(7,3)   0.988    0.968
# c(6,3)   0.993    0.935
# c(5,3)   0.944    0.935
# c(4,3)   0.977    0.968
# c(4,2)   0.947    0.935
# c(3,3)   0.980    0.968
# c(3,2)   0.980    0.968
# c(9,6)   0.988    0.968
# c(9,9)   0.934    0.935
