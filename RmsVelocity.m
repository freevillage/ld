function rmsVelocity = RmsVelocity( layerThickness, intervalVelocity )

oneWayTravelTime = layerThickness ./ intervalVelocity;

rmsVelocity = sqrt( sum( intervalVelocity.^2 .* oneWayTravelTime ) ./ sum( oneWayTravelTime ) );

end