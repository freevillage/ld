function SaveAllFigures( saveFormat, fileNameBeginning )
%SAVEALLFIGURES Save all open figures
%   This function saves or prints to file all open figures

if nargin < 2
    fileNameBeginning = 'Figure';
    if nargin < 1
        saveFormat = 'pdf';
    end
end

figureHandles = get( 0, 'Children' );
totalFigures = length( figureHandles );

for iFigure = 1 : totalFigures
    fullFileName = [ fileNameBeginning, num2str( iFigure ) ];
    saveas( figureHandles(iFigure), fullFileName, saveFormat );
end


end

