function PrintAllFigures( saveFolder, varargin )

openFigures = findall( 0, 'type', 'figure' );
totalFigures = length( openFigures );

for iFig = 1 : totalFigures
    currentFigure = openFigures(iFig);
    saveFilename = tempname( saveFolder );
    
    figure( currentFigure );
    PrintFigure( saveFilename, varargin{:} );
end

end