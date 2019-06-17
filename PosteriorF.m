function posteriorStats = PosteriorF( observedData, fTrue, sigmaNoise )

%Nantennas = length( observedData ) / 2;

%CleanSignal = @(f0) exp( 1i * 2 * pi * f0 * ( 0 : Nantennas-1 ) );
%MeanLikelihood = @(f0) [ real( CleanSignal(f0) ), imag( CleanSignal(f0) ) ];
%CovLikelihood = @(sigma) sigma * eye( 2*Nantennas );

%LikelihoodUnnormalized = @(f) mvnpdf( observedData, MeanLikelihood(f), CovLikelihood(sigmaNoise) );

normalization = integral( ...
    @(f) LikelihoodUnnormalized( f, observedData, sigmaNoise ), ...
    fTrue - sigmaNoise/10, ...
    fTrue + sigmaNoise/10 ...
    );

%FreqLikelihood = @(f) LikelihoodUnnormalized(f) / normalization;

muF = integral( @(f) f .* FreqLikelihood(f,observedData, sigmaNoise, normalization), fTrue - sigmaNoise/10, fTrue + sigmaNoise/10 );
mu2F = integral( @(f) f .* f .* FreqLikelihood(f, observedData, sigmaNoise, normalization), fTrue - sigmaNoise/10, fTrue + sigmaNoise/10 );
sigmaF = sqrt( mu2F - muF*muF );

posteriorStats = [ muF, sigmaF ];

end

function y = CleanSignal( f0, Nantennas )

y = ToColumn( exp( 1i * pi * f0 * ( 0 : Nantennas-1 ) ) );

end

function ml = MeanLikelihood( f0, Nantennas )

cleanSignal = CleanSignal(f0, Nantennas);

ml = [ real( cleanSignal ) ; imag( cleanSignal ) ];

end


function lu = LikelihoodUnnormalized( freqs, observedData, sigmaNoise )

Nantennas = length( observedData ) / 2;
lu = arrayfun( @(f) mvnpdf( observedData, MeanLikelihood(f,Nantennas), CovLikelihood(sigmaNoise,Nantennas) ), freqs );

end

function cl = CovLikelihood( sigma, Nantennas )

cl = sigma * sigma * eye( 2*Nantennas );

end


function fl = FreqLikelihood( freqs, observedData, sigmaNoise, normalization )

fl = LikelihoodUnnormalized( freqs, observedData, sigmaNoise ) / normalization;

end
