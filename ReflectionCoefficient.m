function R = ReflectionCoefficient( IncidentVelocity, RefractedVelocity, varargin )

if( nargin == 2 )
    IncidenceAngle = 0;
else
    IncidenceAngle = varargin{ 1 };
end

RefractionAngle = SnellsLaw( IncidenceAngle, IncidentVelocity, RefractedVelocity );
ProjectedIncidentVelocity = IncidentVelocity * cos( IncidenceAngle );
ProjectedRefractedVelocity = RefractedVelocity * cos( RefractionAngle );

R = ( ProjectedIncidentVelocity - ProjectedRefractedVelocity ) ...
    / ( ProjectedIncidentVelocity + ProjectedRefractedVelocity );

end