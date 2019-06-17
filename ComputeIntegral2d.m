function integral = ComputeIntegral2d( x, y, f )

integral = trapz( y, trapz( x, f ) );

end