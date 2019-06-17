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


%% Total array elements resolution

% ranges = [30 300 3000 30000 30000 300000];
ranges = 3 * 10.^(1:7);
totalRanges = length( ranges );

fastTimeEnd = logspace( -8, -4, 5 );
totalFastTimeEnds = length( fastTimeEnd );

seeds = ToColumn( 1:2 );
totalSeeds = length( seeds );

sourcePhases = linspace( 0, pi, totalSeeds );

locationsL2 = nan( 3, totalFastTimeEnds, totalRanges, totalSeeds );
dataSNR = nan( totalFastTimeEnds, totalRanges, totalSeeds );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iRange = 1 : totalRanges
        for kSeed = 1 : totalSeeds
            GetArrayPosition = @(t) ranges(iRange) * NormalizeVector(initialArrayPosition);
            args = { ...
                'SigmaNoise', 1e-100, ...
                'SlowTimeEnd', 0, ...
                'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
                'SourcePositionFcn', GetSourcePosition, ...
                'SourcePhase', pi/3, ...
                'SourceFrequency', sourceFrequency, ...
                'ElementSpacing', elementSpacing, ...
                'ArrayPositionFcn', GetArrayPosition ...
                'FourierTransformLength', 2^24, ...
                'FourierWindowFunction', @blackman, ...
                'RandomNumberGenerator', { seeds(kSeed) } ...
                };
            resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
            locationsL2(:,jFastTimeEnd,iRange,kSeed) = resultsL2.sourceLocation(:);
            dataSNR(jFastTimeEnd,iRange,kSeed) = resultsL2.dataSNR(1);
        end
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors =  DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalRanges totalSeeds] ) );

%%

meanLocationErrors = mean( locationErrors, 3 );

figure
loglog( fastTimeEnd, meanLocationErrors, ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] )
axis tight

legendSize = arrayfun( @(d) sprintf( '3x10^{%d}', d ), log10(ranges/3), 'UniformOutput', false );
sizeLegend = legend( legendSize{:}, 'Location', 'EastOutside' );
title( sizeLegend, 'Range [m]' );



