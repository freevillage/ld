function AfphiOptimal = DFSLeastSquaresSingleSnapshot( signal )

signalReIm = ReIm( ToRow( signal ) );

% Initial approximation
freqApproximate = DiscreteFrequencySpectrum( signal, 'Method', 'CorrelationSinglePhase' ); 
%freqApproximate = rand;
amplitudeApproximate = mean( abs( ToColumn( signal ) ) );
amplitudeApproximate = 1;
phaseApproximate = 2*pi * rand;
phaseApproximate = 0;

x0 = [ amplitudeApproximate; freqApproximate; phaseApproximate ];

lb = [0.99, -1, -0.01];
ub = [1.01*amplitudeApproximate, 1, 0.01];

options = optimoptions( 'fmincon', ...
    'GradObj', 'on', ...
    'TolX', 1e-15, ...
    'TolFun', 1e-15 );

leastSquaresProblem = createOptimProblem( 'fmincon', ...
    'x0', x0, ...
    'objective', @(x) LeastSquaresCost( x, signalReIm ), ...
    'lb', lb, ...
    'ub', ub, ...
    'options', options );

%AfphiOptimal = run( MultiStart( 'UseParallel', true, 'Display', 'off' ), leastSquaresProblem, 10 );

AfphiOptimal = run( GlobalSearch( 'Display', 'off' ), leastSquaresProblem );

%AfphiOptimal = fmincon( leastSquaresProblem );

% n = 0 : (totalAntennas-1);
% 
% fun = @(x,n) x(1) * [ ToRow( cos( x(2)*pi*n + x(3) ) ), ToRow( sin( x(2)*pi*n + x(3) ) ) ];
% options = optimoptions( 'lsqcurvefit', ...
%     'MaxFunEvals', 1e3, ...
%     'MaxIter', 1e3, ...
%     'TolX', 1e-6, ...
%     'TolFun', 1e-6 );
% 
% leastSquaresProblem = createOptimProblem( 'lsqcurvefit', ...
%     'x0', x0, ...
%     'objective', fun, ...
%     'lb', lb, ...
%     'ub', ub, ...
%     'xdata', n, ...
%     'ydata', signalReIm, ...
%     'options', options );
% 
% AfphiOptimal = run( ...
%     MultiStart( 'UseParallel', true ), ...
%     leastSquaresProblem, ...
%     1000 );


% AfphiOptimal = lsqcurvefit( fun, x0, n, signalReIm, lb, ub, options );

end

function xy = ReIm( z )

assert( isvector ( z ) );
zColumn = ToColumn( z );
xyColumn = [ real( zColumn ) ; imag( zColumn ) ];

if iscolumn( z )
    xy = xyColumn;
else
    xy = transpose( xyColumn );
end

end


function [lsc, grad] = LeastSquaresCost( x, d )

A   = x(1);
f   = x(2);
phi = x(3);

Nantennas = length(d) / 2;

n = 0 : Nantennas-1;

lsc = sum( ( A * [ ToRow( cos( f*pi*n + phi ) ), ToRow( sin( f*pi*n + phi ) ) ] - ToRow(d) ) .^ 2 );

if nargout > 1
    
    dReal = d(1:Nantennas);
    dImag = d(Nantennas+1:end);
    
    partialA = sum( 2 * cos( f*pi*n + phi ) .* ( A .* cos( f*pi*n + phi ) - dReal ) ) ...
        + sum( 2 * sin( f*pi*n + phi ) .* ( A .* sin( f*pi*n + phi ) - dImag ) );
    
    partialF = sum( -2 * A * n * pi .* ( A * cos( f*pi*n + phi ) - dReal ) .* sin( f*pi*n + phi ) ) ...
        + sum(  2 * A * n * pi .* ( A * sin( f*pi*n + phi ) - dImag ) .* cos( f*pi*n + phi ) );
    
    partialPhi = sum( -2 * A .* ( A * cos( f*pi*n + phi ) - dReal ) .* sin( f*pi*n + phi ) ) ...
        + sum(  2 * A .* ( A * sin( f*pi*n + phi ) - dImag ) .* cos( f*pi*n + phi ) );
    
    grad = [ partialA, partialF, partialPhi ];
    
end

end