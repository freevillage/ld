function SetDefaultFontSize( FontSize, LineWidth )

DefaultFontSize  = 20;
DefaultLineWidth = 2;

% If inputs are missing then set them to default values
if( nargin < 2 )
    LineWidth = DefaultLineWidth;
    if( nargin < 1 )
        FontSize = DefaultFontSize;
    end
end

% Set font size to a specified value
set( 0, 'defaultaxesfontsize', FontSize );
set( 0, 'defaulttextfontsize', FontSize );

% Set line width to a specified value
set( 0, 'defaultaxeslinewidth', LineWidth );
set( 0, 'defaultlinelinewidth', LineWidth );

end