function reflectionTime = DipMoveout( reflectorDepth, reflectorDip, geophoneOffset, velocity )

twoWayPerpendicularTravelTime = 2 * reflectorDepth ./ velocity;
reflectionTime = sqrt( twoWayPerpendicularTravelTime.^2 ...
    + ( (geophoneOffset.^2 + 4.*geophoneOffset.*reflectorDepth.*sin(reflectorDip)) ./ velocity.^2) );


end