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


%% Velocity resolution


fastTimeEnd = logspace( -8, -4, 4 );
totalFastTimeEnds = length( fastTimeEnd );

seeds = ToColumn( 1 : 1 );
totalSeeds = length( seeds );

sourcePhases = linspace( 0, pi, totalSeeds );

locationsL2 = nan( 3, totalFastTimeEnds, totalSeeds );
locationsCoarseL2 = nan( 3, totalFastTimeEnds, totalSeeds );
dataSNR = nan( totalFastTimeEnds, totalSeeds );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iSeed = 1 : totalSeeds
        args = { ...
            'SigmaNoise', 1e-5, ...
            'FastTimeSamplingFrequency', 1e9, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'SourcePhase', sourcePhases(iSeed), ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition, ...
            'FourierTransformLength', 2^24, ...
            'FourierWindowFunction', @(n) gausswin(n,4), ...
            'RandomNumberGenerator', { seeds(iSeed) } ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,jFastTimeEnd,iSeed) = resultsL2.sourceLocation(:);
        locationsCoarseL2(:,jFastTimeEnd,iSeed) = resultsL2.sourceLocationCoarse(:);
        dataSNR(jFastTimeEnd,iSeed) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors = DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalSeeds ] ) );

locationCoarseErrors = DistanceL2( ...
    locationsCoarseL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalSeeds ] ) );

meanLocationErrors = mean( locationErrors, 3 );
meanLocationCoarseErrors = mean( locationCoarseErrors, 3 );

%%

figure
loglog( ...
    fastTimeEnd, meanLocationCoarseErrors, ...
    fastTimeEnd, meanLocationErrors, ...
    '-o', 'MarkerFaceColor', 'auto' )
legend( 'Approximate','Refined' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] )

% legendVelocity = arrayfun( @num2str, velocity, 'UniformOutput', false );
% velocityLegend = legend( legendVelocity{:}, 'Location', 'EastOutside' );
% title( velocityLegend, 'Array velocity [m/s]' );
