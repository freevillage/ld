function varargout = ProgressBarType( varargin )
%ProgressBarType controls progress bar appearance
% 
%  Type = ProgressBarType returns the progress bar type currently set.
%
%  ProgressBarType NewType sets the desired type. NewType must be a string
%  from the following list of acceptable types:
%       Window
%       Console
%       File
%       None
%
%  Example
%       ProgressBarType Window;
%       WaitBar = ProgressBar( 'Message', 'Busy' );
%       TotalIterations = 100;
%       for IterationNumber = 1 : TotalIterations
%           DoSomething;
%           WaitBar.SetProgress( IterationNumber / TotalIterations );
%       end
%       WaitBar.Delete;


%   Copyright 2010 Oleg V. Poliannikov
%   $Revision: 1.0 $  $Date: 2010/01/09 10:37 $
%   $Revision: 1.1 $  $Date: 2011/08/29 14:03 $ Added comments and renamed
%   variables
assert( nargout <= 1, 'ProgressBarType:TooManyOutputs', 'The number of output values cannot be greater than one.' );
assert( nargin  <= 1, 'ProgressBarType:TooManyInputs',  'The number of input parameters cannot be greater than one.' );

% The current progress bar type is stored in the global variable GLOBAL__PROGRESS__BAR__TYPE. 
% If it has not been set then it is assumed that the type is 'None'. 
global GLOBAL__PROGRESS__BAR__TYPE;
if( isempty( GLOBAL__PROGRESS__BAR__TYPE ) )
    GLOBAL__PROGRESS__BAR__TYPE = 'None';
end

% The input argument can only be a new bar type, which will be set to the
% global variable.
if( nargin == 1 )
    newBarType = varargin{1};
    
    switch( newBarType )
        % Allowed types
        case{ 'Graphics', 'Window', 'Console', 'File', 'None' }
            
            % For backward compatibility Graphics and Window are treated as
            % identical modes.
            if( strcmp( newBarType, 'Graphics' ) )
                newBarType = 'Window';
            end
            
            GLOBAL__PROGRESS__BAR__TYPE = newBarType;
        otherwise
            error( 'ProgressBarType:InvalidInput', ...
                   'Invalid type. Please type help ProgressBarType to see the list of acceptable types.' );
    end
    
else % if nargin == 0
    newBarType = GLOBAL__PROGRESS__BAR__TYPE;
    
end

% the function returns a value of an output variable is supplied of if the
% function is called with no parameters at all. In the latter case, the
% type will be shown in the console.
if( nargout == 1 || ( nargout == 0 && nargin == 0 ) )
    varargout{1} = newBarType;
end


end % of ProgressBarType
