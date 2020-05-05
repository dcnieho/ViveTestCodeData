This repository contains code and data from the paper
Niehorster, D.C., Li, L. & Lappe, M. (2017). The accuracy and precision
of position and orientation tracking in the HTC Vive virtual reality
system for scientific research. i-Perception. doi: 10.1177/2041669517708205

The code and data in this repository are licensed under the Creative
Commons Attribution 4.0 (CC BY 4.0) license. When using any of the
contents of this repository, with or without modification, please cite
Niehorster, D.C., Li, L. & Lappe, M. (2017). The accuracy and precision
of position and orientation tracking in the HTC Vive virtual reality
system for scientific research. i-Perception.

[![DOI](https://zenodo.org/badge/89741881.svg)](https://zenodo.org/badge/latestdoi/89741881)  
This repository is available from www.github.com/dcnieho/ViveTestCodeData

What's in the repository:
* acquisition: python/Vizard 5.6 scripts for recording data. Contains:
    * testTracking - acquire data upon trigger pull, used for capturing data along grid 
    * testTrackingOcclusion - acquire data after intervening track loss. Used for recovery tests
    * testTrackingLatency - show image until tracker position changed significantly. Used for latency test
* analysis: matlab scripts for analyzing data
    * Figure 2: testTrackFaceOneWay
    * Figure 3: testTrackFaceOneWay
    * Figure 4: testTrackFaceBothWays
    * Figure 5: rotationInternalConsistency
    * Figure 6: testTrackFaceBothWays
    * Figure 7: testTrackFaceBothWays
    * Figure 8: testTrackRecovery
    * Figure 9: testTrackRecovery
    * Figure 10: testTrackRecovery
    * Figure 11ab: testTrackFaceBothWays5m
    * Figure 11c: testTrackRecovery
    * Figure 12ab: testTrackFaceBothWays5m
    * Figure 12c: testTrackRecovery
    * Figure 13ab: testTrackFaceBothWays5m
    * Figure 13c: testTrackRecovery
* data: folder with data files from the paper





## Data disclaimer, limitations and conditions of release
By downloading this data set, you expressly agree to the following conditions of release and acknowledge the following disclaimers issued by the authors:

### A. Conditions of Release
Data are available by permission of the authors. Use of data in publications, either digital or hardcopy, must be cited as follows: 
- Niehorster, D.C., Li, L. & Lappe, M. (2017). The accuracy and precision of position and orientation tracking in the HTC Vive virtual reality system for scientific research. i-Perception. doi: 10.1177/2041669517708205

### B. Disclaimer of Liability
The authors shall not be held liable for any improper or incorrect use or application of the data provided, and assume no responsibility for the use or application of the data or interpretations based on the data, or information derived from interpretation of the data. In no event shall the authors be liable for any direct, indirect or incidental damage, injury, loss, harm, illness or other damage or injury arising from the release, use or application of these data. This disclaimer of liability applies to any direct, indirect, incidental, exemplary, special or consequential damages or injury, even if advised of the possibility of such damage or injury, including but not limited to those caused by any failure of performance, error, omission, defect, delay in operation or transmission, computer virus, alteration, use, application, analysis or interpretation of data.

### C. Disclaimer of Accuracy of Data
No warranty, expressed or implied, is made regarding the accuracy, adequacy, completeness, reliability or usefulness of any data provided. These data are provided "as is." All warranties of any kind, expressed or implied, including but not limited to fitness for a particular use, freedom from computer viruses, the quality, accuracy or completeness of data or information, and that the use of such data or information will not infringe any patent, intellectual property or proprietary rights of any party, are disclaimed. The user expressly acknowledges that the data may contain some nonconformities, omissions, defects, or errors. The authors do not warrant that the data will meet the user’s needs or expectations, or that all nonconformities, omissions, defects, or errors can or will be corrected. The authors are not inviting reliance on these data, and the user should always verify actual data.
