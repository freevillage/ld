function phases = DiscreteFrequencySpectrum( signal, varargin )

% Parsing input to extract the method and the number of frequencies
input = ParseDFSInput( varargin{:} );

% Performing inversion using supplied parameters
switch input.Results.Method
    case 'CorrelationSinglePhase'
        phases = DiscreteFrequencySpectrumCorrelationSinglePhase( signal );
    case 'Prony'
        phases = DiscreteFrequencySpectrumProny( signal, input.Results.TotalFrequencies );
    case 'TotalLeastSquaresProny'
        phases = DiscreteFrequencySpectrumTLSProny( signal, input.Results.TotalFrequencies );
    case 'RootMusic' 
        phases = DiscreteFrequencySpectrumRootMusic( signal, input.Results.TotalFrequencies );
    case 'MatrixPencil'
        phases = DiscreteFrequencySpectrumMatrixPencil( signal, input.Results.TotalFrequencies, ...
            input.Results.PencilParameter );
    case 'Music'
        phases = DiscreteFrequencySpectrumMusic( signal, input.Results.TotalFrequencies, ...
            input.Results.FrequencySensitivity, ...
            input.Results.TotalRefinements, ...
            input.Results.RefinementFactor );
    case 'Esprit'
        phases = DiscreteFrequencySpectrumEsprit( signal, input.Results.TotalFrequencies );
    case 'MaximumLikelihoodSinglePhase'
        phases = DiscreteFrequencySpectrumMaxLikelihoodSinglePhase( signal, ...
            input.Results.NoiseStandardDeviation );
    case 'LeastSquaresSinglePhase'
        phases = DiscreteFrequencySpectrumLeastSquaresSinglePhase( signal );
    otherwise
        error( 'Unsupported method' );
end % of methods switch

end % of function