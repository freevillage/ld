function PrintFigure( filename, varargin )
% Prints figure using the standard print command in several frequently used
% formats. These formats are predefined in the text of the routine.

formats = struct( 'Name', { 'epsc', 'ps', 'tiff', 'png', 'pdf' }, ...
                  'Extension', { 'eps', 'ps', 'tif', 'png', 'pdf' } );

totalPrints = length( formats );

printDialog = ProgressBar( ...
    'Name', 'Print figures', ...
    'Message', 'Printing figures to files...' );

for iPrint = 1 : totalPrints
    
    currentFormat = formats(iPrint);
    
    printDialog.SetMessage( [ 'Creating ', upper( currentFormat.Name ), ' file' ] );
    
    printingDriver = [ '-d', currentFormat.Name ];
    fullFilename = [ filename, '.', currentFormat.Extension ];
    print( printingDriver, fullFilename, varargin{ : } );
    
    printDialog.SetProgress( iPrint / totalPrints ); 
end

printDialog.Delete;

end % of PrintFigure
