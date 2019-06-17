function plot1D( varargin )

% If the first argument isn't an instance of GraphAxis class then all
% argument are assumed to conform to the plot syntax
firstArgument = varargin{ 1 };

if( ~isa( firstArgument, 'GraphAxis' ) )
    plot( varargin{ : } );
else
    plotArguments = cell( 1, nargin );
    plotArguments{ 1 } = firstArgument.Locations;
    plotArguments{ 2:end } = varargin{ 2 : end };
    plot( plotArguments );
    xlabel( firstArgument.Label );
end

end % of plot1D
    
    