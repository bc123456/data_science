# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

# Load dplyr R package for efficient handling of data frames
library(dplyr)

# Load results
load(file = "FGL3_results.rdata")

# Results are stored in FGL3_results
# AGN vs PSR:
# LR_P -> Logistic Regression (LR) results (for PSR vs AGN classification)
# LR_Pred -> Category predicted by LR (using best threshold): "PSR" or "AGN"
# RF_P -> Random Forest (RF) with 10-fold cross-validation results (for PSR vs AGN classification)
# RF_Pred -> Category predicted by RF with 10-fold cross-validation (using best threshold): "PSR" or "AGN"
# YNG vs MSP:
# BLR_PSR_P -> Boosted Logistic Regression results (for 'Young' (YNG) vs 'Millisecond' pulsars (MSP))
# BLR_PSR_Pred -> Category of pulsar predicted by BLR
# RF_PSR_P -> Random Forest (RF) prediction (for 'Young' (YNG) vs 'Millisecond' pulsars (MSP))
# RF_PSR_Pred -> Category of pulsar predicted by Random Forest (RF)

# Results for Table 6: Most significant  3FGL unassociated sources predicted by both RF and LR to be pulsars
unassoc_results <- FGL3_results %>%
        filter(CLASS1 == "") %>%
        filter(Signif > 10) %>%
        filter(LR_Pred==RF_Pred) %>%
        filter(LR_Pred=="PSR") %>%
        arrange(desc(Signif))

# Results for Table 7: Predictions for 3FGL sources with known SNR/PWN associations
SNR_PWN_results <- FGL3_results %>%
        filter(CLASS1 == "SNR" | CLASS1 == "snr" | CLASS1 == "spp" | CLASS1 == "PWN " | CLASS1 == "pwn")

# Results for Table 8: Predictions for 3FGL sources associated with known gamma-ray binaries
BIN_results <- FGL3_results %>%
        filter(CLASS1 == "HMB" | CLASS1 == "BIN")

# Results for Table 9: List of 3FGL sources with largest (>75) values of PSR and AGN outlyingness
FGL3_results_outlyingness <- FGL3_results %>%
        filter(FGL3_results$PSR_Out > 75 & FGL3_results$AGN_Out > 75)

# Results for Table 10: List of 3FGL sources for which the RF and LR classifiers are in agreement with 
# each other but disagree with the 3FGL catalog classification
FGL3_results_pulsarness <- FGL3_results %>%
        filter(CLASS1 == "PSR" | CLASS1 == "psr" 
               | CLASS1 == "BCU" | CLASS1 == "bcu" 
               | CLASS1 == "BLL" | CLASS1 == "bll"
               | CLASS1 == "FSRQ"| CLASS1 == "fsrq"
               | CLASS1 == "rdg" | CLASS1 == "RDG"
               | CLASS1 == "nlsy1" | CLASS1 == "NLSY1"
               | CLASS1 == "agn" | CLASS1 == "ssrq"
               | CLASS1 == "sey") %>%
        mutate(pulsarness = factor(CLASS1=="PSR" | CLASS1=="psr", labels = c("AGN", "PSR")))

# How many sources give the same prediction with RF and LR?
sum(FGL3_results_pulsarness$LR_Pred==FGL3_results_pulsarness$RF_Pred) # A: 1825
misclassifications <- filter(FGL3_results_pulsarness, 
                             (FGL3_results_pulsarness$LR_Pred==FGL3_results_pulsarness$RF_Pred)
                             &(FGL3_results_pulsarness$RF_Pred!=FGL3_results_pulsarness$pulsarness))
