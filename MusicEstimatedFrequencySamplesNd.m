function estimatedFreqs = MusicEstimatedFrequencySamplesNd( Nantennas, Nsamples, fTrue, sigmaNoise )

cleanData = sum( exp( 1i * pi * bsxfun( @times, ToColumn( fTrue ), 0 : Nantennas-1 ) ) );
noiseSamples = ComplexGaussianNoise( sigmaNoise, [Nsamples, Nantennas] );
noisyData = bsxfun( @plus, cleanData, noiseSamples );
Nf = length( fTrue );

estimatedFreqs = nan( Nsamples, Nf );

parfor iSample = 1 : Nsamples
    estimatedFreqs(iSample,:) = DiscreteFrequencySpectrum( ...
        noisyData(iSample,:), ...
        'Method', 'Music', ...
        'TotalFrequencies', Nf, ...
        'RefinementFactor', 5, ...
        'TotalRefinements', 5 );
end

end