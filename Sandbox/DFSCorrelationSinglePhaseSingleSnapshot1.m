function phase = DFSCorrelationSinglePhaseSingleSnapshot1( signal )

% This will need to be turned into an optional parameter
shouldOptimize = false;

% Make the signal zero-phase
assert( isvector( signal ) && isnumeric( signal ) );
signal = signal / signal(1);
signalLength = length( signal );

% First we find the approximate phase on the grid. A finer grid takes up
% more memory and slows evaluation.



% The following is a much more MEMORY efficient version of this:
% correlations = exp( -1i * ToColumn( pi*omegaGrid ) * ToRow( 0:signalLength-1 ) ) * ToColumn( signal );
%n = 0:signalLength-1;
s = ToColumn( signal );

totalGridPoints = 2*10^3;

omegaGridMin = -1;
omegaGridMax = 1;

totalRefinements = 10;

for iRefinement = 1 : totalRefinements+1
    omegaGrid = linspace( omegaGridMin, omegaGridMax, totalGridPoints );
    deltaOmega = omegaGrid(2) - omegaGrid(1);
    correlations = ComputeCorrelations( omegaGrid, signal );
    
    [~,indexMax] = max( correlations );
    phase = omegaGrid(indexMax);
    
    omegaGridMin = phase - 5 * deltaOmega;
    omegaGridMax = phase + 5 * deltaOmega;
end

% end of memory efficient version of correlations

% Then we use local optimization to find a better estimate.

if shouldOptimize
    phase = LocallyMaximizeCorrelationBnd( signal, phase + 1 * [-deltaOmega, deltaOmega] );
end

phase = WrapToOne( phase );

end


function correlations = ComputeCorrelations( omegaGrid, signal )

totalOmegas = length( omegaGrid );
omegaMin = omegaGrid(1);
deltaOmega = omegaGrid(2) - omegaGrid(1);

totalSignalSamples = length( signal );
signal = ToColumn( signal );

A = [ 1, SuccessivePowers( exp( -1i*pi*omegaMin ), totalSignalSamples - 1 ) ];
B = [ 1, SuccessivePowers( exp( -1i*pi*deltaOmega ), totalOmegas - 1 ) ];

correlations = nan( totalOmegas, 1 );

for k = 1 : totalOmegas
    correlations(k) = (A .* [ 1, SuccessivePowers( B(k), totalSignalSamples - 1 ) ]) * signal;
end

end


function phaseOptimal = LocallyMaximizeCorrelationBnd( signal, phaseApproximateRange )

n = 0:length(signal)-1;
signal = ToColumn( signal );

CorrelationImagingFcn = @(omega) abs( exp( -1i * pi * omega * n ) * signal );

optimizationOptions = optimset( ...
    'TolX', 10*eps, ...
    'TolFun', 10*eps );

phaseOptimal = fminbnd( @(omega) -CorrelationImagingFcn(omega), phaseApproximateRange(1), phaseApproximateRange(2), optimizationOptions );

end
