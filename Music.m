close all;
clear all; %#ok<*CLSCR>
home
Fmin = 300 * 10^6; % minimum possible frequency
Fmax = 310 * 10^6; % maximum possible frequency
totalExponentsInSource = 2; % number of monochromatic components in a source
c = LightSpeed;
Fsrc = sort( RandomUniform( Fmin, Fmax, [1 totalExponentsInSource] ) ); % source frequencies
phiSrc = RandomUniform( 0, 2*pi, [1 totalExponentsInSource] ); % source phases

Asrc = ones( [1 totalExponentsInSource] ); % amplitudes
Fs = 4 * Fmax; % sampling frequency

% Fsrc = 350 * 10^6;
% Asrc = 1;
% phiSrc = 0;

T0=0; % 
T01 = 1;
deltaT = 5*10^(-6); % recording window size
r0 = 1000;
t0 = 1.;
Nsamples = floor( deltaT* Fs );
tau = deltaT / Nsamples;
%vStill = 0.1; 

t = TrimToOddLength( T0 : 1/Fs : T0+deltaT );

y = RecordedDataTime(t, r0, Asrc, Fsrc, phiSrc );

tns = t * 10^9; % time in nanoseconds

figure, plot( tns, real( y ) ), title( 'Recorded signal' )
xlabel( 'Time [ns]' ), ylabel( 'Real part' )

%%

tic
bandThickness = 1000; %Hz
totalIterations = 5;
Fhat = RefinedMusicSpectralEstimation( y, [Fmin, Fmax], 10^5, Fs, totalExponentsInSource, bandThickness, totalIterations );
toc

RelativeError( Fsrc, Fhat )

Decimate = @(x) x(1:1000:end); % Sumbsample signals for plotting

% figure
% hold on
% plot( Decimate(Fnorm) * Fs, Decimate(I) )
% stem( Fsrc, max(Decimate(I)) * ones(1,totalExponentsInSource) )
% hold off;
% title( 'Imaging function' );
% xlabel( 'Frequency (Hz)' );
% ylabel( 'Imaging function' );

%% Geolocation using one source
%
posSource = [0., 0., 0.];
posReceiver0 = [-500., 200., 1000.];
flyingDirection = [1, 0, 0];
T0 = 0;
Tf = 20;
deltaT = 5*10^(-6);
speed = 40; % Typical average drone speed
totalSlowTimes = 10;
tSlow = linspace( T0, Tf, totalSlowTimes );

