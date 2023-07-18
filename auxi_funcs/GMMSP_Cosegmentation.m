function [sup_pixel,N] = GMMSP_Cosegmentation(image_t1,image_t2,seg_scal)
[h, w, b1]=size(image_t1);
[~, ~, b2]=size(image_t2);
v_x = floor(sqrt(h*w/seg_scal));
if v_x < 8
    v_x = 8;
end
v_y = v_x;
new_image = zeros(h, w,3);
new_image_t1 = sqrt(sum(image_t1.^2,3));
new_image_t1 = (new_image_t1 - min(new_image_t1(:)))./(max(new_image_t1(:))-min(new_image_t1(:)));
new_image_t2 = sqrt(sum(image_t2.^2,3));
new_image_t2 = (new_image_t2 - min(new_image_t2(:)))./(max(new_image_t2(:))-min(new_image_t2(:)));

new_image(:,:,1) = new_image_t1;
new_image(:,:,2) = new_image_t2;

new_image = im2uint8(new_image);
sup_pixel = mx_GMMSP(new_image, v_x, v_y);
N = max(sup_pixel(:));