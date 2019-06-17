function IsShown = ShowColorBar( varargin )

% The global variable where the infrmation is stored
global GLOBAL__SHOW__COLOR__BAR;

% If the variable is undefined then assume that the colorbar is not needed
if( isempty( GLOBAL__SHOW__COLOR__BAR ) )
    GLOBAL__SHOW__COLOR__BAR = false;
end

% Depending on the number of in and out variables the function may be used
% to set the desired state or obtain it
switch nargin
    % If there are no input parameters... 
    case 0
        % ... then we display the current state of need of colobar: true or
        % false
        if( nargout <= 1 )
            IsShown = GLOBAL__SHOW__COLOR__BAR;
        % Only one output parameter is allowed
        else
            error( 'Too many output parameters' );
        end
    % If there is one input then it becomes the new state
    case 1
        GLOBAL__SHOW__COLOR__BAR = logical( varargin{ 1 } );
    % Two or more parameters are not allowed
    otherwise
        error( 'Too many input parameters' );
end
            

end % of ShowColorBar