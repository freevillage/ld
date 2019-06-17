% $y_n = \sum\limits_{k=1}^K c_k z_k^n + \sigma_n w_n, \quad z_k=e^{-i\pi \theta_k},\quad w_n \sim N(0,1), \quad n\in \{0,\ldots,N-1\}$
totalAntennas = 101;
nAntenna = (0:totalAntennas-1)';

sourceFrequency = [ 300, 300, 300 ] * 10^6; %Hz
centralFrequency = mean( sourceFrequency );
directionTrue = degtorad( [ 20 ] );
totalDirections = length( directionTrue );
sourcePhase = RandomUniform( 0, 2*pi, [1 totalDirections] );
sourceAmplitude = RandomUniform( 0, 1, [1 totalDirections] );
c = LightSpeed;
arraySpacing = c / ( 2*max(sourceFrequency) );
totalSnapshots = 1000;
samplingFrequency = 20*max(sourceFrequency);
time0 = 0;
time = time0 + (1/samplingFrequency) * (0:totalSnapshots-1);

recordedData = nan( totalDirections, totalAntennas, totalSnapshots );

for kDirection = 1 : totalDirections
    for nAntenna = 0 : totalAntennas-1
        for jSnapshot = 1 : totalSnapshots
            recordedData(kDirection,nAntenna+1,jSnapshot) = sourceAmplitude(kDirection) ...
                * exp( 2*pi*1i * sourceFrequency(kDirection) * time(jSnapshot) ) ...
                * exp( 1i * sourcePhase(kDirection) ) ...
                * exp( 2*pi*1i* sourceFrequency(kDirection) * nAntenna * arraySpacing * sin( directionTrue(kDirection) ) / c );
        end
    end
end

recordedData = squeeze( sum( recordedData ) ); % add sources contributions


% show results for angles
totalF0Guess = 100;
radtodeg( directionTrue )


w_hat1 = radtodeg( EspritDoa( recordedData, totalDirections, centralFrequency, arraySpacing ) )
w_hat2 = radtodeg( MusicDoa ( recordedData, totalDirections, centralFrequency, arraySpacing ) )



