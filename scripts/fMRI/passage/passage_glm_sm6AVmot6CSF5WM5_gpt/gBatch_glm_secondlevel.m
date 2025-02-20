function gBatch_glm_secondlevel(options)

iflag = options.contrast_name;
T_threshold = options.T_threshold;
List_tags = {'pos','neg'};

T = options.T;
Dir_output = fullfile(options.Dir_results,'secondlevel',options.model_glm,iflag,['N' num2str(height(T))]);
if ~exist(Dir_output,'dir')
    mkdir(Dir_output)
end


writetable(T,fullfile(Dir_output,'List_subjects.csv'));


imgList = cell(height(T),1);
for i =1:height(T)
    subID = sprintf('sub-%d',T{i,'subid'});
    imgList(i) = {fullfile(options.Dir_results,'firstlevel',options.model_glm,...
        subID,sprintf('%s.nii',options.contrast_img))};
end



matlabbatch{1}.spm.stats.factorial_design.dir = {Dir_output};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = imgList;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%
matlabbatch{2}.spm.stats.fmri_est.spmmat = {[Dir_output '/SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat = {[Dir_output '/SPM.mat']};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'pos';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'neg';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;


for j = 1:2
    n = length(matlabbatch);    
    for i = 1:height(T_threshold)
        flag_FWE = T_threshold.FWE(i);
        tag = List_tags{j};
        p_str = sprintf('%.3f',T_threshold.p(i));
        
        matlabbatch{n+i}.spm.stats.results.spmmat = {[Dir_output '/SPM.mat']};
        matlabbatch{n+i}.spm.stats.results.conspec.titlestr = '';
        matlabbatch{n+i}.spm.stats.results.conspec.contrasts = j;
        if flag_FWE
            matlabbatch{n+i}.spm.stats.results.conspec.threshdesc = 'FWE';
            label = sprintf('%s-%s-FWEp%sc%d',tag,iflag,p_str(3:end),T_threshold.cluster(i));
        else
            matlabbatch{n+i}.spm.stats.results.conspec.threshdesc = 'none';
            label = sprintf('%s-%s-p%sc%d',tag,iflag,p_str(3:end),T_threshold.cluster(i));
        end
        matlabbatch{n+i}.spm.stats.results.conspec.thresh = T_threshold.p(i);
        matlabbatch{n+i}.spm.stats.results.conspec.extent = T_threshold.cluster(i);
        matlabbatch{n+i}.spm.stats.results.conspec.conjunction = 1;
        matlabbatch{n+i}.spm.stats.results.conspec.mask.none = 1;
        matlabbatch{n+i}.spm.stats.results.units = 1;
        
        matlabbatch{n+i}.spm.stats.results.export{1}.tspm.basename = sprintf('%s-t',label);
        matlabbatch{n+i}.spm.stats.results.export{2}.binary.basename = sprintf('%s-mask',label);
        matlabbatch{n+i}.spm.stats.results.export{3}.nary.basename = sprintf('%s-n',label);
    end
end

spm_jobman('run',matlabbatch)

%% ------------------------------ save graph------------------------------------


List_files = {'t','mask','n'};

for i = 1:height(T_threshold)
    for j = 1:2
        for t = 1:3
            tag = List_tags{j};
            p_str = sprintf('%.3f',T_threshold.p(i));
            postfix = List_files{t};
            flag_FWE = T_threshold.FWE(i);
            
            if flag_FWE
                file_src = fullfile(Dir_output,sprintf('spmT_%.4d_%s-%s-FWEp%sc%d-%s.nii',j,tag,iflag,p_str(3:end),T_threshold.cluster(i),postfix));
                file_dest = fullfile(Dir_output,sprintf('%s-%s-FWEp%sc%d-%s.nii',tag,iflag,p_str(3:end),T_threshold.cluster(i),postfix));
                
            else
                file_src = fullfile(Dir_output,sprintf('spmT_%.4d_%s-%s-p%sc%d-%s.nii',j,tag,iflag,p_str(3:end),T_threshold.cluster(i),postfix));
                file_dest = fullfile(Dir_output,sprintf('%s-%s-p%sc%d-%s.nii',tag,iflag,p_str(3:end),T_threshold.cluster(i),postfix));
                
            end
            
            movefile(file_src,file_dest);
        end
    end
end
end