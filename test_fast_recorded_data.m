Norm1Dim = @(mat) squeeze(sqrt(sum(mat.^2)));
sz = [totalAntennasX totalAntennasY totalSlowTimes totalFastTimes];
qq = Norm1Dim ( shiftdim( receiverPosition, 2 ) ...
    - repmat( thisSourcePosition, [1 sz] ) );

Distance = @(x,y) squeeze( sqrt( sum( (x-y).^2 ) ) );

distances = Distance( repmat( xs, [1 Ntimes Nantennas] ), xr );
match = norm( abs( exp( (-2*pi*1i/c) * fsrc * ( distances - repmat( c*t, [1 Nantennas] ) ) ) ./ distances .* conj( y ) ) .^ 2, 2 );