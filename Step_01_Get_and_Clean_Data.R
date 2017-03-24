# These scripts are associated with the following publication:
# Title: "Classification and Ranking of Fermi LAT Gamma-ray Sources from the 3FGL Catalog Using Machine Learning Techniques"
# Authors: Saz Parkinson, P. M. (HKU/LSR, SCIPP), Xu, H. (HKU), Yu, P. L. H. (HKU), Salvetti, D. (INAF-Milan), Marelli, M. (INAF-Milan), Falcone, A. D. (Penn State)
# Journal: The Astrophysical Journal (2016), in press
# url: http://arxiv.org/abs/1602.00385
# NB: You are welcome to use these scripts for your own purposes, but if you do so, we kindly ask that you cite the above publication.

# Load fermicatsR package containing Fermi LAT Catalogs
library(fermicatsR)

# Load dplyr R package for efficient handling of data frames
library(dplyr)

# Define function to compute the SED points (energy flux at the geometric mean of the energy band)
sedflux <- function(photon_flux, alpha, Elo, Ehi) {
        R <- Elo/Ehi
        GeV2erg <- 0.00160217657
        (GeV2erg*Elo)*(alpha-1)*(photon_flux)*(R^(alpha/2 - 1))/(1-(R^(alpha-1)))
}

# Subselect small number of variables from those available in 3FGL
FGL3_01 <- select(FGL3, 
                  Source_Name, RAJ2000, DEJ2000, GLON, GLAT, 
                  Spectral_Index, Energy_Flux100, Variability_Index, 
                  Conf_68_SemiMajor, Conf_68_SemiMinor, Conf_68_PosAng, 
                  Conf_95_SemiMajor, Conf_95_SemiMinor, Conf_95_PosAng, 
                  Signif_Avg, Pivot_Energy, Flux_Density, Unc_Flux_Density, 
                  Flux1000, Unc_Flux1000, Energy_Flux100, Unc_Energy_Flux100, 
                  Signif_Curve, Flux100_300, Flux300_1000, Flux1000_3000, 
                  Flux3000_10000, Flux10000_100000, CLASS1, ASSOC1)

# Add new variables (SED points and hardness ratios) computed using sedflux function above      
FGL3_02 <- mutate(FGL3_01, 
                  SED100_300 = sedflux(Flux100_300, Spectral_Index, 0.1, 0.3), 
                  SED300_1000 = sedflux(Flux300_1000, Spectral_Index, 0.3, 1.0), 
                  SED1000_3000 = sedflux(Flux1000_3000, Spectral_Index, 1.0, 3.0), 
                  SED3000_10000 = sedflux(Flux3000_10000, Spectral_Index, 3.0, 10.0), 
                  SED10000_100000 = sedflux(Flux10000_100000, Spectral_Index, 10.0, 100.0), 
                  hr12 = (SED300_1000-SED100_300)/(SED300_1000+SED100_300), 
                  hr23 = (SED1000_3000-SED300_1000)/(SED1000_3000+SED300_1000), 
                  hr34 = (SED3000_10000-SED1000_3000)/(SED3000_10000+SED1000_3000), 
                  hr45 = (SED10000_100000-SED3000_10000)/(SED10000_100000+SED3000_10000), 
                  CLASS1 = gsub(" ", "", CLASS1))

# Drop highly correlated and some unused variables
FGL3_03 <- select(FGL3_02, 
                  -Unc_Flux1000, -Energy_Flux100, -Conf_95_SemiMajor, -Conf_95_SemiMinor, 
                  -Flux100_300, -Conf_68_SemiMajor, -Conf_68_SemiMinor, -Conf_68_PosAng, 
                  -Flux1000, -SED100_300, -SED300_1000, -SED1000_3000, -SED3000_10000, 
                  -SED10000_100000, -Flux300_1000, -Flux1000_3000, -Flux3000_10000)

# Take log of variables with highly skewed distributions (removing zeroes to avoid -Inf)
FGL3_04 <-  filter(FGL3_03, FGL3_03$Signif_Curve != 0) %>%
        mutate(Variability_Index = log(Variability_Index), 
               Pivot_Energy = log(Pivot_Energy), 
               Flux_Density = log(Flux_Density), 
               Unc_Flux_Density = log(Unc_Flux_Density), 
               Unc_Energy_Flux100 = log(Unc_Energy_Flux100), 
               Flux10000_100000 = log(Flux10000_100000), 
               Signif_Curve = log(Signif_Curve))

# Drop a few more unused variables
FGL3_05 <- select(FGL3_04, -Pivot_Energy, -Unc_Flux_Density, -Flux10000_100000)

