totalTimes = 3000;
time = linspace( 0, 2*pi, totalTimes );
timeAxis = GraphAxis( time, 'Time', 's' );

F1 = 30;
F2 = 200;

signalValues = ...
    sin( 2*pi * F1 * time ) .* (time < pi ) ...
    + sin( 2*pi * F2 * time ) .* (time > pi );

data = DatasetNd( timeAxis, signalValues );
stft = ShortTimeFourierTransform( data, 0.5, 'psd' );

display( abs( stft ) );