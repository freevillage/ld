t = linspace( 0, 2*pi, 100 );
x = sin( t );
snr = 1;
y = awgn( x, snr, 'measured' );
n = y - x;
plot( t, x, t, y )
legend( 'Clean', 'Noisy' )
xlabel( 'Time' )
ylabel( 'Signal' )
title( 'Adding WGN to signal' )
