function fmriBatch_secondlevel_nest(options)

contrastID = options.icontrast;
iflag = options.iflag;
regressor = options.regName;
% firstlevel_path = 'Firstlevel_rmsub_rmFuncWord_DurationAs0';

outDir = [options.outputDir '/secondlevel/' options.secondDir '/' options.secondDir_subfolder];
if ~exist(outDir,'dir')
    mkdir(outDir)
end
% subList = dir(['E:\phd\RA\ABC\Singleword' regressor '\' firstlevel_path]);
% subList = subList(3:end);
subList = options.secondSubList;
% subList = subList(1:10,:);
% subList = subList(contains(subList(:,2),'slumlordreach'),:);
% % codes for generating subset of subjects
% subList = renamevars(subList,["Var1","Var2"],["sub","task"]);
% subList(:,"rand")=num2cell(randperm(height(subList))');
% subList=sortrows(subList,"rand");
% subList=subList(1:50,["sub","task"]);


imgList = cell(length(subList),1);
for i =1:length(subList)
    isub = cell2mat(subList(i,1));
    %ipassage = cell2mat(subList(i,2));
%     imgList(i) = {['/work/desai-lab/reilly3/xuanyang/Nastase/data/FirstLevel/' regressor '_MNImask_derive/' ipassage '/' isub '/beta_combined.nii']};
    imgList(i) = {[options.outputDir '/firstlevel/' options.firstDir '/' isub '/' contrastID '.nii']};
end



matlabbatch_2nd{1}.spm.stats.factorial_design.dir = {outDir};


matlabbatch_2nd{1}.spm.stats.factorial_design.des.t1.scans = imgList;
matlabbatch_2nd{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch_2nd{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch_2nd{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch_2nd{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch_2nd{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch_2nd{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch_2nd{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch_2nd{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%
matlabbatch_2nd{2}.spm.stats.fmri_est.spmmat = {[outDir '/SPM.mat']};
matlabbatch_2nd{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch_2nd{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch_2nd{3}.spm.stats.con.spmmat = {[outDir '/SPM.mat']};
matlabbatch_2nd{3}.spm.stats.con.consess{1}.tcon.name = 'pos';
matlabbatch_2nd{3}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch_2nd{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch_2nd{3}.spm.stats.con.delete = 0;

matlabbatch_2nd{4}.spm.stats.con.spmmat = {[outDir '/SPM.mat']};
matlabbatch_2nd{4}.spm.stats.con.consess{1}.tcon.name = 'neg';
matlabbatch_2nd{4}.spm.stats.con.consess{1}.tcon.weights = [-1];
matlabbatch_2nd{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch_2nd{4}.spm.stats.con.delete = 0;

matlabbatch_2nd{5}.spm.stats.results.spmmat = {[outDir '/SPM.mat']};
matlabbatch_2nd{5}.spm.stats.results.conspec.titlestr = '';
matlabbatch_2nd{5}.spm.stats.results.conspec.contrasts = 1;
matlabbatch_2nd{5}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch_2nd{5}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch_2nd{5}.spm.stats.results.conspec.extent = 0;
matlabbatch_2nd{5}.spm.stats.results.conspec.conjunction = 1;
matlabbatch_2nd{5}.spm.stats.results.conspec.mask.none = 1;
matlabbatch_2nd{5}.spm.stats.results.units = 1;
matlabbatch_2nd{5}.spm.stats.results.export{1}.eps = true;

spm_jobman('run',matlabbatch_2nd)

List_eps = dir(fullfile(outDir,'*.eps'));
char_all = fileread(List_eps(1).name);
% a = strsplit(char_all,'(FWEp: ');
% b = strsplit(cell2mat(a(2)),') t ');
% numbers = regexp(cell2mat(b(1)), '\d+\.?\d*', 'match');
% FWEz = str2double(numbers{1});
% FDRz = str2double(numbers{2});
% FWEc = ceil(str2double(numbers{3}));
% FDRc = ceil(str2double(numbers{4}));
a = strsplit(char_all,'FWEc: ');
b = strsplit(cell2mat(a(2)),', FDRc: ');
%FWEc_str = cell2mat(b(1));
% if strcmp(FWEc_str,'Inf')
%    FWEc = 1000;
% else
%     FWEc = ceil(str2double(FWEc_str));
% end
FWEc = 22;
FWEc_str = '22';
%%

matlabbatch{1}.spm.stats.results.spmmat = {[outDir '/SPM.mat']};
matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch{1}.spm.stats.results.conspec.extent = FWEc;
matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{1}.spm.stats.results.units = 1;
% matlabbatch{2}.spm.stats.results.export{1}.ps = true;
matlabbatch{1}.spm.stats.results.export{1}.tspm.basename = [iflag '_tspm_FWEc' FWEc_str];
matlabbatch{1}.spm.stats.results.export{2}.binary.basename = [iflag '_mask_FWEc' FWEc_str];
matlabbatch{1}.spm.stats.results.export{3}.nary.basename = [iflag '_nary_FWEc' FWEc_str];

matlabbatch{2}.spm.stats.results.spmmat = {[outDir '/SPM.mat']};
matlabbatch{2}.spm.stats.results.conspec.titlestr = '';
matlabbatch{2}.spm.stats.results.conspec.contrasts = 2;
matlabbatch{2}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{2}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch{2}.spm.stats.results.conspec.extent = FWEc;
matlabbatch{2}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{2}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{2}.spm.stats.results.units = 1;
% matlabbatch{4}.spm.stats.results.export{1}.ps = true;
matlabbatch{2}.spm.stats.results.export{1}.tspm.basename = [iflag '_tspm_FWEc' FWEc_str];
matlabbatch{2}.spm.stats.results.export{2}.binary.basename = [iflag '_mask_FWEc' FWEc_str];
matlabbatch{2}.spm.stats.results.export{3}.nary.basename = [iflag '_nary_FWEc' FWEc_str];

spm_jobman('run',matlabbatch)
%-----------------------------------------------------------------------
end