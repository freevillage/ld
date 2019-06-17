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
fastTimeEnd = logspace( -8, -4, 5 );
totalFastTimeEnds = length( fastTimeEnd );

fastTimeSamplingFrequency = 2e9;

sigmaNoiseDoa = logspace( -19, -3, 9 );
sigmaNoise = sigmaNoiseDoa * sqrt( fastTimeSamplingFrequency / (2*sourceFrequency) );
totalSigmas = length( sigmaNoise );

seeds = ToColumn( (1:2)+1234 );
totalSeeds = length( seeds );

sourcePhases = linspace( 0, pi, totalSeeds );

locationsL2 = nan( 3, totalFastTimeEnds, totalSigmas, totalSeeds );
dataSNR = nan( totalFastTimeEnds, totalSigmas, totalSeeds );

parfor iFastTimeEnd = 1 : totalFastTimeEnds
    thisFastTimeEnd = fastTimeEnd(iFastTimeEnd);
    for jSigma = 1 : totalSigmas
        thisSigmaNoise = sigmaNoise(jSigma);
        for kSeed = 1 : totalSeeds
            args = { ...
		'FastTimeSamplingFrequency', fastTimeSamplingFrequency, ...
                'SigmaNoise', thisSigmaNoise, ...
                'SourcePhase', pi/4, ...
                'SourceClockShift', 0, ...
                'FastTimeEnd', thisFastTimeEnd, ...
                'SourcePositionFcn', GetSourcePosition, ...
                'SourceFrequency', sourceFrequency, ...
                'ElementSpacing', elementSpacing, ...
                'TotalElements', totalArrayElements, ...
                'FourierTransformLength', 2^24, ...
                'FourierWindowFunction', @hann, ...
                'ArrayPositionFcn', GetArrayPosition, ...
                'RandomNumberGenerator', { seeds(kSeed) }
                };
            resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
            locationsL2(:,iFastTimeEnd,jSigma,kSeed) = resultsL2.sourceLocation(:);
            dataSNR(iFastTimeEnd,jSigma,kSeed) = resultsL2.dataSNR(1);
        end
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors =  DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalSigmas] ) );

%%

meanLocationErrors = mean( locationErrors, 3 );

figure
loglog( fastTimeEnd, fliplr( meanLocationErrors ), ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
ylabel( 'Location error [m]' );
xlabel( 'Fast time recording window [s]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] );

dataSNRDOA = dataSNR(1,:,1) + 10 * log10( fastTimeSamplingFrequency / sourceFrequency );

legendSigma = arrayfun( @num2str, fliplr( round( dataSNRDOA ) ), 'UniformOutput', false );
sigmaLegend = legend( legendSigma{:}, 'Location', 'EastOutside' );
title( sigmaLegend, 'SNR [dB]' );

