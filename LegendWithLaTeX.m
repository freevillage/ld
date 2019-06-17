function legendHandle = LegendWithLaTeX( labelsCell )

legendHandle = legend( labelsCell{:} );
set( legendHandle, 'Interpreter', 'latex' );

end