posReceiver = repmat( posReceiver0', [1 totalSlowTimes] ) + speed * flyingDirection' * tSlow;

figure
hold on
plot3( ...
    posReceiver(1,:), posReceiver(2,:), posReceiver(3,:), ...
    posSource(1), posSource(2), posSource(3), 'r*' );
plot3( posReceiver(1,1), posReceiver(2,1), posReceiver(3,1), 'bo', 'MarkerFaceColor', 'g' )
plot3( posReceiver(1,totalSlowTimes), posReceiver(2,totalSlowTimes), posReceiver(3,totalSlowTimes), 'bo', 'MarkerFaceColor', 'r' )
axis( [-500 500 -500 500 -100 1500] );
title( 'Flying straight' );
xlabel( 'Easting [m]' );
ylabel( 'Northing [m]' );
zlabel( 'Altitude [m]' );
grid on
hold off
view( -50, 24 );

%distrec = ColumnNorm( posReceiver - repmat( ToColumn( posSource ), [1 totalSlowTimes] ) );

tauFast = EnsureOddLength( 0 : 1/Fs : deltaT );
totalFastTimes = length( tauFast );
tFast = repmat( ToColumn( tSlow ), [1 totalFastTimes] ) +  repmat( ToRow( tauFast ), [totalSlowTimes 1] );

recordedData = nan( totalSlowTimes, totalFastTimes );
for i = 1 : totalSlowTimes
    posReceiverFast = repmat( posReceiver(:,i), [1 totalFastTimes] ) + speed * flyingDirection' * (tFast(i,:)-tSlow(i));
    distrecfast = ColumnNorm( posReceiverFast - repmat( ToColumn( posSource ), [1 totalFastTimes] ) );
    recordedData(i,:) = RecordedDataTime(tFast(i,:), distrecfast, Asrc, Fsrc, phiSrc );
end

%%
Fhat = nan( totalSlowTimes, totalExponentsInSource );
bandThickness = 1000; %Hz

bar = waitbar( 0, 'Processing recorded data...' );

for i = 1 : totalSlowTimes
    Fhat(i, :) = RefinedMusicSpectralEstimation( recordedData(i,:), [Fmin, Fmax], 10^5, Fs, totalExponentsInSource, bandThickness, totalIterations );
    waitbar( i/totalSlowTimes, bar );
end

close( bar );
 
 %%
 velocityEstimated = mean( VelocityFromDoppletShift( ones( totalSlowTimes, 1 ) * Fsrc, Fhat ), 2 );
 plot( tSlow, velocityEstimated, '-o', 'MarkerFaceColor', [0 0.45 0.74] );
 title( 'Estimated radial velocity' );
 xlabel( 'Slow time [s]' );
 ylabel( 'Velocity [m/s]' );
 
 %% Geolocation using an array
posSource = [ ...
    0, 0, 0 ; ...
    -500, 400, 0  ...
  %  500, 200, 0 ...
    ];
posSource = transpose( posSource );
totalSources = size( posSource, 2 );

posArray0 = [-500.; 200.; 1000.];
flyingDirection = [1, 0, 0];
T0 = 0;
Tf = 20;
deltaT = 100*10^(-6);
speed = 40; % Typical average drone speed
totalSlowTimes = 10;
tSlow = linspace( T0, Tf, totalSlowTimes );

posArray = repmat( posArray0, [1 totalSlowTimes] ) + speed * flyingDirection' * tSlow;
lx = 10;
ly = 10;
Nx = 10;
Ny = 10;
theta = 0;
phi = 0;

posReceiver = nan( totalSlowTimes, 3, Nx, Ny );

figure
hold on
plot3( posSource(1,:), posSource(2,:), posSource(3,:), 'r*' )

for i = 1 : totalSlowTimes
    posReceiver(i,:,:,:) = UniformLinearArray2D( [lx ly], [Nx Ny], posArray(:,i), [theta, phi] );
    plot3( ToRow( posReceiver(i,1,:,:) ), ToRow( posReceiver(i,2,:,:) ), ToRow( posReceiver(i,3,:,:) ), 'g.', 'MarkerFaceColor', 'g' )
end
hold off
axis equal
title( 'Array flying straight' );
xlabel( 'Easting [m]' );
ylabel( 'Northing [m]' );
zlabel( 'Altitude [m]' );
grid on
axis( [-500 500 -500 500 0 1500] );
view( -50, 24 ); 
grid on

%%

tauFast = EnsureOddLength( 0 : 1/Fs : deltaT );
totalFastTimes = length( tauFast );
tFast = bsxfun( @plus, ToColumn( tSlow ), ToRow( tauFast ) );

modelledData = nan( Nx, Ny, totalSources, totalSlowTimes, totalFastTimes );
for ix = 1 : Nx
    for jy = 1 : Ny
        for ks = 1 : totalSources
            for kt = 1 : totalSlowTimes
                posReceiverFast = repmat( ToColumn( posReceiver(kt,:,ix,jy) ), [1 totalFastTimes] ) + speed * flyingDirection' * (tFast(i,:)-tSlow(i));
                distrecfast = pdist2( posSource(:,ks)', posReceiverFast' );
                modelledData(ix,jy,ks,kt,:) = RecordedDataTime(tFast(i,:), distrecfast, Asrc, Fsrc, phiSrc );
            end
        end
    end
end

arrayData = squeeze( sum( modelledData, 3 ) );

%%

yArray = squeeze( arrayData( 1, :, 2, : ) );

yArray = yArray(:,1:end);
% Fhat = RefinedMusicSpectralEstimation( yArray, [Fmin, Fmax], 10^6, Fs, totalSources * totalExponentsInSource, bandThickness, totalIterations );

radtodeg( MusicDoa( yArray, totalSources, mean( Fsrc ), lx/(Nx-1) ) )

% totalDirections = 10^2;
% directions = linspace( -pi/2, pi/2, totalDirections ); 
% 
% tic
% directionalPower = MusicDirectionOfArrival( directions, yArray, lx/(Nx-1), totalSources, 2*pi*LightSpeed/mean(Fsrc) );
% toc
% 
% figure
% plot( directions, ToDecibels( directionalPower, max(directionalPower) ) )
% xlim( [-pi/2, pi/2] )
% set( gca, 'XTick', [ -pi/2 -pi/4 0 pi/4 pi/2 ], 'XTickLabel', {'-\pi/2', '-\pi/4', '0', '\pi/4', '\pi/2'} )
% 
% directions(FindLargestPeaks( directionalPower, totalSources ))