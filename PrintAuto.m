function PrintAuto( filename, varargin )

set(gcf, 'PaperPositionMode', 'auto');
PrintFigure( filename, varargin{:} );

end