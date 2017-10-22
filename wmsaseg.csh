#!/bin/csh -f 


#Tool for automatically segmenting WMSA from NAWM using FreeSurfer tools and the wmsaseg.m MatLab toolbox

#Written by Emily Lindemer 08/24/2016



set VERSION = '$Id: wmsaseg,v 2.0 2016/08/24 13:41:59 lindemer Exp $';

##TODO: CHANGE THIS DEFAULT 
set subject = ();
set bbrinit = "--init-fsl"
set outsub = wmsa;
set tmpdir = ();
set cleanup = 1;
set LF = ();
set DoReg = 1;
set RegOnly = 0;
set DoCANorm = 1;
set origsubject = ();
set GetOrigFromLong = 0;
set t1 = 0;
set t2 = 0;
set pd = 0;
set flair = 0;
set segtype = 0;

set inputargs = ($argv);
set PrintHelp = 0;
if($#argv == 0) goto usage_exit;
set n = `echo $argv | grep -e -help | wc -l` 
if($n != 0) then
  set PrintHelp = 1;
  goto usage_exit;
endif
set n = `echo $argv | grep -e -version | wc -l` 
if($n != 0) then
  echo $VERSION
  exit 0;
endif
goto parse_args;
parse_args_return:
goto check_params;
check_params_return:

set outdir = $SUBJECTS_DIR/$subject/mri/$outsub
mkdir -p $outdir

if($#tmpdir == 0) then
  if(-dw /scratch)   set tmpdir = /scratch/tmpdir.wmsaseg.$$
  if(! -dw /scratch) set tmpdir = $SUBJECTS_DIR/$subject/tmp/tmpdir.wmsaseg.$$
endif
mkdir -p $tmpdir

if($#LF == 0) set LF = $outdir/wmsaseg.log
if($LF != /dev/null) rm -f $LF

set StartTime = `date`;
set tSecStart = `date '+%s'`;

echo "Log file for wmsaseg" >> $LF
date  | tee -a $LF
echo "" | tee -a $LF
echo "setenv SUBJECTS_DIR $SUBJECTS_DIR" | tee -a $LF
echo "cd `pwd`"  | tee -a $LF
echo $0 $inputargs | tee -a $LF
echo "" | tee -a $LF
echo "setenv FREESURFER_HOME $FREESURFER_HOME" | tee -a $LF
cat $FREESURFER_HOME/build-stamp.txt | tee -a $LF
echo $VERSION | tee -a $LF
uname -a  | tee -a $LF

set mdir = $SUBJECTS_DIR/$subject/mri
pushd $mdir 
set mdir = `pwd`
echo "Current dir `pwd`" |tee -a $LF

if($pd&&$flair) then
  exit 1;
endif

if($t2&&!$flair)||($t2&&!$pd)) then
  exit 1;
endif

if($pd&&!$t2) then
  exit 1;
endif

#TODO: echo something to the log about the type
if($t2&&$pd) then
  set segtype = 1;
  set gca = $FREESURFER_HOME/average/wmsa_new_eesmith.gca
endif

#TODO: these atlases need to be moved to the $FREESURFER_HOME DIRECTORY
#There is also a T1/T2 atlas available but has not yet been tested -- future dev
if($t2&&$flair) then
  set segtype = 2;
  set gca = /autofs/cluster/tract/emily/atlases/wmsa.miccai.atlas.t1t2flair.gca
endif

if($flair&&!$pd&&!$t2) then
  set segtype = 3;
  set gca = /autofs/cluster/tract/emily/atlases/wmsa.miccai.atlas.t1flair.gca
endif


if($t2) then
  set t2vol = $SUBJECTS_DIR/$origsubject/mri/orig/T2.mgz
  set t2anat = $mdir/T2.anat.mgz
endif

if($pd) then
  set pdvol = $SUBJECTS_DIR/$origsubject/mri/orig/PD.mgz
  set pdanatvol = $mdir/PD.anat.mgz
endif

if($flair) then
  set flair = $SUBJECTS_DIR/$origsubject/mri/orig/FLAIR.mgz
  set flairanat = $SUBJECTS_DIR/$origsubject/mri/FLAIR.anat.mgz
endif


if($DoReg) then
  # Register T2 to anatomical
  if($t2) then
    set t2reg = $mdir/T2.register.dat
    set update = `UpdateNeeded $t2reg $t2`
    if($update) then
      set cmd = (bbregister --s $subject --mov $t2vol --reg $t2reg $bbrinit --t2 --fsl-bet-mov)
      echo $cmd |& tee -a $LF
      $cmd |& tee -a $LF
      if($status) exit 1;
    endif
    # Apply registration to T2
    set cmd = (mri_vol2vol --mov $t2 --reg $t2reg --fstarg --o $t2anat --no-save-reg)
    echo $cmd |& tee -a $LF
    $cmd |& tee -a $LF
    if($status) exit 1;
    # Convert to uchar
    set cmd = (mri_convert $t2anat $t2anat -odt uchar)
    echo $cmd |& tee -a $LF
    $cmd |& tee -a $LF
    if($status) exit 1;
  endif


  #Register FLAIR to anatomical 
  if($flair) then
    set flairreg = $mdir/FLAIR.register.dat
    set cmd = (bbregister --s $subject --mov $flairvol --reg $flairreg  --t2)
    echo $cmd |& tee -a $LF
    $cmd |& tee -a $LF
    if($status) exit 1;

    # Apply registration to FLAIR
    set cmd = (mri_vol2vol --mov $flair --reg $flairreg --fstarg --o $flairanat --no-save-reg)
    echo $cmd |& tee -a $LF
    $cmd |& tee -a $LF
    if($status) exit 1;
    # Convert to uchar
    set cmd = (mri_convert $flairanat $flairanat -odt uchar)
    echo $cmd |& tee -a $LF
    $cmd |& tee -a $LF
    if($status) exit 1;
  
  endif


  # Force PD and T2 reg to be the same - this will not always be the case
  if($pd) then
    set pdreg = $t2reg;
    
    # Apply registration to PD
    set cmd = (mri_vol2vol --mov $pd --reg $pdreg --fstarg --o $pdanat --no-save-reg)
    echo $cmd |& tee -a $LF
    $cmd |& tee -a $LF
    if($status) exit 1;
    # Convert to uchar
    set cmd = (mri_convert $pdanat $pdanat -odt uchar)
    echo $cmd |& tee -a $LF
    $cmd |& tee -a $LF
    if($status) exit 1;
  endif

endif # DoReg


if($RegOnly) then
  echo "Registration only requested, so exiting now" | tee -a $LF
  if($cleanup) rm -rf $tmpdir
  set tSecEnd = `date '+%s'`;
  @ tSecRun = $tSecEnd - $tSecStart;
  set tRunHours = `echo $tSecRun/3600|bc -l`
  set tRunHours = `printf %5.2f $tRunHours`
  set EndTime = `date`;
  echo "StartEnd $StartTime $EndTime" |& tee -a $LF
  echo "wmsaseg-Run-Time-Hours $tRunHours" |& tee -a $LF
  echo "wmsaseg done (registration only)" |& tee -a $LF
endif


set tallta = $mdir/transforms/talairach.lta
set talm3z = $mdir/transforms/talairach.m3z
set nu = $mdir/nu.mgz
set norm = $mdir/norm.mgz

# Intensity normalize
date |& tee -a $LF

if($pd) then
  set pdnorm = $outdir/PD.canorm.mgz
endif

if($flair) then
  set flairnorm = $outdir/FLAIR.canorm.mgz
endif

if($t2) then
  set t2norm = $outdir/T2.canorm.mgz
endif

set t1norm = $outdir/T1.canorm.mgz
set ctrlpts = $outdir/ctrl_pts.wmsa.mgz



if($DoCANorm) then

  if($type == 1) then
    set cmd = (mri_ca_normalize -n 1 -mask $mdir/brainmask.mgz -c $ctrlpts\
      $norm $pdanat $t2anat $gca $tallta $t1norm $pdnorm $t2norm)
  endif
  if($type == 2) then
    set cmd = (mri_ca_normalize -n 1 -mask $mdir/brainmask.mgz -c $ctrlpts\
      $norm $t2anat $flairanat $gca $tallta $t1norm $t2norm $flairnorm)
  endif
  if($ype == 3) then
    set cmd = (mri_ca_normalize -n 1 -mask $mdir/brainmask.mgz -c $ctrlpts\
      $norm $flairanat $gca $tallta $t1norm $flairnorm)
  endif

  echo $cmd |& tee -a $LF
  $cmd |& tee -a $LF
  if($status) exit 1;
endif


#########I AM HERE

#create labels
date |& tee -a $LF
switch ($typeseg)
  case [1]:
      matlab -nodisplay -nodesktop -r "run /autofs/cluster/tract/emily/wmsa_continuous/wmsaseg('$SUBJECTS_DIR','$origsubject','$outsub','t1',1,'t2',1,'pd',1)"
  case [2]:
      matlab -nodisplay -nodesktop -r "run /autofs/cluster/tract/emily/wmsa_continuous/wmsaseg('$SUBJECTS_DIR','$origsubject','$outsub','t1',1,'t2',1,'flair',1)"
  case [3]:
      matlab -nodisplay -nodesktop -r "run /autofs/cluster/tract/emily/wmsa_continuous/wmsaseg('$SUBJECTS_DIR','$origsubject','$outsub','t1',1,'flair',1)"
  default: 

endsw


# Run segstats to get volume
set cmd = (mri_segstats --seg $wmsasegedit \
  --sum $outdir/wmsa.stats \
  --pv $mdir/norm.mgz --in $mdir/norm.mgz \
  --empty --excludeid 0 --excl-ctxgmwm --supratent --subcortgray \
  --in-intensity-name norm --in-intensity-units MR \
  --etiv --surf-wm-vol --surf-ctx-vol --totalgray \
  --ctab $FREESURFER_HOME/ASegStatsLUT.txt --subject $subject)
echo $cmd |& tee -a $LF
$cmd |& tee -a $LF
if($status) exit 1;

# Run segstats to get intensities
foreach mode (T1 T2 PD FLAIR)
  set invol = $outdir/$mode.canorm.mgz
  set stat = $outdir/wmsa.$mode.dat
  set cmd = (mri_segstats --i $invol --seg $wmsasegedit --id 78 79 --sum $stat --ctab-default)
  echo $cmd
  $cmd
  if($status) exit 1;
end
  
if($cleanup) rm -rf $tmpdir

set tSecEnd = `date '+%s'`;
@ tSecRun = $tSecEnd - $tSecStart;
set tRunHours = `echo $tSecRun/3600|bc -l`
set tRunHours = `printf %5.2f $tRunHours`
set EndTime = `date`;
echo "StartEnd $StartTime $EndTime" |& tee -a $LF
echo "wmsaseg-Run-Time-Hours $tRunHours" |& tee -a $LF
echo "wmsaseg done" |& tee -a $LF

exit 0

###############################################

############--------------##################
parse_args:
set cmdline = ($argv);
while( $#argv != 0 )

  set flag = $argv[1]; shift;
  
  switch($flag)

    case "--s":
      if($#argv < 1) goto arg1err;
      set subject = $argv[1]; shift;
      breaksw

    case "--s+orig":
      if($#argv < 1) goto arg1err;
      set origsubject = $argv[1]; shift;
      breaksw

    case "--s+long":
      set GetOrigFromLong = 1;
      breaksw

    case "--sub":
    case "--subdir":
      if($#argv < 1) goto arg1err;
      set outsub = $argv[1]; shift;
      breaksw

    case "--init-spm":
      set bbrinit = "--init-spm"
      breaksw

    case "--gca":
      if($#argv < 1) goto arg1err;
      set gca = $argv[1]; shift;
      breaksw

    case "--no-reg":
      set DoReg = 0;
      breaksw

    case "--reg-only":
      set RegOnly = 1;
      breaksw

    case "--halo1":
      set Halo = 1;
      breaksw

    case "--halo2":
      set Halo = 2;
      breaksw

    case "--no-canorm":
      set DoCANorm = 0;
      breaksw

    case "--log":
      if($#argv < 1) goto arg1err;
      set LF = $argv[1]; shift;
      breaksw

    case "--nolog":
    case "--no-log":
      set LF = /dev/null
      breaksw

    case "--tmpdir":
      if($#argv < 1) goto arg1err;
      set tmpdir = $argv[1]; shift;
      set cleanup = 0;
      breaksw

    case "--nocleanup":
      set cleanup = 0;
      breaksw

    case "--pd":
      set pd = 0;
      breaksw

    case "--flair":
      set flair = 1;
      breaksw

    case "--t2":
      set t2 = 1;
      breaksw

    case "--cleanup":
      set cleanup = 1;
      breaksw

    case "--debug":
      set verbose = 1;
      set echo = 1;
      breaksw

    default:
      echo ERROR: Flag $flag unrecognized. 
      echo $cmdline
      exit 1
      breaksw
  endsw

end

goto parse_args_return;
############--------------##################

############--------------##################
check_params:

if($#subject == 0) then
  echo "ERROR: must spec subject"
  exit 1;
endif
if(! -e $SUBJECTS_DIR/$subject) then
  echo "ERROR: cannot find $subject"
  exit 1;
endif
if(-e $SUBJECTS_DIR/$subject/mri/$outsub/wmsa.edited.mgz) then
  echo "Results for subject $subject already exist, skipping"
  exit 0;
endif
if($GetOrigFromLong) then
  set origsubject = `echo $subject | sed 's/\.long./ /g' | awk '{print $1}'`
  echo "Getting orig from long: $subject $origsubject"
endif
if($#origsubject == 0) set origsubject = $subject

if($nopd) then
foreach mode (T2 PD)
  set fname = $SUBJECTS_DIR/$origsubject/mri/orig/$mode.mgz
  if(! -e $fname) then
    set fname = $SUBJECTS_DIR/$origsubject/mri/$mode.mgz
    if(! -e $fname) then
      echo "ERROR: cannot find $fname"
      exit 1;
    endif
  endif
end
else
  if($flair_include) then
  foreach mode (T2 FLAIR)
    set fname = $SUBJECTS_DIR/$origsubject/mri/orig/$mode.mgz
    if(! -e $fname) then
      set fname = $SUBJECTS_DIR/$origsubject/mri/$mode.mgz
      if(! -e $fname) then
	echo "ERROR: cannot find $fname"
	exit 1;
      endif
    endif
  end
  else
  foreach mode ( T2 )
    set fname = $SUBJECTS_DIR/$origsubject/mri/orig/$mode.mgz
    if(! -e $fname) then
      set fname = $SUBJECTS_DIR/$origsubject/mri/$mode.mgz
      if(! -e $fname) then
	echo "ERROR: cannot find $fname"
	exit 1;
      endif
    endif
  end
  endif
endif

if(! -e $gca) then
  echo "ERROR: cannot find $gca"
  exit 1;
endif

goto check_params_return;
############--------------##################

############--------------##################
arg1err:
  echo "ERROR: flag $flag requires one argument"
  exit 1
############--------------##################
arg2err:
  echo "ERROR: flag $flag requires two arguments"
  exit 1
############--------------##################

############--------------##################
usage_exit:
  echo ""
  echo "wmsaseg --s subject"
  echo "  --s+orig origsubject : get T2 and PD from origsubject (good for long)" 
  echo "  --s+long : get T2 and PD from orig long subject (origsubject.long.base_base)" 
  echo "  --sub output sub dir (default is wmsa)"
  echo "  --gca gcafile"
  echo "  --no-reg : do not register mode to anat"
  echo "  --no-canorm : do not run mri_ca_norm (eg, if used another)"
  echo "  --init-spm : default is fsl"
  echo "  --reg-only : only perform registration"
  echo "  --halo1"
  echo "  --halo2"
  echo ""

  if(! $PrintHelp) exit 1;
  echo $VERSION
  cat $0 | awk 'BEGIN{prt=0}{if(prt) print $0; if($1 == "BEGINHELP") prt = 1 }'
exit 1;
