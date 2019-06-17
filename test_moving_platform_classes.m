%% Locating source from a moving platform using DOA
%
%% Source description
% 
%
sourcePosition = ToColumn( [ 20,-50, 40 ] );
freqMin = 300 * 10^6; % minimum possible frequency
freqMax = 300 * 10^6; % maximum possible frequency
totalSources = 1; % number of monochromatic components in a source
c = LightSpeed;
freqSource = sort( RandomUniform( freqMin, freqMax, [1 totalSources] ) ); % source frequencies
phaseSource = RandomUniform( 0, 2*pi, [1 totalSources] ); % source phases
freqCentral = mean( freqSource );
amplitudeSource = ones( [1 totalSources] ); % amplitudes

source = PolychromaticSource( ...
    sourcePosition, ...
    amplitudeSource, ...
    freqSource, ...
    phaseSource );

%% Array geometry
%
% 
%
arrayLengthX = 1;
arrayLengthY = 1;
totalAntennasX = 21;
totalAntennasY = 23;
arraySpacingX = arrayLengthX/(totalAntennasX-1);
arraySpacingY = arrayLengthY/(totalAntennasY-1);

array = UniformRectangularAntennaArray( ...
    [ totalAntennasX totalAntennasY ], ...
    [ arraySpacingX arraySpacingY ] ...
    );

%% Description of platform motion
%
% 
%
initialArrayPosition = [-400; 0; 2000];
arraySpeed = 40;

GetArrayPosition = @(t) initialArrayPosition + arraySpeed * [ t; sin(t); cos(t) ];
GetRotationAboutX = @(t) 0.1 * cos(t);
GetRotationAboutY = @(t) 0.1 * sin(2*t);
GetRotationAboutZ = @(t) 0.1 * cos(4*t);

movingUra = MovingURA( array, ...
    GetArrayPosition, ...
    GetRotationAboutX, ...
    GetRotationAboutY, ...
    GetRotationAboutZ ...
    );

%% Discrete times of data recording

slowTimeBeg = 0;
slowTimeEnd = 20;
slowSamplingPeriod = 0.1;
slowTime = slowTimeBeg : slowSamplingPeriod : slowTimeEnd;
totalSlowTimes = length( slowTime );

fastSamplingPeriod = 1e-9;
fastRecordingTime = 1e-9;
fastDelay = 0 : fastSamplingPeriod : fastRecordingTime;
totalFastTimes = length( fastDelay );

% fastTime = repmat( ToRow( slowTime ), [totalFastTimes 1] ) ...
%     + repmat( ToColumn( fastDelay ), [1 totalSlowTimes] );

fastTime = bsxfun( @plus, ToColumn( fastDelay ), ToRow( slowTime ) );

arrayPosition = MultidimensionalArrayFun( movingUra.positionFcn, fastTime);
receiverPosition = movingUra.GetAntennaPositions( fastTime );

assert( isequal( size( receiverPosition ), ...
    [ 3 movingUra.array.totalCols movingUra.array.totalRows totalFastTimes totalSlowTimes ] ), ...
    'Unexpected size of receiverPosition' )


