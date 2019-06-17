function phases = DiscreteFrequencySpectrumMatrixPencil( y, M, L )

assert( ismatrix( y ) );
if isvector( y ), y = ToColumn( y ); end

[N, K] = size( y );
if nargin < 3 || ( nargin == 3 && L == -1 )
    L = round( 5*N/12 );
    assert( IsPositiveInteger( L ) );
end

Ye = nan( N-L+1, K*L );

for k = 1 : K
    Yk = hankel( y(1:N-L+1,k), y(N-L+1:N,k) );
    
    [U,Sigma,V] = svd( Yk );
    Sigma(M+1:end,M+1:end) = 0;
    Yk = U * Sigma * V';
    
    Ye( :, (1:L) + (k-1)*L ) = Yk;
end

Ya = Ye( 1:end-1, : );
Yb = Ye( 2:end, : );

YaPlus = pinv( Ya' * Ya ) * Ya';
%YaPlus = ( Ya' * Ya ) \ Ya';


eigenValues = eigs( YaPlus * Yb, M );

phases = sort( WrapToOne( mod( angle( eigenValues ), 2*pi ) / pi ) );

end % of function
