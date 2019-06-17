function pairwiseSum = PairwiseSum( a, b )

assert( isvector( a ) && isvector( b ), ...
    'a and b must be vectors' );

pairwiseSum = bsxfun( @plus, ToColumn( a ), ToRow( b ) );

end % of PairwiseSum