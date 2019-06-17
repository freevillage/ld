fTrue = linspace( 0.7, 0.7, 1 );
Nf = length( fTrue );
Nantennas = 11;
sigmaNoise = logspace( -6, 1, 8 );
Nsigma = length( sigmaNoise );
Nsamples = 100;

estimatedFreqs = nan( Nf, Nsigma, Nsamples );

samplesProgressBar = waitbar( 0, 'Processing samples...' );

for i = 1 : Nf
    for j = 1 : Nsigma
        estimatedFreqs(i,j,:) = MusicEstimatedFrequencySamples( Nantennas, Nsamples, fTrue(i), sigmaNoise(j) );
        waitbar( ((i-1)*Nsigma+j) / (Nf*Nsigma), samplesProgressBar );
    end
end

delete( samplesProgressBar );

muFreqs    = mean( estimatedFreqs, 3 );
sigmaFreqs = std( estimatedFreqs, 0, 3 );

%%

Nplots = Nf * Nsigma;

figure

for i = 1 : Nf
    for j = 1 : Nsigma
    kPlot = (i-1)*Nsigma + j;
    subplot( Nf, Nsigma, kPlot )
    hold on
    theseFreqs = estimatedFreqs(i,j,:);
    minFreq = min( theseFreqs );
    maxFreq = max( theseFreqs );
    plotFreqs = linspace( minFreq, maxFreq, 1000 );
    histogram( squeeze( estimatedFreqs(i,j,:) ), 20, 'Normalization', 'pdf' );
    plot( plotFreqs, normpdf( plotFreqs, muFreqs(i,j), sigmaFreqs(i,j) ), 'LineWidth', 3 );
    title( 'Empirical PDF' );
    xlabel( 'Normalized frequency' );
    xlim( [minFreq, maxFreq] );
    ylabel( 'PDF' );
    end
end

%%

CleanSignal = @(f0) ToColumn( exp( 1i * pi * f0 * ( 0 : Nantennas-1 ) ) );
MeanLikelihood = @(f0) [ real( CleanSignal(f0) ) ; imag( CleanSignal(f0) ) ];
CovLikelihood = @(sigma) sigma * sigma * eye( 2*Nantennas );

Nsamples = 100;

observedDataSamples = nan( Nf, Nsigma, Nsamples, 2*Nantennas );

%%
for i = 1 : Nf
    for j = 1 : Nsigma
        observedDataSamples(i,j,:,:) = mvnrnd( MeanLikelihood(fTrue(i)), CovLikelihood(sigmaNoise(j)), Nsamples );
    end
end

posteriorStats = nan( Nf, Nsigma, 2, Nsamples );
posteriorWaitbar = waitbar( 0, 'Calculating posteriors...' );

for i = 1 : Nf
    thisFTrue = fTrue(i);
    for j = 1 : Nsigma
        thisSigmaNoise = sigmaNoise(j);
        parfor k = 1 : Nsamples            
            posteriorStats(i,j,:,k) = PosteriorF( squeeze( observedDataSamples(i,j,k,:) ), thisFTrue, thisSigmaNoise );
        end
        waitbar( ((i-1)*Nsigma+j) / (Nf*Nsigma), posteriorWaitbar );
    end
end

delete( posteriorWaitbar );

%%

sigmaMaxL = nan( Nf, Nsigma );

sigmaPosterior = real( posteriorStats(:,:,2,1) );


for i = 1 : Nf
    for j = 1 : Nsigma
        sigmaMaxL(i,j) = std( squeeze( posteriorStats(i,j,1,:) ) );
    end
end

figure, subplot( 1, 2, 1 )

loglog( ...
    sigmaNoise, sigmaPosterior, '-o', ...
    sigmaNoise, sigmaMaxL, '-d', ...
    sigmaNoise, sigmaFreqs, '-^', ...
    'LineWidth', 3 ...
    );
legend( 'Posterior', 'Max Likelihood', 'MUSIC', ...
    'Location', 'NorthWest' )
legend( 'boxoff' )
title( 'Uncertainty of frequency inversion' )
xlabel( '\sigma_{noise}' )
xlim( minmax( sigmaNoise ) )
ylabel( '\sigma(f)' )
grid on

subplot( 1, 2, 2 )

semilogx( ...
    sigmaNoise, sigmaPosterior./sigmaFreqs, '-o',  ...
    sigmaNoise, sigmaMaxL./sigmaFreqs, '-d', ...
    'LineWidth', 3 ...
    );
grid on
legend( 'Posterior/MUSIC', 'Max Likelihood/MUSIC', ...
    'Location', 'NorthWest');
legend( 'boxoff' )
title( 'Improvement in frequency inversion' );
xlabel( '\sigma_{noise}' )
xlim( minmax( sigmaNoise ) )
ylabel( '\sigma(f)/\sigma_{MUSIC}(f)' )

