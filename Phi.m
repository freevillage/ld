%\[Phi][M_Integer, \[Omega]_Real] := E^(-2 \[Pi] I \[Omega] Range[0, M]
%   )
   
function phi = Phi( M, omega )

omega = ToRow( omega );
range = ToColumn( 0 : M );

phi = exp( -2*pi*1i * range * omega );

end