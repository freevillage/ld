function numbers = RandomUniform( a, b, sizeNumbers )

assert( IsNumericScalar( a ) );
assert( IsNumericScalar( b ) );

numbers = a + rand( sizeNumbers ) * (b-a);

end