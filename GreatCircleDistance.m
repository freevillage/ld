function distance = GreatCircleDistance( varargin )

% Each point is a couple (lat, lon) in degrees
% http://en.wikipedia.org/wiki/Great-circle_distance

[ latS, lonS, latF, lonF ] = ParseInput( varargin{:} );

deltaLon = lonF - lonS;

centralAngle = acos( sin(latS) * sin(latF) + cos(latS) * cos(latF) * cos(deltaLon)  );
distance = earthRadius * centralAngle;

end


function [ latA, lonA, latB, lonB ] = ParseInput( varargin )

scalarInput = nargin == 4;
vectorInput = nargin == 2;

assert( scalarInput || vectorInput );

if scalarInput
    latA = degtorad( varargin{1} );
    lonA = degtorad( varargin{2} );
    latB = degtorad( varargin{3} );
    lonB = degtorad( varargin{4} );
    
elseif vectorInput
    pointA = varargin{1};
    pointB = varargin{2};
    
    latA = degtorad( pointA(1) );
    lonA = degtorad( pointA(2) );
    latB = degtorad( pointB(1) );
    lonB = degtorad( pointB(2) );
end

end