function Result = IsOdd( Data )

IntegerData = int16( Data );

if( ~isequal( Data, IntegerData ) )
    error( 'IsOdd:NotAnInteger', ...
        'Input must be integer' );
end

Result = logical( mod( IntegerData, 2 ) );

end