Fs = 10; %Hz
dt = 1 / Fs;
Nt = logspace( 1, 4, 4 );

for i = 1 : length( Nt )
    t = ToColumn( (0:Nt(i)-1) * dt );
    f = 1.5;
    freqsNormalized = (-0.5 : 1/Nt(i) : 0.5);
    freqs = Fs * freqsNormalized;
    phi = pi/2;
    x = exp( 2*pi*1i*f*t ) - 2 * exp( 2*pi*1i*2*f*t );
    
%     window = ToColumn( GaussianTaper( length(t) ) );
%     xWindowed = x .* window;
%     normXWindowed = trapz(t, conj(xWindowed).*xWindowed);
%     normWindow = trapz( t, conj(window) .* window );
%     xWindowed = xWindowed / normXWindowed;

    totalFreqs = length( freqs );
    XW = nan( size( freqs ) );
    
    parfor j = 1 : totalFreqs
        XW(j) = FourierIntegral( ...
            t, x, freqs(j), ...
            'WindowFunction', @GaussianTaper, ...
            'FourierParameters', [0, -2*pi], ...
            'Dimension', 1 );
    end
    
    
    
    % W0 = FourierIntegral( t, ones(size(x)), 0, ...
    %     'WindowFunction', @GaussianTaper, ...
    %     'FourierParameters', [0, -2*pi], ...
    %     'Dimension', 1 ...
    %     );
    
    subplot( 2, 2, i )
    plot( freqs, abs(XW) )
    ylim( [0 2] )
    xlabel( 'Frequency (Hz)' )
    ylabel( 'Spectrum magnitude' )
    title( sprintf( 'Signal spectrum (N_t=%d)', Nt(i) ) )
end