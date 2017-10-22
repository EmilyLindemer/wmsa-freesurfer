# Background

This document provides an overview of the MatLab white matter signal abnormality (WMSA) segmentation tool that can be used after processing a given subject with FreeSurfer’s recon-all stream. All recons should be manually inspected for proper gray/white and gray/pial boundaries, edited, and re-processed with recon-all if necessary before using this tool. 

This tool has the functionality to perform WMSA segmentation with any of the following combinations of structural imaging modalities:

* T1 + FLAIR
* T1 + T2 + FLAIR
* T1 + T2 + PD
* T1 + T2

This tool will output 3 new volumes for each subject: 


* `wmsaseg.mgz`: this is a binary segmentation map of all WMSA
* `wmsa_continuous.mgz`: this is a continuous damage map of the entire cerebral WM
* `wmsa_subclasses.mgz`: this is a subclass map of the continuous damage map, grouping voxels using k-means clustering with k=5
