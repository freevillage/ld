function phase = DFSCorrelationSinglePhaseSingleSnapshot( signal )

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
    minusipiw = ToColumn( -1i * pi * omegaGrid );
    
    correlations = nan( [totalGridPoints 1] );
    for k = 1 : totalGridPoints
        correlations(k) =  cumprod( [1, repmat( exp( minusipiw(k) ), [1 signalLength-1] ) ] ) * s ;
    end
    
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

function phaseOptimal = LocallyMaximizeCorrelationBnd( signal, phaseApproximateRange )

n = 0:length(signal)-1;
signal = ToColumn( signal );

CorrelationImagingFcn = @(omega) abs( exp( -1i * pi * omega * n ) * signal );

optimizationOptions = optimset( ...
    'TolX', 10*eps, ...
    'TolFun', 10*eps );

phaseOptimal = fminbnd( @(omega) -CorrelationImagingFcn(omega), phaseApproximateRange(1), phaseApproximateRange(2), optimizationOptions );

end

% function phaseOptimal = LocallyMaximizeCorrelation( signal, phaseApproximate )
% 
% n = 0:length(signal)-1;
% signal = ToColumn( signal );
% 
% optimizationOptions = optimoptions( 'fminunc', ...
%     'TolX', 1e-16, ...
%     'TolFun', 1e-16, ...
% ... %    'Algorithm', 'quasi-newton', ...
%     'Display', 'off' );
% CorrelationImaging = @(omega) abs( exp( -1i * pi * omega * n ) * signal );
% phaseOptimal = fminunc( @(omega) -CorrelationImaging(omega), phaseApproximate, optimizationOptions );
% 
% end