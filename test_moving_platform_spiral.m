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
totalAntennasY = 21;
arraySpacingX = arrayLengthX/(totalAntennasX-1);
arraySpacingY = arrayLengthY/(totalAntennasY-1);

%%
%
% Description of platform motion
%
totalTimes = 100;
timeBeg = 0;
timeEnd = 20;
time = linspace( timeBeg, timeEnd, totalTimes );

initialArrayPosition = [-400; 0; 400];
velocity = 40;

arrayPosition = nan( totalTimes, 3 );
alpha = nan( 1, totalTimes );
beta = nan( 1, totalTimes );
gamma = nan( 1, totalTimes );

for it = 1 : totalTimes
    arrayPosition(it,:) = initialArrayPosition + velocity * [ time(it); 5 * cos( time(it) ); 5 * sin( time(it) ) ];
    alpha(it) = cos(time(it)); % Rotation around x-axis
    beta(it) = sin(time(it)); %cos(time(it)); % Rotation around y-axis
    gamma(it) = cos(4*time(it)); % Rotation around z-axis
end

receiverPosition = nan( totalTimes, 3, totalAntennasX, totalAntennasY );
for it = 1 : totalTimes
    receiverPosition(it,:,:,:) = UniformRectangularArray( ...
        [arrayLengthX arrayLengthY], ...
        [totalAntennasX totalAntennasY], ...
        arrayPosition(it,:), ...
        [alpha(it), beta(it), gamma(it)] );
end

%%
%
% Display geometry
%
figure
hold on
plot3( sourcePosition(1), sourcePosition(2), sourcePosition(3), ...
    'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 15 )
plot3( arrayPosition(:,1), arrayPosition(:,2), arrayPosition(:,3), ...
    'g-' )
plot3( arrayPosition(1,1), arrayPosition(1,2), arrayPosition(1,3), ...
    'go', 'MarkerFaceColor', 'g' )
plot3( arrayPosition(end,1), arrayPosition(end,2), arrayPosition(end,3), ...
    'go', 'MarkerFaceColor', 'r' )
view( [-13 30] )
legend( 'Source location', 'Platform path', 'Starting point', 'End point' )
grid on
xlabel( 'x' ), ylabel( 'y' ), zlabel( 'z' ), title( 'Experiment geometry' )


%%
%
% True angles
%
anglesTrue = nan( totalTimes, 2 );
for it = 1 : totalTimes
    thisArrayPosition = ToColumn( arrayPosition(it,:) );
    
    rotationMatrix = RotationMatrix( alpha(it), beta(it), gamma(it) );
    xRotated = rotationMatrix * [1;0;0];
    yRotated = rotationMatrix * [0;1;0];
    
    anglesTrue(it,1) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, xRotated );
    anglesTrue(it,2) = pi/2 - AngleBetweenVectors3D(sourcePosition - thisArrayPosition, yRotated );
end


%%
%
% Simulating recorded data
%
recordedData = nan( totalTimes, totalAntennasX, totalAntennasY );

% Generating recorded data for each antenna in the array
for kt = 1 : totalTimes
    for ix = 1 : totalAntennasX
        for jy = 1 : totalAntennasY
            thisReceiverPosition = ToColumn( squeeze( receiverPosition( kt, :, ix, jy ) ) );
            sourceReceiverDistance = sqrt( sum( (sourcePosition - thisReceiverPosition).^2 ) );
            recordedData(kt,ix,jy) = RecordedDataTime( ...
                time(kt), ...
                sourceReceiverDistance, ...
                amplitudeSource, ...
                freqSource, ...
                phaseSource );
        end
    end
end

%%
%
% Estimating directions of arrival using correlation
%
anglesEstimated = nan( totalTimes, 2 );
for kt = 1 : totalTimes
    anglesEstimated(kt,:) = CorrelationDoaUraSingleDirection ( ...
        squeeze( recordedData(kt,:,:) ), ...
        freqCentral, ...
        [arraySpacingX arraySpacingY] );
end

% fprintf( 'True angles     : %f%c, %f%c\n', ...
%     radtodeg( anglesTrue(1) ), char(176), radtodeg( anglesTrue(2) ), char(176) )
% fprintf( 'Estimated angles: %f%c, %f%c\n', ...
%     radtodeg( anglesEstimated(1) ), char(176), radtodeg( anglesEstimated(2) ), char(176) )

%%
figure
subplot( 2, 2, 1 )
plotAngles1 = plot( time, radtodeg( anglesTrue(:,1) ), '--', ...
    time, radtodeg( anglesEstimated(:,1) ) );
plotAngles1(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival' )
legend( 'True', 'Estimated' )

subplot( 2, 2, 2 )
plotAngles2 = plot( time, radtodeg( anglesTrue(:,2) ), '--', ...
    time, radtodeg( anglesEstimated(:,2) ) );
plotAngles2(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival' )
legend( 'True', 'Estimated' )

subplot( 2, 2, 3 )
plot( time, minus( anglesTrue(:,1), anglesEstimated(:,1) ) )
xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
title( 'Estimation error' )

subplot( 2, 2, 4 )
plot( time, minus( anglesTrue(:,2) + eps, anglesEstimated(:,2) ) )
xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
title( 'Estimation error' )


%%
%
% Calculating tower location based on estimated DOAs
%
x0 = nan( totalTimes, 2 );
y0 = nan( totalTimes, 2 );

for kt = 1 : totalTimes
    [thisX0, thisY0] = DirectionToGroundLocation( ...
        arrayPosition(kt,:), ...
        alpha(kt), ...
        beta(kt), ...
        gamma(kt), ...
        anglesEstimated(kt,1), ...
        anglesEstimated(kt,2) );
    
    x0(kt,:) = thisX0;
    y0(kt,:) = thisY0;
end

%%
%
% At each time there are _two_ possible locations. One should be correct and another one will not be. 
% The section belows checks if at least one of the two estimated locations is correct.  
%

sourceEstimated1 = transpose( [ x0(:,1) , y0(:,1) ] );
sourceEstimated2 = transpose( [ x0(:,2) , y0(:,2) ] );
sourcePositionMatrix = repmat( sourcePosition(1:2), [1 totalTimes] );

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
axis( 1e-1 *[-1 1 -1 1] )
hold off;

legend( 'True source location', 'Estimated location 1', 'Estimated location 2', 'Closest to the true' )

%% 
%
% This figure shows how the estimator switches from solution 2 to
% solution 1 as the direction of the source with respect to the platform
% changes.

figure
stem( time, whichIsClosest )
xlabel( 'Time [s]' )
ylabel( 'Estimator number' )
title( 'Best solution' );