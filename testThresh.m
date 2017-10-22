function [ dice ] = testThresh(main_dir,subj_id,refvol,manlabel,contmap,threshes )
%This is for testing subjects who already have continuous maps made to
%assess for different threshold levels with which to determine binary
%lesion segmentation

%refvol here should either be FLAIR.canorm.mgz or T2.canorm.mgz if FLAIR
%unavailable 


dice=zeros(1,length(threshes));
wmparc=MRIread(sprintf('%s/%s/mri/wmparc.mgz',main_dir,subj_id));

    for i=1:length(threshes)

        [binvol,kmap]=label_subject_bin(contmap,refvol,wmparc,threshes(i));
        dice(i)=evaluateDice(binvol,manlabel);

    end


end

