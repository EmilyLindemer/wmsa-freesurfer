# Basic Implementation

The following steps are required to run this tool: 

1. Run the provided .csh script that performs image registration and intensity normalization. I have included 3 atlases for intensity normalization to be used depending on your input modalities. For example, if you are using T1 + FLAIR, you should use the `wmsa.miccair.atlas.t1flair.gca` located in the `preproc-atlases` subdirectory:

`wmsaseg_regandnorm_wrapper.csh  $SUBJ_DIR  $SUBJ_ID  $WMSA_OUTDIR  $ATLAS`

where `$SUBJ_DIR` is your main directory housing all subjects' individual directories, `$SUBJ_ID` is the ID corresponding to the name of an individual subject's directory, `$WMSA_OUTDIR` is the name of the new directory where all WMSA outputs will go, and `$ATLAS` is the full path to the appropriate atlas from the `/preproc-atlases` directory for your dataset.

2. Using matlab, run the wmsaseg.m function with the following command-line inputs. Again, the example below is for a use case using T1 + FLAIR: 

`wmsaseg(“$SUBJ_DIR”, “$SUBJ_ID”, “$WMSA_OUTDIR”, “t1”, 1, “flair”, 1)`

3. For output measure in table form, `mri_segstats` can be run on any of the three tool outputs to derive regional measures of WMSA load, continuous damage, or WMSA load by subclass using the following command: 

`mri_segstats --seg $SUBJ_DIR/$SUBJ_ID/mri/wmparc.mgz --sum $SUBJ_DIR/$SUBJ_ID/mri/$WMSA_OUTDIR/wmsa.stats --pv $SUBJ_DIR/$SUBJ_ID/mri/norm.mgz --in $SUBJ_DIR/$SUBJ_ID/mri/$WMSA_OUTDIR/$WMSA_OUTPUT.mgz --empty --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --etiv --surf-wm-vol --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt `
