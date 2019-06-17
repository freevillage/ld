function datasetDelayed = Delay1d( dataset, delay )

assert( ndims( dataset ) == 1 );

datasetInterpolant = Interpolant( dataset );
datasetDelayed = dataset;

datasetDelayed(:) = datasetInterpolant( dataset.Axes.Points - delay );

end


