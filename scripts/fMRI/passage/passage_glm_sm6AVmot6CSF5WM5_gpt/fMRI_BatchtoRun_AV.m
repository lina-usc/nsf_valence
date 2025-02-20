%% set directories
%restoredefaultpath;
clc;clear;
addpath(genpath('/work/xy6/dependencies/spm12/'));
spm('defaults','fmri');

Dir_github = '/work/xy6/Project/ABC/github';
repo = 'ABC_valence';
pipeline = 'passage_glm_gptRatingTest';
Dir_working = fullfile(Dir_github,repo,'scripts','fMRI','passage',pipeline); % current script folder
Dir_results = fullfile(Dir_github,'derivatives','fmri',pipeline); % current script folder
Dir_dataset = '/work/desai-lab/ABC_dataset';
Dir_deriv = fullfile(Dir_github,'derivatives');
options.Dir_working = Dir_working;
options.Dir_dataset = Dir_dataset;

options.Dir_timing = fullfile(Dir_github,'derivatives','behavioral','timings');
options.Dir_results = Dir_results;
options.Dir_smooth = fullfile(Dir_github,'derivatives','fmri','afni_smooth-bold');

if ~exist(Dir_results,'dir')
   mkdir(Dir_results);
end

%% model
modal = 'text';
rater = 'gpt-4o-2024-08-06';
options.model_rating = [modal '_' rater];
options.model_glm = 'sm6_AVmot6CSF5WM5';

Dir_results = fullfile(Dir_github,'derivatives','fmri',pipeline,options.model_rating); 
if ~exist(Dir_results,'dir')
   mkdir(Dir_results);
end

options.Dir_timing = fullfile(Dir_github,'derivatives','behavioral','timings');
options.Dir_results = Dir_results;
options.Dir_smooth = fullfile(Dir_github,'derivatives','fmri','afni_smooth-bold');

%% Pariticipants
df_subjects = readtable(fullfile(Dir_working,'df_subjects_N168.csv')); % read master file 

%%
options.TR=.953;
options.sessions = {'passage'};
options.conditions = {'mean','A','V'};

parfor i = 1:height(df_subjects)
    options_tmp = options;
    options_tmp.subid = df_subjects{i,'subid'};
    options_tmp.story = cell2mat(df_subjects{i,'story'});
    options_tmp.T_subj = df_subjects(i,:);
    options_tmp = gBatch_makeContrasts(options_tmp);
    fmriBatch_firstlevel_AV(options_tmp);
end

%% second level


options_tmp = options;
filename = fullfile(Dir_results,'firstlevel',options.model_glm,'sub-1008','contrasts.mat');
if exist(filename,'file')
    design_contrast = load(filename);
end
T_design = struct2table(design_contrast.design);

T_threshold = table();

T_threshold.p = [0.05;0.001;0.002;0.005;0.01;0.02;0.05];
T_threshold.FWE = [1;0;0;0;0;0;0];
T_threshold.cluster = zeros(height(T_threshold),1);
options_tmp.T_threshold = T_threshold;

%================== misophonia ==================
% T_M = T_subs(contains(T_subs.name,'sub-1'),:);
% T_M = T_master(ismember(T_master.x_participant_id,T_M.name),:);

options_tmp.model_glm_2nd = sprintf('all_N%d',height(df_subjects));
% options_tmp.T_M = T_M;
options_tmp.T = df_subjects;

for c = 1:height(T_design)
    
    options_tmp.contrast_name = T_design.name{c};
    options_tmp.test = T_design.test{c};
    if strcmp(T_design.test{c},'t')
        options_tmp.contrast_img = sprintf('con_%.4d',T_design.idx_c(c));
    elseif strcmp(T_design.test{c},'F')
        options_tmp.contrast_img = sprintf('spmF_%.4d',T_design.idx_c(c));
    end
    
    cd(Dir_working);
    gBatch_glm_secondlevel(options_tmp);
end