function result = ShortTimeFourierTransform( signal, windowLength, outputType )

assert( IsDataset( signal ) ...
    && isvector( signal ) );

if nargin < 3
    outputType = 'stft';
end

totalTimes = size( signal );
samplingFrequency = 1 / signal.Axes.Step;
windowLengthInPts = floor( windowLength / signal.Axes.Step );
% 
% if IsEven( totalTimes )
%     integerTimes  = -totalTimes/2 : totalTimes/2 - 1;
% else
%     integerTimes  = -(totalTimes-1)/2 : (totalTimes-1)/2;
% end
% 
% frequencies = integerTimes / totalTimes * samplingFrequency;


[stft, frequencies, times, psd] = spectrogram( signal.Values, ...
     windowLengthInPts, ...
     windowLengthInPts - 1, ...
     pow2( nextpow2( totalTimes ) ), ...
     samplingFrequency );
 
 if strcmp( outputType, 'stft' )
     resultValues = stft;
 elseif strcmp( outputType, 'psd' )
     resultValues = psd;
 else
     error( 'Wrong outputType' );
 end
 
 result = DatasetNd( GraphAxis( times, signal.Axes.Name, signal.Axes.Units ), ...
     GraphAxis( frequencies, 'Frequency', 'Hz' ), ...
     transpose( resultValues ) );

end