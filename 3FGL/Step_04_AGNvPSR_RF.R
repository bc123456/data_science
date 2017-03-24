# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

# AGN vs PSR classification using Random Forests (RF)
# Load workspace from previous step
load(".RData")

# Load randomForest and pROC packages
library(randomForest)
library(pROC)

set.seed(1)

# First use 10-fold cross validation method to fit models and get the forecast of each block of data
k <- 10
for (i in 1:k) {
  Model <- randomForest(pulsarness~., data = FGL3_train[-Block_index[i, ], ], importance = TRUE)
  predictions_FGL3_train_CV[((i-1)*(nrow(FGL3_train_CV)/k) + 1):((i)*(nrow(FGL3_train_CV)/k))] <-
    predict(Model, newdata = FGL3_train[Block_index[i, ], ], type = "Prob")[, 2]
  print(i)
}

# Get best threshold 
Best_threshold_train_CV <- ROC_threshold_plots_tables(FGL3_train_CV$pulsarness, predictions_FGL3_train_CV)

# Now Modeling using all the data
rf.full.FGL3 <- randomForest(pulsarness~., data = FGL3_train, importance = TRUE)
# The importance of each variable
importance(rf.full.FGL3)
varImpPlot(rf.full.FGL3)
# Prediction for train and test
predictions_FGL3_train <- predict(rf.full.FGL3, newdata = FGL3_train, type = "Prob")[, 2]
predictions_FGL3_test <- predict(rf.full.FGL3, newdata = FGL3_test, type = "Prob")[,2 ]

# Generate ROC plots, and print contingency tables
ROC_threshold_plots_tables(FGL3_train$pulsarness, predictions_FGL3_train, FGL3_test$pulsarness, predictions_FGL3_test, 
                           threshold = Best_threshold_train_CV[1])
cat("Best threshold from cross-validation:", Best_threshold_train_CV)

# Add RF Prediction probabilities to FGL3_results
FGL3_results$RF_P <- predict(rf.full.FGL3, newdata = FGL3_tidy, type = "Prob")[,2 ]

# Add RF Prediction category to FGL3_results
FGL3_results$RF_Pred <- ifelse(FGL3_results$RF_P > Best_threshold_train_CV[1], 
                                     c("PSR"), c("AGN")) 

# Plot for the paper
par(mfrow = c(1,1))
varImpPlot(rf.full.FGL3, pch = 19, type = 1, main = "")

# Clean up and Set aside required data sets
Environ <- ls()
Environ <- Environ[Environ != "FGL3_tidy"
                   & Environ != "FGL3_results"
                   & Environ != "FGL3_test" 
                   & Environ != "FGL3_train" 
                   & Environ != "predictions_FGL3_train_CV" 
                   & Environ != "Block_index" 
                   & Environ != "FGL3_train_CV"
                   & Environ != "ROC_threshold_plots_tables"
                   & Environ != "FGL3_Pulsars_train"
                   & Environ != "FGL3_Pulsars_test"
                   & Environ != "rf.full.FGL3"]
rm(list = Environ)

# Save current workspace for subsequent steps
save.image()
