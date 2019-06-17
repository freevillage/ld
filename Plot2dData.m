function plotHandle = Plot2dData( data, varargin )

assert( size( data, 1 ) == 2 )

dataX = squeeze( data(1,:) );
dataY = squeeze( data(2,:) );

plotHandle = plot( dataX, dataY, varargin{:} );

end