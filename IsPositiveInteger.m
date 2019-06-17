function flag = IsPositiveInteger( input )

flag = IsIntegerNumber( input ) && all( input > 0 );

end