%% Display geometry
%
% 
%
figure, hold on
Plot3dData( source.position, 'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 15 );
Plot3dData( arrayPosition(:,1,:), 'g-' );
Plot3dData( arrayPosition(:,1,1), 'go', 'MarkerFaceColor', 'g' );
Plot3dData( arrayPosition(:,1,end), 'go', 'MarkerFaceColor', 'r' );
view( [-13 30] )
legend( 'Source location', 'Platform path', 'Starting point', 'End point' )
grid on
xlabel( 'Easting [m]' ), ylabel( 'Northing [m]' ), zlabel( 'Altitude [m]' )
title( 'Experiment geometry' )
hold off

%% Simulating recorded data
%
% 
%
cleanData = RecordedDataUra( receiverPosition, source, fastTime );

noiseSnr = 1;
areRecordedDataNoisy = false;
noisyData = nan( size( cleanData ) );

for ks = 1 : totalSlowTimes
    noisyData(:,:,:,ks) = AddWhiteGaussianNoise( ...
        cleanData(:,:,:,ks), ...
        noiseSnr, 'measured' );
end

if areRecordedDataNoisy
    recordedData = noisyData;
else
    recordedData = cleanData;
end

% Plotting a sample trace
figure
contour( abs(recordedData(:,:,1,1) )', 'ShowText', 'on' )
axis( [ 1 array.totalCols 1 array.totalRows ] )
set( gca, ...
    'XTick', 1:array.totalCols, ...
    'YTick', 1:array.totalRows ...
    );
xlabel( 'Antenna column' ), ylabel( 'Antenna row' )
title( 'Sample recorded signal amplitude' )

%% Estimating directions of arrival using correlation
%
% 
%

%
% True angles
%
anglesTrue = MultidimensionalArrayFun( ...
    @(time) TrueAngles( movingUra, source, time ), ...
    fastTime ...
    );

%
% Estimated angles
%
progressBar = waitbar( 0, 'Estimating DOAs...' );

anglesEstimated = nan( 2, totalSlowTimes );
for ks = 1 : totalSlowTimes
    anglesEstimated(:,ks) = DirectionsOfArrivalUra( ...
        recordedData(:,:,:,ks), ...
        freqCentral, ...
        [arraySpacingX arraySpacingY], ...
        'Method', 'CorrelationSinglePhase', ...
        'TotalFrequencies', totalSources );
    
    waitbar( ks/totalSlowTimes, progressBar );
end

delete( progressBar );

%
% Compare true angles with estimated ones
%
anglesTrueX = ToRow( squeeze( anglesTrue(1,1,:) ) );
anglesTrueY = ToRow( squeeze( anglesTrue(2,1,:) ) );
figure
subplot( 2, 2, 1 )
plotAngles1 = plot( slowTime, radtodeg( anglesTrueX ), '--', ...
    slowTime, radtodeg( anglesEstimated(1,:) ) );
plotAngles1(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival' )
legend( 'True', 'Estimated' )

subplot( 2, 2, 2 )
plotAngles2 = plot( slowTime, radtodeg( anglesTrueY ), '--', ...
    slowTime, radtodeg( anglesEstimated(2,:) ) );
plotAngles2(1).LineWidth = 3;
xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
title( 'Direction of arrival' )
legend( 'True', 'Estimated' )

subplot( 2, 2, 3 )
plot( slowTime, radtodeg( minus( anglesTrueX, anglesEstimated(1,:) ) ) )
xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
title( 'Estimation error' )

subplot( 2, 2, 4 )
plot( slowTime, radtodeg( minus( anglesTrueY, anglesEstimated(2,:) ) ) )
xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
title( 'Estimation error' )


%% Calculating tower location based on estimated DOAs
%
% 
%

sourcePositionEstimated = Doa2Pos( ...
    arrayPosition(:,1,:), ...
    movingUra.rotationXFcn(slowTime), ...
    movingUra.rotationYFcn(slowTime), ...
    movingUra.rotationZFcn(slowTime), ...
    anglesEstimated(1,:), anglesEstimated(2,:) ...
    );

sourcePositionEstimationError = sourcePositionEstimated - source.position;

figure, hold on
line( ...
    [0, sourcePositionEstimationError(1)], ...
    [0, sourcePositionEstimationError(2)], ...
    [0, sourcePositionEstimationError(3)], ...
    'Color', 'r' ...
    );
Plot3dData( [0; 0; 0], 'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 15 );
text( 0, 0, 0, '$\quad x_s$', 'Interpreter', 'latex' )
Plot3dData( sourcePositionEstimated - source.position, 'rp', 'MarkerFaceColor', 'w', 'MarkerSize', 15 );
text( sourcePositionEstimationError(1), sourcePositionEstimationError(2), sourcePositionEstimationError(3), ...
    '$\quad \hat{x}_s$', 'Interpreter', 'latex' )
text( sourcePositionEstimationError(1)/2, sourcePositionEstimationError(2)/2, sourcePositionEstimationError(3)/2, ...
    sprintf( '$%s = %f$', '\quad \|\hat{x}_s-x_s\|', norm( sourcePositionEstimationError ) ), ...
        'Interpreter', 'latex' )
xlabel( '\epsilon_x [m]' ), ylabel( '\epsilon_y [m]' ), zlabel( '\epsilon_z [m]' )
title( 'Tower location estimation error' )
axis( max(abs(sourcePositionEstimationError)) * [-1 1 -1 1 -1 1] )
grid on
view( [-25 30] )
hold off


