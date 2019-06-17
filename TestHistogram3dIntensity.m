function TestHistogram3dIntensity

meanVector = [2 3];
covarianceMatrix = [1 1.5; 1.5 3];
totalSamples = 20;

totalBinsX = 30;
totalBinsY = 20;

samples2d = mvnrnd( meanVector, covarianceMatrix, totalSamples );

subplot( 1, 3, 1 );
[histogram, xH, yH] = ShowHistogramIntensity( samples2d, [totalBinsX totalBinsY] );
[xmesh, ymesh] = ndgrid( xH, yH );
pdfGaussian = FitGaussianPDF( xH, yH, histogram );
hold on
plot( samples2d(:,1), samples2d(:,2), 'k+' );
xlabel( 'x' );
ylabel( 'y' );
title( 'Dot plot and histogram of the data' );


subplot( 1, 3, 2 );
imagesc( xH, yH, pdfGaussian' );
set( gca, 'Ydir', 'Normal' );
xlabel( 'x' );
ylabel( 'y' );
title( 'Gaussian fit' );

subplot( 1, 3, 3 );
confidenceLevel = 0.95;
ShowConfidenceRegion( xH, yH, histogram, confidenceLevel, 'b' );
hold on
ShowConfidenceRegion( xH, yH, pdfGaussian, confidenceLevel, 'r' );
legend( 'Histogram', 'PDF' );
xlabel( 'x' );
ylabel( 'y' );
title( 'Confidence regions' )

end