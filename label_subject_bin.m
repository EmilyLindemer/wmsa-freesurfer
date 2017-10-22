function [ binvol,kmap ] = label_subject_bin( contmap,flair,wmparc,thresh )
%This function takes the continuous damage map and applies heuristics to
%decide which subclasses of continuous damage are true "lesions"

%It outputs a map with 5 different subclasses of WM damage as well as a
%binary map with only 'true lesions' segmented

%Created by Emily Lindemer 08/11/2016

nc=1;


inds=find(contmap.vol>0);

[idx,ctr]=kmeans(contmap.vol(inds),5);

ctr=[ctr [1:5]'];
ctr=sortrows(ctr,1);

for i=1:5
   temp=find(idx==ctr(i,2));
   idx(temp)=i*100;
   clear temp
end

idx=idx/100;

kmap=flair;
kmap.vol(:,:,:)=0;

kmap.vol(inds)=idx;


flair_mean=mean(flair.vol(inds));
flair_std=std(flair.vol(inds));

%inds2=find(idx>3);
%inds2=find(idx>2);
%inds2=inds(inds2);

%inds4=setdiff(inds,inds2);

%inds3=find(flair.vol(inds2)>(flair_mean+thresh*flair_std));
%inds4=find(flair.vol(inds4)>(flair_mean+(thresh+0.5)*flair_std));


%final_inds=inds2(inds3);

inds2=intersect(find(contmap.vol(inds)>1.5),find(flair.vol(inds)>(flair_mean+thresh*flair_std)));

final_inds=inds(inds2);

keep=ones(1,length(final_inds));

for i=1:length(final_inds)
     
    [x,y,z]=ind2sub([256 256 256],final_inds(i));
    nbhd=wmparc.vol((x-nc):(x+nc),(y-nc):(y+nc),(z-nc):(z+nc));
    nbhd_vals=unique(nbhd);
    if(sum(nbhd_vals(nbhd_vals<3000&nbhd_vals>999))>0)
        keep(i)=0;
    end
   
end

binvol=kmap;
binvol.vol(:,:,:)=0;

binvol.vol(final_inds(keep==1))=1;

end

