function dataFourier = FourierTransform( varargin )

[ data, dimension, name, units ] = ParseInput( varargin{:} );

[ axisFourier, dataFourierValues ] = CenteredFourierTransform( data.Axes(dimension), ...
    data.Values, ...
    MatrixDimension( data, dimension ), ...
    name, ...
    units );

axesFourier = num2cell( data.Axes );
axesFourier{dimension} = axisFourier;
dataFourier = DatasetNd( axesFourier{:}, dataFourierValues );

end


function [ axisFourier, signalFourier ] = CenteredFourierTransform( axisOriginal, signalOriginal, dimension, name, units )

totalTimes = size( signalOriginal, dimension );
samplingFrequency = axisOriginal.Step;

if IsEven( totalTimes )
    integerTimes  = -totalTimes/2 : totalTimes/2 - 1;
else
    integerTimes  = -(totalTimes-1)/2 : (totalTimes-1)/2;
end

frequencies = integerTimes / totalTimes * samplingFrequency;
axisFourier = GraphAxis( frequencies, name, units );

phaseCorrection = shiftdim( ToColumn( exp( -1i * axisOriginal.Points(1) * 2*pi * frequencies ) ), -dimension+1 );
sizePhaseCorrection = size( signalOriginal );
sizePhaseCorrection(dimension) = 1;
phaseCorrection = repmat( phaseCorrection, sizePhaseCorrection );

signalFourier = fftshift( fft( signalOriginal, [], dimension ), dimension ) / totalTimes ...
    .* phaseCorrection;

end

function [ data, dimension, name, units ] = ParseInput( varargin )

totalInputs = nargin;
assert( totalInputs >= 1 );

data = varargin{1};
dimension = Conditional( totalInputs < 2, 1,  varargin{2} );

if totalInputs < 3, name = '';  else name  = varargin{3}; end
if totalInputs < 4, units = ''; else units = varargin{4}; end

end % of function 
