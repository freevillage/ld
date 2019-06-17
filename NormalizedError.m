function epsilon = NormalizedError( xTrue, xEstimated )

epsilon = 2 * ( xEstimated - xTrue ) ./ ( xEstimated + xTrue );

end