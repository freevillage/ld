function arrayLinspace = MatchingLinspace( array )

assert( isvector( array ) && isfloat( array ) );

arrayLinspace = linspace( array(1), array(end), length( array ) );
arrayLinspace = reshape( arrayLinspace, size( array ) );

end