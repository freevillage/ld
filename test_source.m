%% Locating source using MUSIC
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
arrayPosition = ToColumn( [ -400, 0, 400 ] );
arrayLengthX = 1;
arrayLengthY = 1;
totalAntennasX = 11;
totalAntennasY = 21;
arraySpacingX = arrayLengthX/(totalAntennasX-1);
arraySpacingY = arrayLengthY/(totalAntennasY-1);

%%
%
% Array rotation angles
%
alpha = 0; % Rotation around x-axis
beta = 0; % Rotation around y-axis
gamma = 0; % Rotation around z-axis
receiverPosition = UniformRectangularArray( [arrayLengthX arrayLengthY], ...
    [totalAntennasX totalAntennasY], ...
    arrayPosition, ...
    [alpha, beta, gamma] );
%%
%
% True angles
%
rotationMatrix = RotationMatrix( alpha, beta, gamma );
xRotated = rotationMatrix * [1;0;0];
yRotated = rotationMatrix * [0;1;0];
anglesTrue = nan( 1, 2 );
anglesTrue(1) = pi/2 - AngleBetweenVectors3D(sourcePosition - arrayPosition, xRotated );
anglesTrue(2) = pi/2 - AngleBetweenVectors3D(sourcePosition - arrayPosition, yRotated );

%%
%
% Simulating recorded data
%
sourceReceiverDistance = nan( totalAntennasX, totalAntennasY );
for ix = 1 : totalAntennasX
    for jy = 1 : totalAntennasY
        thisReceiverPosition = squeeze( receiverPosition( :, ix, jy ) );
        sourceReceiverDistance(ix,jy) = sqrt( sum( (sourcePosition - thisReceiverPosition).^2 ) );
    end
end

recordedData = nan( totalAntennasX, totalAntennasY );

% Generating recorded data for each antenna in the array
for ix = 1 : totalAntennasX
    for jy = 1 : totalAntennasY
        recordedData(ix,jy) = RecordedDataTime( 0, sourceReceiverDistance(ix,jy), ...
            amplitudeSource, freqSource, phaseSource );
    end
end
%%
%
% Estimating directions of arrival using MUSIC
%
anglesEstimated = MusicDoaUra ( recordedData, totalSources, freqCentral, [arraySpacingX arraySpacingY] );
fprintf( 'True angles     : %f%c, %f%c\n', ...
    radtodeg( anglesTrue(1) ), char(176), radtodeg( anglesTrue(2) ), char(176) )
fprintf( 'Estimated angles: %f%c, %f%c\n', ...
    radtodeg( anglesEstimated(1) ), char(176), radtodeg( anglesEstimated(2) ), char(176) )

%%
%
% Calculating tower location based on estimated DOAs
%
[x0, y0] = DirectionToGroundLocation( arrayPosition, alpha, beta, gamma, ...
    anglesEstimated(1), anglesEstimated(2) );

%%
%
% There is an ambiguity when going from estimated angles to the actual
% location of the tower. One of these two solutions should be right. I need
% to figure out exactly the conditions when it is which.
%
figure( 'Name', 'Geometry' )
hold on
plot3( ToColumn(receiverPosition(1,:,:)), ToColumn(receiverPosition(2,:,:)), ToColumn(receiverPosition(3,:,:)), ...
    'g^', 'MarkerFaceColor', 'g' );
plot3( sourcePosition(1), sourcePosition(2), sourcePosition(3), ...
    'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 20 );
xlabel( 'x' ), ylabel( 'y' ), zlabel( 'z' ), title( 'Geometry' );
set( gca, 'XDir', 'Reverse', 'YDir', 'Reverse' );
view( [-37 30] )
axis equal
plot3( x0(1), y0(1), 0, 'ko', 'MarkerSize', 20 );
plot3( x0(2), y0(2), 0, 'ro', 'MarkerSize', 20 );

grid on;

legend( 'Platform', 'Tower', 'Estimated location 1', 'Estimated location 2' )


