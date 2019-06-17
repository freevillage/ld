% DOA problem using a 2D array at a fixed location
%
% Set up a problem with a single source and a stationary array.
totalArrayElements = [5 5];
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
fastTimeEnd = logspace( -8, -4, 9 );
totalFastTimeEnds = length( fastTimeEnd );

sigmaNoise = logspace( -13, -3, 11 );
totalSigmas = length( sigmaNoise );

locationsL2 = nan( 3, totalFastTimeEnds, totalSigmas );
dataSNR = nan( totalFastTimeEnds, totalSigmas );

for iFastTimeEnd = 1 : totalFastTimeEnds
    parfor jSigma = 1 : totalSigmas
        args = { ...
            'SigmaNoise', sigmaNoise(jSigma), ...
            'SourceClockShift', 0, ...
            'FastTimeEnd', fastTimeEnd(iFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,iFastTimeEnd,jSigma) = resultsL2.sourceLocation(:);
        dataSNR(iFastTimeEnd,jSigma) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors =  DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalSigmas] ) );

%%

figure
loglog( fastTimeEnd, fliplr( locationErrors ), ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
ylabel( 'Location error [m]' );
xlabel( 'Fast time recording window [s]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] );

legendSigma = arrayfun( @num2str, fliplr( floor( dataSNR(1,:) ) ), 'UniformOutput', false );
sigmaLegend = legend( legendSigma{:}, 'Location', 'EastOutside' );
title( sigmaLegend, 'SNR [dB]' );

