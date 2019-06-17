function antennaPositions = GetAntennaPositions( movingUra, time )
sizeAntennaPositions = [ 3, movingUra.array.totalCols, movingUra.array.totalRows, size( time ) ];
getAntennaPositionFcn = @(t) movingUra.array.GetAntennaPositions( ...
    movingUra.positionFcn(t), ...
    [ movingUra.rotationXFcn(t), movingUra.rotationYFcn(t), movingUra.rotationZFcn(t) ] );
antennaPositions = MultidimensionalArrayFun( getAntennaPositionFcn, time );
assert( isequal( size( antennaPositions ), sizeAntennaPositions ) );
%             antennaPositionsTimeVectorized = arrayfun( getAntennaPositionFcn, ToColumn( time ), 'UniformOutput', false );
%             antennaPositions = reshape( cat( 4, antennaPositionsTimeVectorized{:} ), sizeAntennaPositions );
end