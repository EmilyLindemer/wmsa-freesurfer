function wmsaseg( main_dir,subj_id,outsub,varargin )
%This is the main function of the WMSAseg tool which implements several
%subfunctions to create maps of continuous damage, subclasses of damage,
%and binary segmentation of WMSA.

%This function currently relies on the existence of a wmsa
%subdirectory within a subject's mri directory using the standard
%FreeSurfer recon processing stream. It requires that the subject's T1w
%image has been fully reconned. 

%This function currently works with a T1/T2/FLAIR, T1/FLAIR, or T1/T2/PD
%combination.

%This function requires the existence of a T1.canorm.mgz, T2.canorm.mgz and
%FLAIR.canorm.mgz volume within the wmsa directory which are
%three volumes all registered to anatomical space and normalized to the
%wmsa.miccai.atlas.t1t2flair.gca atlas. See wmsaseg.csh script for this. 

%Created by Emily Lindemer 08/12/2016


p=inputParser;
defaultT1=0;
defaultT2=0;
defaultPD=0;
defaultFLAIR=0;
defaultThresh=3;
defaultVents=0;

addRequired(p,'main_dir',@(x)validateattributes(x,{'char'},{'nonempty'}))
addRequired(p,'subj_id',@(x)validateattributes(x,{'char'},{'nonempty'}))
addRequired(p,'outsub',@(x)validateattributes(x,{'char'},{'nonempty'}))
addParameter(p,'t1',defaultT1,@isnumeric);
addParameter(p,'t2',defaultT2,@isnumeric);
addParameter(p,'pd',defaultPD,@isnumeric);
addParameter(p,'flair',defaultFLAIR,@isnumeric);
addParameter(p,'thresh',defaultThresh,@isnumeric);
addParameter(p,'fuzzyvents',defaultVents,@isnumeric);

parse(p,main_dir,subj_id,outsub,varargin{:});

t1_e=0;
t2_e=0;
pd_e=0;
flair_e=0;
thresh=p.Results.thresh;
outsub=p.Results.outsub;
vents=0;


if(p.Results.t1~=0)
    if (p.Results.t1==1)
        t1=MRIread(sprintf('%s/%s/mri/%s/T1.canorm.mgz',main_dir,subj_id,outsub));
        t1_e=1;
        t1_m=fast_vol2mat(t1);
    else
        sprintf('The value %f is not a valid input for the T1 flag',p.Results.t1)
    end
end
if(p.Results.t2~=0)
    if (p.Results.t2==1)
        t2=MRIread(sprintf('%s/%s/mri/%s/T2.canorm.mgz',main_dir,subj_id,outsub));
        t2_e=1;
        t2_m=fast_vol2mat(t2);
    else
         sprintf('The value %f is not a valid input type for the T2 flag',p.Results.t2)
    end
end
if(p.Results.pd~=0)
    if (p.Results.pd==1)
        pd=MRIread(sprintf('%s/%s/mri/%s/PD.canorm.mgz',main_dir,subj_id,outsub));
        pd_e=1;
        pd_m=fast_vol2mat(pd);
    else
        sprintf('The value %f is not a valid input type for the PD flag',p.Results.pd)
    end
end
if(p.Results.flair~=0)
    if (p.Results.flair==1)
      flair=MRIread(sprintf('%s/%s/mri/%s/FLAIR.canorm.mgz',main_dir,subj_id,outsub));
      flair_e=1;
      flair_m=fast_vol2mat(flair);
    else
      sprintf('The value %f is not a valid input type for the flair flag',p.Results.flair)
    end
end


if(p.Results.fuzzyvents~=0)
    vents=1;
end


if (pd_e==1)
    if (t2_e == 0 || t1_e == 0 || flair_e == 1)
        sprintf('The required input is T1/T2/PD, T1/T2/FLAIR, or T1/FLAIR')
        exit
    end
    volarray=[t1_m; t2_m; pd_m]';
    load('/atlases/t1t2pd_atlas_08232016.mat','atlas');
elseif(t2_e==1 && flair_e==1)
    if (t1_e == 0 || pd_e == 1)
        sprintf('The required input is T1/T2/PD, T1/T2/FLAIR, or T1/FLAIR')
        exit
    end
    volarray=[t1_m; t2_m; flair_m]';
    load('/atlases/t1t2flair_atlas_08112016.mat','atlas');
elseif(t2_e==0 && flair_e==1)
    if (t1_e == 0 || pd_e == 1)
        sprintf('The required input is T1/T2/PD, T1/T2/FLAIR, or T1/FLAIR')
        exit
    end
    volarray=[t1_m; flair_m]';
    load('t1flair_atlas_08252016.mat','atlas');
elseif(t1_e == 1 && t2_e == 1) 
    volarray = [t1_m; t2_m]';
    load('/atlases/t1t2_atlas_05032017.mat','atlas')
end



wmparc=MRIread(sprintf('%s/%s/mri/wmparc.mgz',main_dir,subj_id));



if(vents==0)
    contmap=label_subject_cont(atlas,volarray,wmparc,0);
else
    contmap=label_subject_cont(atlas,volarray,wmparc,1);
end
    
newvol=wmparc;
newvol.vol=contmap;

MRIwrite(newvol,sprintf('%s/%s/mri/%s/wmsa_continuous.mgz',main_dir,subj_id,outsub));



if(flair_e==1)
    [binvol,kmap]=label_subject_bin(newvol,flair,wmparc,thresh);
else
    %use T2 as the outlier if there is no FLAIR 
    [binvol,kmap]=label_subject_bin(newvol,t2,wmparc,thresh);
end


MRIwrite(kmap,sprintf('%s/%s/mri/%s/wmsa_subclasses.mgz',main_dir,subj_id,outsub));
MRIwrite(binvol,sprintf('%s/%s/mri/%s/wmsaseg.mgz',main_dir,subj_id,outsub));


end

