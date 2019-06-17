function y = parspace( d1, d2, n )

if( nargin == 2 )
    n = 100;
end

n = double( n );

if( d1 >= d2 )
    error( 'd2 must be greater than d1' );
else
    y = d1 + sqrt( linspace( 0, ( d2 - d1 ) ^ 2, n ) );
end

end