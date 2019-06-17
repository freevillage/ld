close all
warning('off','all');


%% Locating source from a moving platform using MUSIC
%
% Source description
%
sourcePosition = ToColumn( [ 0, 0, 0 ] );
freqMin = 300 * 10^6; % minimum possible frequency
freqMax = 300 * 10^6; % maximum possible frequency
totalSources = 1; % number of monochromatic components in a source
c = LightSpeed;
freqSource = sort( RandomUniform( freqMin, freqMax, [1 totalSources] ) ); % source frequencies
phaseSource = RandomUniform( 0, 2*pi, [1 totalSources] ); % source phases
freqCentral = mean( freqSource );
amplitudeSource = ones( [1 totalSources] ); % amplitudes
%%
%
% Array geometry
%
arrayLengthX = 1;
arrayLengthY = 1;
totalAntennasX = 41;
totalAntennasY = 43;
arraySpacingX = arrayLengthX/(totalAntennasX-1);
arraySpacingY = arrayLengthY/(totalAntennasY-1);

%%
%
% Description of platform motion
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

fastSamplingPeriod = 1e-9;
fastRecordingTime = 1e-8;
fastDelay = 0 : fastSamplingPeriod : fastRecordingTime;
totalFastTimes = length( fastDelay );

fastTime = repmat( ToColumn( slowTime ), [1 totalFastTimes] ) ...
    + repmat( ToRow( fastDelay ), [totalSlowTimes 1] );

arrayPosition = nan( 3, totalSlowTimes, totalFastTimes );
alpha = nan( totalSlowTimes, totalFastTimes );
beta = nan( totalSlowTimes, totalFastTimes );
gamma = nan( totalSlowTimes, totalFastTimes );
receiverPosition = nan( totalSlowTimes, totalFastTimes, 3, totalAntennasX, totalAntennasY );

parfor iSlow = 1 : totalSlowTimes
    for jFast = 1 : totalFastTimes
        arrayPosition(:,iSlow,jFast) = GetArrayPosition( fastTime(iSlow,jFast) );
        alpha(iSlow,jFast) = GetRotationAboutX( fastTime(iSlow,jFast) );
        beta(iSlow,jFast) = GetRotationAboutY( fastTime(iSlow,jFast) );
        gamma(iSlow,jFast) = GetRotationAboutY( fastTime(iSlow,jFast) );
        
        receiverPosition(iSlow,jFast,:,:,:) = UniformRectangularArray( ...
            [arrayLengthX arrayLengthY], ...
            [totalAntennasX totalAntennasY], ...
            arrayPosition(:,iSlow,jFast), ...
            [alpha(iSlow,jFast), beta(iSlow,jFast), gamma(iSlow,jFast)] );
    end
end

