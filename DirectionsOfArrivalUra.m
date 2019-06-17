function directions = DirectionsOfArrivalUra( arrayData, sourceFrequency, arraySpacing, varargin )

% Parsing input
totalDimensions = ndims( arrayData );
assert( totalDimensions == 2 || totalDimensions == 3 );
[totalRows, totalCols, ~] = size( arrayData );

assert( isscalar( sourceFrequency ) );

assert( isvector( arraySpacing ) ...
    && isreal( arraySpacing ) ...
    && all( arraySpacing > 0 ) ...
    && length( arraySpacing ) <= 2 );

if isscalar( arraySpacing )
    arraySpacing = [arraySpacing arraySpacing];
end

input = ParseDFSInput( varargin{:} );

% Processing URA along rows and columns
totalDirections = input.Results.TotalFrequencies;

directionsRows = nan( totalRows, totalDirections );
parfor iRow = 1 : totalRows
        directionsRows(iRow,:) = DirectionOfArrival( squeeze( arrayData(iRow,:,:) ), sourceFrequency, arraySpacing(2), varargin{:} );
end
directionsRows = mean( directionsRows );

directionsCols = nan( totalCols, totalDirections );
parfor jCol = 1 : totalCols
        directionsCols(jCol,:) = DirectionOfArrival( squeeze( arrayData(:,jCol,:) ), sourceFrequency, arraySpacing(1), varargin{:} );
end
directionsCols = mean( directionsCols );

directions = [directionsCols ; directionsRows];

end % of function