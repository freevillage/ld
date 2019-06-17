function flag = test_doa_methods_all( fastRecordingTimeInPeriods, initialAltitude, clockShift, aspectAngle, sigmaNoise, arraySpeed, arrayPerturbations )
flag = 0;

shouldUseCache = false; 
if nargin < 7, arrayPerturbations = struct( 'i', 1, 'j', 1, 'dx', 0, 'dy', 0 ); end
if nargin < 6, arraySpeed = [100000, 0]; end
if isscalar( arraySpeed ), arraySpeed = [arraySpeed 0]; end

arrayInitialSpeed = arraySpeed(1);
arrayAcceleration = arraySpeed(2);

close all 
saveDirectory = '/wavedata/poliann/mat_all_new';
isWaitbarShown = false;

if arrayAcceleration == 0
    saveFilename = sprintf( ...
        'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f_%.8f.mat', ...
        fastRecordingTimeInPeriods, initialAltitude, clockShift, aspectAngle, log10(sigmaNoise), arrayInitialSpeed, mean( arrayPerturbations.dx ) );
else
    saveFilename = sprintf( ...
        'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f-%.2f_%.8f.mat', ...
        fastRecordingTimeInPeriods, initialAltitude, clockShift, aspectAngle, log10(sigmaNoise), arrayInitialSpeed, arrayAcceleration, mean( arrayPerturbations.dx ) );
end
    
saveFilename = fullfile( saveDirectory, saveFilename );
if shouldUseCache && exist( saveFilename, 'file' ), return; end

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

% initialAltitude = 3000;
initialArrayPosition = [-400; 0; initialAltitude];
initialArrayPosition = initialAltitude * [ -1 ; 0; 1 ];
initialArrayPosition = [ -400*initialAltitude/3000 ; 0 ; initialAltitude ];

%angleRadialAxis = pi;
radialDirection = NormalizeVector( sourcePosition - initialArrayPosition );
flightDirection = RotationMatrix3D( [0, 1, 0], aspectAngle ) * radialDirection;

GetArrayPosition = @(t) initialArrayPosition + (arrayInitialSpeed+t*arrayAcceleration/2) * t * flightDirection;
GetRotationAboutX = @(t) 0 * cos(t);
GetRotationAboutY = @(t) 0 * sin(t);
GetRotationAboutZ = @(t) 0 * cos(4*t);

slowTimeBeg = 0;
slowTimeEnd = 0.0001;
slowSamplingPeriod = 0.001;
slowTime = slowTimeBeg : slowSamplingPeriod : slowTimeEnd;
totalSlowTimes = length( slowTime );

fastSamplingPeriod = 1e-9;
%fastRecordingTimeInPeriods = 20000;
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
        gamma(iSlow,jFast) = GetRotationAboutZ( fastTime(iSlow,jFast) );
        
        receiverPosition(iSlow,jFast,:,:,:) = PerturbedUniformRectangularArray( ...
            [arrayLengthX arrayLengthY], ...
            [totalAntennasX totalAntennasY], ...
            arrayPosition(:,iSlow,jFast), ...
            [alpha(iSlow,jFast), beta(iSlow,jFast), gamma(iSlow,jFast)], ...
            arrayPerturbations.i, arrayPerturbations.j, arrayPerturbations.dx, arrayPerturbations.dy );
    end
end

