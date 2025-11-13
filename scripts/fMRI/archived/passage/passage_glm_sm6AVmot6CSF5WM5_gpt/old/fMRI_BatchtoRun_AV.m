%% set directories
%restoredefaultpath;
addpath(genpath('/work/xy6/dependencies/spm12/'));
spm('defaults','fmri');

Dir_github = '/work/xy6/Project/ABC/github';
repo = 'ABC_valence';
pipeline = 'glm_1st_gptRatingTest';
Dir_working = fullfile(Dir_github,repo,'scripts','fMRI','passage',pipeline);
Dir_dataset = '/work/desai-lab/ABC_dataset';
Dir_deriv = fullfile(Dir_github,'derivatives');
options.workingDir = Dir_working;
options.dataDir = Dir_dataset;

options.timingDir = fullfile(Dir_github,'derivatives','behavioral','timings');
options.outputDir = fullfile(Dir_github,'derivatives','fMRI','passage',pipeline);
options.fmridataDir = fullfile(options.dataDir,'derivatives','afni-smooth');

%% Pariticipants
df_subjects = readtable(fullfile(Dir_working,'df_subjects_N112.csv')); % read master file 

% excluded subjects and tasks
% sub_ex = {'sub-278';'sub-278';'sub-139';'sub-132';'sub-139';'sub-132'};
% task_ex = {'black';'forgot';'slumlord';'slumlord';'reach';'reach'};


%% Creat timings
options.TR=.953;
%BlankTR = [8;3;8];
%BlankTR = [8;3];
%options.nTR = [550,1205];
%BlankSecs = BlankTR*options.TR;
%options.taskMatrix = table(tasklist,BlankTR,BlankSecs);
options.taskname = 'passage';
%regs = {'GPT_'};%GPT_intact GPT_shuffle word_NRC word_Warr word_NRC GPT_intact
%TR_length = [0];%[0, 550, 240]
%min_length = {'full'};%{'full','13min','6min'}
%sub_length = {'all'};%{'all','50','100','150','200'};0-all subjects
%modallist = {'text'};

options.timingPostfix = '_byseg';

modallist = {'text'};
for m = 1:length(modallist)
    options.modal = modallist{m};
    

    %options.outputPostfix = ['_BF_signedtworegressors_VDur_' modal ''];
    options.outputPostfix = ['_BFSR_AV_' options.modal];
    for t = 1:length(min_length) %different story length
        options.passagelength = TR_length(t); %0=fulllength,or number of TR;240 550
        flag_minName = cell2mat(min_length(t));


        for j = 1:length(regs) % different regressors
            options.regName = cell2mat(regs(j)); 
            options.firstDir = [options.regName '_' flag_minName options.outputPostfix];
            parfor i = 1:length(subList_ana) 

                isub = cell2mat(subList_ana(i,1));
                ipassagelist = split(cell2mat(subList_ana(i,2)),',');
%                 fmriBatch_firstlevel_nest_newrule_VabsA(isub, ipassagelist, options);
%                 fmriBatch_firstlevel_nest_newrule_VA(isub, ipassagelist, options);
                fmriBatch_firstlevel_nest_newrule_AV(isub, ipassagelist, options);
            end

            for n = sub_length
%                 subList_exlowacc = ["sub-141", "sub-144", "sub-277", "sub-279", "sub-281", "sub-296","sub-297", "sub-302"];
                subList_exlowacc = [""];
                filterOut = ismember(subList_ana(:,1), subList_exlowacc);
                rowsToFilter = any(filterOut, 2);
                subList_ana_exlowacc = subList_ana(~rowsToFilter, :);
               
                options.secondSubList = subList_ana_exlowacc;
                %options.secondSubList = subList_ana;
                options.secondDir = [options.regName '_' flag_minName options.outputPostfix '_highacc'];
                %label = [options.modal '_' options.regName];
                %flag = {['mean_' label],[options.modal 'signedL_V'],[options.modal 'signedL_A']};
                label = [options.modal '_siL'];
                flag = {[label '_m'],[label '_A'],[label '_V']};
                contrast = {'con_0001','con_0002','con_0003'};
                for c = 1:length(flag)
                    options.iflag = cell2mat(flag(c));
                    options.icontrast = [cell2mat(contrast(c)) ''];
                    %options.secondDir_subfolder = [options.regName '_' flag_minName '_' cell2mat(sub_length) 'subjs' options.outputPostfix options.iflag];
                    options.secondDir_subfolder = [options.regName '_' flag_minName '_' num2str(length(options.secondSubList)) 'subjs' options.outputPostfix options.iflag];
                    
                    cd([options.workingDir '']);
                    fmriBatch_secondlevel_nest_FWEc22(options);
                end
            end
        end
    end
end
