# Segmentation Parameters

Some datasets may require parameter adjustment for optimal WMSA segmentation due to acquisition at different field strengths and/or different imaging parameters. It is recommended to first run `wmsaseg.m` with the default parameters as described above and to visually inspect the output before deciding to alter any of the segmentation parameters. For best practice, all data in a given dataset should be processed using the same set of segmentation parameters. 

The following segmentation parameters can be adjusted: 


***thresh***: the default setting is 3, and can be changed to any value including decimal values. The higher the value, the more conservative the segmentation tool will be in labeling WMSA. If the tool is consistently underlabeling WMSA in your dataset, try adjusting this number downwards by a small amount at the command-line. 

For example: 


`wmsaseg(“$SUBJ_DIR”, “$SUBJ_ID”, “$WMSA_OUTDIR”, “t1”, 1, “flair”, 1,”thresh”, 2.8)`

Conversely, if the tool is consistently overlabeling WMSA, adjust this number upwards by a small amount. 


***fuzzyvents***: default setting is 0, but can be changed to 1 at the command-line when running wmsa.m by adding ‘fuzzyvents’,1 to the command-line argument. This may be useful for lower-res images where there is a lot of partial voluming around the ventricles. If the first iteration of the segmentation tool produces many false positive WMSA labels around the ventricles, use this flag. 


For example: 


`wmsaseg(“$SUBJ_DIR”, “$SUBJ_ID”, “$WMSA_OUTDIR”, “t1”, 1, “flair”, 1,”fuzzyvents”, 1)`
