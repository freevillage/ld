function phase = DFSMaxLikelihoodSinglePhaseSingleSnapshot( signal, sigmaNoise )

% Initial approximation
phaseApproximate = DFSCorrelationSinglePhaseSingleSnapshot( signal ); 

options = optimoptions( 'fmincon', ...
    'Display', 'off', ...
    'TolCon', 1e-12, ...
    'TolX', 1e-12 ...
    );
%options = optimoptions( 'fmincon' );

problem.options = options;
problem.solver = 'fmincon';
problem.objective = @(freqs) - LogLikelihoodUnnormalized( freqs, ReIm(signal), sigmaNoise );
problem.x0 = phaseApproximate;
problem.lb = -1;
problem.ub = 1;

phase = fmincon( problem );

% 
% posteriorStats = PosteriorF( ReIm(signal), phaseApproximate, sigmaNoise );
% 
% phase = posteriorStats(1);



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

function y = CleanSignal( f0, Nantennas )

y = ToColumn( exp( 1i * pi * f0 * ( 0 : Nantennas-1 ) ) );

end

function ml = MeanLikelihood( f0, Nantennas )

cleanSignal = CleanSignal(f0, Nantennas);

ml = [ real( cleanSignal ) ; imag( cleanSignal ) ];

end


function lu = LogLikelihoodUnnormalized( freqs, observedData, sigmaNoise )

Nantennas = length( observedData ) / 2;
lu = arrayfun( @(f) logmvnpdf( observedData, MeanLikelihood(f,Nantennas), CovLikelihood(sigmaNoise,Nantennas) ), freqs );

end

function cl = CovLikelihood( sigma, Nantennas )

cl = sigma * sigma * eye( 2*Nantennas );

end


function fl = FreqLikelihood( freqs, observedData, sigmaNoise, normalization )

fl = LikelihoodUnnormalized( freqs, observedData, sigmaNoise ) / normalization;

end
