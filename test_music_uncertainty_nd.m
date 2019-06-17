fTrue = [0.3 0.7];
Nf = length( fTrue );
Nantennas = 11;
sigmaNoise = logspace( -6, 1, 8 );
Nsigma = length( sigmaNoise );
Nsamples = 200;

estimatedFreqs = nan( Nsamples, Nf, Nsigma );
muFreqs = nan( Nf, Nsigma );
covFreqs = nan( Nf, Nf, Nsigma );

samplesProgressBar = waitbar( 0, 'Processing samples...' );

for j = 1 : Nsigma
    estimatedFreqs(:,:,j) = MusicEstimatedFrequencySamplesNd( Nantennas, Nsamples, fTrue, sigmaNoise(j) );
    
    muFreqs(:,j) = mean( estimatedFreqs(:,:,j) );
    covFreqs(:,:,j) = cov( estimatedFreqs(:,:,j) );
    
    waitbar( j / Nsigma, samplesProgressBar );
end

delete( samplesProgressBar );


%%

% figure
% 
% for j = 1 : Nsigma
%     subplot( 1, Nsigma, j )
%     hold on
%     theseFreqs = estimatedFreqs(:,:,j);
%     histogram2( theseFreqs(:,1), theseFreqs(:,2), 'Normalization', 'pdf' );
%     minmaxFreqs = minmax( transpose( theseFreqs ) );
%     [ xGrid, yGrid ] = ndgrid( linspace( minmaxFreqs(1,1)', minmaxFreqs(1,2), 100 )', linspace( minmaxFreqs(2,1), minmaxFreqs(2,2), 100 ) );
%     surf( xGrid, yGrid, reshape( mvnpdf( [ ToColumn(xGrid) , ToColumn(yGrid) ], muFreqs(:,j)', covFreqs(:,:,j) ), 100, 100 ) )
%     %plot( plotFreqs, normpdf( plotFreqs, muFreqs(i,j), sigmaFreqs(i,j) ), 'LineWidth', 3 );
%     title( 'Empirical PDF' );
%     xlabel( 'Normalized frequency' );
% %    xlim( [minFreq, maxFreq] );
%     ylabel( 'PDF' );
%     view( [-37 30] )
% end

%%

CleanSignal = @(fTrue) ToColumn( sum( exp( 1i * pi * bsxfun( @times, ToColumn( fTrue ), 0 : Nantennas-1 ) ) ) );
MeanLikelihood = @(f0) [ real( CleanSignal(f0) ) ; imag( CleanSignal(f0) ) ];
CovLikelihood = @(sigma) sigma * sigma * eye( 2*Nantennas );

Nsamples = 10;

observedDataSamples = nan( Nsamples, 2*Nantennas, Nsigma );

for j = 1 : Nsigma
        observedDataSamples(:,:,j) = mvnrnd( MeanLikelihood(fTrue), CovLikelihood(sigmaNoise(j)), Nsamples );
end


%%

posteriorMean = nan( Nsamples, Nf, Nsigma );
posteriorCov = nan( Nsamples, Nf, Nf, Nsigma );
posteriorWaitbar = waitbar( 0, 'Calculating posteriors...' );

for j = 1 : Nsigma
    thisSigmaNoise = sigmaNoise(j);
    for k = 1 : Nsamples
        [thisPosteriorMean, thisPosteriorCov] = PosteriorFNd( squeeze( observedDataSamples(k,:,j) ), fTrue, thisSigmaNoise );
        posteriorMean(k,:,j) = thisPosteriorMean;
        posteriorCov(k,:,:,j) = thisPosteriorCov;
    end
    waitbar( j/Nsigma, posteriorWaitbar );
end

delete( posteriorWaitbar );

%%

covMaxL = nan( Nf, Nf, Nsigma );

covPosterior = squeeze( posteriorCov(1,:,:,:) );


for j = 1 : Nsigma
    covMaxL(:,:,j) = cov( posteriorMean(:,:,j) );
end

%%

std1Posterior = sqrt( squeeze(covPosterior(1,1,:)) );
std2Posterior = sqrt( squeeze(covPosterior(2,2,:)) );

std1MaxL = sqrt( squeeze( covMaxL(1,1,:) ) );
stdMaxL = sqrt( squeeze( covMaxL(2,2,:) ) );

std1Freqs = sqrt( squeeze( covFreqs(1,1,:) ) );
std2Freqs = sqrt( squeeze( covFreqs(2,2,:) ) );

figure, subplot( 2, 2, 1 )

loglog( ...
    sigmaNoise, std1Posterior, '-o', ...
    sigmaNoise, std1MaxL, '-d', ...
    sigmaNoise, std1Freqs, '-^', ...
    'LineWidth', 3 ...
    );
legend( 'Posterior', 'Max Likelihood', 'MUSIC', ...
    'Location', 'NorthWest' )
legend( 'boxoff' )
title( 'Uncertainty of f_1 inversion' )
xlabel( '\sigma_{noise}' )
xlim( minmax( sigmaNoise ) )
ylabel( '\sigma(f_1)' )
grid on

subplot( 2, 2, 2 )

loglog( ...
    sigmaNoise, std2Posterior, '-o', ...
    sigmaNoise, stdMaxL, '-d', ...
    sigmaNoise, std2Freqs, '-^', ...
    'LineWidth', 3 ...
    );
legend( 'Posterior', 'Max Likelihood', 'MUSIC', ...
    'Location', 'NorthWest' )
legend( 'boxoff' )
title( 'Uncertainty of f_2 inversion' )
xlabel( '\sigma_{noise}' )
xlim( minmax( sigmaNoise ) )
ylabel( '\sigma(f_1)' )
grid on


subplot( 2, 2, 3 )

semilogx( ...
    sigmaNoise, std1Posterior./std1Freqs, '-o',  ...
    sigmaNoise, std1MaxL./std1Freqs, '-d', ...
    'LineWidth', 3 ...
    );
grid on
legend( 'Posterior/MUSIC', 'Max Likelihood/MUSIC', ...
    'Location', 'NorthWest');
legend( 'boxoff' )
title( 'Improvement in f_1 inversion' );
xlabel( '\sigma_{noise}' )
xlim( minmax( sigmaNoise ) )
ylabel( '\sigma(f_1)/\sigma_{MUSIC}(f_1)' )

subplot( 2, 2, 4 )

semilogx( ...
    sigmaNoise, std2Posterior./std2Freqs, '-o',  ...
    sigmaNoise, stdMaxL./std2Freqs, '-d', ...
    'LineWidth', 3 ...
    );
grid on
legend( 'Posterior/MUSIC', 'Max Likelihood/MUSIC', ...
    'Location', 'NorthWest');
legend( 'boxoff' )
title( 'Improvement in f_2 inversion' );
xlabel( '\sigma_{noise}' )
xlim( minmax( sigmaNoise ) )
ylabel( '\sigma(f_2)/\sigma_{MUSIC}(f_2)' )

