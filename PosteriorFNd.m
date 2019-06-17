function [ posteriorMean, posteriorCov ] = PosteriorFNd( observedData, fTrue, sigmaNoise )

integrationRegion = { ...
    fTrue(1) - sigmaNoise/10, ...
    fTrue(1) + sigmaNoise/10, ...
    fTrue(2) - sigmaNoise/10, ...
    fTrue(2) + sigmaNoise/10 ...
    'Method', 'iterated'
    };

normalization = integral2( ...
    @(f1,f2) LikelihoodUnnormalized( f1,f2, observedData, sigmaNoise ), ...
    integrationRegion{:} ...
    );

FreqLikelihood = @(f1,f2) LikelihoodUnnormalized( f1, f2, observedData, sigmaNoise ) / normalization;

mu1 = integral2( @(f1,f2) f1 .* FreqLikelihood(f1,f2), integrationRegion{:} );
mu2 = integral2( @(f1,f2) f2 .* FreqLikelihood(f1,f2), integrationRegion{:} );

posteriorMean = [ mu1, mu2 ];

sigma11 = integral2( @(f1,f2) (f1-mu1) .* (f1-mu1) .* FreqLikelihood(f1,f2), integrationRegion{:} );
sigma12 = integral2( @(f1,f2) (f1-mu1) .* (f2-mu2) .* FreqLikelihood(f1,f2), integrationRegion{:} );
sigma22 = integral2( @(f1,f2) (f2-mu2) .* (f2-mu2) .* FreqLikelihood(f1,f2), integrationRegion{:} );
    
posteriorCov = [ ...
    sigma11, sigma12 ; ...
    sigma12, sigma22 ...
    ];

end

%-------------------------------------------------------------------------%

function y = CleanSignal( f0, Nantennas )

y = ToColumn( sum( exp( 1i * pi * bsxfun( @times, ToColumn( f0 ), 0 : Nantennas-1 ) ) ) );

end

%-------------------------------------------------------------------------%

function ml = MeanLikelihood( f0, Nantennas )

cleanSignal = CleanSignal(f0, Nantennas);

ml = [ real( cleanSignal ) ; imag( cleanSignal ) ];

end

%-------------------------------------------------------------------------%

function lu = LikelihoodUnnormalized( f1, f2, observedData, sigmaNoise )

Nantennas = length( observedData ) / 2;

sizeF = size( f1 );

f1f2 = [ ToColumn( f1 ), ToColumn( f2 ) ];
lu = nan( size( f1f2, 1 ), 1 );

parfor i = 1 : size( f1f2, 1 )
    lu(i) = mvnpdfQuadOnly( ToColumn( observedData ), MeanLikelihood(f1f2(i,:),Nantennas), CovLikelihood(sigmaNoise,Nantennas) );
end

lu = reshape( lu, sizeF );

end

%-------------------------------------------------------------------------%

function cl = CovLikelihood( sigma, Nantennas )

cl = sigma * sigma * eye( 2*Nantennas );

end


% function fl = FreqLikelihood( f1, f2, observedData, sigmaNoise, normalization )
% 
% fl = LikelihoodUnnormalized( f1, f2, observedData, sigmaNoise ) / normalization;
% 
% end
