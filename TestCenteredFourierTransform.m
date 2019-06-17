totalTimes = 1000;
time = linspace( 0, 2*pi, totalTimes );
timeAxis = GraphAxis( time, 'Time', 's' );

signal = [ sin( 20*time ) ; cos( 40*time ) ];

compAxis = GraphAxis( 1:2, '', '' );

[ freqAxis, signalFourier ] = CenteredFourierTransform( timeAxis, signal );

%dataTime = DatasetNd( timeAxis, signal );
dataFourier = DatasetNd( compAxis, freqAxis, signalFourier );

subplot( 2, 1, 1 );
display( abs( 2.*1i .* dataFourier(1,:) ) );

subplot( 2, 1, 2 );
display( abs( dataFourier(2,:) ) );
