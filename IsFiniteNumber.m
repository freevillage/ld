function flags = IsFiniteNumber( array )

flags = ~isnan( array ) & isfinite( array );

end