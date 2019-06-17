function y = WrapRealPartToOne( z )

y = nan( size( z ) );

y(isreal(z))  = WrapToOne( z(isreal(z)) );
y(~isreal(z)) = complex( WrapToOne( real( z(~isreal(z)) ) ), imag( z(~isreal(z)) ) ); 

end