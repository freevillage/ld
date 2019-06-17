function DisplayWiggles( varargin )

[gather, traceDimension, timeDimension, direction, color] = ParseInput( varargin{:} );

totalTraces = size( gather, traceDimension );
traceAxis = gather.Axes(traceDimension);
timeAxis  = gather.Axes(timeDimension );

times = timeAxis.Locations;
maxAmplitude = max( abs( gather.Values( : ) ) );
minStep = mean( diff( traceAxis.Points ) );
gather = gather ./ maxAmplitude .* minStep;

for iTrace = 1 : totalTraces
    if traceDimension == 1
        thisTrace = squeeze( gather( iTrace, : ) );
    else
        thisTrace = squeeze( gather( :, iTrace ) );
    end
    
    traceDisplayOffset = traceAxis.Points(iTrace);
    
    switch direction        
        case 'vertically'
            wtva( thisTrace.Values + traceDisplayOffset, times, color );
            
        case 'horizontally'
            wtva( thisTrace.Values + traceDisplayOffset, times, color, traceDisplayOffset, 1, -1 );
            
    end
end


% Form and label the plot
switch direction
    case 'vertically'
        set( gca, 'YDir', 'Reverse' );
        ylabel( timeAxis.Label );
        xlim( [ traceAxis.Min - minStep , traceAxis.Max + minStep ] );
        xlabel( traceAxis.Label );
    case 'horizontally'
        xlabel( timeAxis.Label );
        ylim( [ traceAxis.Min - minStep , traceAxis.Max + minStep ] );
        ylabel( traceAxis.Label );
    otherwise
        error( 'Unknown display direction' );
end


end % of function

function [gather, traceDimension, timeDimension, direction, color] = ParseInput( varargin )

assert( nargin >= 1, 'No input parameters' );
gather = DatasetNd( varargin{1} );
assert( ismatrix( gather ) );

if nargin == 1
    traceDimension = 1;
    direction = 'vertically';
end

if nargin == 2 
    if isnumeric( varargin{2} )
        traceDimension = varargin{2};
        direction = 'vertically';
    elseif ischar( varargin{2} )
        direction = varargin{2};
        traceDimension = 1;
    else
        error( 'DisplayWiggles:ParseInput:WrongInput', 'Second input must be a numebr or a string' );
    end
end

if nargin == 3
    traceDimension = varargin{2};
    direction = varargin{3};
end

assert( IsNumericScalar( traceDimension ) && ismember( traceDimension, [1 2] ) );

if traceDimension == 1
    timeDimension = 2;
else
    timeDimension = 1;
end

allowedDirections = { 'horizontally', 'vertically' };

assert( ischar( direction ) ...
    && any( strncmp( direction, allowedDirections, 1 ) ) );
    
color = 'k';

end