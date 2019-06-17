function DeconvolvedTrace = DeconvolveRicker( InputTrace, CentralFrequency, Stabilization )

assert( ndims( InputTrace ) == 1, ...
    'Dataset:DeconvolveRicker:WrongDim', ...
    'The input trace must be a 1D dataset' );

% Deconvolution is performed in the Fourier domain. So we convert the input
% trace to Fourier
InputTraceFourier = CenteredFourierTransform( InputTrace );

% The input wavelet is Ricker with a given central frequency
NormalizedFrequencies = InputTraceFourier.Axes.Locations / CentralFrequency;
SourceFourier = ( 2/sqrt(pi) ) * ( NormalizedFrequencies .^ 2 ) .* exp( - NormalizedFrequencies .^ 2 );

% Deconvolution with numerical stabilization to prevent the numerical
% vision from blowing up
DeconvolvedTrace = ( InputTraceFourier .* conj( SourceFourier ) ) ...
    / ( SourceFourier .* conj( SourceFourier ) + Stabilization );

end % of DeconvolveTrace