function input = ParseDFSInput( varargin )

input = inputParser;

defaultMethod = 'Prony';
supportedMethods = { ...
    'Prony', ...
    'TotalLeastSquaresProny', ...
    'CorrelationSinglePhase', ...
    'RootMusic', ...
    'MatrixPencil', ...
    'Music', ...
    'Esprit', ...
    'MaximumLikelihoodSinglePhase', ...
    'LeastSquaresSinglePhase' ...
    };

defaultTotalFrequencies = 1;
defaultPencilParameter = -1;
defaultFrequencySensitivity = 1e-6;
defaultTotalRefinements = 0;
defaultRefinementFactor = 10;
defaultNoiseStandardDeviation = 1;

input.addOptional( 'Method', defaultMethod, @(methodName) any( validatestring( methodName, supportedMethods ) ) );
input.addOptional( 'TotalFrequencies', defaultTotalFrequencies, @IsPositiveInteger );
input.addOptional( 'PencilParameter', defaultPencilParameter, @IsPositiveInteger );
input.addOptional( 'FrequencySensitivity', defaultFrequencySensitivity, @IsPositiveScalar );
input.addOptional( 'TotalRefinements', defaultTotalRefinements, @(n) IsPositiveInteger(n) || (n == 0) );
input.addOptional( 'RefinementFactor', defaultRefinementFactor, @IsPositiveScalar );
input.addOptional( 'NoiseStandardDeviation', defaultNoiseStandardDeviation, @(x) IsPositiveScalar(x) || ( x==0 ) );

input.parse( varargin{:} );

end
