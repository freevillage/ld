function [histogramUnbiased, xBins, yBins] = ShowHistogramIntensity( varargin )
% ShowHistogramIntensity plots histogram as an intensity map. The syntax 
% used in this function is identical to <a href="matlab:help hist3">hist3</a>
%
% Example:
%     meanVector = [2 3];
%     covarianceMatrix = [1 1.5; 1.5 3];
%     totalSamples = 1000;
% 
%     totalBinsX = 20;
%     totalBinsY = 20;
% 
%     samples2d = mvnrnd( meanVector, covarianceMatrix, totalSamples );
% 
%     ShowHistogramIntensity( samples2d, [totalBinsX totalBinsY] );
%     hold on
%     plot( samples2d(:,1), samples2d(:,2), 'k+' );
%     xlabel( 'x' );
%     ylabel( 'y' );
% 
%     title( 'Dot plot and histogram of the data' );
%
% See also:
%     HIST, HIST3

%   Copyright 2013 Oleg V. Poliannikov (oleg.poliannikov@gmail.com) 
%   $Revision: 2.0.1.0 $  $Date: 2013/02/18 14:47:00 $

[ axisHandle, histogramInputs ] = axescheck( varargin{:} );
if isempty( axisHandle )
    axisHandle = gca;
end

histogram = hist3( histogramInputs{:} );
[totalHistogramRows, totalHistogramCols] = size( histogram );
histogramUnbiased = histogram;
histogramUnbiased(totalHistogramRows+1, totalHistogramCols+1) = 0;

data = histogramInputs{1};
xData = data(:,1);
yData = data(:,2);

xBins = linspace( min(xData), max(xData), totalHistogramRows+1 );
yBins = linspace( min(yData), max(yData), totalHistogramCols+1 );

axes( axisHandle );
imagesc( xBins, yBins, transpose( histogramUnbiased ) );
set( axisHandle, 'YDir', 'Normal' );

end

