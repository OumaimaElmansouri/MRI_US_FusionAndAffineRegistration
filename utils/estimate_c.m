% close all 
% clear 
% clc
% %% Input : x1, y1, x2, y2, B
% 
% load('irm_test.mat');
% load('us_test.mat');
function [cest,A] = estimate_c(irm,us)
y1 = irm;
y1 = y1(3:end,1:end-1);
y1 = imresize(y1,[100 100]);
%y1 = y1/max(max(y1));
y2 = imresize(us,[600 600]);
%y2 = y2/max(max(y2));

yint = imresize(y1,6,'bicubic');
% figure; imshow(y1,[]);
% title(' y_1 ');
% figure;  imshow(y2,[]);
% title('y_2 '); 
[n1,n2] = size(y2);

Jx = conv2(yint,[-1 1],'same');
Jy = conv2(yint,[-1 1]','same');
gradY = sqrt(Jx.^2+Jy.^2); 

%%

yi = reshape(yint,n1*n2,1);
yu = reshape(y2,n1*n2,1);
dyi =reshape(gradY,n1*n2,1);
 A = [ones(n1*n2,1) yi yi.^2 yi.^3 yi.^4 dyi dyi.*yi dyi.*yi.^2 dyi.*yi.^3 dyi.^2 dyi.^2.*yi ...
      dyi.^2.*yi.^2 dyi.^3 dyi.^3.*yi dyi.^4]; 

cest = pinv(A)*yu;
%save('cest','cest')
%%
% xu = A*cest;
% xu = reshape(xu,n1,n2);
% figure;  imagesc(y2); colormap 'gray'
% title('y_{us}');
% figure;  imagesc(xu); colormap 'gray'
% title('\Phi(y_{irm})');
% figure; imagesc(y1);colormap 'gray'
% title('y_{irm}');
% residus = max(max(abs(y2-xu)))
% residus = norm((y2-xu),1)
% residus = norm((y2-xu),2)
