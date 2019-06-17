function freqPeak = RefinedMusicSpectralEstimation( signal, freqRange, totalFreqs, freqSampling, totalExponentsInSource, refinedBandThickness, totalIterations )

if nargin < 7
    totalIterations = 2; % default value
end

freqPeakApprox = MusicSpectralEstimation( signal, freqRange, totalFreqs, freqSampling, totalExponentsInSource );

for iter = 1 : totalIterations-1
    freqBandsRefined  = [ (ToColumn( freqPeakApprox ) - refinedBandThickness), (ToColumn( freqPeakApprox ) + refinedBandThickness) ];
    freqPeakApprox = MusicSpectralEstimation( signal, freqBandsRefined, totalFreqs, freqSampling, totalExponentsInSource );
    
    refinedBandThickness = refinedBandThickness / 10;

end

freqPeak = freqPeakApprox;


end % of function