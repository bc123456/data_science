# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

# Computation of AGN and PSR "outlyingness" using Random Forests (RF)

# Load workspace from previous step:
load(".RData")

# Load randomForest package:
library(randomForest)

# Set random seed:
set.seed(1)

# Compute RF predictions on entire FGL3 data:
results <- predict(rf.full.FGL3, newdata = FGL3_tidy, proximity = TRUE, type = "Prob")

# Use proximity matrix to compute PSR and AGN "outlyingness":
nobs <- dim(FGL3_tidy)[1]
PSR_Out <- numeric(nobs)
AGN_Out <- numeric(nobs)

for (i in 1:nobs ) {
        PSR_proximities <- results$proximity[FGL3_tidy$pulsarness == "Pulsar", i] 
        PSR_Out[i] <- 1./sum(PSR_proximities^2)
        AGN_proximities <- results$proximity[FGL3_tidy$agnness == "AGN", i] 
        AGN_Out[i] <- 1./sum(AGN_proximities^2)
}

# Normalize outlyingness:       
PSR_Out_norm <- (PSR_Out - median(PSR_Out[FGL3_tidy$pulsarness == "Pulsar"])) / 
        mad(PSR_Out[FGL3_tidy$pulsarness=="Pulsar"])
AGN_Out_norm <- (AGN_Out - median(AGN_Out[FGL3_tidy$agnness == "AGN"])) / 
        mad(AGN_Out[FGL3_tidy$agnness=="AGN"])

# Add outlyingness to FGL3_results data frame:
FGL3_results$PSR_Out <- round(PSR_Out_norm, digits = 3)
FGL3_results$AGN_Out <- round(AGN_Out_norm, digits = 3)

# Outlyingness Plot:
plot(FGL3_results$PSR_Out, FGL3_results$AGN_Out, 
     xlim = c(0.1,900), ylim = c(0.1,3000), 
     xlab = "PSR Outlyingness", 
     ylab = "AGN Outlyingness", 
     log = "xy",
     type = "n")
legend(0.1, 6, c("AGN", "Pulsars", "Non-AGN/Non-Pulsars"), pch = c(17, 19, 1))
points(FGL3_results$PSR_Out[FGL3_tidy$agnness=="AGN"], 
       FGL3_results$AGN_Out[FGL3_tidy$agnness=="AGN"], 
       pch = 17)
points(FGL3_results$PSR_Out[FGL3_tidy$pulsarness=="Pulsar"], 
       FGL3_results$AGN_Out[FGL3_tidy$pulsarness=="Pulsar"], 
       pch = 19)
points(FGL3_results$PSR_Out[(FGL3_tidy$agnness!="AGN")&(FGL3_tidy$pulsarness!="Pulsar")], 
       pch = 1)
abline(h = 10, lty = 2, lwd = 3)
abline(v = 10, lty = 2, lwd = 3)

# Clean up and Set aside required data sets:
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

# Save current workspace for subsequent steps:
save.image()  
