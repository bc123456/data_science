# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

#  First 2 scripts deal with the preparation of data and the ROC and Table functions
source("Step_01_Get_and_Clean_Data.R")
source("Step_02_ROC_and_Table_function.R")

# Scripts 3-4 deal with the AGN (Active Galactic Nuclei) vs PSR (Pulsar) classification
source("Step_03_AGNvPSR_LR_Backward.R") # Logistic Regression (backward stepwise)
source("Step_04_AGNvPSR_RF.R") # Random Forests

# Script 5 computes the (RF) outlyingness 
source("Step_05_AGNvPSR_RF_Outlyingness.R")

# Scripts 6-7 deal with the Young (YNG) vs Millisecond Pulsar (MSP) classification
source("Step_06_YNGvMSP_BLR.R") # Boosted Logistic Regression
source("Step_07_YNGvMSP_RF.R") # Random Forests

# Write results to a file
save(FGL3_results, file = "FGL3_results.rdata", compress = "xz")
write.table(FGL3_results, file = "FGL3_results.dat", col.names = TRUE)
write.csv(FGL3_results, file = "FGL3_results.csv")        
