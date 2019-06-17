function RefractionAngle = SnellsLaw( IncidenceAngle, Velocity1, Velocity2 )

if ( or( IncidenceAngle < 0, IncidenceAngle > pi/2 ) )
    error( 'Angle of incidence must be between 0 and pi/2' );
end

VelocityRatio = Velocity2 / Velocity1;
InverseVelocityRatio = 1 / VelocityRatio;

if( InverseVelocityRatio > 1 )
    CriticalAngle = pi / 2;
else
    CriticalAngle = asin( InverseVelocityRatio );
end

if( IncidenceAngle > CriticalAngle )
    RefractionAngle = 0;
else
    RefractionAngle = asin( sin( IncidenceAngle ) * VelocityRatio );
end


end