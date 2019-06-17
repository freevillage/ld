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
totalAntennasX = 21;
totalAntennasY = 23;
arraySpacingX = arrayLengthX/(totalAntennasX-1);
arraySpacingY = arrayLengthY/(totalAntennasY-1);

%%
%
% Description of platform motion
%
initialArrayPosition = [-400; 0; 3000];
arraySpeed = 40;

GetArrayPosition = @(t) initialArrayPosition + arraySpeed * [ t; cos(t); sin(t) ] / sqrt(2);
% GetRotationAboutX = @(t) cos(t);
% GetRotationAboutY = @(t) sin(t);
% GetRotationAboutZ = @(t) cos(4*t);
GetRotationAboutX = @(t) 0; % no platform rotation
GetRotationAboutY = @(t) 0;
GetRotationAboutZ = @(t) 0;

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
beta  = nan( totalSlowTimes, totalFastTimes );
gamma = nan( totalSlowTimes, totalFastTimes );
receiverPosition = nan( totalSlowTimes, totalFastTimes, 3, totalAntennasX, totalAntennasY );

for is = 1 : totalSlowTimes
    for jf = 1 : totalFastTimes
        arrayPosition(:,is,jf) = GetArrayPosition( fastTime(is,jf) );
        alpha(is,jf) = GetRotationAboutX( fastTime(is,jf) );
        beta(is,jf) = GetRotationAboutY( fastTime(is,jf) );
        gamma(is,jf) = GetRotationAboutY( fastTime(is,jf) );
        
        receiverPosition(is,jf,:,:,:) = UniformRectangularArray( ...
            [arrayLengthX arrayLengthY], ...
            [totalAntennasX totalAntennasY], ...
            arrayPosition(:,is,jf), ...
            [alpha(is,jf), beta(is,jf), gamma(is,jf)] );
    end
end

