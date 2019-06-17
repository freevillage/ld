function matrixDimension = MatrixDimension( data, dataDimension )

totalDimensions = ndims( data );

assert( IsPositiveInteger( dataDimension ) ...
    && isscalar( dataDimension ) ...
    && dataDimension >= 1 ...
    && dataDimension <= totalDimensions );

if dataDimension > 1
    matrixDimension = dataDimension;
elseif dataDimension == 1
    if totalDimensions == 1
        matrixDimension = 2;
    else
        matrixDimension = 1;
    end
else
    error( 'MatrixDimension:InvalidDataDimension', 'Data dimension is invalid' );

end