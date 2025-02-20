function fmriBatch_firstlevel_AV(options)

% Output Directory
subid = options.subid;

%outDir = fullfile(options.Dir_results 'firstlevel' options.firstDir '/' isub];
Dir_output = fullfile(options.Dir_results,'firstlevel',options.model_glm,sprintf('sub-%d',subid));

if ~exist(Dir_output,'dir')
    mkdir(Dir_output);
else
    if exist(fullfile(Dir_output, 'con_0001.nii'),'file')
        return
    else
        if exist(fullfile(Dir_output, 'SPM.mat'),'file')
            delete(fullfile(Dir_output,'SPM.mat'));
        end
    end
    
end

matlabbatch{1}.spm.stats.fmri_spec.dir = {Dir_output};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = options.TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

%% model specification

story = options.story;
%nTR = options.nTR{strcmp(options.taskMatrix.tasklist, ipassage), "BlankSecs"};

% Input File

%imgFile_nii = [options.dataDir '/afni-smooth/' isub '/func/rs_' isub '_task-' ipassage '_space-MNI152NLin2009cAsym_res-native_desc-clean_bold.nii'];
img_smooth_gz = cell2mat(options.T_subj{1,'Passage_smooth'});
img_smooth = strrep(img_smooth_gz,'.nii.gz','.nii');
if ~exist(img_smooth,'file')
   gunzip(img_smooth_gz); 
end

img_mask_gz = cell2mat(options.T_subj{1,'Passage_mask'});
if subid>1197 
    img_mask_gz_raw = img_mask_gz;
    List_strs = strsplit(img_mask_gz,'/');
    file = List_strs{end};
    img_mask_gz = fullfile(Dir_output,file);
    if ~exist(img_mask_gz,'file')
        copyfile(img_mask_gz_raw,img_mask_gz);
    end
end

img_mask = strrep(img_mask_gz,'.nii.gz','.nii');
if ~exist(img_mask,'file')
   gunzip(img_mask_gz); 
end

% Timing File
file_timing = cell2mat(options.T_subj{1,'Passage_timing'});
file_confounds = cell2mat(options.T_subj{1,'Passage_confounds'});

delay = options.T_subj{1,'delay'};
    % motion
% motionfile = [options.fmridataDir '/' isub '/' ipassage '/' isub '_task-' ipassage '.txt'];
% timingfile = [options.timingDir '/Timing_' ipassage '_' options.timingPostfix '.csv'];
% imgFile = {imgFile_nii};

%     
opts = detectImportOptions(file_timing); % Initial detection
opts.VariableNamesLine = 1;
opts.DataLines = [2 Inf];
T_timing = readtable(file_timing, opts);
%     load(timingfile,'timing');

label_V = 'V';
label_A = 'A';
T_timing = T_timing(~ismissing(T_timing{:,label_V}),:);
T_timing = T_timing(~ismissing(T_timing{:,'onset'}),:);
T_timing = T_timing(~ismissing(T_timing{:,'offset'}),:);
T_timing{:,'onset_real'} = T_timing{:,'onset'}+delay;
T_timing{:,'offset_real'} = T_timing{:,'offset'}+delay;

t = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(t).scans = {img_smooth};
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.name = story;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.onset = T_timing{:,'onset_real'};
%%
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.duration = T_timing{:,'onset_real'} - T_timing{:,'offset_real'}; % 0:exclude Duration; Duration: include Duration
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).name = 'A';
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).param = T_timing{:,label_A}-mean(T_timing{:,label_A});
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(1).poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).name = 'V';
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).param = T_timing{:,label_V}-mean(T_timing{:,label_V});
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.pmod(2).poly = 1;

%%
matlabbatch{1}.spm.stats.fmri_spec.sess(t).cond.orth = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(t).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(t).regress = struct('name', {}, 'val', {});
%matlabbatch{1}.spm.stats.fmri_spec.sess(t).multi_reg = {motionfile};
matlabbatch{1}.spm.stats.fmri_spec.sess(t).multi_reg = {file_confounds};
matlabbatch{1}.spm.stats.fmri_spec.sess(t).hpf = 128;

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {img_mask};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%%
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(Dir_output,'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%%

%% contrast

design = options.design_contrast.design;

matlabbatch{3}.spm.stats.con.spmmat = {fullfile(Dir_output,'SPM.mat')};
for i = 1:length(design)

    if strcmp(design(i).test,'t')
        
        matlabbatch{3}.spm.stats.con.consess{i}.tcon.name = design(i).name;
        matlabbatch{3}.spm.stats.con.consess{i}.tcon.weights = design(i).weights;
        matlabbatch{3}.spm.stats.con.consess{i}.tcon.sessrep = 'none';
        
    elseif strcmp(design(i).test,'F')
        matlabbatch{3}.spm.stats.con.consess{i}.fcon.name = design(i).name;
        matlabbatch{3}.spm.stats.con.consess{i}.fcon.weights = design(i).weights;
        matlabbatch{3}.spm.stats.con.consess{i}.fcon.sessrep = 'none';
    end

end

matlabbatch{3}.spm.stats.con.delete = 0;

filename = fullfile(Dir_output,'options.mat');
save(filename,'options');

spm_jobman('run',matlabbatch);

fprintf("sub-%d is done.\n",subid);
end