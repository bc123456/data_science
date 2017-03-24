#Readme

All the R code used in the 3FGL classification project.

## Abstract
We apply a number of statistical and machine learning techniques to classify and rank gamma-ray sources from the Third Fermi Large Area Telescope Source Catalog (3FGL), according to their likelihood of falling into the two major classes of gamma-ray emitters: pulsars (PSR) or active galactic nuclei (AGNs). Using 1904 3FGL sources that have been identified/associated with AGNs (1738) and PSR (166), we train (using 70% of our sample) and test (using 30%) our algorithms and find that the best overall accuracy (>96%) is obtained with the Random Forest (RF) technique, while using a logistic regression (LR) algorithm results in only marginally lower accuracy. We apply the same techniques on a subsample of 142 known gamma-ray pulsars to classify them into two major subcategories: young (YNG) and millisecond pulsars (MSP). Once more, the RF algorithm has the best overall accuracy (∼90%), while a boosted LR analysis comes a close second. We apply our two best models (RF and LR) to the entire 3FGL catalog, providing predictions on the likely nature of unassociated sources, including the likely type of pulsar (YNG or MSP). We also use our predictions to shed light on the possible nature of some gamma-ray sources with known associations (e.g., binaries, supernova remnants/pulsar wind nebulae). Finally, we provide a list of plausible X-ray counterparts for some pulsar candidates, obtained using Swift, Chandra, and XMM. The results of our study will be of interest both for in-depth follow-up searches (e.g., pulsar) at various wavelengths and for broader population studies.

## References:

Rmd file of the result:

http://www.physics.hku.hk/~pablo/pulsarness.html

Link to the relevant paper:

https://arxiv.org/abs/1602.00385
