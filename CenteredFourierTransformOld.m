function [ FrequencyAxis, SignalFD ] = CenteredFourierTransform( TimeAxis, SignalTD, varargin )

SamplingInterval = TimeAxis.Step;
SamplingFrequency = 2*pi  / SamplingInterval;

[ SignalFD, Frequencies ] = CenteredFFT( SignalTD, SamplingFrequency, varargin{:} );

FrequencyAxis = GraphAxis( Frequencies, 'Frequency', 'Hz' );

end





function [X,freq]=CenteredFFT(x,Fs, varargin)
%this is a custom function that helps in plotting the two-sided spectrum
%x is the signal that is to be transformed
%Fs is the sampling rate

if( nargin == 2 )
    Dimension = 1;
else
    Dimension = varargin{ 1 };
end

N = size( x, Dimension );
 
%this part of the code generates that frequency axis
if( IsEven( N ) )
    k=-N/2:N/2-1; % N even
else
    k=-(N-1)/2:(N-1)/2; % N odd
end

T=N/Fs;
freq=k/T;  %the frequency axis
 
%takes the fft of the signal, and adjusts the amplitude accordingly

X = fft( x, [], Dimension ) / N;
X = fftshift( X, Dimension );
end
