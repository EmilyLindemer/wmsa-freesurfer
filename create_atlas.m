function [ atlas ] = create_atlas( main_dir, subj_list )
%This function takes in a list of atlas subjects and their main directory
%to create an atlas of healthy WM voxel values per FreeSurfer WM
%parcellation

%Created by Emily 08/11/2016


%Use the 72 standard WM parcellations from FS 
segids=[3001:3035,4001:4035,5001:5002];
nc=1;

for i=1:length(subj_list)
    
    t1=MRIread(sprintf('%s/%s/mri/wmsa_06192014/T1.canorm.mgz',main_dir,subj_list{i}));
    t2=MRIread(sprintf('%s/%s/mri/wmsa_06192014/T2.canorm.mgz',main_dir,subj_list{i}));
    %flair=MRIread(sprintf('%s/%s/mri/wmsa_06192014/PD.canorm.mgz',main_dir,subj_list{i}));

    lesionmask=MRIread(sprintf('%s/%s/mri/wmsaKN.mgz',main_dir,subj_list{i}));
    wmparc=MRIread(sprintf('%s/%s/mri/wmparc.mgz',main_dir,subj_list{i}));
    
    for j=1:length(segids)
        
              
        inds=find(wmparc.vol==segids(j));
        keep=ones(1,length(inds));
        for k = 1:length(inds)
            
            [x,y,z]=ind2sub([256 256 256],inds(k));
            nbhd=wmparc.vol((x-nc):(x+nc),(y-nc):(y+nc),(z-nc):(z+nc));
            wmsavox=lesionmask.vol((x-nc):(x+nc),(y-nc):(y+nc),(z-nc):(z+nc));
            
            nbhd_vals=unique(nbhd);
            wmsa_vals=unique(wmsavox);
            for l = 1:length(nbhd_vals)
                if(~ismember(nbhd_vals(l),segids))
                    keep(k)=0;
                    break
                end
            end
            %if(length(wmsa_vals)>1)
             if(ismember(reshape(wmsavox,[1 27]),498))
                keep(k)=0;
            end
            
                        
        end
        
        if(i==1)
            %atlas{j}=[t1.vol(inds(keep==1)) t2.vol(inds(keep==1)) flair.vol(inds(keep==1))];
            atlas{j}=[t1.vol(inds(keep==1)) t2.vol(inds(keep==1))];
        else
            %atlas{j}=[atlas{j}; [t1.vol(inds(keep==1)) t2.vol(inds(keep==1)) flair.vol(inds(keep==1))]];
            atlas{j}=[t1.vol(inds(keep==1)) t2.vol(inds(keep==1))];
        end
        
    end

    clear t1 t2 flair lesionmask wmparc
    i
    
end

