function mask = ellipseMask( xAxis, zAxis, focus1, focus2, thresholdDistance )

[ xgrid, zgrid ] = ndgrid( xAxis.Locations, zAxis.Locations );
mask = zeros( size( xgrid ) );

sumOfDistancesToFoci = sqrt( ( xgrid - focus1.x ) .^ 2 + ( zgrid - focus1.z  ) .^ 2 ) ...
                     + sqrt( ( xgrid - focus2.x ) .^ 2 + ( zgrid - focus2.z  ) .^ 2 ); 
mask( sumOfDistancesToFoci <= thresholdDistance ) = 1;

end % of ellipseMask