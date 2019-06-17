function directions = DirectionsOfArrivalUraSingleRowCol( arrayData, sourceFrequency, arraySpacing, varargin )

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

%directionsRows = nan( totalRows, totalDirections );
iRow = (totalRows+1)/2;
directionsRows = DirectionOfArrival( squeeze( arrayData(iRow,:,:) ), sourceFrequency, arraySpacing(2), varargin{:} );

%directionsCols = nan( totalCols, totalDirections );
jCol = (totalCols+1)/2;
directionsCols = DirectionOfArrival( squeeze( arrayData(:,jCol,:) ), sourceFrequency, arraySpacing(1), varargin{:} );

directions = [directionsCols ; directionsRows];

end % of function