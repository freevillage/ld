function mismatch = LeastSquaresPhaseCorrectionTest( recordedData, TemplateFcn, y, f )

normalizedData = NormalizeVector( squeeze( recordedData ) );
normalizedTemplate = NormalizeVector( squeeze( TemplateFcn( y, f ) ) );

L2MatrixNorm = @(mat) norm( ToColumn(mat), 2 );
phaseFit = @(phase) L2MatrixNorm( normalizedData - normalizedTemplate * exp( 1i * phase ) );
phaseInitial = mean( ToColumn( angle( normalizedData./normalizedTemplate ) ) );

[~,mismatch] = fminsearch( phaseFit, phaseInitial );

end