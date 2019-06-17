function varargout = FigureStyle( varargin )
%FigureStyle changes the appearance of created figures by adjusting fonts
%  and line thickness
%
%  FigureStyle newFigureStyle sets the desired style of all figures.
%  newFigureStyle must be a string from the list of acceptable figure
%  styles:
%       ARTICLE
%       ONECOLUMN, same as ARTICLE
%       SEGABSTRACT
%       TWOCOLUMN, same as SEGABSTRACT
%       BEAMER
%       DEFAULT
%
%  Example
%       FigureStyle BEAMER
%       plot( -10:0.1:10, ( -10:0.1:10 ).^ 2 );
%       xlabel( 'x' ), ylabel( 'y' ), title( 'Parabola' )

%   Copyright 2011 Oleg V. Poliannikov
%   $Revision: 1.0 $  $Date: 2011/08/08 14:43 $
%   %Revision: 1.1 $  $Date: 2011/08/29 14:20 $ Added a stricter input
%   check

% The function only allows one input or one output or both
assert( nargout <= 1, ...
    'FigureStyle:TooManyOutputs', ...
    'The number of output values cannot be greater than one.' );
assert( nargin  <= 1, ...
    'FigureStyle:TooManyInputs', ...
    'The number of input parameters cannot be greater than one.' );

global GLOBAL__FIGURE__STYLE;
if( isempty( GLOBAL__FIGURE__STYLE ) )
    GLOBAL__FIGURE__STYLE = 'DEFAULT';
end

if( nargin == 1 )
    
    % The input argument can only be a string, which indicates the desired
    % figure style. 
    newFigureStyle = varargin{1};
    assert( ischar( newFigureStyle ), 'FigureStyle:InputNotString', 'The input must be a string!' );
    
    % The new style must be from the list of allowed styles. Any other
    % input generates an error.
    permittedFigureStyles = { 'ARTICLE', ...
        'ONECOLUMN', ...
        'SEGABSTRACT', ...
        'TWOCOLUMN', ...
        'BEAMER', ...
        'DEFAULT' };
    assert( ismember( newFigureStyle, permittedFigureStyles ), 'FigureStyle:InvalidInput', 'The figure style is not recognized' ); 
   
    
    GLOBAL__FIGURE__STYLE = upper( newFigureStyle );

    switch newFigureStyle 

        case { 'ARTICLE', 'ONECOLUMN' }
            SetFigureParameters( 'Helvetica', 12, 1 );
        case { 'SEGABSTRACT', 'TWOCOLUMN' }
            SetFigureParameters( 'Helvetica', 20, 1 );
        case 'BEAMER'
            SetFigureParameters( 'Helvetica', 20, 2 );
        case 'DEFAULT'
            SetFigureParameters( 'Helvetica', 10, 1 );
        otherwise
            error( 'FigureStyle:InvalidInput', 'The figure style is not recognized' );

    end

else % if nargin == 0
    newFigureStyle = GLOBAL__FIGURE__STYLE;
end

% the function returns a value or an output variable is supplied of if the
% function is called with no parameters at all. In the latter case, the
% type will be shown in the console.
if( nargout == 1 || ( nargout == 0 && nargin == 0 ) )
    varargout{1} = newFigureStyle;
end

end