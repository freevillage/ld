function varargout = SqueezeDatasets( varargin )

assert( nargout <= 1, ...
    'SqueezeDatasets:TooManyOutputs', ...
    'The number of output parameters cannot be greater than one' );
assert( nargin <= 1, ...
    'SqueezeDatasets:TooManyInput', ...
    'The number of input parameters cannot be greater than one' );

global GLOBAL__SQUEEZE__DATASETS__FLAG

% By default the flag is set to 'true'
if( isempty( GLOBAL__SQUEEZE__DATASETS__FLAG ) )
    GLOBAL__SQUEEZE__DATASETS__FLAG = true;
end

if( nargin == 1 )
    NewFlag = varargin{1};
    assert( islogical( NewFlag ) && ( numel( NewFlag ) == 1 ), ...
        'SqueezeDatasets:InvalidInputType', ...
        'Input parameter must be true or false' );
    
else % if nargin == 0
    NewFlag = GLOBAL__SQUEEZE__DATASETS__FLAG;

end

if( nargout == 1 || ( nargout == 0 && nargin == 0 ) )
    varargout{1} = NewFlag;
end

end % of SqueezeDatasets