function projection = OrthogonalProjection( vector, line )

assert( isvector( vector ) ...
    && isvector( line ) ...
    && ndims( vector ) == ndims( line ) );

projection = dot( vector, line ) ./ dot( line, line ) .* line; 

end