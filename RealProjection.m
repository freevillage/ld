function pi = RealProjection( x, y )

pi = y * dot( x, y ) / dot( y, y );

end