%%
%
% Display geometry
%
% figure( 'Visible', 'off' );
% hold on
% plot3( sourcePosition(1), sourcePosition(2), sourcePosition(3), ...
%     'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 15 )
% plot3( arrayPosition(1,:,1), arrayPosition(2,:,1), arrayPosition(3,:,1), ...
%     'g-' )
% plot3( arrayPosition(1,1,1), arrayPosition(2,1,1), arrayPosition(3,1,1), ...
%     'go', 'MarkerFaceColor', 'g' )
% plot3( arrayPosition(1,end,1), arrayPosition(2,end,1), arrayPosition(3,end,1), ...
%     'go', 'MarkerFaceColor', 'r' )
% view( [-13 30] )
% legend( 'Source location', 'Platform path', 'Starting point', 'End point' )
% grid on
% xlabel( 'x' ), ylabel( 'y' ), zlabel( 'z' ), title( 'Experiment geometry' )
% axis equal



%%
%
% True angles
%
anglesTrue = nan( 2, totalSlowTimes, totalFastTimes );
anglesTrueShifted = nan( 2, totalSlowTimes, totalFastTimes );

for iSlow = 1 : totalSlowTimes
    for jFast = 1 : totalFastTimes
        thisArrayPosition = ToColumn( arrayPosition(:,iSlow,jFast) );
        thisArrayPositionShifted = thisArrayPosition + [ 0 ; 1 ; 0 ];
        
        rotationMatrix = RotationMatrix( alpha(iSlow,jFast), beta(iSlow,jFast), gamma(iSlow,jFast) );
        xRotated = rotationMatrix * [1;0;0];
        yRotated = rotationMatrix * [0;1;0];
        
        anglesTrue(1,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, xRotated );
        anglesTrue(2,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, yRotated );
        
        anglesTrueShifted(1,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPositionShifted, xRotated );
        anglesTrueShifted(2,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPositionShifted, yRotated );
    end
end

% save anglesTrue anglesTrue
% save anglesTrueShifted anglesTrueShifted
% save arrayPosition arrayPosition
% save receiverPosition receiverPosition

%%
%
% Simulating recorded data
%
recordedData = nan( totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
cleanData = recordedData;
dataSNR = nan( totalSlowTimes, 1 );
% sigmaNoise = nan( totalSlowTimes, 1 );
%snr = 10; % dB
% sigmaNoise = 1e-11;
areRecordedDataNoisy = true;

if isWaitbarShown, progressBar = waitbar( 0, 'Simulating recorded data...' ); end

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
    
    %cleanData = initialAltitude/3000 * cleanData;
    
    rng(1000+kSlow);
    
    if areRecordedDataNoisy
        %recordedData(kSlow,:,:,:) = AddWhiteGaussianNoise( cleanData(kSlow,:,:,:), snr, 'measured' );
        dataNoise = sigmaNoise * ( randn( size( cleanData(kSlow,:,:,:) ) ) +1i*randn( size( cleanData(kSlow,:,:,:) ) ) );
        dataSNR(kSlow) = snr( real( ToColumn( cleanData(kSlow,:,:,:) ) ), real( ToColumn( dataNoise ) ) );
        recordedData(kSlow,:,:,:) = cleanData(kSlow,:,:,:) + dataNoise;
        %sigmaNoise(kSlow) = std( ToColumn( real( recordedData(kSlow,:,:,:) - cleanData(kSlow,:,:,:) ) ) );
    end
    
    if isWaitbarShown, waitbar( kSlow/totalSlowTimes, progressBar ); end
end

dataSNR = mean( dataSNR );

if isWaitbarShown, delete( progressBar ); end

%%
%
% Estimating directions of arrival using different methods
%
FastTimeGather = @(data,iSlowTime) shiftdim( squeeze( data(iSlowTime,:,:,:) ), 1 );

methodDescriptions = { ...
...%    { 'Method', 'CorrelationSinglePhase' }, ...
... %    { 'Method', 'Prony' }, ...
    { 'Method', 'TotalLeastSquaresProny' }, ...
... %    { 'Method', 'MatrixPencil' }, ...
    { 'Method', 'RootMusic' } ...
... %     { 'Method', 'Music', 'FrequencySensitivity', 1e-4, 'TotalRefinements', 4, 'RefinementFactor', 10 }, ...
...%    { 'Method', 'Esprit' } ...
%     { 'Method', 'LeastSquaresSinglePhase' }
    };

% methodDescriptions = methodDescriptions{ 1 };

totalMethods = length( methodDescriptions );
if totalMethods == 1, methodDescriptions = {methodDescriptions}; end

anglesEstimated = nan( 2, totalSlowTimes, totalMethods );

if isWaitbarShown, progressBarMethods = waitbar( 0, 'Estimating DOAs... ' ); end

for iMethod = 1 : totalMethods
    thisMethod = methodDescriptions{iMethod};
%     thisMethodName = thisMethod{2};
    if isWaitbarShown, waitbar( iMethod/totalMethods, progressBarMethods, sprintf( 'Estimating DOAs using %s', thisMethodName ) ); end
    
    if isWaitbarShown, progressBarTimes = waitbar( 0, 'Processing slow times...' ); end
    
    for kSlow = 1 : totalSlowTimes
        anglesEstimated(:,kSlow,iMethod) = DirectionsOfArrivalUraSingleRowCol( ...
            FastTimeGather( recordedData, kSlow ), ...
            freqCentral + clockShift, ...
            [arraySpacingX arraySpacingY], ...
            'TotalFrequencies', totalSources, ...
            'NoiseStandardDeviation', sigmaNoise, ...
            thisMethod{:} );
        
        if isWaitbarShown, waitbar( kSlow/totalSlowTimes, progressBarTimes ); end
    end
    
    if isWaitbarShown, delete( progressBarTimes ); end
    
end

if isWaitbarShown, delete( progressBarMethods ); end

%%

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
% end % of for iMethod


save( saveFilename, '-regexp', '^(?!(cleanData|recordedData)$).', '-v7.3' );


end
