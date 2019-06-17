function eta = Mollifier( x )

eta = zeros( size( x ) );
inside = ( abs(x) < 1 );

eta( inside ) = exp( -1 ./ (1-x(inside).*x(inside) ) );

end