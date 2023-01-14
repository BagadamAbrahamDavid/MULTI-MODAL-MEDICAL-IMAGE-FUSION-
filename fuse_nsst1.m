clc
clear all
close all
addpath('shearlet_toolbox_1');
cd IMAGES
[J,P]=uigetfile('*.*','select T1-weighted image');
I1=double(imread(strcat(P,J)));

[J,P]=uigetfile('*.*','select T2-weighted image');
I2=double(imread(strcat(P,J)));
cd ..
lpfilt='maxflat';
shear_parameters.dcomp =[ 3  3  4  4];
shear_parameters.dsize =[32 32 16 16];
Tscalars=[0 3 4];

[dst1,shear_f1]=nsst_dec2(I1,shear_parameters,lpfilt);
dst_scalars1=nsst_scalars(size(I1,1),shear_f1,lpfilt);

[dst2,shear_f2]=nsst_dec2(I2,shear_parameters,lpfilt);
dst_scalars2=nsst_scalars(size(I2,1),shear_f2,lpfilt);

P11=[dst_scalars1{1} dst_scalars1{2} dst_scalars2{3} dst_scalars2{4} dst_scalars2{5}]

P22=[dst_scalars2{1} dst_scalars2{2} dst_scalars1{3} dst_scalars1{4} dst_scalars1{5}]

fun = @(x)x(1)*exp(-norm(x)^2);
lb = [-min(P11),-min(P22)];
ub = [max(P11),max(P22)];
nvars=2;
rng default 
options = optimoptions('particleswarm','SwarmSize',100,'HybridFcn',@fmincon);
T=particleswarm(fun,nvars,lb,ub,options);

for k=1:5
    A=dst1{k};
    B=dst2{k};
    F{k}=abs(T(1)).*A+abs(T(2)).*B;
end

xr=nsst_rec2(F,shear_f1,lpfilt); 

figure,subplot(131);imshow(I1,[]);
subplot(132);imshow(I2,[]);
subplot(133);imshow(xr,[]);
    

PS=psnr(mat2gray(xr),mat2gray(I1))/2
SS=std2(mat2gray(xr))
SM=ssim(uint8(mat2gray(xr).*255),uint8(mat2gray(I1).*255))
E=entropy(xr)


