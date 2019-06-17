function yesno = IsPositiveDefinite( matrix )

assert( ismatrix( matrix ), 'Input must be a matrix' );

yesno = all( eig( matrix ) > 0 );

end