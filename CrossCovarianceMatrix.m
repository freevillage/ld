function covMatrix = CrossCovarianceMatrix( mat )

totalDimensions = ndims( mat );
assert( totalDimensions <= 2 );

if isvector( mat )
    covMatrix = ToColumn( mat ) * ToRow( conj( mat ) );
else
    covMatrix = mat * mat';
end

end