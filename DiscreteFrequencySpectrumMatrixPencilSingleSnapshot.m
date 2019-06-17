function phases = DiscreteFrequencySpectrumMatrixPencilSingleSnapshot( y, M, L )

assert( isvector( y ) );
N = length( y );
if nargin < 3 || ( nargin == 3 && L == -1 )
    L = floor( N/2 );
end
y = ToColumn( y );

Y = hankel( y(1:N-L+1), y(N-L+1:N) );

[U,Sigma,V] = svd( Y );
Sigma(M+1:end,M+1:end) = 0;
Y = U * Sigma * V';

Ya = Y( 1:end-1, : );
Yb = Y( 2:end, : );

YaPlus = ( Ya' * Ya ) \ Ya';

eigenValues = eig( YaPlus * Yb );

phases = sort( WrapToOne( mod( angle( eigenValues(1:M) ), 2*pi ) / pi ) );

end % of function
