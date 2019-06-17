function [X,freq]=CenteredFastFourierTransform( x, varargin )
%this is a custom function that helps in plotting the two-sided spectrum
%x is the signal that is to be transformed
%Fs is the sampling rate

input = inputParser;

defaultSamplingFrequency = 1;
defaultDimension = 1;
defaultNumberPoints = 0;
defaultWindowFcn = @(N) ones( N, 1 );

addParameter( input, 'SamplingFrequency', defaultSamplingFrequency, @IsPositiveScalar );
addParameter( input, 'Dimension', defaultDimension, @IsPositiveInteger);
addParameter( input, 'NumberPoints', defaultNumberPoints, @IsPositiveInteger );
addParameter( input, 'WindowFunction', defaultWindowFcn, @(fh) isa(fh, 'function_handle') );

parse( input, varargin{:} );

if isvector( x ), x = ToColumn( x ); end

Fs = input.Results.SamplingFrequency;
dimension = input.Results.Dimension;
sz = size( x, dimension );
N = max( [input.Results.NumberPoints sz] );
WindowFcn = input.Results.WindowFunction;

%if N > sz, x(N) = 0; end % Pad with zeros if necessary

sizeWindowRepMat = size( x );
sizeWindowRepMat(dimension) = 1;

windowCoeffs = repmat( shiftdim( ToColumn( WindowFcn( sz ) ), 1-dimension ), sizeWindowRepMat );
x = x .* windowCoeffs;
 
%this part of the code generates that frequency axis
if( IsEven( N ) )
    k=-N/2:N/2-1; % N even
else
    k=-(N-1)/2:(N-1)/2; % N odd
end

T=N/Fs;
freq=k/T;  %the frequency axis
 
%takes the fft of the signal, and adjusts the amplitude accordingly

X = fft( x, N, dimension ) / N;
X = fftshift( X, dimension );
end