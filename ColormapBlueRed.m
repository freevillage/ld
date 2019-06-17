function [] = ColormapBlueRed( varargin )
%
% Use blue and red colormap. COLORMAP_BLUERED(ncol,type) generates a colormap consisting of ncol
% colors (default=1025). Use odd number of colors for value zero to be mapped as white. Type specifies
% whether a linear (default) or parabolic color-scaling is to be used.
%
% Remco Muijs
% 06-03-2002

%nargin=length(varargin);

% Process input and assign number of columns and power to be used
switch( nargin )
    case 0
        TotalColumns = 1025;
        Power = 1;
    case 1
        TotalColumns = varargin{ 1 };
        Power = 1;
    case 2
        TotalColumns = varargin{ 1 };
        Power = varargin{ 2 };
end

Step = 1 / floor( TotalColumns / 2 );

Column1 = transpose( [ ( 0 : Step : 1 - Step ), ones( 1, floor( TotalColumns / 2 ) + 1 ) ] .^ Power );
Column2 = transpose( [ ( 0 : Step : 1 - Step ), 1, ( 1 - Step : -Step : 0 ) ] .^ Power );
Column3 = transpose( [ ones( 1, floor( TotalColumns / 2 ) + 1 ), ( 1 - Step : -Step : 0 ) ] .^ Power );
colormap( [ Column1 Column2 Column3 ] );

%set value zero as center of caxis (for white background)
caxis([-max(abs(caxis)) max(abs(caxis))]);