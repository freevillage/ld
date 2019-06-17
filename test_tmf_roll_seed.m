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


%% Effect of roll
rollRate = logspace( -2, 3, 6 );
totalRollRates = length( rollRate );

fastTimeEnd = logspace( -8, -3, 11 );
totalFastTimeEnds = length( fastTimeEnd );

seeds = ToColumn( 1 : 2 );
totalSeeds = length( seeds );

sourcePhases = linspace( 0, pi, totalSeeds );

GetArrayPosition = @(t) initialArrayPosition;

locationsL2 = nan( 3, totalFastTimeEnds, totalRollRates, totalSeeds );
dataSNR = nan( totalFastTimeEnds, totalRollRates, totalSeeds );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iRoll = 1 : totalRollRates
        for kSeed = 1 : totalSeeds
            args = { ...
                'SigmaNoise', 1e-101, ...
                'SourcePhase', sourcePhases(kSeed), ...
                'SlowTimeEnd', 0, ...
                'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
                'SourcePositionFcn', GetSourcePosition, ...
                'SourceFrequency', sourceFrequency, ...
		'SourcePhase', pi/7, ...
                'ElementSpacing', elementSpacing, ...
                'ArrayPositionFcn', GetArrayPosition, ...
                'RotationFcn', @(t) RotationMatrix( 2*pi*rollRate(iRoll) * t, 0, 0 ), ...
                'RandomNumberGenerator', { seeds(kSeed) } ...
                };
            resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
            locationsL2(:,jFastTimeEnd,iRoll,kSeed) = resultsL2.sourceLocation(:);
            dataSNR(jFastTimeEnd,iRoll,kSeed) = resultsL2.dataSNR(1);
        end
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors =  DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalRollRates totalSeeds] ) );
%%
meanLocationErrors = mean( locationErrors, 3 );

figure
loglog( fastTimeEnd, meanLocationErrors', ...
    '-o', 'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] )

legendRoll = arrayfun( @num2str, rollRate, 'UniformOutput', false );
rollLegend = legend( legendRoll{:}, 'Location', 'EastOutside' );
title( rollLegend, 'Roll rate [Hz]' );

