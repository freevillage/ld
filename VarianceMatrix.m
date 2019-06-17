function v = VarianceMatrix( mat )

totalDimensions = ndims( mat );
assert( totalDimensions <= 2 );

if isvector( mat )
    v = ToColumn( mat ) * ToRow( conj( mat ) );
else
    v = sum( abs(mat) .^ 2, 2 );
end


end