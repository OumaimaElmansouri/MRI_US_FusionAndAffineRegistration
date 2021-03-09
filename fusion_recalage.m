%**************************************************************************
% Author: Oumaima El Mansouri (2019 Oct.)
% University of Toulouse, IRIT/INP-ENSEEIHT
% Email: oumaima.el-mansouri@irit.fr
% ---------------------------------------------------------------------
% Copyright (2020): Oumaima El Mansouri, Fabien Vidal, Adrian~Basarab, Denis Kouamé, Jean-Yves Tourneret.
%
% Permission to use, copy, modify, and distribute this software for
% any purpose without fee is hereby granted, provided that this entire
% notice is included in all copies of any software which is or includes
% a copy or modification of this software and in all copies of the
% supporting documentation for such software.
% This software is being provided "as is", without any express or
% implied warranty.  In particular, the authors do not make any
% representation or warranty of any kind concerning the merchantability
% of this software or its fitness for any particular purpose."
% ---------------------------------------------------------------------
%
%%
close all
clear all
clc

addpath ./utils;
addpath ./images;
addpath './tools';

%% Load or read images

% if needed resize MRI and US images (Nus = d*Nmri), in this example d = 6
% (d is an integer)
load('y1.mat'); %MRI image
load('y2.mat');% US image


%% Image normalization
%linear normalization

y1_max = max(y1(:));
y1 = y1/y1_max;
y2_max = max(y2(:));
y2 = y2/y2_max;


%% Registration parameters
%Apply an Affine transformation to US image

%Affine matrix
u=20; v=50; %translation parameters
theta = 0.06;%rotation parameters
Sx=1; Sy=1;
h1=0.01; h2=0.02;

T = make_transformation_matrix([u v],theta,[Sx Sy],[h1 h2]);
y2 = applyAffineTransformation(y2,T);

%% Display observation
figure; imagesc(y1);colormap 'gray'; axis off
title(' y_{MRI}');
figure;  imagesc(y2);colormap 'gray'; axis off
title('y_{US}');

%% Initialization of PALM
% US denoising
net = denoisingNetwork('DnCNN');
denoisedI = denoiseImage(y2,net);
y2=denoisedI;
y2 = imgaussfilt(y2,2);
% MRI super resolution
yint = imresize(y1,6,'bicubic');
Jx = conv2(yint,[-1 1],'same');
Jy = conv2(yint,[-1 1]','same');
gradY = sqrt(Jx.^2+Jy.^2);


%% parameters
% blur kernel 
[n1,n2] = size(y2);
B = fspecial('gaussian',5,4);
[FB,FBC,F2B,~] = HXconv(y2,B,'Hx');
gama = 1e-3;

% define the difference operator kernel
dh = zeros(n1,n2);
dh(1,1) = 1;
dh(1,2) = -1;
dv = zeros(n1,n2);
dv(1,1) = 1;
dv(2,1) = -1;
% compute FFTs for filtering
FDH = fft2(dh);
FDHC = conj(FDH);
F2DH = abs(FDH).^2;
FDV = fft2(dv);
FDV = conj(FDV);
F2DV = abs(FDV).^2;
c1 = 1e-8;
F2D = F2DH + F2DV +c1;

%% Registration MRI feature
Jx = conv2(yint*y1_max,[-1 1],'same');
Jy = conv2(yint*y1_max,[-1 1]','same');
gradYm = sqrt(Jx.^2+Jy.^2);

%% Hyperparameters
taup = 1;
tau = taup;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% paramètre IRM (influence TV) %%%%%%%%%%%%%%%%%%%%%%%%%
tau10 = 1e-12 ;        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% paramètre IRM (influence echo) %%%%%%%%%%%%%%%%%%%%%%%%%
tau1 =1e-4;       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% paramètre US (influence observation) %%%%%%%%%%%%%%%%%%%%%%%%%
tau2 = 2e-4;       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% paramètre US (influence TV) %%%%%%%%%%%%%%%%%%%%%%%%%
tau3 = 9e-3;       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% paramètre US (influence IRM) %%%%%%%%%%%%%%%%%%%%%%%%%
% Linear Lipschitz contant
a = 0.02;
b =5e-1;


%% PALM algorithm for MRI and US fusion and affine registration

stoppingrule = 1;
tolA = 1e-4;
maxiter = 30;
n_iter = 2;
d=6;
x2 = y2+c1;
x1 = yint;
BX = ifft2(FB.*fft2(x1));
cest = estimate_c(y1,y2);
c = abs(cest);

for i = 1:n_iter
    %%%%%%%%%%%%%%%%%%%%%%%%%% update Xirm %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    x1 = FSR_xirm_NL(x1,y1,x2,gradY,B,d,c,F2D,tau,tau10,'false');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% update Xus %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    x2 = Descente_grad_xus_NL(y2,x1,x2,c,gama,tau1,tau2,tau3,'false');
    
    tau10 = 2*tau10*norm(a+b*x2)/5;
 
    %%%%%%%%%%%%%%%%%%%%%%%%% Affine registration %%%%%%%%%%%%%%%%%%%%%%%
    % registration US feature
    Jx = conv2(y2*y2_max,[-1 1],'same');
    Jy = conv2(y2*y2_max,[-1 1]','same');
    gradYu = sqrt(Jx.^2+Jy.^2);
    
    TOptim  = EstimateAffineTransformation(gradYu,gradYm,'sd');
    x2 = applyAffineTransformation(x2,TOptim);
    y2 = applyAffineTransformation(y2,TOptim);
   %%%%%%%%%%%%%%%%%%%%%%%%% Polynomial function %%%%%%%%%%%%%%%%%%%%%%%
    cest = estimate_c(y1,y2);
    c = abs(cest);
end

%% Display Fused image
figure; imagesc(x2);colormap 'gray'; axis off
