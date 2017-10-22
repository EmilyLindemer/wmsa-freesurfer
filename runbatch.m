for i=1:length(VarName1)
    if(exist(sprintf('%s/%s/mri/wmsa_testdev/T2.canorm.mgz',maindir,VarName1{i}),'file'))
        wmsaseg(maindir,VarName1{i},'wmsa_testdev','t1',1,'t2',1,'flair',1)
        i
    end
end