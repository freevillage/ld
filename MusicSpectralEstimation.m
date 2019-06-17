function [Fpeak, Fnormalized, I] = MusicSpectralEstimation( y, Frange, NF, Fs, s )

% Fmin = Frange(1);
% Fmax = Frange(2);
% 
% Fnormalized = linspace( Fmin/Fs, Fmax/Fs, NF );

Fnormalized = Bandspaces( Frange, NF, 0.1 * Frange ) / Fs;

I = ImagingFunction( Fnormalized, length(y) - 1, NoiseSpace( y, s ) );

Fpeak = Fs * sort( Fnormalized( FindLargestPeaks( I, s ) ) );

end


