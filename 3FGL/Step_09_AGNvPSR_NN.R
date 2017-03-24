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

#scaled <- model.matrix( as.formula(paste("~", paste(n, collapse = " + "))), data = scaled)

FGL3_train_ <- scaled[1:nrow(FGL3_train),]
FGL3_test_ <- scaled[-(1:nrow(FGL3_train)),]

# Load neural network package
library(neuralnet)

# Start training

n <- names(FGL3_train_)
f <- as.formula(paste("pulsarness ~", paste(n[!n %in% "pulsarness"], collapse = " + ")))
nn <- neuralnet(f,data=FGL3_train_,hidden=c(3,3),linear.output=TRUE)
#plot(nn)
# Predictions

pr.nn_test <- neuralnet::compute(nn, FGL3_test_[,1:9])    # add neuralnet:: to avoid namespace colision with ggplot2 and dplyr
predictions_FGL3_test <- pr.nn_test$net.result

pr.nn_train <- neuralnet::compute(nn, FGL3_train_[,1:9])
predictions_FGL3_train <- pr.nn_train$net.result

# Get Training Set threshold, generate ROC plots, and print contingency tables
Best_threshold_train <- ROC_threshold_plots_tables(FGL3_train_$pulsarness, 
                                                   predictions_FGL3_train, 
                                                   FGL3_test_$pulsarness, 
                                                   predictions_FGL3_test)



# Normalize the full

FGL3_tidy_attr_and_y <- FGL3_tidy[,c(3,4,6,7,8,11,12,13,14,16)]
FGL3_tidy_attr <- FGL3_tidy_attr_and_y[,1:9]

maxs_tidy <- apply(FGL3_tidy_attr, 2, max)
mins_tidy <- apply(FGL3_tidy_attr, 2, min)

scaled_tidy_attr <- as.data.frame(scale(FGL3_tidy_attr, center = mins_tidy, scale = maxs_tidy - mins_tidy))
scaled_tidy <- cbind(scaled_tidy_attr, FGL3_tidy_attr_and_y[10])
scaled_tidy$pulsarness <- as.numeric(scaled_tidy$pulsarness) # convert factor to numeric
# Add LR Prediction Probabilities to FGL3_results data frame:
pr.nn_tidy <- neuralnet::compute(nn, scaled_tidy[,1:9])
FGL3_results$NN_P <- round(pr.nn_tidy$net.result, digits = 3)

# Add LR Prediction category to FGL3_results data frame:
FGL3_results$NN <- ifelse(FGL3_results$NN_P > Best_threshold_train[1],
                               "PSR", "AGN")
