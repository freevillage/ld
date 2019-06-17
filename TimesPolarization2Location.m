function EstimatedSourceLocation = TimesPolarization2Location( ReceiverLocation, Vp, Vs, PArrivalTime, SArrivalTime, PolarizationVector )

% Make sure the polarization vector is unit length. The radial distance
% will be inferred from the supplied travel times
PolarizationVector = PolarizationVector / norm( PolarizationVector );

RadialDistanceFromReceiver = PSDelay( Vp, Vs, PArrivalTime, SArrivalTime );

Shift = RadialDistanceFromReceiver * PolarizationVector;

EstimatedSourceLocation = Location3D( ReceiverLocation.X + Shift( 1 ), ...
    ReceiverLocation.Y + Shift( 2 ), ...
    ReceiverLocation.Z + Shift( 3 ) );

end