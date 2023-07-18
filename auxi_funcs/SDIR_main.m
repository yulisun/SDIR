function [Reg_Y,DI_Y,delt_Y,Reg_X,DI_X,delt_X,t1_feature,t2_feature,Cosup] = SDIR_main(image_t1,image_t2,opt)
[image_t1,norm_par_t1] = image_normlized(image_t1,opt.type_t1);
[image_t2,norm_par_t2] = image_normlized(image_t2,opt.type_t2);
image_t1 = double(image_t1);
image_t2 = double(image_t2);
h = fspecial('average',5);
image_t1 = imfilter(image_t1, h,'symmetric');
image_t2 = imfilter(image_t2, h,'symmetric');
[Cosup,~] = GMMSP_Cosegmentation(image_t1,image_t2,opt.Ns);   
[t1_feature,t2_feature,norm_par] = MMfeature_extraction(Cosup,image_t1,image_t2); %feature extraction
%% Sx
opt.kmax =round(sqrt(size(t1_feature,2))*1);
opt.kF = opt.kmax*5;
[Ghn_t1,Ghf_t1] = Structure_representation(t1_feature,opt);
[Ghn_t2,Ghf_t2] = Structure_representation(t2_feature,opt);
Ghn_t1 = Ghn_t1-diag(diag(Ghn_t1));
Ghn_t2 = Ghn_t2-diag(diag(Ghn_t2));
Ghf_t1 = Ghf_t1-diag(diag(Ghf_t1));
Ghf_t2 = Ghf_t2-diag(diag(Ghf_t2));
%%
opt.beta = opt.beta_t1;
[regression_Y, delt_Y,RelDiff] = Structural_regression(t2_feature,Ghn_t1,Ghf_t1,opt);% t1--->t2
opt.beta = opt.beta_t2;
[regression_X, delt_X,RelDiff] = Structural_regression(t1_feature,Ghn_t2,Ghf_t2,opt);% t2--->t1

%%
DI_Y  = suplabel2DI(Cosup,sum(delt_Y.^2,1));
[Reg_Y,~,~] = suplabel2ImFeature(Cosup,regression_Y,size(image_t2,3));% t1--->t2
Reg_Y = DenormImage(Reg_Y,norm_par(size(image_t1,3)+1:end));
if strcmp(opt.type_t2,'optical') == 1
   Reg_Y = Reg_Y*(norm_par_t2(2)-norm_par_t2(1))+norm_par_t2(1);
elseif strcmp(opt.type_t2,'sar') == 1
    Reg_Y = Reg_Y*(norm_par_t2(2)-norm_par_t2(1))+norm_par_t2(1);
    Reg_Y = exp(Reg_Y)-1;
end

DI_X  = suplabel2DI(Cosup,sum(delt_X.^2,1));
[Reg_X,~,~] = suplabel2ImFeature(Cosup,regression_X,size(image_t1,3));% t2--->t1
Reg_X = DenormImage(Reg_X,norm_par(1:size(image_t1,3)));
if strcmp(opt.type_t1,'optical') == 1
   Reg_X = Reg_X*(norm_par_t1(2)-norm_par_t1(1))+norm_par_t1(1);
elseif strcmp(opt.type_t1,'sar') == 1
    Reg_X = Reg_X*(norm_par_t1(2)-norm_par_t1(1))+norm_par_t1(1);
    Reg_X = exp(Reg_X)-1;
end
    


