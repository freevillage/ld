function difference = PairwiseDifference( vectorA, vectorB )

assert( isvector( vectorA ) && isvector( vectorB ) );

difference = repmat( ToColumn( vectorA ), [1 length( vectorB )] ) ...
    - repmat( ToRow( vectorB ), [length( vectorA ) 1] );

end