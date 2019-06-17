function flag = IsSquareMatrix( array )

flag = ismatrix( array ) ...
    && IsConstantArray( size( array ) );

end