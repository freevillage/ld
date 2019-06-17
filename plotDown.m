function plotDown( varargin )

% If the first argument isn't an instance of GraphAxis class then all
% argument are assumed to conform to the plot syntax
firstArgument = varargin{ 1 };

if( ~isa( firstArgument, 'GraphAxis' ) )
    plot( varargin{ [ 2, 1, 3:end ] } );
else
    plotArguments = cell( 1, nargin );
    plotArguments{ 2 } = firstArgument.Locations;
    plotArguments{ 1 } = varargin{ 2 };
    plotArguments{ 3:end } = varargin{ 3 : end };
    plot( plotArguments );
    set( gca, 'YDir', 'Reverse' );
    ylabel( 'firstArgument.Label );
end

end % of plotDown function