# Create a tidy data set including "pulsarness" and "agnness" factors
FGL3_tidy <- select(FGL3_05, -RAJ2000, -DEJ2000, -GLON, -Signif_Avg) %>%
        mutate(agnness = factor(CLASS1 == "BCU" | CLASS1 == "bcu" 
                                |CLASS1 == "BLL" | CLASS1 == "bll"
                                |CLASS1 == "FSRQ"| CLASS1 == "fsrq"
                                |CLASS1 == "rdg" | CLASS1 == "RDG"
                                |CLASS1 == "nlsy1" | CLASS1 == "NLSY1"
                                |CLASS1 == "agn" | CLASS1 == "ssrq"
                                |CLASS1 == "sey", 
                                labels = c("Non-AGN", "AGN")),
               pulsarness = factor(CLASS1 == "PSR" | CLASS1 == "psr",
                                   labels = c("Non-Pulsar", "Pulsar")))

# Create the FGL3_results data frame that will contain final results
FGL3_results <- select(FGL3_05, Source_Name,
                       Signif = Signif_Avg,
                       Flux = Flux_Density,
                       RA = RAJ2000,
                       DEC = DEJ2000,
                       GLON, GLAT, ASSOC1, CLASS1) %>%
        mutate(Source_Name = substr(Source_Name, 6, 18),
               RA = format(RA, digits = 2),
               DEC = format(DEC, digits = 2),
               GLON = format(GLON, digits = 2),
               GLAT = format(GLAT, digits = 2),
               Signif = round(Signif, digits = 3)) %>%
        mutate(Flux = format(exp(Flux), scientific = TRUE, digits = 3))

# Select data for PSR (pulsarness == "Pulsar") vs AGN (agnness == "AGN") classification
FGL3_AGNPSR <- filter(FGL3_tidy, pulsarness == "Pulsar" | agnness == "AGN")

# Drop sources with missing values and some unused variables
FGL3_AGNPSR <- na.omit(FGL3_AGNPSR)
FGL3_AGNPSR <- select(FGL3_AGNPSR, -CLASS1, -ASSOC1, -Source_Name,
                      -GLAT, -Conf_95_PosAng, -agnness)

# Set Random seed
set.seed(1)

# Separate into training (70%) and testing (30%) sets
train <- sample(nrow(FGL3_AGNPSR), round(nrow(FGL3_AGNPSR)*0.7))
FGL3_test <- FGL3_AGNPSR[-train, ]
FGL3_train <- FGL3_AGNPSR[train, ]

# Split training data into k (10) blocks for k-fold cross-validation
k <- 10
Index <- sample(nrow(FGL3_train))
Block_index <- matrix(data = Index[1:(floor(nrow(FGL3_train)/k)*k)], nrow = k, byrow = TRUE)
FGL3_train_CV <- FGL3_train[Index[1:(floor(nrow(FGL3_train)/k)*k)], ]

# Initialise predictions vector
predictions_FGL3_train_CV <- rep(0, nrow(FGL3_train_CV))

# Prepare pulsar data sets for YNG vs MSP classification
pulsars_long <- mutate(pulsars, PSR_coords = substr(PSR, 6, 12))
FGL3_pulsars <- FGL3_tidy %>%
        filter(pulsarness == "Pulsar") %>%
        mutate(ASSOC1 = as.character(ASSOC1))

a <- strsplit(FGL3_pulsars$ASSOC1, "PSR J")
b <- character(nrow(FGL3_pulsars))

for (i in 1:nrow(FGL3_pulsars)) {
        b[i] <- gsub(" ", "", a[[i]][2])       
}

FGL3_pulsars$ASSOC1_code <- b
FGL3_pulsars <- mutate(FGL3_pulsars, ASSOC1_code = substr(ASSOC1_code, 1, 7))
bothFGL3andpulsars <- inner_join(pulsars_long, FGL3_pulsars, 
                                 by = c("PSR_coords" = "ASSOC1_code"))
FGL3_Pulsars <- mutate(bothFGL3andpulsars, 
                       pulsarness = factor(P_ms >= 10, labels = c("MSP", "YNG"))) %>%
        select(-P_ms, -Codes, -RAJ_deg, -DECJ_deg, -Refs, -CLASS1, -ASSOC1, 
               -Source_Name, -PSR, -PSR_coords, -Edot, -agnness)

# Separate pulsar data set into 30% (testing test) and 70% (training test)
set.seed (1)

train <- sample(nrow(FGL3_Pulsars), round(nrow(FGL3_Pulsars)*0.7))
FGL3_Pulsars_test <- FGL3_Pulsars[-train, ]
FGL3_Pulsars_train <- FGL3_Pulsars[train, ]

# Clean up and Set aside required data sets                                                                                                                     
Environ <- ls()
Environ <- Environ[Environ != "FGL3_tidy"
                   & Environ != "FGL3_results" 
                   & Environ != "FGL3_AGNPSR"
                   & Environ != "FGL3_test" 
                   & Environ != "FGL3_train" 
                   & Environ != "predictions_FGL3_train_CV" 
                   & Environ != "Block_index" 
                   & Environ != "FGL3_train_CV"
                   & Environ != "FGL3_Pulsars_train"
                   & Environ != "FGL3_Pulsars_test"]
rm(list = Environ)

# Save current workspace for subsequent steps
save.image()
