function varargout = EarthSphericalToCartesian( longitude, latitude, depth )

[ x, y, z ] = sph2cart( degtorad( longitude ), ...
    degtorad( latitude ), ...
    earthRadius - depth );

assert( nargout == 0 || nargout == 1 || nargout == 3 );
if nargout == 1 || nargout == 0
    varargout = {[ x, y, z ]};
elseif nargout == 3
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
else
    error( 'Wrong number of outputs' );
end

end