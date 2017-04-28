This repository contains code and data from the paper
Niehorster, D.C., Li, L. & Lappe, M. (2017). The accuracy and precision
of position and orientation tracking in the HTC Vive virtual reality
system for scientific research. i-Perception.

The code and data in this repository are licensed under the Creative
Commons Attribution 4.0 (CC BY 4.0) license. When using any of the
contents of this repository, with or without modification, please cite
Niehorster, D.C., Li, L. & Lappe, M. (2017). The accuracy and precision
of position and orientation tracking in the HTC Vive virtual reality
system for scientific research. i-Perception.


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