% arrayPosition = nan( totalSlowTimes, 3 );
% alpha = nan( 1, totalSlowTimes );
% beta = nan( 1, totalSlowTimes );
% gamma = nan( 1, totalSlowTimes );
% receiverPosition = nan( totalSlowTimes, 3, totalAntennasX, totalAntennasY );
% 
% 
% for it = 1 : totalSlowTimes
%     arrayPosition(it,:) = GetArrayPosition( slowTime(it) );
%     alpha(it) = GetRotationAboutX( slowTime(it) );
%     beta(it) = GetRotationAboutY( slowTime(it) );
%     gamma(it) = GetRotationAboutZ( slowTime(it) );
%     
%     receiverPosition(it,:,:,:) = UniformRectangularArray( ...
%         [arrayLengthX arrayLengthY], ...
%         [totalAntennasX totalAntennasY], ...
%         arrayPosition(it,:), ...
%         [alpha(it), beta(it), gamma(it)] );
% end

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
recordedData = nan( totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
noiseSnr = 30;
areRecordedDataNoisy = false;

progressBar = waitbar( 0, 'Simulating recorded data...' );

% Generating recorded data for each antenna in the array
for ks = 1 : totalSlowTimes
    parfor lt = 1 : totalFastTimes
        for ix = 1 : totalAntennasX
            for jy = 1 : totalAntennasY
                thisReceiverPosition = ToColumn( squeeze( receiverPosition( ks, lt, :, ix, jy ) ) );
                sourceReceiverDistance = sqrt( sum( (sourcePosition - thisReceiverPosition).^2 ) );
                recordedData(ks,lt, ix,jy) = RecordedDataTime( ...
                    fastTime(ks,lt), ...
                    sourceReceiverDistance, ...
                    amplitudeSource, ...
                    freqSource, ...
                    phaseSource );
            end
        end
    end
    
    if areRecordedDataNoisy
        recordedData(ks,:,:,:) = AddWhiteGaussianNoise( recordedData(ks,:,:,:), noiseSnr, 'measured', 1 );
    end
    
    waitbar( ks/totalSlowTimes, progressBar );
end

delete( progressBar );

%%
%
% Estimating directions of arrival using correlation
%
FastTimeGather = @(data,is) shiftdim( squeeze( data(is,:,:,:) ), 1 );

progressBar = waitbar( 0, 'Estimating DOAs...' );

anglesEstimated = nan( 2, totalSlowTimes );
for ks = 1 : totalSlowTimes
    anglesEstimated(:,ks) = DirectionsOfArrivalUra( ...
        FastTimeGather( recordedData, ks ), ...
        freqCentral, ...
        [arraySpacingX arraySpacingY], ...
        'Method', 'CorrelationSinglePhase', ...
        'TotalFrequencies', totalSources );
    
    waitbar( ks/totalSlowTimes, progressBar );
end

delete( progressBar );

% fprintf( 'True angles     : %f%c, %f%c\n', ...
%     radtodeg( anglesTrue(1) ), char(176), radtodeg( anglesTrue(2) ), char(176) )
% fprintf( 'Estimated angles: %f%c, %f%c\n', ...
%     radtodeg( anglesEstimated(1) ), char(176), radtodeg( anglesEstimated(2) ), char(176) )

%%
figure
subplot( 2, 2, 1 )
plotAngles1 = plot( slowTime, radtodeg( anglesTrue(1,:,1) ), '--', ...
    slowTime, radtodeg( anglesEstimated(1,:) ) );
plotAngles1(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival' )
legend( 'True', 'Estimated' )

subplot( 2, 2, 2 )
plotAngles2 = plot( slowTime, radtodeg( anglesTrue(2,:,1) ), '--', ...
    slowTime, radtodeg( anglesEstimated(2,:) ) );
plotAngles2(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival' )
legend( 'True', 'Estimated' )

subplot( 2, 2, 3 )
plot( slowTime, radtodeg( minus( anglesTrue(1,:,1), anglesEstimated(1,:) ) ) )
xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
title( 'Estimation error' )

subplot( 2, 2, 4 )
plot( slowTime, radtodeg( minus( anglesTrue(2,:,1) + eps, anglesEstimated(2,:) ) ) )
xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
title( 'Estimation error' )


%%
%
% Calculating tower location based on estimated DOAs
%
x0 = nan( totalSlowTimes, 2 );
y0 = nan( totalSlowTimes, 2 );

for ks = 1 : totalSlowTimes
    [thisX0, thisY0] = DirectionToGroundLocation( ...
        arrayPosition(:,ks,1), ...
        alpha(ks,1), ...
        beta(ks,1), ...
        gamma(ks,1), ...
        anglesEstimated(1,ks), ...
        anglesEstimated(2,ks) );
    
    x0(ks,:) = thisX0;
    y0(ks,:) = thisY0;
end

%%
%
% At each time there are _two_ possible locations. One should be correct and another one will not be. 
% The section belows checks if at least one of the two estimated locations is correct.  
%

sourceEstimated1 = transpose( [ x0(:,1) , y0(:,1) ] );
sourceEstimated2 = transpose( [ x0(:,2) , y0(:,2) ] );
sourcePositionMatrix = repmat( sourcePosition(1:2), [1 totalSlowTimes] );

errorDistance1 = sqrt( sum( (sourceEstimated1 - sourcePositionMatrix).^2 ) );
errorDistance2 = sqrt( sum( (sourceEstimated2 - sourcePositionMatrix).^2 ) );

[~,whichIsClosest] =  min( [ errorDistance1 ; errorDistance2 ] );

bestEstimate = sourceEstimated1;
bestEstimate(:,whichIsClosest==2) = sourceEstimated2(:,whichIsClosest==2);

%%
%
% This figure shows estimated locations. The best estimate is encircled.
%
% *Note the scale on the y axis!*

figure
hold on
% plot3( ToColumn(receiverPosition(1,:,:)), ToColumn(receiverPosition(2,:,:)), ToColumn(receiverPosition(3,:,:)), ...
%     'g^', 'MarkerFaceColor', 'g' );
plot( sourcePosition(1), sourcePosition(2), ...
    'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 20 );
plot( x0(:,1), y0(:,1), 'k.' );
plot( x0(:,2), y0(:,2), 'b.' );
plot( bestEstimate(1,:), bestEstimate(2,:), 'ro', 'MarkerSize', 15 );
xlabel( 'x' ), ylabel( 'y' ), title( 'Estimating source location' );
grid on;
text( 0, 0.03, sprintf( 'Mean location: (%f,%f)', mean( bestEstimate, 2 ) ) )
axis( 1 *[-1 1 -1 1] )
hold off;

legend( 'True source location', 'Estimated location 1', 'Estimated location 2', 'Closest to the true' )

%% 
%
% This figure shows how the estimator switches from solution 2 to
% solution 1 as the direction of the source with respect to the platform
% changes.

figure
stem( slowTime, whichIsClosest )
xlabel( 'Time [s]' )
ylabel( 'Estimator number' )
title( 'Best solution' );