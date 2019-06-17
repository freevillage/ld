function SetPresentationStyle( Style )

% Author: Oleg V. Poliannikov
% Last updated: September 4, 2012


% Input must be a string
if( ~ischar( Style ) )
    error( 'SetPresentationStyle:InputNotString', ...
        'The input parameter must be a string' );
end

% Set the actual atyle depending on the request
switch( lower( Style ) )
    case 'article'
        SetFigureParameters( 'Helvetica', 15, 3, 1 );
    case 'segabstract'
        SetFigureParameters( 'Helvetica', 20, 3, 1 );
    case 'beamer'
        SetFigureParameters( 'Bitstream Vera Sans', 20, 3, 2 );
    otherwise
        error( 'SetPresentationStyle:InvalidInput', ...
            'The style requested is unrecognized' );
end


end % of SetPresentationStyle