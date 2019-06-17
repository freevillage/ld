function estimatedFreqs = MusicEstimatedFrequencySamples( Nantennas, Nsamples, fTrue, sigmaNoise )

cleanData = exp( 1i * pi * fTrue * ( 0 : Nantennas-1 ) );
%Nfreqs = 1;
noiseSamples = ComplexGaussianNoise( sigmaNoise, [Nsamples, Nantennas] );
noisyData = bsxfun( @plus, cleanData, noiseSamples );

estimatedFreqs = nan( Nsamples, 1 );

parfor iSample = 1 : Nsamples
    estimatedFreqs(iSample) = DiscreteFrequencySpectrum( ...
        noisyData(iSample,:), ...
        'Method', 'Music', ...
        'TotalRefinements', 5, ...
        'RefinementFactor', 5 );
end

end