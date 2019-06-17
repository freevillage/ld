function relativeError = RelativeError( xTrue, xEstimated )

relativeError = ( xEstimated - xTrue ) ./ xTrue;

end