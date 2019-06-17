function area = SupportArea( gridX, gridY, f, confidenceLevel )

%% Check input
assert( isvector( gridX ) ...
    && isvector( gridY ) ...
    && ismatrix( f ) ...
    && size( f, 1 ) == length( gridX ) ...
    && size( f, 2 ) == length( gridY ) );

confidenceLevelDefault = 0.95;
isConfidenceLevelUndefined = nargin < 4;

if isConfidenceLevelUndefined
    confidenceLevel = confidenceLevelDefault;
end
assert( IsProbability( confidenceLevel ) );

%% Main body
threshold = FindConfidenceContourLevel( gridX, gridY, f, confidenceLevel );
support = (f >= threshold);
area = ComputeIntegral2d( gridX, gridY, support );

end