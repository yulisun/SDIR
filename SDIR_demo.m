clear;
close all
addpath(genpath(pwd))
%% load dataset
% dataset#1 to dataset#6
dataset = 'dataset#6';
Load_dataset % For other datasets, we recommend a similar pre-processing as in "Load_dataset"
fprintf(['\n Data loading is completed...... ' '\n'])
%% Parameter setting
% With different parameter settings, the results will be a little different
% Ns: the number of superpxiels,  Ns = 2500 is recommended.
% beta: 5 <= beta <= 25 is recommended.
%--------------------Available datasets and Parameters---------------------
%    Dataset       |          beta_t1       |         beta_t2       |
%   dataset#1      |            5           |           10          |
%   dataset#2      |            5           |           10          |
%   dataset#3      |            5           |           15          |
%   dataset#4      |            10          |           20          |
%   dataset#5      |            10          |           20          |
%   dataset#6      |            10          |           10          |
%--------------------------------------------------------------------------
opt.Ns = 2500;
opt.Niter = 20; % Number of outer loop iterations
opt.N_inner = 10; % Number of inner loop iterations
opt.lambda = 0.1;
opt.beta_t1 = 10;
opt.beta_t2 = 20;
opt.upsilon = 1; % imbalance parameter
if strcmp(dataset,'dataset#1') == 1 || strcmp(dataset,'dataset#2') == 1
    opt.beta_t1 = 5;
    opt.beta_t2 = 10;
elseif strcmp(dataset,'dataset#3') == 1
    opt.beta_t1 = 5;
    opt.beta_t2 = 15;
elseif strcmp(dataset,'dataset#4') == 1 || strcmp(dataset,'dataset#5') == 1
    opt.beta_t1 = 10;
    opt.beta_t2 = 20;
elseif strcmp(dataset,'dataset#6') == 1
    opt.beta_t1 = 10;
    opt.beta_t2 = 10;
end
%%
fprintf(['\n SDIR is running...... ' '\n'])
time = clock;
[Reg_Y,DI_Y,delt_Y,Reg_X,DI_X,delt_X,t1_feature,t2_feature,Cosup] = SDIR_main(image_t1,image_t2,opt);
fprintf(['\n' '====================================================================== ' '\n'])
fprintf('\n');fprintf('The total computational time of SDIR is %i \n' ,etime(clock,time));
fprintf(['\n' '====================================================================== ' '\n'])
%% Displaying results
fprintf(['\n Displaying the results...... ' '\n'])
[Precision_forward, Recall_forward]= PR_plot(DI_Y,Ref_gt,500);
[Precision_backward, Recall_backward]= PR_plot(DI_X,Ref_gt,500);
[AUP_forward,~] = AUC_Diagdistance(Precision_forward, Recall_forward);
[AUP_backward,~] = AUC_Diagdistance(Precision_backward, Recall_backward);

figure;
subplot(231);imshow(image_t1);title('original imgt1')
subplot(232);imshow(uint8(Reg_X));title('regression imgt1')
subplot(233);imshow(remove_outlier(DI_X),[]);title('backward DI')
subplot(234);imshow(image_t2);title('original imgt2')
subplot(235);imshow(uint8(Reg_Y));title('regression imgt2')
subplot(236);imshow(remove_outlier(DI_Y),[]);title('forward DI')

figure;
plot(Recall_forward,Precision_forward);hold on
plot(Recall_backward,Precision_backward);
legend('Forward DI','Backward DI');
title('PR curves')
result = 'SDIR: Forward AUP is %4.3f; Backward AUP is %4.3f \n';
fprintf(result,AUP_forward,AUP_backward)
%%
if AUP_forward < 0.3
    fprintf('\n'); disp('Please select the appropriate beta_t1 for SDIR!')
end
if AUP_backward < 0.3
    fprintf('\n'); disp('Please select the appropriate beta_t2 for SDIR!')
end
