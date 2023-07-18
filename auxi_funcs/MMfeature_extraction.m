function [t1_feature,t2_feature,norm_para] = MMfeature_extraction(sup_t1,image_t1,image_t2) 
[h,w,b1] = size(image_t1);
[h,w,b2] = size(image_t2);
idx_t1 = label2idx(sup_t1);
nbr_sp  = max(sup_t1(:));
re_image_t1=reshape(image_t1,[h*w,b1]);
re_image_t2=reshape(image_t2,[h*w,b2]);
for i = 1:nbr_sp
    index_vector = idx_t1{i};
    %----t1
    sub_superpixel_t1 = re_image_t1(index_vector,1:b1);
    mean_feature_t1 = (mean(sub_superpixel_t1));
    median_feature_t1 = (median(sub_superpixel_t1));
    t1_feature(i,1:b1) = mean_feature_t1;
    t1_feature(i,b1+1:2*b1) = median_feature_t1;
    %-----t2
    sub_superpixel_t2 = re_image_t2(index_vector,1:b2);
    mean_feature_t2 = (mean(sub_superpixel_t2));
    median_feature_t2 = (median(sub_superpixel_t2));
    t2_feature(i,1:b2) = mean_feature_t2;
    t2_feature(i,b2+1:2*b2) = median_feature_t2; 
end
t1_feature = t1_feature';
t2_feature = t2_feature';    
t1_feature(find(isnan(t1_feature)==1)) = 0;    
t2_feature(find(isnan(t2_feature)==1)) = 0; 
%% Normalization
for i = 1:b1
    norm_para(i) = max(t1_feature(i,:))+eps;
end
for i = 1:b2
    norm_para(b1+i) = max(t2_feature(i,:))+eps;
end
for i = 1:size(t1_feature,1)
    t1_feature(i,:) = t1_feature(i,:)/(max(t1_feature(i,:))+eps);
end
for i = 1:size(t2_feature,1)
    t2_feature(i,:) = t2_feature(i,:)/(max(t2_feature(i,:))+eps);
end
