%% Estimating velocity relative to a tower
%
%%

%% Source description
%
DisplayFigures( true )

sourcePosition = ToColumn( [ 0, 0, 0 ] );
freqMin = 300 * 10^6; % minimum possible frequency
freqMax = 300 * 10^6; % maximum possible frequency
totalSources = 1; % number of monochromatic components in a source
c = LightSpeed;
freqSource = sort( RandomUniform( freqMin, freqMax, [1 totalSources] ) ); % source frequencies
phaseSource = RandomUniform( 0, 2*pi, [1 totalSources] ); % source phases
freqCentral = mean( freqSource );
amplitudeSource = ones( [1 totalSources] ); % amplitudes
%% Array geometry
%
arrayLengthX = 1;
arrayLengthY = 1;
totalAntennasX = 3;
totalAntennasY = 3;
arraySpacingX = arrayLengthX/(totalAntennasX-1);
arraySpacingY = arrayLengthY/(totalAntennasY-1);

%% Description of platform motion
%
initialArrayPosition = [-400; 0; 3000];
arraySpeed = 40;

GetArrayPosition = @(t) initialArrayPosition + arraySpeed * [ t; cos(t); sin(t) ] / sqrt(2);
GetRotationAboutX = @(t) cos(t);
GetRotationAboutY = @(t) sin(t);
GetRotationAboutZ = @(t) cos(4*t);

slowTimeBeg = 0;
slowTimeEnd = 20;
slowSamplingPeriod = 1;
slowTime = slowTimeBeg : slowSamplingPeriod : slowTimeEnd;
totalSlowTimes = length( slowTime );

fastSamplingPeriod = 1/8/freqCentral;
fastSamplingFrequency = 1 / fastSamplingPeriod;
fastRecordingTime = 100000 * fastSamplingPeriod;
fastDelay = 0 : fastSamplingPeriod : fastRecordingTime;
totalFastTimes = length( fastDelay );

fastTime = repmat( ToColumn( slowTime ), [1 totalFastTimes] ) ...
         + repmat( ToRow( fastDelay ), [totalSlowTimes 1] );

arrayPosition = nan( 3, totalSlowTimes, totalFastTimes );
alpha = nan( totalSlowTimes, totalFastTimes );
beta = nan( totalSlowTimes, totalFastTimes );
gamma = nan( totalSlowTimes, totalFastTimes );
receiverPosition = nan( totalSlowTimes, totalFastTimes, 3, totalAntennasX, totalAntennasY );

%buildingPathProgressBar = waitbar( 0, 'Building platform path...' );

parfor iSlow = 1 : totalSlowTimes
    for jFast = 1 : totalFastTimes
        arrayPosition(:,iSlow,jFast) = GetArrayPosition( fastTime(iSlow,jFast) );
        alpha(iSlow,jFast) = GetRotationAboutX( fastTime(iSlow,jFast) );
        beta(iSlow,jFast)  = GetRotationAboutY( fastTime(iSlow,jFast) );
        gamma(iSlow,jFast) = GetRotationAboutZ( fastTime(iSlow,jFast) );
        
        receiverPosition(iSlow,jFast,:,:,:) = UniformRectangularArray( ...
            [arrayLengthX arrayLengthY], ...
            [totalAntennasX totalAntennasY], ...
            arrayPosition(:,iSlow,jFast), ...
            [alpha(iSlow,jFast), beta(iSlow,jFast), gamma(iSlow,jFast)] );
    end
    %waitbar( iSlow/totalSlowTimes, buildingPathProgressBar );
end

%delete( buildingPathProgressBar );

