function valuesInterpolated = InterpolateNearestBelow( pointsOnGrid, valuesOnGrid, pointsInterpolated )

valuesInterpolated = valuesOnGrid( arrayfun( @(thisPoint) find( pointsOnGrid <= thisPoint, 1, 'last' ), pointsInterpolated ) );

end


