function CenterCAxis( varargin )

DefaultFactor = 1;

switch nargin
    case 0
        ScalingFactor = DefaultFactor;
    case 1
        if( ~isnumeric( varargin{ 1 } ) )
            error( 'Argument must be a positive number' );
        else
            ScalingFactor = abs( varargin{ 1 } ); % sign is ignored
        end
end

[ CMin, CMax ] = caxis;
caxis( ScalingFactor * [ -CMax, CMax ] );

end