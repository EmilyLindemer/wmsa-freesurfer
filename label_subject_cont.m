function [outvol] = label_subject_cont(atlas,volarray,wmparc,vents )
%This function takes an individual subject and labels their WM based on the
%wmparc.mgz file, using an atlas created by create_atlas.m

%Note: this assumes T1/T2/FLAIR for now, will update later

%TODO: these should be masked by the WM mask but eroded by 1 to avoid
%cortex partial voluming
%BUT this might be too conservative, alternatively we could check against
%the wmparc.mgz and just make sure that there are no cortical voxels next
%to something that we're calling WMSA. 

%the vents flag can be either 1 or 0 for if someone has a low-res image and
%there is a lot of partial voluming around the ventricles. 

%Created by Emily Lindemer 08/11/2016

segids=[3001:3035,4001:4035,5001:5002];
gmids=[1000:1035,2000:2035];


if(vents==0)
    subcortids=[11:12,50:51,28,60,26,58,17,53,18,54];
    gmnbs=9;
    subcortnbs=3;
else
    subcortids=[11:12,50:51,28,60,26,58,17,53,18,54,4,43];
    gmnbs=15;
    subcortnbs=5;
end

nc=1;

outvol=wmparc;
outvol=fast_vol2mat(outvol);
outvol(:)=0;

    for i=1:length(segids)

        inds=find(wmparc.vol==segids(i));
        
        %Check for GM in nbhd to account for partial voluming
        keep=ones(1,length(inds));
        for k = 1:length(inds)
            
            [x,y,z]=ind2sub([256 256 256],inds(k));
            nbhd=wmparc.vol((x-nc):(x+nc),(y-nc):(y+nc),(z-nc):(z+nc));        
            nbhd=reshape(nbhd,[1 27]);
            if(sum(ismember(nbhd,gmids))>9||sum(ismember(nbhd,subcortids))>3)
                keep(k)=0;
            end
            
        end
        %End PV check
        
        finalinds=inds(keep==1);
            
        if(~isempty(finalinds))
           m=sqrt(mahal(volarray(finalinds,:),atlas{i}));
           outvol(finalinds)=m;
        end
            
        clear finalinds inds   
        
    end
    
    outvol=fast_mat2vol(outvol,wmparc.volsize);

end

