function [ lagAxis, signalsCorrelation ] = correlation( varargin )

if( ~isa( varargin{ 1 }, 'GraphAxis' ) )
    error( 'The first argument must be a time axis' );
else
    tAxis = varargin{ 1 };
end % of check for the time axis

[ signalsCorrelation, lags ] = xcorr( varargin{ 2:end } );
lagAxis = GraphAxis( tAxis.Step * lags, 'Lag', tAxis.Units ); 

end % of autocorrelation