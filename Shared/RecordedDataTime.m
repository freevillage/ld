function recordings = RecordedDataTime( t, r, Asrc, Fsrc, phisrc )

Nsrc = length( Asrc );
Nt = length( t );
Nr = length( r );
c = LightSpeed;

if( Nt > 1 && Nr == 1 )
    r = r * ones( [1 Nt] );
    Nr = Nt;
end

t = ToRow( t );
r = ToRow( r );
Asrc = ToColumn( Asrc );
Fsrc = ToColumn( Fsrc );
phisrc = ToColumn( phisrc );

amplitudes = Asrc * ones( 1, Nt );
frequencies = Fsrc * ones( 1, Nt );
distances = ones( Nsrc, 1 ) * r;
times = ones( Nsrc, 1 ) * t;
phases = phisrc * ones( 1, Nt );

geometricSpreading = 1 ./ ( 4*pi*distances );

recordings = geometricSpreading .* amplitudes .* exp( 1i/c * ( -2*pi * frequencies .* (distances - c*times) + c * phases ) );
if( Nsrc > 1 )
    recordings = sum( recordings );
end

end