function [xNew, yNew] = SnapTo2dGrid( xOld, yOld, gridX, gridY )

[meshX, meshY] = ndgrid( gridX, gridY );
pointsOnGrid = [ meshX(:), meshY(:) ];
pointsOld = [ xOld(:), yOld(:) ];
indexClosest = knnsearch( pointsOnGrid, pointsOld );
xNew = reshape( pointsOnGrid( indexClosest, 1 ), size( xOld ) );
yNew = reshape( pointsOnGrid( indexClosest, 2 ), size( yOld ) );

end