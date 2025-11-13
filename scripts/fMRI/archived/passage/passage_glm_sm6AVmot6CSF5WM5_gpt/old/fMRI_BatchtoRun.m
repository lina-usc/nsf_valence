%% set directories
restoredefaultpath;
addpath(genpath('/opt/SPM12'));
spm('defaults','fmri');
options.workingDir = '/home/cluster/projects/Nastase_narratives/github/Valence_Narrative/fmri/ParametricModulation/sign_L';
options.dataDir = '/home/cluster/projects/Nastase_narratives/dataset';
options.timingDir = '/home/cluster/projects/Nastase_narratives/github/results/behavioral/timing';

options.outputDir = '/home/cluster/projects/Nastase_narratives/github/results/fmri/ParametricModulation';
options.fmridataDir = [options.dataDir '/afni-smooth'];

%% Pariticipants
participants = readtable([options.dataDir '/Participants.xlsx']); % read master file downloaded from github

% excluded subjects and tasks
% sub_ex = {'sub-278';'sub-278';'sub-139';'sub-132';'sub-139';'sub-132'};
% task_ex = {'black';'forgot';'slumlord';'slumlord';'reach';'reach'};
sub_ex = {'sub-278';'sub-278';'sub-139';'sub-139'};
task_ex = {'black';'forgot';'slumlord';'reach'};
subList_ex = table(sub_ex,task_ex);
tasklist = ["black";"slumlordreach";"forgot"];

flag = false(height(participants),1);
task_matrix = strings(size(height(participants),length(tasklist)));
for i = 1:length(tasklist)
    itask = tasklist(i) ;
    
    iflag = contains(participants.task,itask);
    flag = flag | iflag;
    task_matrix(iflag,i) = itask;
    task_matrix(~iflag,i) = missing;
    iflag_ex = contains(subList_ex.task_ex,itask);
    isublist_ex = subList_ex.sub_ex(iflag_ex);
    flag_ex = false(height(participants),1);
    for j = 1:length(isublist_ex)
        isub_ex = cell2mat(isublist_ex(j));
        task_matrix(find(contains(participants.participant_id,isub_ex)),i) = missing;
    end
end
SubList = participants(flag,:);
task_matrix = task_matrix(flag,:);
task_vector = strings(size(height(SubList),1));
for i=1:height(SubList)
    task_vector(i)=strjoin(rmmissing(task_matrix(i,:)),',');
end
t=table(task_vector','VariableNames',{'task_ana'});
SubList = [SubList,t];
SubList(SubList.task_ana=='',:) = [];
subList_ana = SubList{:,{'participant_id','task_ana'}};

%% Creat timings
options.TR=1.5;
BlankTR = [8;3;8];
%BlankTR = [8;3];
%options.nTR = [550,1205];
BlankSecs = BlankTR*options.TR;
options.taskMatrix = table(tasklist,BlankTR,BlankSecs);
options.taskname = 'passage';
regs = {'Human'};%GPT_intact GPT_shuffle word_NRC word_Warr word_NRC GPT_intact
TR_length = [0];%[0, 550, 240]
min_length = {'full'};%{'full','13min','6min'}
sub_length = {'all'};%{'all','50','100','150','200'};0-all subjects
%modallist = {'text'};

modallist = {'audio'};
for m = 1:length(modallist)
    options.modal = modallist{m};
    options.timingPostfix = 'weighted_byseg_n';

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
