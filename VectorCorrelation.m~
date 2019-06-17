function Correlation = VectorCorrelation( FirstVector, SecondVector )

MaxLength    = max( length( FirstVector ), length( SecondVector ) );
PaddedLength = 2 ^ nextpow2( 2 * MaxLength - 1 );

FirstFFT = fft( FirstVector, PaddedLength );
SecondFFT = fft( SecondVector, PaddedLength );

Correlation = ifft( FirstFFT .* conj( SecondFFT ) ); 



end % of VectorCorrelation