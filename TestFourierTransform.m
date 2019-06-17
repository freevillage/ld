totalTimes = 1000;
time = linspace( 0, 2*pi, totalTimes );
timeAxis = GraphAxis( time, 'Time', 's' );

F1 = 2;
F2 = 4;

signalValues = [ sin( 2*pi*F1*time ) ; cos( 2*pi*F2*time ) ];

compAxis = GraphAxis( 1:2, '', '' );

data = DatasetNd( compAxis, timeAxis, signalValues );
dataFourier = FourierTransform( data, 2, 'Frequency', 'Hz' );
dataReconstructed = InverseFourierTransform( dataFourier, 2, 'Time', 's' );

subplot( 2, 2, 1 );
display( real( 2.*1i .* dataFourier(1,:) ) );

subplot( 2, 2, 2 );
display( real( dataFourier(2,:) ) );

subplot( 2, 2, 3 );
display( imag( dataReconstructed(1,:) ) );

subplot( 2, 2, 4 );
display( imag( dataReconstructed(2,:) ) );
