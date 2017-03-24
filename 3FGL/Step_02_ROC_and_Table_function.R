# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

# Load workspace from previous step
load(".RData")

# Load pROC package
library(pROC)

# Function to get the best threshold
ROC_threshold <- function(truth, prediction) {
        ROC <- roc(truth, prediction)
        ROC_table <- cbind(ROC$thresholds, ROC$specificities, ROC$sensitivities)
        ROC_table[which.max(ROC_table[, 2] + ROC_table[, 3]), ]        
}

# Function to plot ROC curves
ROC_plots <- function(truth_train, prediction_train, truth_test, prediction_test) {
        par(mfrow = c(1, 2))
                ROC_train <- roc(truth_train, prediction_train, 
                        plot = TRUE, print.auc = TRUE, main = "ROC Train", print.thres = "best")
                ROC_test <- roc(truth_test, prediction_test, 
                        plot = TRUE, print.auc = TRUE, main = "ROC Test", print.thres = "best")
}

# Function to generate contingency tables
ROC_tables <- function(truth_train, prediction_train, truth_test, prediction_test, 
                       cat1 = "Pulsar", cat2 = "AGN") {
        ROC <- roc(truth_train, prediction_train)
        ROC_table <- cbind(ROC$thresholds, ROC$specificities, ROC$sensitivities)
        threshold <- ROC_table[which.max(ROC_table[, 2] + ROC_table[, 3]), ] 

        # Training data
        nrow_train <- length(prediction_train)
        Predict_class_train <- rep("NA", nrow_train)
        Predict_class_train <- ifelse(prediction_train > threshold[1], cat1, cat2) 
        real_category <- truth_train
        print(table(Predict_class_train, real_category))
        
        # Testing data
        nrow_test <- length(prediction_test)
        Predict_class_test <- rep("NA", nrow_test)
        Predict_class_test <- ifelse(prediction_test > threshold[1], cat1, cat2) 
        real_category <- truth_test
        print(table(Predict_class_test, real_category))
}

ROC_threshold_plots_tables <- function(truth_train, prediction_train, truth_test, prediction_test, 
                                       threshold = 0, cat1 = "Pulsar", cat2 = "AGN") {
        
        if (threshold == 0) {
                # Compute best threshold if none is provided
                ROC <- roc(truth_train, prediction_train)
                ROC_table <- cbind(ROC$thresholds, ROC$specificities, ROC$sensitivities)
                best_threshold <- ROC_table[which.max(ROC_table[, 2] + ROC_table[, 3]), ] 
        } else {
                # Don't compute threshold if one is provided
                best_threshold <- threshold
        }

        if (nargs() > 2) { 
                # Make ROC plots
                par(mfrow = c(1, 2))
                ROC_train <- roc(truth_train, prediction_train, 
                         plot = TRUE, print.auc = TRUE, main = "ROC Train", print.thres = "best")
                ROC_test <- roc(truth_test, prediction_test, 
                        plot = TRUE, print.auc = TRUE, main = "ROC Test", print.thres = "best")
        
                # Generate contingency tables
                # Training data
                nrow_train <- length(prediction_train)
                Predict_class_train <- rep("NA", nrow_train)
                Predict_class_train <- ifelse(prediction_train > best_threshold[1], cat1, cat2) 
                real_category <- truth_train
                print(table(Predict_class_train, real_category))

                # Testing data
                nrow_test <- length(prediction_test)
                Predict_class_test <- rep("NA", nrow_test)
                Predict_class_test <- ifelse(prediction_test > best_threshold[1], cat1, cat2) 
                real_category <- truth_test
                print(table(Predict_class_test, real_category))
        }
        return(best_threshold)
}

# Function to get best threshold, plot ROC curves and print tables
ROCandTable <- function(predictions_FGL3_train, FGL3_train, predictions_FGL3_test, FGL3_test, Best_threshold) {

        # Plot ROC curve and Table for train and testing data
        par(mfrow = c(1, 2))
        # Draw ROC for train_data
        ROC_FGL3_train <- roc(FGL3_train$pulsarness, predictions_FGL3_train, 
                              plot = TRUE, print.auc = TRUE, main = "ROC FGL3 Train", print.thres = "best")
        # Draw ROC for test_data
        ROC_FGL3_test <- roc(FGL3_test$pulsarness, predictions_FGL3_test, 
                             plot = TRUE, print.auc = TRUE, main="ROC FGL3 Test", print.thres = "best")
       
        # Using The Best Threshold from cross-validation method
        Best_threshold 
        # Table for training data
        nrow_train <- nrow(FGL3_train)
        Predict_class <- rep("NA", nrow_train)
        for (i in 1:nrow_train) {
                if (predictions_FGL3_train[i] <= Best_threshold[1]) {
                        Predict_class[i] <- "AGN"
                } else {
                        Predict_class[i] <- "Pulsar"
                }
        }
        real_category <- FGL3_train$pulsarness
        print(table(Predict_class, real_category))
        # Table for testing data
        nrow_test <- nrow(FGL3_test)
        Predict_class <- rep("NA", nrow_test)
        for (i in 1:nrow_test) {
                if (predictions_FGL3_test[i] <= Best_threshold[1]){
                        Predict_class[i] <- "AGN"
                } else {
                        Predict_class[i] <- "Pulsar"
                }
        }
        real_category <- FGL3_test$pulsarness
        print(table(Predict_class, real_category))
}

# Save current workspace for subsequent steps
save.image()
