close all force
clc

%% Locating source from a moving platform using MUSIC
%
% Source description
%
sourcePosition = ToColumn( [ 0,0,0 ] );
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
initialArrayPosition = [0; 0; 2000];
arraySpeed = 40;

GetArrayPosition = @(t) initialArrayPosition + arraySpeed*[ t; sin(t); t ];
GetRotationAboutX = @(t) cos(t);
GetRotationAboutY = @(t) sin(2*t);
GetRotationAboutZ = @(t) 0;

slowTimeBeg = 0;
slowTimeEnd = 20;
slowSamplingPeriod = 0.1;
slowTime = slowTimeBeg : slowSamplingPeriod : slowTimeEnd;
totalSlowTimes = length( slowTime );

fastSamplingPeriod = 1e-9;
fastRecordingTime = 1e-9;
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

%%
% figure
% subplot( 2, 2, 1 )
% plotAngles1 = plot( slowTime, radtodeg( anglesTrue(1,:,1) ), '--', ...
%     slowTime, radtodeg( anglesEstimated(1,:) ) );
% plotAngles1(1).LineWidth = 3;
% xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
% title( 'Direction of arrival' )
% legend( 'True', 'Estimated' )
%
% subplot( 2, 2, 2 )
% plotAngles2 = plot( slowTime, radtodeg( anglesTrue(2,:,1) ), '--', ...
%     slowTime, radtodeg( anglesEstimated(2,:) ) );
% plotAngles2(1).LineWidth = 3;
% xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
% title( 'Direction of arrival' )
% legend( 'True', 'Estimated' )
%
% subplot( 2, 2, 3 )
% plot( slowTime, radtodeg( minus( anglesTrue(1,:,1), anglesEstimated(1,:) ) ) )
% xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
% title( 'Estimation error' )
%
% subplot( 2, 2, 4 )
% plot( slowTime, radtodeg( minus( anglesTrue(2,:,1) + eps, anglesEstimated(2,:) ) ) )
% xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
% title( 'Estimation error' )


%%
%
% Calculating tower location based on estimated DOAs
%

x0_estimate = Doa2Pos(arrayPosition(:,:,1), ...
    alpha(:,1), beta(:,1), gamma(:,1), ...
    anglesEstimated(1,:), anglesEstimated(2,:))
