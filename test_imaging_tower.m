close all force

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
initialArrayPosition = [-400; 0; 2000];
arraySpeed = 40;

GetArrayPosition = @(t) initialArrayPosition + arraySpeed * [ t; sin(t); t ];
GetRotationAboutX = @(t) 0.1 * cos(t);
GetRotationAboutY = @(t) -0.1 * sin(2*t);
GetRotationAboutZ = @(t) 0;

slowTimeBeg = 0;
slowTimeEnd = 20;
slowSamplingPeriod = 0.1;
slowTime = slowTimeBeg : slowSamplingPeriod : slowTimeEnd;
totalSlowTimes = length( slowTime );

fastSamplingPeriod = 1e-9;
fastRecordingTime = 2e-9;
fastDelay = 0 : fastSamplingPeriod : fastRecordingTime;
totalFastTimes = length( fastDelay );

fastTime = repmat( ToColumn( slowTime ), [1 totalFastTimes] ) ...
    + repmat( ToRow( fastDelay ), [totalSlowTimes 1] );

arrayPosition = nan( 3, totalSlowTimes, totalFastTimes );
alpha = nan( totalSlowTimes, totalFastTimes );
beta  = nan( totalSlowTimes, totalFastTimes );
gamma = nan( totalSlowTimes, totalFastTimes );
receiverPosition = nan( totalSlowTimes, totalFastTimes, 3, totalAntennasX, totalAntennasY );

for is = 1 : totalSlowTimes
    for jf = 1 : totalFastTimes
        arrayPosition(:,is,jf) = GetArrayPosition( fastTime(is,jf) );
        alpha(is,jf) = GetRotationAboutX( fastTime(is,jf) );
        beta(is,jf)  = GetRotationAboutY( fastTime(is,jf) );
        gamma(is,jf) = GetRotationAboutZ( fastTime(is,jf) );
        
        receiverPosition(is,jf,:,:,:) = UniformRectangularArray( ...
            [arrayLengthX arrayLengthY], ...
            [totalAntennasX totalAntennasY], ...
            arrayPosition(:,is,jf), ...
            [alpha(is,jf), beta(is,jf), gamma(is,jf)] );
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
for is = 1 : totalSlowTimes
    for jf = 1 : totalFastTimes
        thisArrayPosition = ToColumn( arrayPosition(:,is,jf) );
        
        rotationMatrix = RotationMatrix( alpha(is,jf), beta(is,jf), gamma(is,jf) );
        xRotated = rotationMatrix * [1;0;0];
        yRotated = rotationMatrix * [0;1;0];
        
        anglesTrue(1,is,jf) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, xRotated );
        anglesTrue(2,is,jf) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, yRotated );
    end
end


