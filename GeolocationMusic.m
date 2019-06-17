
%By Honghao Tang
clc
clear all
format short %The data show that as long shaping scientific 
doa=degtorad( [20 60] ); %Direction of arrival 
N=2000;%Snapshots
w=[pi/4 pi/3]';%Frequency
totalReceivers=10;%Number of array elements
totalSourceComponents=length(w); %The number of signal
wavelength = 150;%Wavelength
arraySpacing = wavelength / 2;%Element spacing
snr = 1;%SNA
D=zeros(totalSourceComponents,totalReceivers); %To creat a matrix with P row and M column
for k=1:totalSourceComponents
D(k,:)=exp(-1i*2*pi*arraySpacing*sin(doa(k))/wavelength*(0:totalReceivers-1)); %Assignment matrix 
end
D=D';
xx=2*exp(1i*(w*(1:N))); %Simulate signal
arrayData=D*xx;
arrayData=arrayData+awgn(arrayData,snr);%Insert Gaussian white noise
figure,subplot(1,2,1),plot(abs(arrayData'))

totalDirections = 10^6;
directions = linspace( -pi/2, pi/2, totalDirections ); 

% [eigenVecs,~] = eig( CrossCovarianceMatrix( arrayData ) ); %Find the eigenvalues and eigenvectors of R 
% noiseSpace = eigenVecs( :, 1:totalReceivers-totalSourceComponents ); %Estimate noise subspace
% directionalPower =  NormalizeVector( 1 ./ VarianceMatrix( exp( ( -2*pi*1i*arraySpacing/wavelength ) * ToColumn( sin(directions) ) * (0:totalReceivers-1) ) * noiseSpace ) )  ;

tic
directionalPower = MusicDirectionOfArrival( directions, arrayData, arraySpacing, totalSourceComponents, wavelength );
toc

fprintf( 'Direction of arrival: %f\n', radtodeg( directions(FindLargestPeaks( directionalPower, totalSourceComponents )) ) )
subplot(1,2,2), plot( radtodeg(directions), ToDecibels(directionalPower) )
xlabel('angle \theta [degree]')
ylabel('spectrum function P(\theta) [dB]')
title('DOA estimation based on MUSIC algorithm ')
grid on

% Alternative way
directionsRootMusic = MusicDoa( arrayData, totalSourceComponents );
fprintf( 'Direction of arrival (root-music): %f\n', radtodeg( asin( directionsRootMusic ) ) );