function plotHandle = Plot3dData( data, varargin )

assert( size( data, 1 ) == 3 )

dataX = squeeze( data(1,:) );
dataY = squeeze( data(2,:) );
dataZ = squeeze( data(3,:) );

plotHandle = plot3( dataX, dataY, dataZ, varargin{:} );

end