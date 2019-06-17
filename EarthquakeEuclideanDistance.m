function distance = EarthquakeEuclideanDistance ( earthquakeLocation1, earthquakeLocation2 )

distance = norm( ...
    EarthSphericalToCartesian( earthquakeLocation1(1), earthquakeLocation1(2), earthquakeLocation1(3) ) ...
    - EarthSphericalToCartesian( earthquakeLocation2(1), earthquakeLocation2(2), earthquakeLocation2(3) ) );

end