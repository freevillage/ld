N = 100;
resolution = 10^-8;

xx = linspace( -resolution, resolution, N );
yy = linspace( -resolution, resolution, N );
[xGrid,yGrid] = ndgrid( xx, yy );

costs = nan( N );


for i = 1 : N
    for j = 1 : N
        costs(i,j) = log(ExtendedCostFunction( [xGrid(i,j);0;yGrid(i,j)] ));
    end
end

imagesc( costs )
colorbar 