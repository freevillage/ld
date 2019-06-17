close all;
clear all; %#ok<*CLSCR>
home
Fmin = 399 * 10^6; % minimum possible frequency
Fmax = 401 * 10^6; % maximum possible frequency
totalExponentsInSource = 3; % number of monochromatic components in a source
c = LightSpeed;
Fsrc = sort( RandomUniform( Fmin, Fmax, [1 totalExponentsInSource] ) ); % source frequencies
phiSrc = RandomUniform( 0, 2*pi, [1 totalExponentsInSource] ); % source phases

Asrc = ones( [1 totalExponentsInSource] ); % amplitudes
Fs = 2 * Fmax; % sampling frequency

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

t = EnsureOddLength( T0 : 1/Fs : T0+deltaT );

y = RecordedDataTime(t, r0, Asrc, Fsrc, phiSrc );

tns = t * 10^9; % time in nanoseconds

figure;
plot( tns, real( y ) );
title( 'Recorded signal' );
xlabel( 'Time [ns]' );
ylabel( 'Real part' );


%% Geolocation using an array
posSource = [...
    0, 0, 0 ; ...
    -500, -400, 0; ...
    500, 0, 0
    ];
Nsrc = size( posSource, 1 );
posArray0 = [-500., 200., 1000.];
flyingDirection = [1, 0, 0];
T0 = 0;
Tf = 20;
deltaT = 5*10^(-6);
speed = 40; % Typical average drone speed
totalSlowTimes = 10;
tSlow = linspace( T0, Tf, totalSlowTimes );

posArray = repmat( posArray0', [1 totalSlowTimes] ) + speed * flyingDirection' * tSlow;
lx = 10;
ly = 10;
Nx = 5;
Ny = 5;
theta = 0;
phi = 0;

posReceiver = nan( totalSlowTimes, 3, Nx, Ny );

arrayReference = UniformLinearArray2D( [lx ly], [Nx Ny], [0 0 0], [theta, phi] );

figure
plot3( ToRow( arrayReference(1,:,:) ), ToRow( arrayReference(2,:,:) ), ToRow( arrayReference(3,:,:) ), ...
    'g^', 'MarkerFaceColor', 'g' )
title( 'Reference array' );
xlabel( 'x' );
ylabel( 'y' );


figure
hold on
plot3( posSource(:,1), posSource(:,2), posSource(:,3), 'r*' )

for i = 1 : totalSlowTimes
    posReceiver(i,:,:,:) = UniformLinearArray2D( [lx ly], [Nx Ny], posArray(:,i), [theta, phi] );
    plot3( ToRow( posReceiver(i,1,:,:) ), ToRow( posReceiver(i,2,:,:) ), ToRow( posReceiver(i,3,:,:) ), ...
        'g.', 'MarkerFaceColor', 'g' )
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

% Contributions of each source to each array at each time
sourceArrayData = nan( Nsrc, Nx, Ny, totalSlowTimes, totalFastTimes );
for ls = 1 : Nsrc
    for ix = 1 : Nx
        for jy = 1 : Ny
            for kt = 1 : totalSlowTimes
                posReceiverFast = repmat( ToColumn( posReceiver(kt,:,ix,jy) ), [1 totalFastTimes] ) ...
                    + speed * flyingDirection' * (tFast(i,:)-tSlow(i));
                distrecfast = ColumnNorm( posReceiverFast - repmat( ToColumn( posSource(ls,:) ), [1 totalFastTimes] ) );
                sourceArrayData(ls,ix,jy,kt,:) = RecordedDataTime(tFast(i,:), distrecfast, Asrc, Fsrc, phiSrc );
            end
        end
    end
end

% All sources contributions together
arrayData = squeeze( sum( sourceArrayData ) );

figure;
for ix = 1 : Nx
    for jy = 1 : Ny
        subplot( Nx, Ny, (ix-1)*Ny + jy );
        plot( tFast(1,:), squeeze( real ( arrayData(ix,jy,1,:) ) ) ) 
        title( sprintf( 'i=%d, j=%d', ix, jy ) );
    end
end
suptitle( sprintf( 'Recorded data (real part) at t_{slow}=%.1f', tSlow(1) ) )
