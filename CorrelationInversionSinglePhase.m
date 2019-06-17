function phase = CorrelationInversionSinglePhase( signal )

% This will need to be turned into an optional parameter
shouldOptimize = true;

% First we find the approximate phase on the grid. A finer grid takes up
% more memory and slows evaluation.

totalGridPoints = 10^4;
omegaGrid = linspace( 0, 2, totalGridPoints );

signalLength = length( signal );

correlations = exp( -1i * ToColumn( pi*omegaGrid ) * ToRow( 0:signalLength-1 ) ) * ToColumn( signal );
[~,indexMax] = max( correlations );

phase = omegaGrid(indexMax);
phase = WrapToOne( phase );

% Then we use local optimization to find a better estimate.

if shouldOptimize
    phase = LocallyMaximizeCorrelation( signal, phase );
end

end

function phaseOptimal = LocallyMaximizeCorrelation( signal, phaseApproximate )

n = 0:length(signal)-1;
signal = ToColumn( signal );

optimizationOptions = optimoptions( 'fminunc', ...
    'TolX', 1e-16, ...
    'TolFun', 1e-16, ...
    'Algorithm', 'quasi-newton', ...
    'Display', 'off' );
CorrelationImaging = @(omega) abs( exp( -1i * omega * n ) * signal );
phaseOptimal = fminunc( @(omega) -CorrelationImaging(pi*omega), phaseApproximate, optimizationOptions );


end