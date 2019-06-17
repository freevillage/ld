close all 

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
totalAntennasX = 11;
totalAntennasY = 13;
arraySpacingX = arrayLengthX/(totalAntennasX-1);
arraySpacingY = arrayLengthY/(totalAntennasY-1);

%%
%
% Description of platform motion
%
initialArrayPosition = [-400; 0; 3000];
arraySpeed = 40;


GetArrayPosition = @(t) initialArrayPosition + arraySpeed * [ t; cos(t); sin(t) ] /sqrt(2);
GetRotationAboutX = @(t) cos(t);
GetRotationAboutY = @(t) sin(t);
GetRotationAboutZ = @(t) cos(4*t);

slowTimeBeg = 0;
slowTimeEnd = 20;
slowSamplingPeriod = 0.2;
slowTime = slowTimeBeg : slowSamplingPeriod : slowTimeEnd;
totalSlowTimes = length( slowTime );

fastSamplingPeriod = 1e-9;
fastRecordingTimeInPeriods = 20000;
fastRecordingTime = fastRecordingTimeInPeriods * fastSamplingPeriod;
fastDelay = 0 : fastSamplingPeriod : fastRecordingTime;
totalFastTimes = length( fastDelay );

fastTime = repmat( ToColumn( slowTime ), [1 totalFastTimes] ) ...
         + repmat( ToRow( fastDelay ), [totalSlowTimes 1] );

arrayPosition = nan( 3, totalSlowTimes, totalFastTimes );
alpha = nan( totalSlowTimes, totalFastTimes );
beta = nan( totalSlowTimes, totalFastTimes );
gamma = nan( totalSlowTimes, totalFastTimes );
receiverPosition = nan( totalSlowTimes, totalFastTimes, 3, totalAntennasX, totalAntennasY );

for iSlow = 1 : totalSlowTimes
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
recordedData = nan( totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
cleanData = recordedData;
sigmaNoise = nan( totalSlowTimes, 1 );
%snr = 10; % dB
sigmaNoise = 1e-9;
areRecordedDataNoisy = true;

progressBar = waitbar( 0, 'Simulating recorded data...' );

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
    
    if areRecordedDataNoisy
        %recordedData(kSlow,:,:,:) = AddWhiteGaussianNoise( cleanData(kSlow,:,:,:), snr, 'measured' );
        recordedData(kSlow,:,:,:) = cleanData(kSlow,:,:,:) ...
            + sigmaNoise * randn( size( cleanData(kSlow,:,:,:) ) );
        %sigmaNoise(kSlow) = std( ToColumn( real( recordedData(kSlow,:,:,:) - cleanData(kSlow,:,:,:) ) ) );
    end
    
    waitbar( kSlow/totalSlowTimes, progressBar );
end

delete( progressBar );

%%
%
% Estimating directions of arrival using different methods
%
FastTimeGather = @(data,iSlowTime) shiftdim( squeeze( data(iSlowTime,:,:,:) ), 1 );

methodDescriptions = { ...
%    { 'Method', 'CorrelationSinglePhase' }, ...
    { 'Method', 'Prony' }, ...
    { 'Method', 'TotalLeastSquaresProny' }, ...
... %     { 'Method', 'MatrixPencil' }, ...
    { 'Method', 'RootMusic' }, ...
... %     { 'Method', 'Music', 'FrequencySensitivity', 1e-4, 'TotalRefinements', 4, 'RefinementFactor', 10 }, ...
    { 'Method', 'Esprit' } ...
%     { 'Method', 'LeastSquaresSinglePhase' }
    };

%methodDescriptions = methodDescriptions( [2 8] );

totalMethods = length( methodDescriptions );
if totalMethods == 1, methodDescriptions = {methodDescriptions}; end

anglesEstimated = nan( 2, totalSlowTimes, totalMethods );

progressBarMethods = waitbar( 0, 'Estimating DOAs... ' );

for iMethod = 1 : totalMethods
    thisMethod = methodDescriptions{iMethod};
    thisMethodName = thisMethod{2};
    waitbar( iMethod/totalMethods, progressBarMethods, sprintf( 'Estimating DOAs using %s', thisMethodName ) );
    
    progressBarTimes = waitbar( 0, 'Processing slow times...' );
    
    for kSlow = 1 : totalSlowTimes
        anglesEstimated(:,kSlow,iMethod) = DirectionsOfArrivalUra( ...
            FastTimeGather( recordedData, kSlow ), ...
            freqCentral, ...
            [arraySpacingX arraySpacingY], ...
            'TotalFrequencies', totalSources, ...
            'NoiseStandardDeviation', sigmaNoise, ...
            thisMethod{:} );
        
        waitbar( kSlow/totalSlowTimes, progressBarTimes );
    end
    
    delete( progressBarTimes );
    
end

delete( progressBarMethods );

%%

for iMethod = 1 : totalMethods
    
    thisMethod = methodDescriptions{iMethod};
    thisMethodName = thisMethod{2};
    
    figure( 'Name', thisMethodName );
    estimatedLegend = sprintf( 'Estimated with %s', thisMethodName );
    estimationErrorTitle = sprintf( '%s estimation error', thisMethodName );  
    
    subplot( 2, 2, 1 )
    plotAngles1 = plot( slowTime, radtodeg( anglesTrue(1,:,1) ), '--', ...
        slowTime, radtodeg( anglesEstimated(1,:,iMethod) ) );
    plotAngles1(1).LineWidth = 3;
    xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
    title( 'Direction of arrival' )
    legend( 'True', estimatedLegend, 'Location', 'SouthOutside' )
    
    subplot( 2, 2, 2 )
    plotAngles2 = plot( slowTime, radtodeg( anglesTrue(2,:,1) ), '--', ...
        slowTime, radtodeg( anglesEstimated(2,:,iMethod) ) );
    plotAngles2(1).LineWidth = 3;   
    xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
    title( 'Direction of arrival' )
    legend( 'True', estimatedLegend, 'Location', 'SouthOutside' )
    
    subplot( 2, 2, 3 )
    plot( slowTime, radtodeg( minus( anglesTrue(1,:,1), anglesEstimated(1,:,iMethod) ) ) )
    xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
    title( estimationErrorTitle )
    
    subplot( 2, 2, 4 )
    plot( slowTime, radtodeg( minus( anglesTrue(2,:,1), anglesEstimated(2,:,iMethod) ) ) )
    xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
    title( estimationErrorTitle )
    
end % of for iMethod

saveFilename = sprintf( 'test_doa_results_%.0f.mat', fastRecordingTimeInPeriods );

save( saveFilename );
