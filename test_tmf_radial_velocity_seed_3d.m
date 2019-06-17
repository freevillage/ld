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

aspectAngle = 0;
velocity = 10 .^ (-0:2:4);
velocity = [-fliplr(velocity) , velocity];
%velocity = 10^5;
totalVelocities = length( velocity );

fastTimeEnd = logspace( -8, -4, 9 );
totalFastTimeEnds = length( fastTimeEnd );

seeds = ToColumn( 1:2 );
totalSeeds = length( seeds );

sourcePhases = linspace( 0, pi, totalSeeds );

radialDirection = NormalizeVector( initialArrayPosition - sourcePosition );
flightDirection = RotationMatrix3D( [0, 1, 0], aspectAngle ) * radialDirection;

locationsL2 = nan( 3, totalFastTimeEnds, totalVelocities, totalSeeds );
dataSNR = nan( totalFastTimeEnds, totalVelocities, totalSeeds );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iVelocity = 1 : totalVelocities
        for kSeed = 1 : totalSeeds
        GetArrayPosition = @(t) initialArrayPosition + velocity(iVelocity) * t * flightDirection;
        args = { ...
            'SigmaNoise', 1e-101, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'SourcePhase', sourcePhases(kSeed), ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition, ...
            'RandomNumberGenerator', { seeds(kSeed) } ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching3D, args  );
        locationsL2(:,jFastTimeEnd,iVelocity,kSeed) = resultsL2.sourceLocation(:);
        dataSNR(jFastTimeEnd,iVelocity,kSeed) = resultsL2.dataSNR(1);
        end
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors = DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalVelocities totalSeeds] ) );

%%

meanLocationErrors = mean( locationErrors, 3 );

figure
loglog( fastTimeEnd, meanLocationErrors, ...
    '-o', 'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] )

legendVelocity = arrayfun( @num2str, velocity, 'UniformOutput', false );
velocityLegend = legend( legendVelocity{:}, 'Location', 'EastOutside' );
title( velocityLegend, 'Array velocity [m/s]' );
