function plotHandle = plotMapView( varargin )

% If the first two arguments aren't of type GraphAxis, then all arguments
% are assumed to conform to the pcolor syntax and fed to that function
if( ~( isa( varargin{ 1 }, 'GraphAxis' ) && isa( varargin{ 2 }, 'GraphAxis' ) ) )
    plotHandle = pcolor( transpose( varargin{ : } ) );
else
    modifiedPcolorArgs = cell( 1, nargin );
    modifiedPcolorArgs{   1   } = varargin{ 1 }.Locations;
    modifiedPcolorArgs{   2   } = varargin{ 2 }.Locations;
    modifiedPcolorArgs{   3   } = transpose( varargin{ 3 } );
    modifiedPcolorArgs{ 4:end } = varargin{ 4:end };
    
    plotHandle = pcolor( modifiedPcolorArgs{ : } );
    xlabel( varargin{1}.Label );
    ylabel( varargin{2}.Label );
    axis( [ varargin{1}.MinValue varargin{1}.MaxValue, ...
            varargin{2}.MinValue varargin{2}.MaxValue ] );
end % of test for the first two args

set( plotHandle, 'EdgeColor', 'none' );

end % of plotMapView