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


fastTimeEnd = logspace( -8, -3, 6 );
totalFastTimeEnds = length( fastTimeEnd );

seeds = 6193459;
%seeds = randi(10000, [1 1]);
%seeds = randi( 1000, [20 1], 'distributed' );
%seeds = randi( 1000 );
totalSeeds = length( seeds );

sourcePhases = linspace( 0, pi, totalSeeds );

locationsL2 = nan( 3, totalFastTimeEnds, totalSeeds );
locationsCoarseL2 = nan( 3, totalFastTimeEnds, totalSeeds );
dataSNR = nan( totalFastTimeEnds, totalSeeds );

for jFastTimeEnd = 1 : totalFastTimeEnds
    for iSeed = 1 : totalSeeds
        args = { ...
            'SigmaNoise', 1e-103, ...
            'FastTimeSamplingFrequency', 1e9, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'SourcePhase', pi/3, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition, ...
            'FourierTransformLength', 2^24, ...
            'FourierWindowFunction', @hann, ...
            'RandomNumberGenerator', { seeds(iSeed) } ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching3D, args  );
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

angleErrors = abs( rad2deg(atan2(locationsL2(1,:),locationsL2(3,:))-atan2(initialArrayPosition(1),initialArrayPosition(3))));

%%

figure
loglog( ...
    fastTimeEnd, (meanLocationErrors), ...
    '-o', 'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] )

figure( 'Name', 'Angle resolution' )
loglog( fastTimeEnd, angleErrors, ...
    '-o', ...
    'MarkerFaceColor', 'Auto' ...
    )
grid on
xlabel( 'Fast time recording window [s]' )
ylabel( 'Absolute angle estimation error [deg]' )
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1 ] )

% legendVelocity = arrayfun( @num2str, velocity, 'UniformOutput', false );
% velocityLegend = legend( legendVelocity{:}, 'Location', 'EastOutside' );
% title( velocityLegend, 'Array velocity [m/s]' );
