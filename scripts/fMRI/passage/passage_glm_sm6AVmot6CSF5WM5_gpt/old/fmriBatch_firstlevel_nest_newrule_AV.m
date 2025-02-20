function fmriBatch_firstlevel_nest_newrule_AV(isub, ipassagelist, options)

% Output Directory
outDir = [options.outputDir '/firstlevel/' options.firstDir '/' isub];

if ~exist(outDir,'dir')
    mkdir(outDir);
else
    if exist([options.outputDir '/firstlevel/' options.firstDir '/' isub '/con_0001.nii'],'file')
        return
    end
end
matlabbatch{1}.spm.stats.fmri_spec.dir = {outDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = options.TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

%% model specification - nested
for t = 1:length(ipassagelist)
    
    ipassage = cell2mat(ipassagelist(t));
    %nTR = options.nTR{strcmp(options.taskMatrix.tasklist, ipassage), "BlankSecs"};
    
    % Input File
    if strcmp(ipassage,'black') || strcmp(ipassage,'forgot')
        imgFile_nii = [options.dataDir '/afni-smooth/' isub '/func/rs_' isub '_task-' ipassage '_space-MNI152NLin2009cAsym_res-native_desc-clean_bold.nii'];
    else
        imgFile_nii = [options.dataDir '/afni-smooth/' isub '/func/' isub '_task-' ipassage '_space-MNI152NLin2009cAsym_res-native_desc-clean_bold.nii'];
    end
 
    if ~exist(imgFile_nii,'file')
        zipfile = [imgFile_nii '.gz'];
        gunzip(zipfile);
    end
    % mask = [options.workingDir '/' isub '/' ipassage '/' isub '_task-' ipassage '_space-T1w_desc-brain_mask.nii'];
    % mask_gz = ['']
    mask = [options.dataDir '/fmriprep/' isub '/func/' isub '_task-' ipassage '_space-MNI152NLin2009cAsym_res-native_desc-brain_mask.nii'];
    
    if ~exist(mask,'file')
        zipfile = [mask '.gz'];
        gunzip(zipfile);
    end
    

    
    % Timing File
    aTR = options.passagelength;
    if aTR == 0
        % motion
        motionfile = [options.fmridataDir '/' isub '/' ipassage '/' isub '_task-' ipassage '.txt'];
        timingfile = [options.timingDir '/Timing_' ipassage '_' options.timingPostfix '.csv'];
        imgFile = {imgFile_nii};
    else
        motionfile = [options.fmridataDir '/' isub '/' ipassage '/' isub '_task-' ipassage '_' num2str(aTR) 'TR.txt'];
        timingfile = [options.timingDir '/Timing_' ipassage '_' options.timingPostfix '_' num2str(aTR) 'TR.csv'];
        imgFile = cell(aTR,1);
        for i = 1:aTR
            imgFile(i,1) = {[imgFile_nii ',' num2str(i)]};
        end
    end
%     
    opts = detectImportOptions(timingfile); % Initial detection
    opts.VariableNamesLine = 1;
    opts.DataLines = [2 Inf];
    timing = readtable(timingfile, opts);
%     load(timingfile,'timing');
    
    label_V = [options.regName '_V_' options.modal];
    label_A = [options.regName '_A_' options.modal];
    timing = timing(~ismissing(timing{:,label_V}),:);
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).scans = imgFile;
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.name = ipassage;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.onset = timing.onset_addBlankTR;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.duration = timing.offset_addBlankTR - timing.onset_addBlankTR; % 0:exclude Duration; Duration: include Duration
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).name = 'A';
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).param = timing{:,label_A}-mean(timing{:,label_A});
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).name = 'V';
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).param = timing{:,label_V}-mean(timing{:,label_V});
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).poly = 1;
    
    
    
    
%     matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).name = 'neg';
%     matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).param = timing.neg;
%     matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).poly = 1;
%     %%

%     if strcmp(options.regName, 'valence')
%         % Word Frequency
%         matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).name = 'valence';
%         matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).param = timing.valence;
%         matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).poly = 1;
%     elseif strcmp(options.regName, 'arousal')
%         % Word contextual diversity
%         matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).name = 'arousal';
%         matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).param = timing.arousal;
%         matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).poly = 1;
%         
%     else
%         fprintf('no regressors\n');
%     end
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.orth = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).regress = struct('name', {}, 'val', {});
    %matlabbatch{1}.spm.stats.fmri_spec.sess(t).multi_reg = {motionfile};
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(t).hpf = 128;
end


matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {mask};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%%
matlabbatch{2}.spm.stats.fmri_est.spmmat = {[outDir '/SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%%
matlabbatch{3}.spm.stats.con.spmmat = {[outDir '/SPM.mat']};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ['mean'];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = repmat([1 0 0],1,length(ipassagelist));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{4}.spm.stats.con.spmmat = {[outDir '/SPM.mat']};
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name = label_A;
matlabbatch{4}.spm.stats.con.consess{1}.tcon.weights = repmat([0 1 0],1,length(ipassagelist));
matlabbatch{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{5}.spm.stats.con.spmmat = {[outDir '/SPM.mat']};
matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = label_V;
matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = repmat([0 0 1],1,length(ipassagelist));
matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
% matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'neg';
% matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = repmat([0 0 -1],1,length(ipassagelist));
% matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
% 
% matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'pos_neg';
% matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = repmat([0 1 -1],1,length(ipassagelist));
% matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
% 
% matlabbatch{4}.spm.stats.con.spmmat = {[outDir '/SPM.mat']};
% matlabbatch{4}.spm.stats.con.consess{1}.tcon.name = 'WordConc';
% matlabbatch{4}.spm.stats.con.consess{1}.tcon.weights = [0 0 1 0];
% matlabbatch{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
% 
% matlabbatch{5}.spm.stats.con.spmmat = {[outDir '/SPM.mat']};
% matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'WordPhonLen';
% matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [0 0 0 1];
% matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

spm_jobman('run', matlabbatch);
fprintf("%s-%s is done.\n",isub);
end