function U2 = NoiseSpace( y, s )

M = length( y ) - 1;
h = hankel( y(1 : M/2+1), y(M/2+1 : end) );
[~,~,W] = svd( h );
W = conj( W );

U2 = W( :, s+1 : end );


end