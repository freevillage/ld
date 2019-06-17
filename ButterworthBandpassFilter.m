function [ B, A ] = ButterworthBandpassFilter( LowFrequency, HighFrequency, varargin )

input = inputParser;
input.addRequired( 'LowFrequency',  @IsPositiveScalar ); 
input.addRequired( 'HighFrequency', @IsPositiveScalar );
input.addOptional( 'TimeStep', 1.0, @IsPositiveScalar );
input.addOptional( 'Order', 2, @(x) IsPositiveInteger(x) && isscalar(x) );
parse( input, LowFrequency, HighFrequency, varargin{:} );

frequencySampling = 1.0 / input.Results.TimeStep;
frequencyNyquist = frequencySampling / 2;
[ B, A ] = butter( input.Results.Order, ...
    [input.Results.LowFrequency/frequencyNyquist, input.Results.HighFrequency/frequencyNyquist] );

end