%% Display experiment geometry
%
figure
hold on
plot3( sourcePosition(1), sourcePosition(2), sourcePosition(3), ...
    'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 15 )
plot3( arrayPosition(1,:,1), arrayPosition(2,:,1), arrayPosition(3,:,1), ...
    'g-', 'LineWidth', 2 )
plot3( arrayPosition(1,1,1), arrayPosition(2,1,1), arrayPosition(3,1,1), ...
    'go', 'MarkerFaceColor', 'g' )
plot3( arrayPosition(1,end,1), arrayPosition(2,end,1), arrayPosition(3,end,1), ...
    'go', 'MarkerFaceColor', 'r' )
view( [-13 30] )
legend( 'Source location', 'Platform path', 'Starting point', 'End point', ...
    'Location', 'SouthOutside', ...
    'Orientation', 'Horizontal' )
grid on
xlabel( 'x' ), ylabel( 'y' ), zlabel( 'z' ), title( 'Experiment geometry' )

%% Calculating antenna true velocities
%
receiverPositionSlow = squeeze( receiverPosition( :,1,:,:,: ) );
velocityReceiver = nan( size( receiverPositionSlow ) );
velocityTowardsTower = nan( size( receiverPositionSlow ) );
signSpeedTrue = nan( totalSlowTimes, totalAntennasX, totalAntennasY );

for jy = 1 : totalAntennasY
    for ix = 1 : totalAntennasX
        for mDim = 1 : 3
            for kSlow = 1 : totalSlowTimes
                velocityReceiver(kSlow,mDim,ix,jy) = mean( squeeze( gradient( receiverPosition(kSlow,:,mDim,ix,jy), fastSamplingPeriod ) ) );
            end
        end
    end
end

sourcePositionMatrix = repmat( ToRow( sourcePosition ), [totalSlowTimes, 1, totalAntennasX, totalAntennasY] );

% Calculate unit vectors towards known tower location for all antennas
% at all times
directionTowardsTower =  sourcePositionMatrix - receiverPositionSlow;

for kSlow = 1 : totalSlowTimes
    for ix = 1 : totalAntennasX
        for jy = 1 : totalAntennasY
            unitDirection = NormalizeVector( squeeze( directionTowardsTower(kSlow,:,ix,jy) ) );
            velocity = squeeze( velocityReceiver(kSlow,:,ix,jy) );
            
            radialVelocityAmplitude = dot( velocity, unitDirection );
            velocityTowardsTower(kSlow,:,ix,jy) = radialVelocityAmplitude * unitDirection;
            signSpeedTrue(kSlow,ix,jy) = sign( radialVelocityAmplitude );
        end
    end
end

speedTrue = sqrt( squeeze( sum( velocityTowardsTower.^2, 2 ) ) );
speedTrue = speedTrue .* signSpeedTrue;

%% Simulating recorded data
%

% Prepare clean data
cleanData = nan( totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
noisyData = nan( size( cleanData ) );

recordedDataProgressBar = waitbar( 0, 'Simulating recorded data...' );

sourcePositionFastTime = repmat( ToRow( sourcePosition ), [ totalFastTimes, 1 ] );

noiseSnrMin = 1;
noiseSnrMax = 100;
totalSnrExperiments = 15;

noiseSnr = linspace( noiseSnrMin, noiseSnrMax, totalSnrExperiments ); % dB
areRecordedDataNoisy = true;

for kSlow = 1 : totalSlowTimes
    for ix = 1 : totalAntennasX
        for jy = 1 : totalAntennasY
            
            thisReceiverPositionFastTime = squeeze( receiverPosition( kSlow, :, :, ix, jy ) );
            sourceReceiverDistanceFastTime = sqrt( sum( (sourcePositionFastTime - thisReceiverPositionFastTime).^2, 2 ) );
            cleanData(kSlow,:, ix,jy) = RecordedDataTime( ...
                fastTime(kSlow,:), ...
                sourceReceiverDistanceFastTime, ...
                amplitudeSource, ...
                freqSource, ...
                phaseSource );
            
        end
    end
    waitbar( kSlow/totalSlowTimes, recordedDataProgressBar );
end

delete( recordedDataProgressBar );


methodDescriptions = { ...
    { 'Method', 'CorrelationSinglePhase' }, ...
    { 'Method', 'Prony' }, ...
    { 'Method', 'TotalLeastSquaresProny' }, ...
    { 'Method', 'MatrixPencil' }, ...
    { 'Method', 'RootMusic' }, ...
    { 'Method', 'Music', 'FrequencySensitivity', 1e-4, 'TotalRefinements', 3, 'RefinementFactor', 100 }, ...
    { 'Method', 'Esprit' } 
    };
methodDescriptions = methodDescriptions(1);

totalMethods = length( methodDescriptions );

methodNames = cell( 1, totalMethods );
executionTimes = nan( totalMethods, 1 );

FastTimeGather = @(data,iSlowTime) shiftdim( squeeze( data(iSlowTime,:,:,:) ), 1 );

freqsEstimated = nan( totalSnrExperiments, totalMethods, totalSlowTimes, totalAntennasX, totalAntennasY, totalSources );

progressBarSnr = waitbar( 0, 'Processing different SNRs...' );

for snrExperiment = 1 : totalSnrExperiments
    
    noisyData = nan( size( cleanData ) );
    for kSlow = 1 : totalSlowTimes
        for ix = 1 : totalAntennasX
            for jy = 1 : totalAntennasY
                noisyData(kSlow,:,ix,jy) = AddWhiteGaussianNoise( ...
                    squeeze( cleanData(kSlow,:,ix,jy) ), ...
                    noiseSnr(snrExperiment), 'measured', 1 );
            end
        end
    end
        
    if areRecordedDataNoisy
        recordedData = noisyData;
    else
        recordedData = cleanData;
    end
    
    progressBarMethods = waitbar( 0, 'Estimating frequencies' );
    
    for iMethod = 1 : totalMethods
        thisMethod = methodDescriptions{iMethod};
        thisMethodName = thisMethod{2};
        methodNames{iMethod} = thisMethodName;
        
        waitbar( (iMethod-1) / totalMethods, progressBarMethods, ...
            sprintf( 'Estimating frequencies using %s', thisMethodName ) );
        
        progressBarSlowtimes = waitbar( 0, 'Processing slow times...' );
        tic
        for kSlow = 1 : totalSlowTimes
            fastTimeGather = FastTimeGather( recordedData, kSlow );
            
            freqsEstimated(snrExperiment,iMethod,kSlow,:,:,:) = DiscreteFrequencySpectrumHertzUra( fastTimeGather, ...
                fastSamplingFrequency, ...
                'TotalFrequencies', totalSources, ...
                thisMethod{:} );
            
            waitbar( kSlow / totalSlowTimes, progressBarSlowtimes );
        end
        
        executionTimes(iMethod) = toc;
        delete( progressBarSlowtimes );
        
        %waitbar( iMethod / totalMethods, progressBarMethods );
        
    end
    
    delete( progressBarMethods );
    
    waitbar( snrExperiment/totalSnrExperiments, progressBarSnr );
    
end

delete( progressBarSnr );

%% Plot estimated frequencies
%
figure

ix = 1;
jy = 1;
snrExperiment = 1;
profileTrue = transpose( freqSource * ones( size( slowTime ) ) );
profilesEstimated = squeeze( freqsEstimated(snrExperiment,:,:,ix,jy) );

subplot( 1, 2, 1 ), hold on
plot( slowTime, profileTrue/1e6, 'LineWidth', 3 )
plot( slowTime, profilesEstimated/1e6 )
%ylim( 3 * max( profileTrue ) * [-1 1] )
legends = [ { 'Still source frequency' }, methodNames ];
legend( legends, 'Location', 'SouthOutside' );
xlabel( 'Slow time [s]' );
ylabel( 'Frequency [MHz]' );
title( 'Frequency estimated from moving array' );
hold off
colorOrder = get( gca, 'ColorOrder' );

profileTrueMatrix = repmat( profileTrue, [1 totalMethods] );
subplot( 1, 2, 2 )
set(gca, 'ColorOrder', colorOrder(2:end,:), 'NextPlot', 'replacechildren');
plot( slowTime, (profilesEstimated - profileTrueMatrix) );
legend( methodNames, 'Location', 'SouthOutside' )
xlabel( 'Slow time [s]' )
ylabel( 'Frequency variations [Hz]' )
title( 'Doppler shift in the recorded signal' )

%% Converting frequencies to velocities
%
speedEstimated = nan( totalSnrExperiments, totalMethods, totalSlowTimes, totalAntennasX, totalAntennasY );

for snrExperiment = 1 : totalSnrExperiments
    for lMethod = 1 : totalMethods
        for kSlow = 1 : totalSlowTimes
            for ix = 1 : totalAntennasX
                for jy = 1 : totalAntennasY
                    speedEstimated(snrExperiment, lMethod,kSlow,ix,jy) = ...
                        VelocityFromDoppletShift( freqSource, freqsEstimated(snrExperiment,lMethod,kSlow,ix,jy) );
                end
            end
        end
    end
end

%% Showing estimation results and errors
%
ix = 1;
jy = 1;
snrExperiment = 1;
profileTrue = speedTrue(:,ix,jy);
profilesEstimated = squeeze( speedEstimated(snrExperiment,:,:,ix,jy) );
figure
subplot( 1, 2, 1 ), hold on
plot( slowTime, profileTrue, 'LineWidth', 3 )
plot( slowTime, profilesEstimated )
ylim( 3 * max( profileTrue ) * [-1 1] )
legends = [ { 'True' }, methodNames ];
legend( legends, 'Location', 'SouthOutside' );
xlabel( 'Slow time [s]' );
ylabel( 'Velocity [m/s]' );
title( 'Radial velocity towards tower' );
hold off
colorOrder = get(gca,'ColorOrder'); 

profileTrueMatrix = repmat( profileTrue, [1 totalMethods] );
velocityEstimateErrors = profilesEstimated - profileTrueMatrix;

subplot( 1, 2, 2 )
set(gca, 'ColorOrder', colorOrder(2:end,:), 'NextPlot', 'replacechildren');
plot( slowTime, velocityEstimateErrors );
legend( methodNames, 'Location', 'SouthOutside' )
xlabel( 'Slow time [s]' )
ylabel( 'Velocity error [m/s]' )
title( 'Velocity estimation error' )
velocityEstimateErrorsAve = ToColumn( ColumnNorm( velocityEstimateErrors ) );

table( velocityEstimateErrorsAve, 'RowNames', methodNames' )

%%
velocityEstimateErrorsAve = nan( totalAntennasX, totalAntennasY, totalMethods, totalSnrExperiments );
for ix = 1 : totalAntennasX
    for jy = 1 : totalAntennasY
        for lSnr = 1 : totalSnrExperiments
            profileTrue = speedTrue(:,ix,jy);
            profilesEstimated = squeeze( speedEstimated(lSnr,:,:,ix,jy) );
            profileTrueMatrix = repmat( profileTrue, [1 totalMethods] );
            velocityEstimateErrors = profilesEstimated - profileTrueMatrix;
            velocityEstimateErrorsAve(ix,jy,:,lSnr) = ToColumn( ColumnNorm( velocityEstimateErrors ) );
        end
    end
end

%%

figure

% customColormap = get(groot,'DefaultAxesColorOrder');
% set( gcf, 'DefaultAxesLineStyleOrder', {'-', '-.','-.'}, 'DefaultAxesColorOrder', customColormap(1:3,:) )


for ix = 1 : totalAntennasX
    for jy = 1 : totalAntennasY
        subplot( totalAntennasY, totalAntennasX, (jy-1) * totalAntennasX + ix )
        antennaVelocityErrorAve = squeeze( velocityEstimateErrorsAve(ix,jy,:,:)/totalSlowTimes );
        antennaPlot = loglog( 10.^(noiseSnr/20), antennaVelocityErrorAve, '.-', 'MarkerSize', 20 );
        set( gca, ...
            'XTick', logspace( 0, 5, 6 ), ...
            'YTick', logspace( -3, 0, 4 ) ), ...
        xlabel( 'SNR')
        ylabel( 'RMS error [m/s]' )
        title( sprintf( 'Antenna i=%d, j=%d', ix, jy ) )
        if( ix == 2 && jy == 3 ), legend( methodNames' ), end
        yLimits = ylim;
        yLimits(1) = 0;
        ylim( [0 1] );
        grid on
%         antennaPlot(4).LineWidth = 2;
%         antennaPlot(5).LineWidth = 2;
%         antennaPlot(6).LineWidth = 2;
    end
end

%save resolution_dump_new

