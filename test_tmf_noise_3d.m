% DOA problem using a 2D array at a fixed location
%
% Set up a problem with a single source and a stationary array.
totalArrayElements = [11 11];
sourceFrequency = 300e6;
sourcePosition = [ 0 ; 0 ; 0 ];
c = physconst('LightSpeed');
wavelength = c / sourceFrequency;
elementSpacing = wavelength/2 * [1 1];
initialArrayPosition = [ -400; 0; 3000 ];
GetArrayPosition = @(t) initialArrayPosition;
GetSourcePosition = @(t) sourcePosition;
GetRotation = @(t) eye(3);
%sigmaNoise = 1e1;

SetDefaultFigureProperties

%% Fasttime window resolution
fastTimeEnd = logspace( -8, -6, 3 );
totalFastTimeEnds = length( fastTimeEnd );

sigmaNoise = 3000/initialArrayPosition(3) * logspace( -20, -11, 10 );
%sigmaNoise = 1e-100;
totalSigmas = length( sigmaNoise );

locationsL2 = nan( 3, totalFastTimeEnds, totalSigmas );
locationsCoarseL2 = nan( 3, totalFastTimeEnds, totalSigmas );
dataSNR = nan( totalFastTimeEnds, totalSigmas );

for iFastTimeEnd = 1 : totalFastTimeEnds
    for jSigma = 1 : totalSigmas
        args = { ...
            'SigmaNoise', sigmaNoise(jSigma), ...
            'SourceClockShift', 0, ...
            'FastTimeSamplingFrequency', 1e9, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(iFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceAmplitude', 1, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition, ...
            'FourierTransformLength', 2^22, ...
            'FourierWindowFunction', @GaussianTaper, ... % (n) gausswin(n,4), ...
            'RandomNumberGenerator', { 12345 }...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching3D, args  );
        locationsL2(:,iFastTimeEnd,jSigma) = resultsL2.sourceLocation(:);
	locationsCoarseL2(:,iFastTimeEnd,jSigma) = resultsL2.sourceLocationCoarse(:);
        dataSNR(iFastTimeEnd,jSigma) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors =  DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalSigmas] ) );

locationErrorsCoarse = DistanceL2( ...
	locationsCoarseL2, ...
	repmat( sourcePosition, [1 totalFastTimeEnds totalSigmas] ) );
%%

figure( 'Name', 'Location results' )
subplot( 2, 1, 2 )
loglog( fastTimeEnd, fliplr( locationErrors ), ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
ylabel( 'Location error [m]' );
xlabel( 'Fast time recording window [s]' );
xlim( minmax( fastTimeEnd ) )
%pbaspect( [4 3 1] );

legendSigma = arrayfun( @num2str, fliplr( floor( dataSNR(1,:) ) ), 'UniformOutput', false );
sigmaLegend = legend( legendSigma{:}, 'Location', 'EastOutside' );
title( sigmaLegend, 'SNR [dB]' );
title( 'Post-TM refinement' )


subplot( 2, 1, 1 )
loglog( fastTimeEnd, fliplr( locationErrorsCoarse ), ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
ylabel( 'Location error [m]' );
xlabel( 'Fast time recording window [s]' );
xlim( minmax( fastTimeEnd ) )
%pbaspect( [4 3 1] );

legendSigma = arrayfun( @num2str, fliplr( floor( dataSNR(1,:) ) ), 'UniformOutput', false );
sigmaLegend = legend( legendSigma{:}, 'Location', 'EastOutside' );
title( sigmaLegend, 'SNR [dB]' );
title( 'Template matching' )
suptitle( sprintf( 'Range: %.0f m', initialArrayPosition(3) ) )

