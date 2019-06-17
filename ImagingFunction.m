function I = ImagingFunction( omega, M, U2 )

Nomega = length( omega );
batchSize = 10^5;
U2tr = transpose( U2 );

I = nan( size( omega ) );

begBatch = 1;

while begBatch <= Nomega
    inBatch = begBatch : min( begBatch+batchSize, Nomega );
    imagingVectors = Phi( M/2, omega(inBatch) );
    I(inBatch) = ColumnNorm( imagingVectors ) ./ ColumnNorm( U2tr * imagingVectors );
    begBatch = begBatch + batchSize;
end

end

% function norm = RowNorm( matrix )
% 
% norm = sqrt( sum( matrix.^2, 2 ) );
% 
% end
