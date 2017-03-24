# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

# AGN vs PSR classification using Logistic Regression (LR) model (backward stepwise selection)
# Load workspace from previous step
load(".RData")

# Load pROC package
library(pROC)

null <- glm(pulsarness ~1, family = binomial, data = FGL3_train)
glm.step.backward.AIC <- step(glm(pulsarness ~., family = binomial, data = FGL3_train),
                              scope = list(lower = null, upper = glm(pulsarness ~., 
                              family = binomial, data = FGL3_train)),
                              direction = "backward")
print(summary(glm.step.backward.AIC))

predictions_FGL3_train <- predict(glm.step.backward.AIC, FGL3_train, type = "response")
predictions_FGL3_test <- predict(glm.step.backward.AIC, FGL3_test, type = "response")

# Get Training Set threshold, generate ROC plots, and print contingency tables
Best_threshold_train <- ROC_threshold_plots_tables(FGL3_train$pulsarness, 
                                                   predictions_FGL3_train, 
                                                   FGL3_test$pulsarness, 
                                                   predictions_FGL3_test)

# Add LR Prediction Probabilities to FGL3_results data frame:
FGL3_results$LR_P <- round(predict(glm.step.backward.AIC, FGL3_tidy,
                                   type = "response"), digits = 3)

# Add LR Prediction category to FGL3_results data frame:
FGL3_results$LR_Pred <- ifelse(FGL3_results$LR_P > Best_threshold_train[1],
                               "PSR", "AGN")

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
