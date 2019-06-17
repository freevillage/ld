function titleHandle = TitleFancy( varargin )

[ plotAxis, inputArguments, ~] = axescheck( varargin{:} );
if isempty( plotAxis )
    plotAxis = gca;
end

currentTextFontSize = get(0,'DefaultTextFontSize');
titleFontSize = currentTextFontSize + 4;

titleHandle = title( plotAxis, inputArguments{:}, ...
    'FontName',   'Helvetica', ...
    'FontSize',    titleFontSize, ...
    'FontWeight', 'bold' );

end