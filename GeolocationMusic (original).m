
%By Honghao Tang
clc
clear all
format short %The data show that as long shaping scientific 
doa=[20 60]/180*pi; %Direction of arrival 
N=200;%Snapshots
w=[pi/4 pi/3]';%Frequency
M=10;%Number of array elements
P=length(w); %The number of signal
lambda=150;%Wavelength
d=lambda/2;%Element spacing
snr=1000;%SNA
D=zeros(P,M); %To creat a matrix with P row and M column
for k=1:P
D(k,:)=exp(-1i*2*pi*d*sin(doa(k))/lambda*[0:M-1]); %Assignment matrix 
end
D=D';
xx=2*exp(1i*(w*[1:N])); %Simulate signal
x=D*xx;
x=x+awgn(x,snr);%Insert Gaussian white noise
figure,subplot(1,2,1),plot(abs(x'))
R=x*x'; %Data covarivance matrix
[N,V]=eig(R); %Find the eigenvalues and eigenvectors of R 
NN=N(:,1:M-P); %Estimate noise subspace
theta=-90:0.5:90; %Peak search
for ii=1:length(theta)
SS=zeros(1,length(M)); 
for jj=0:M-1
SS(1+jj)=exp(-1i*2*jj*pi*d*sin(theta(ii)/180*pi)/lambda); 
end
PP=SS*NN*NN'*SS';
Pmusic(ii)=abs(1/ PP);
end
Pmusic=10*log10(Pmusic/max(Pmusic)); %Spatial spectrum function 
subplot(1,2,2),plot(theta,Pmusic,'-k')
xlabel('angle \theta/degree')
ylabel('spectrum function P(\theta) /dB')
title('DOA estimation based on MUSIC algorithm ')
grid on