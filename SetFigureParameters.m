function SetFigureParameters( FontName, FontSize, LineWidth, AxesLineWidth )

ROOT = 0;

% Default figure parameters
DefaultFontSize  = 20;
DefaultLineWidth = 2;
DefaultAxesLineWidth = 1;
DefaultFontName  = 'Helvetica';

% If inputs are missing then set them to default values
if( nargin < 4 )
    AxesLineWidth = DefaultAxesLineWidth;
    if( nargin < 3 )
        LineWidth = DefaultLineWidth;
        if( nargin < 2 )
            FontSize = DefaultFontSize;
            if( nargin < 1 )
                FontName = DefaultFontName;
            end
        end
    end
end

% Set font
% ... size
set( ROOT, 'defaultaxesfontsize', FontSize );
set( ROOT, 'defaulttextfontsize', FontSize );

% ... name
set( ROOT, 'defaulttextfontname', FontName );
set( ROOT, 'defaultaxesfontname', FontName );

% Set line width to a specified value
set( ROOT, 'defaultaxeslinewidth', AxesLineWidth );
set( ROOT, 'defaultlinelinewidth', LineWidth );

end