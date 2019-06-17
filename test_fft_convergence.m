T0 = 1e-11;
Tf = logspace( -8, -5, 4 );
Fs = logspace( 9, 12, 4 );
Xf = nan( length(Tf), length(Fs) );
error = nan( size( Xf ) );
A = 2.3+1i*1.2;
f = 3e8; % Hz - source frequency
sigmaNoise = 1e-12; % Add noise if necessary

for itf = 1 : length( Tf )
    for jfs = 1 : length( Fs )
        t = ToColumn( T0 : 1/Fs(jfs) : Tf(itf) );
        x = A*exp( 2*pi*1i*f*t );
        
        noise = sigmaNoise * randn( size( x ) );
        x = x + noise;
        
        Xf(itf,jfs) = FourierIntegral( ...
            t, x, f, ...
            'WindowFunction', @GaussianTaper, ...
            'FourierParameters', [0, -2*pi], ...
            'Dimension', 1 );
        error(itf,jfs) = CompensatedComplexSum( [Xf(itf,jfs); -A] );
    end
end

%%
figure
orient landscape
loglog( Tf, abs(error), '-o', 'MarkerFaceColor', 'auto' )
xlabel( 'Fast time recording [s]' )
ylabel( 'Abs of FFT error' )
title( 'Error of FFT estimation' )
fsLabels = arrayfun( @(f)sprintf( '%.0e', f ), Fs, 'UniformOutput', false );
fsLegend = legend( fsLabels, 'Location', 'EastOutside' );
title( fsLegend, 'Sampling frequency' )