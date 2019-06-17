scales = logspace( -10, 0, 11 );
perturbations = [ -fliplr(scales), 0, scales ];
totalPerturbations = length( perturbations );
pr = [-400 ; 0 ; 3000 ];
ps = [ 0 ; 0 ; 0 ];
offset = num2cell(ps - pr);
[az0, elev0, range0] = cart2sph( offset{:} );

azimuths = az0 + perturbations;
elevations = elev0 + perturbations;
ranges = range0 + perturbations;

[azGrid,elevGrid,rangeGrid] = ndgrid( azimuths, elevations, ranges );
costs = nan( totalPerturbations, totalPerturbations, totalPerturbations );

for i = 1 : totalPerturbations
    for j = 1 : totalPerturbations
        for k = 1 : totalPerturbations
            [dx, dy, dz] = sph2cart( azGrid(i,j,k), elevGrid(i,j,k), rangeGrid(i,j,k) );
            x = pr(1) + dx;
            y = pr(2) + dy;
            z = pr(3) + dz;
            costs(i,j,k) = ExtendedCostFunction( [ x;y;z ] );
        end
    end
end

%%

imagesc( azimuths, elevations,log ( squeeze( costs( :, :, 1 ) ) ) )

colorbar