%%
%
% Simulating recorded data
%
cleanData = nan( totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
progressBar = waitbar( 0, 'Simulating recorded data...' );

% Generating recorded data for each antenna in the array
for ks = 1 : totalSlowTimes
    parfor lt = 1 : totalFastTimes
        for ix = 1 : totalAntennasX
            for jy = 1 : totalAntennasY
                thisReceiverPosition = ToColumn( squeeze( receiverPosition( ks, lt, :, ix, jy ) ) );
                sourceReceiverDistance = sqrt( sum( (sourcePosition - thisReceiverPosition).^2 ) );
                cleanData(ks,lt, ix,jy) = RecordedDataTime( ...
                    fastTime(ks,lt), ...
                    sourceReceiverDistance, ...
                    amplitudeSource, ...
                    freqSource, ...
                    phaseSource );
            end
        end
    end
    
    waitbar( ks/totalSlowTimes, progressBar );
end
delete( progressBar );

snrMin = 10;
snrMax = 100;
totalSnrs = 10;
noiseSnr = linspace( snrMin, snrMax, totalSnrs );
areRecordedDataNoisy = true;

noisyData = nan( totalSnrs, totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
for lSnr = 1 : totalSnrs
    for ks = 1 : totalSlowTimes
        noisyData(lSnr,ks,:,:,:) = AddWhiteGaussianNoise( cleanData(ks,:,:,:), ...
            noiseSnr(lSnr), 'measured', 1 );
    end
end


%%
%
% Estimating directions of arrival using correlation
%
FastTimeGather = @(data,is) shiftdim( squeeze( data(is,:,:,:) ), 1 );
methodDescriptions = { ...
    { 'Method', 'CorrelationSinglePhase' }, ...
    { 'Method', 'Prony' }, ...
    { 'Method', 'TotalLeastSquaresProny' }, ...
    { 'Method', 'MatrixPencil' }, ...
    { 'Method', 'RootMusic' }, ...
    { 'Method', 'Music', 'FrequencySensitivity', 1e-4, 'TotalRefinements', 4, 'RefinementFactor', 10 }, ...
    { 'Method', 'Esprit' }
    };
totalMethods = length( methodDescriptions );
if totalMethods == 1, methodDescriptions = {methodDescriptions}; end

anglesEstimated = nan( 2, totalSlowTimes, totalMethods, totalSnrs );

progressBarSnr = waitbar( 0, 'Processing noisy datasets...' );

for lSnr = 1 : totalSnrs
    recordedData = squeeze( noisyData( lSnr, :, :, :, : ) );
    
    progressBarMethods = waitbar( 0, 'Estimating DOAs... ' );
    
    for iMethod = 1 : totalMethods
        thisMethod = methodDescriptions{iMethod};
        thisMethodName = thisMethod{2};
        waitbar( iMethod/totalMethods, progressBarMethods, sprintf( 'Estimating DOAs using %s', thisMethodName ) );
        
        progressBarTimes = waitbar( 0, 'Processing slow times...' );
        
        for ks = 1 : totalSlowTimes
            anglesEstimated(:,ks,iMethod,lSnr) = DirectionsOfArrivalUra( ...
                FastTimeGather( recordedData, ks ), ...
                freqCentral, ...
                [arraySpacingX arraySpacingY], ...
                thisMethod{:}, ...
                'TotalFrequencies', totalSources );
            
            waitbar( ks/totalSlowTimes, progressBarTimes );
        end
        
        delete( progressBarTimes );
    end
    
    delete( progressBarMethods );
    waitbar( lSnr/totalSnrs, progressBarSnr );
end

delete( progressBarSnr );

%%

methodNames = cell( 1, totalMethods );
for iMethod = 1 : totalMethods
    thisMethodDescription = methodDescriptions{iMethod};
    methodNames{iMethod} = thisMethodDescription{2};
end

figure

lSnr = 1;

subplot( 1, 2, 1 )

plotAngles1 = plot( slowTime, radtodeg( anglesTrue(1,:,1) ), '--', ...
    slowTime, radtodeg( squeeze( anglesEstimated(1,:,:,lSnr) ) ) );
plotAngles1(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival, \theta_x' )
legend( 'True', methodNames{:}, 'Location', 'SouthOutside' )

subplot( 1, 2, 2 )

plotAngles2 = plot( slowTime, radtodeg( anglesTrue(2,:,1) ), '--', ...
    slowTime, radtodeg( squeeze( anglesEstimated(2,:,:,lSnr) ) ) );
plotAngles2(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival, \theta_y' )
legend( 'True', methodNames{:}, 'Location', 'SouthOutside' )

%%
%
% Calculating and displaying tower location based on estimated DOAs
%
sourcePositionEstimated = nan( 3, totalMethods, totalSnrs );

anglesEstimated = real( anglesEstimated ); % Remove later!!!

for lSnr = 1 : totalSnrs
    for iMethod = 1 : totalMethods
        
        sourcePositionEstimated(:,iMethod,lSnr) = Doa2Pos(c/freqCentral, arraySpacingX, arraySpacingY, ...
            arrayPosition(:,:,1), alpha(:,1), beta(:,1), gamma(:,1), ...
            anglesEstimated(1,:,iMethod,lSnr), anglesEstimated(2,:,iMethod,lSnr));
        
    end
end

%%
lSnr = 1;
sourcePositionEstimated2d = sourcePositionEstimated(1:2,:,lSnr);
scatter( sourcePositionEstimated2d(1,:), sourcePositionEstimated2d(2,:), ...
    [], linspace( 1, 10, totalMethods ), ...
    'filled' )
legend( methodNames{:} )

%%

sourcePositionBook = repmat( sourcePosition, [ 1 totalMethods totalSnrs ] );
sourceEstimationErrors = transpose( squeeze( sqrt( sum( ( sourcePositionBook - sourcePositionEstimated ) .^ 2 ) ) ) );


%%
figure
hold on
% plot3( ToColumn(receiverPosition(1,:,:)), ToColumn(receiverPosition(2,:,:)), ToColumn(receiverPosition(3,:,:)), ...
%     'g^', 'MarkerFaceColor', 'g' );
plot( sourcePosition(1), sourcePosition(2), ...
    'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 20 );
plot( sourcePositionEstimated(1), sourcePositionEstimated(2), ...
    'k.', 'MarkerSize', 20 );
xlabel( 'Easting [m]' ), ylabel( 'Northing [m]' ), title( 'Estimating tower location' );
grid on;
axis( 100 *[-1 1 -1 1] )
hold off;

legend( 'True source location', 'Estimated location' )
