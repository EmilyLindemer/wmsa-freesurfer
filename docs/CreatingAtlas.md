# Creating Your Own Atlas

In some cases, an investigator may want to create their own atlas for the assessment of WMSA in a given population. This software package provides a tool for this purpose. The requirements for creating your own atlas are as follows: 

1. Data must be a combination of T1w, T2w, PDw, and FLAIR
2. You must provide a set of T1w images for the datasets that are to be included in the atlas
3. These datasets must have been processed through the FreeSurfer recon-all stream
4. These datasets must then be pre-processed with the provided pre-processing script which performs multimodal image registration and intensity normalization
5. Datasets must have manual labels for all WMSA provided as a binary mask in a file called wmsa_man.mgz (label values = 1) that is located in the subject’s /mri subdirectory

To create this atlas, run the following in matlab: 

`[atlas] = create_atlas(‘main_dir’,’subj_list’)`

Where `main_dir` is the main directory where your atlas subjects are located and `subj_list` is a .txt file containing the names of your atlas subjects as they are called in their directories. This will output a data structure into the atlas variable, which can then be saved as a .mat file as are the atlases provided in this software package. 