%%
%
% Display geometry
%
figure
hold on
plot3( sourcePosition(1), sourcePosition(2), sourcePosition(3), ...
    'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 15 )
plot3( arrayPosition(1,:,1), arrayPosition(2,:,1), arrayPosition(3,:,1), ...
    'g-' )
plot3( arrayPosition(1,1,1), arrayPosition(2,1,1), arrayPosition(3,1,1), ...
    'go', 'MarkerFaceColor', 'g' )
plot3( arrayPosition(1,end,1), arrayPosition(2,end,1), arrayPosition(3,end,1), ...
    'go', 'MarkerFaceColor', 'r' )
view( [-13 30] )
legend( 'Source location', 'Platform path', 'Starting point', 'End point' )
grid on
xlabel( 'x' ), ylabel( 'y' ), zlabel( 'z' ), title( 'Experiment geometry' )


%%
%
% True angles
%
anglesTrue = nan( 2, totalSlowTimes, totalFastTimes );
for iSlow = 1 : totalSlowTimes
    for jFast = 1 : totalFastTimes
        thisArrayPosition = ToColumn( arrayPosition(:,iSlow,jFast) );
        
        rotationMatrix = RotationMatrix( alpha(iSlow,jFast), beta(iSlow,jFast), gamma(iSlow,jFast) );
        xRotated = rotationMatrix * [1;0;0];
        yRotated = rotationMatrix * [0;1;0];
        
        anglesTrue(1,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, xRotated );
        anglesTrue(2,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, yRotated );
    end
end


%%
%
% Simulating recorded data
%
cleanData = nan( totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );

progressBarGenerateData = waitbar( 0, 'Simulating recorded data...' );

% Generating recorded data for each antenna in the array
for kSlow = 1 : totalSlowTimes
    for lFast = 1 : totalFastTimes
        for ix = 1 : totalAntennasX
            for jy = 1 : totalAntennasY
                thisReceiverPosition = ToColumn( squeeze( receiverPosition( kSlow, lFast, :, ix, jy ) ) );
                sourceReceiverDistance = sqrt( sum( (sourcePosition - thisReceiverPosition).^2 ) );
                cleanData(kSlow,lFast, ix,jy) = RecordedDataTime( ...
                    fastTime(kSlow,lFast), ...
                    sourceReceiverDistance, ...
                    amplitudeSource, ...
                    freqSource, ...
                    phaseSource );
            end
        end
    end
    
    waitbar( kSlow/totalSlowTimes, progressBarGenerateData );
end

delete( progressBarGenerateData );

%%
%
% Estimating directions of arrival using different methods
%
FastTimeGather = @(data,iSlowTime) shiftdim( squeeze( data(iSlowTime,:,:,:) ), 1 );

methodDescriptions = { ...
    { 'Method', 'CorrelationSinglePhase' }, ...
    { 'Method', 'Prony' }, ...
    { 'Method', 'TotalLeastSquaresProny' }, ...
    { 'Method', 'MatrixPencil' }, ...
    { 'Method', 'RootMusic' }, ...
    { 'Method', 'Music', 'FrequencySensitivity', 1e-4, 'TotalRefinements', 4, 'RefinementFactor', 10 }, ...
    { 'Method', 'Esprit' }
    };

%methodDescriptions = methodDescriptions(1:2);

totalMethods = length( methodDescriptions );

methodNames = GetMethodNamesFromDescriptions( methodDescriptions );

noiseSnrMin = 1; %dB
noiseSnrMax = 100; %dB
totalSnrs = 10;
noiseSnr = linspace( noiseSnrMin, noiseSnrMax, totalSnrs );

anglesEstimated = nan( 2, totalSlowTimes, totalMethods, totalSnrs );

areRecordedDataNoisy = true;

progressBarSnr = waitbar( 0, 'Processing SNRs...' );
progressBarMethods = waitbar( 0, 'Estimating DOAs... ' );
progressBarTimes = waitbar( 0, 'Processing slow times...' );

for mSnr = 1 : totalSnrs
    
    recordedData = nan( size( cleanData ) );
    
    if areRecordedDataNoisy
        for kSlow = 1 : totalSlowTimes
            recordedData(kSlow,:,:,:) = AddWhiteGaussianNoise( cleanData(kSlow,:,:,:), noiseSnr(mSnr), 'measured' );
        end
    end
    
    for iMethod = 1 : totalMethods
        thisMethod = methodDescriptions{iMethod};
        thisMethodName = methodNames{iMethod};
        waitbar( (iMethod-1)/totalMethods, progressBarMethods, sprintf( 'Estimating DOAs using %s', thisMethodName ) );
        
        for kSlow = 1 : totalSlowTimes
            anglesEstimated(:,kSlow,iMethod,mSnr) = DirectionsOfArrivalUra( ...
                FastTimeGather( recordedData, kSlow ), ...
                freqCentral, ...
                [arraySpacingX arraySpacingY], ...
                'TotalFrequencies', totalSources, ...
                thisMethod{:} );
            
            waitbar( kSlow/totalSlowTimes, progressBarTimes );
        end
        
        
    end
    
    waitbar( mSnr/totalSnrs, progressBarSnr );
    
end

delete( progressBarMethods );
delete( progressBarTimes );
delete( progressBarSnr );


% %%
%
% sourcePositionEstimated = nan( 3, totalMethods );
%
% for iMethod = 1 : totalMethods
%
%     thisMethod = methodDescriptions{iMethod};
%     thisMethodName = thisMethod{2};
%
%     figure( 'Name', thisMethodName );
%     estimatedLegend = sprintf( 'Estimated with %s', thisMethodName );
%     estimationErrorTitle = sprintf( '%s estimation error', thisMethodName );
%
%     subplot( 2, 2, 1 )
%     plotAngles1 = plot( slowTime, radtodeg( anglesTrue(1,:,1) ), '--', ...
%         slowTime, radtodeg( anglesEstimated(1,:,iMethod) ) );
%     plotAngles1(1).LineWidth = 3;
%     xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
%     title( 'Direction of arrival' )
%     legend( 'True', estimatedLegend, 'Location', 'SouthOutside' )
%
%     subplot( 2, 2, 2 )
%     plotAngles2 = plot( slowTime, radtodeg( anglesTrue(2,:,1) ), '--', ...
%         slowTime, radtodeg( anglesEstimated(2,:,iMethod) ) );
%     plotAngles2(1).LineWidth = 3;
%     xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
%     title( 'Direction of arrival' )
%     legend( 'True', estimatedLegend, 'Location', 'SouthOutside' )
%
%     subplot( 2, 2, 3 )
%     plot( slowTime, radtodeg( minus( anglesTrue(1,:,1), anglesEstimated(1,:,iMethod) ) ) )
%     xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
%     title( estimationErrorTitle )
%
%     subplot( 2, 2, 4 )
%     plot( slowTime, radtodeg( minus( anglesTrue(2,:,1), anglesEstimated(2,:,iMethod) ) ) )
%     xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
%     title( estimationErrorTitle )
%
%     sourcePositionEstimated(:,iMethod) = Doa2Pos( ...
%         arrayPosition(:,:,1), ...
%         alpha(:,1), beta(:,1), gamma(:,1), ...
%         anglesEstimated(1,:,iMethod), anglesEstimated(2,:,iMethod) );
%
% end % of for iMethod

%% Locaiton using estimated angles

sourcePositionEstimated = nan( 3, totalMethods, totalSnrs );

for mSnr = 1 : totalSnrs
    for iMethod = 1 : totalMethods
        sourcePositionEstimated(:,iMethod,mSnr) = Doa2Pos( ...
            arrayPosition(:,:,1), ...
            alpha(:,1), beta(:,1), gamma(:,1), ...
            anglesEstimated(1,:,iMethod,mSnr), anglesEstimated(2,:,iMethod,mSnr) );
    end
end

sourcePositionMatrix = repmat( sourcePosition, 1, totalMethods, totalSnrs );
sourcePositionEstimationMismatch = sourcePositionEstimated - sourcePositionMatrix;

sourcePositionMismatchX = abs(squeeze( sourcePositionEstimationMismatch(1,:,:) ));
sourcePositionMismatchY = abs(squeeze( sourcePositionEstimationMismatch(2,:,:) ));
sourcePositionMismatchZ = abs(squeeze( sourcePositionEstimationMismatch(3,:,:) ));
sourcePositionMismatchRms = sqrt(squeeze(sum(sourcePositionEstimationMismatch .^ 2)));

figure

subplot( 2, 2, 1 )
loglog( 10.^(noiseSnr/20), sourcePositionMismatchX', '.-', 'MarkerSize', 20 );
set( gca, ...
    'XTick', logspace( 0, 5, 6 ), ...
    'YTick', logspace( -3, 2, 6 ) );
grid on
ylim( [0 100] );
xlabel( 'SNR')
ylabel( 'Error [m]' )
title( 'Error in X' )
legend( methodNames{:} )

subplot( 2, 2, 2 )
loglog( 10.^(noiseSnr/20), sourcePositionMismatchY', '.-', 'MarkerSize', 20 );
set( gca, ...
    'XTick', logspace( 0, 5, 6 ), ...
    'YTick', logspace( -3, 2, 6 ) );
grid on
ylim( [0 100] );
xlabel( 'SNR')
ylabel( 'Error [m]' )
title( 'Error in Y' )

subplot( 2, 2, 3 )
loglog( 10.^(noiseSnr/20), sourcePositionMismatchZ', '.-', 'MarkerSize', 20 );
set( gca, ...
    'XTick', logspace( 0, 5, 6 ), ...
    'YTick', logspace( -3, 2, 6 ) );
grid on
ylim( [0 100] );
xlabel( 'SNR')
ylabel( 'Error [m]' )
title( 'Error in Z' )

subplot( 2, 2, 4 )
loglog( 10.^(noiseSnr/20), sourcePositionMismatchRms', '.-', 'MarkerSize', 20 );
set( gca, ...
    'XTick', logspace( 0, 5, 6 ), ...
    'YTick', logspace( -3, 2, 6 ) );
grid on
ylim( [0 100] );
xlabel( 'SNR')
ylabel( 'Error [m]' )
title( 'Total error' )

suptitle( 'Source Position Estimation Errors' )

%%

save test_doa_methods_snrs



