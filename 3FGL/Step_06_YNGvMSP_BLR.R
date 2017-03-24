# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

# Pulsar (YNG vs MSP) classification using Boosted LR
# Load workspace from previous step
load(".RData")

# Load RWeka and pROC packages
library(RWeka)
library(pROC)

# WOW(LogitBoost)
Model <- LogitBoost(pulsarness ~., data = FGL3_Pulsars_train)
summary(Model)

# Model predictions
predictions_FGL3_Pulsars_train <- predict(Model,
                                          newdata = FGL3_Pulsars_train, type = "probability")[, 2]
predictions_FGL3_Pulsars_test <- predict(Model,
                                         newdata = FGL3_Pulsars_test, type = "probability")[, 2]

# Generate ROC plots and print contingency tables
Best_threshold_train <- ROC_threshold_plots_tables(FGL3_Pulsars_train$pulsarness,
                                                   predictions_FGL3_Pulsars_train,
                                                   FGL3_Pulsars_test$pulsarness,
                                                   predictions_FGL3_Pulsars_test,
                                                   cat1 = "YNG", cat2 = "MSP")

# Add Boosted Logistic Regression Prediction probabilities to FGL3_results data frame
FGL3_results$BLR_PSR_P <- round(predict(Model,
                                        newdata = FGL3_tidy, type = "probability")[, 2],
                                digits = 3)

# Add Boosted Logistic Regression Prediction category to FGL3_results data frame
FGL3_results$BLR_PSR_Pred <- ifelse(FGL3_results$BLR_PSR_P > Best_threshold_train[1],
                                    c("YNG"), c("MSP"))

# Remove "pulsar-type" category prediction for those sources predicted to be AGN
FGL3_results$BLR_PSR_Pred[(FGL3_results$LR_Pred=="AGN")&(FGL3_results$RF_Pred=="AGN")]=""

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
                   & Environ != "FGL3_Pulsars_test"]
rm(list = Environ)

# Save current workspace for subsequent steps
save.image()
