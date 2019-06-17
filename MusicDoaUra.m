function directions = MusicDoaUra( arrayData, totalDirections, sourceFrequency, arraySpacing )

totalDimensions = ndims( arrayData );
assert( totalDimensions == 2 || totalDimensions == 3 );

[totalRows, totalCols, ~] = size( arrayData );

if isscalar( arraySpacing )
    arraySpacing = [arraySpacing arraySpacing];
end


directionsRows = nan( totalRows, totalDirections );
for iRow = 1 : totalRows
        directionsRows(iRow,:) = MusicDoa( arrayData(iRow,:,:), totalDirections, sourceFrequency, arraySpacing(2) );
end
directionsRows = mean( directionsRows );

directionsCols = nan( totalCols, totalDirections );
for jCol = 1 : totalCols
        directionsCols(jCol,:) = MusicDoa( arrayData(:,jCol,:), totalDirections, sourceFrequency, arraySpacing(1) );
end
directionsCols = mean( directionsCols );

directions = [directionsCols, directionsRows];

end % of function